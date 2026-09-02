import psycopg2
from datetime import date


OLTP_CONFIG = {
    "host": "192.168.56.11",
    "database": "sakila_oltp",
    "user": "sakila_app",
    "password": "sakila_app_pw"
}

DWH_CONFIG = {
    "host": "192.168.56.12",
    "database": "sakila_dwh",
    "user": "dwh_app",
    "password": "dwh_app_pw"
}


def get_oltp_connection():
    return psycopg2.connect(**OLTP_CONFIG)


def get_dwh_connection():
    return psycopg2.connect(**DWH_CONFIG)


def test_connections():
    oltp_conn = get_oltp_connection()
    dwh_conn = get_dwh_connection()

    with oltp_conn.cursor() as cur:
        cur.execute("SELECT COUNT(*) FROM rental;")
        rental_count = cur.fetchone()[0]

    with dwh_conn.cursor() as cur:
        cur.execute("SELECT COUNT(*) FROM fact_rental;")
        fact_count = cur.fetchone()[0]

    print(f"OLTP rental: {rental_count}")
    print(f"DWH fact_rental: {fact_count}")

    oltp_conn.close()
    dwh_conn.close()


def load_dim_date():
    oltp_conn = get_oltp_connection()
    dwh_conn = get_dwh_connection()

    with oltp_conn.cursor() as source_cur:
        source_cur.execute("""
            SELECT DISTINCT rental_date::date
            FROM rental
            ORDER BY rental_date::date;
        """)

        dates = source_cur.fetchall()

    with dwh_conn.cursor() as target_cur:
        for row in dates:
            full_date = row[0]

            date_key = int(full_date.strftime("%Y%m%d"))

            target_cur.execute("""
                INSERT INTO dim_date (
                    date_key,
                    full_date,
                    day,
                    month,
                    month_name,
                    quarter,
                    year,
                    day_of_week
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (date_key) DO NOTHING;
            """, (
                date_key,
                full_date,
                full_date.day,
                full_date.month,
                full_date.strftime("%B"),
                ((full_date.month - 1) // 3) + 1,
                full_date.year,
                full_date.strftime("%A")
            ))

    dwh_conn.commit()

    oltp_conn.close()
    dwh_conn.close()

    print(f"dim_date geladen: {len(dates)} Datumswerte")

def load_dim_customer():
    oltp_conn = get_oltp_connection()
    dwh_conn = get_dwh_connection()

    with oltp_conn.cursor() as source_cur:
        source_cur.execute("""
            SELECT
                c.customer_id,
                c.first_name,
                c.last_name,
                ci.city,
                co.country,
                (c.active = 1) AS active
            FROM customer c
            JOIN address a
                ON c.address_id = a.address_id
            JOIN city ci
                ON a.city_id = ci.city_id
            JOIN country co
                ON ci.country_id = co.country_id
            ORDER BY c.customer_id;
        """)

        customers = source_cur.fetchall()

    with dwh_conn.cursor() as target_cur:
        for row in customers:
            target_cur.execute("""
                INSERT INTO dim_customer (
                    customer_id,
                    first_name,
                    last_name,
                    city,
                    country,
                    active
                )
                VALUES (%s, %s, %s, %s, %s, %s)
                ON CONFLICT (customer_id) DO UPDATE SET
                    first_name = EXCLUDED.first_name,
                    last_name = EXCLUDED.last_name,
                    city = EXCLUDED.city,
                    country = EXCLUDED.country,
                    active = EXCLUDED.active;
            """, row)

    dwh_conn.commit()

    oltp_conn.close()
    dwh_conn.close()

    print(f"dim_customer geladen: {len(customers)} Kunden")


def load_dim_film():
    oltp_conn = get_oltp_connection()
    dwh_conn = get_dwh_connection()

    with oltp_conn.cursor() as source_cur:
        source_cur.execute("""
            SELECT
                f.film_id,
                f.title,
                c.name AS category,
                f.rating::text,
                f.rental_rate,
                f.length
            FROM film f
            LEFT JOIN film_category fc
                ON f.film_id = fc.film_id
            LEFT JOIN category c
                ON fc.category_id = c.category_id
            ORDER BY f.film_id;
        """)

        films = source_cur.fetchall()

    with dwh_conn.cursor() as target_cur:
        for row in films:
            target_cur.execute("""
                INSERT INTO dim_film (
                    film_id,
                    title,
                    category,
                    rating,
                    rental_rate,
                    length
                )
                VALUES (%s, %s, %s, %s, %s, %s)
                ON CONFLICT (film_id) DO UPDATE SET
                    title = EXCLUDED.title,
                    category = EXCLUDED.category,
                    rating = EXCLUDED.rating,
                    rental_rate = EXCLUDED.rental_rate,
                    length = EXCLUDED.length;
            """, row)

    dwh_conn.commit()

    oltp_conn.close()
    dwh_conn.close()

    print(f"dim_film geladen: {len(films)} Filme")


def load_dim_store():
    oltp_conn = get_oltp_connection()
    dwh_conn = get_dwh_connection()

    with oltp_conn.cursor() as source_cur:
        source_cur.execute("""
            SELECT
                s.store_id,
                ci.city,
                co.country
            FROM store s
            JOIN address a
                ON s.address_id = a.address_id
            JOIN city ci
                ON a.city_id = ci.city_id
            JOIN country co
                ON ci.country_id = co.country_id
            ORDER BY s.store_id;
        """)

        stores = source_cur.fetchall()

    with dwh_conn.cursor() as target_cur:
        for row in stores:
            target_cur.execute("""
                INSERT INTO dim_store (
                    store_id,
                    city,
                    country
                )
                VALUES (%s, %s, %s)
                ON CONFLICT (store_id) DO UPDATE SET
                    city = EXCLUDED.city,
                    country = EXCLUDED.country;
            """, row)

    dwh_conn.commit()

    oltp_conn.close()
    dwh_conn.close()

    print(f"dim_store geladen: {len(stores)} Filialen")


def load_fact_rental():
    oltp_conn = get_oltp_connection()
    dwh_conn = get_dwh_connection()

    with oltp_conn.cursor() as source_cur:
        source_cur.execute("""
            SELECT
                r.rental_id,
                r.rental_date::date,
                r.customer_id,
                i.film_id,
                i.store_id,
                COALESCE(SUM(p.amount), 0) AS amount,
                CASE
                    WHEN r.return_date IS NOT NULL
                    THEN EXTRACT(
                        DAY FROM (r.return_date - r.rental_date)
                    )::integer
                    ELSE NULL
                END AS rental_duration
            FROM rental r
            JOIN inventory i
                ON r.inventory_id = i.inventory_id
            LEFT JOIN payment p
                ON r.rental_id = p.rental_id
            GROUP BY
                r.rental_id,
                r.rental_date,
                r.customer_id,
                i.film_id,
                i.store_id,
                r.return_date
            ORDER BY r.rental_id;
        """)

        rentals = source_cur.fetchall()

    with dwh_conn.cursor() as target_cur:
        for rental in rentals:
            (
                rental_id,
                rental_date,
                customer_id,
                film_id,
                store_id,
                amount,
                rental_duration
            ) = rental

            date_key = int(rental_date.strftime("%Y%m%d"))

            target_cur.execute("""
                SELECT customer_key
                FROM dim_customer
                WHERE customer_id = %s;
            """, (customer_id,))

            customer_key = target_cur.fetchone()[0]

            target_cur.execute("""
                SELECT film_key
                FROM dim_film
                WHERE film_id = %s;
            """, (film_id,))

            film_key = target_cur.fetchone()[0]

            target_cur.execute("""
                SELECT store_key
                FROM dim_store
                WHERE store_id = %s;
            """, (store_id,))

            store_key = target_cur.fetchone()[0]

            target_cur.execute("""
                INSERT INTO fact_rental (
                    rental_id,
                    date_key,
                    customer_key,
                    film_key,
                    store_key,
                    rental_count,
                    amount,
                    rental_duration
                )
                VALUES (%s, %s, %s, %s, %s, 1, %s, %s)
                ON CONFLICT (rental_id) DO UPDATE SET
                    date_key = EXCLUDED.date_key,
                    customer_key = EXCLUDED.customer_key,
                    film_key = EXCLUDED.film_key,
                    store_key = EXCLUDED.store_key,
                    amount = EXCLUDED.amount,
                    rental_duration = EXCLUDED.rental_duration;
            """, (
                rental_id,
                date_key,
                customer_key,
                film_key,
                store_key,
                amount,
                rental_duration
    ))

    dwh_conn.commit()

    oltp_conn.close()
    dwh_conn.close()

    print(f"fact_rental geladen: {len(rentals)} Vermietungen")

if __name__ == "__main__":
    print("=== ETL gestartet ===")

    test_connections()

    load_dim_date()
    load_dim_customer()
    load_dim_film()
    load_dim_store()
    load_fact_rental()

    print("=== ETL abgeschlossen ===")