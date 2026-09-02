-- Analyse 1: Gesamtübersicht

SELECT
    COUNT(*) AS rentals,
    SUM(amount) AS total_revenue,
    AVG(amount) AS avg_revenue_per_rental,
    AVG(rental_duration) AS avg_rental_duration
FROM fact_rental;


-- Analyse 2: Umsatz nach Jahr und Monat

SELECT
    d.year,
    d.month,
    d.month_name,
    SUM(f.rental_count) AS rentals,
    SUM(f.amount) AS revenue
FROM fact_rental f
JOIN dim_date d
    ON f.date_key = d.date_key
GROUP BY
    d.year,
    d.month,
    d.month_name
ORDER BY
    d.year,
    d.month;


-- Analyse 3: Umsatz nach Jahr

SELECT
    d.year,
    SUM(f.rental_count) AS rentals,
    SUM(f.amount) AS revenue
FROM fact_rental f
JOIN dim_date d
    ON f.date_key = d.date_key
GROUP BY d.year
ORDER BY d.year;


-- Analyse 4: Drill-down nach Datum

SELECT
    d.year,
    d.month,
    d.full_date,
    SUM(f.rental_count) AS rentals,
    SUM(f.amount) AS revenue
FROM fact_rental f
JOIN dim_date d
    ON f.date_key = d.date_key
GROUP BY
    d.year,
    d.month,
    d.full_date
ORDER BY
    d.full_date;


-- Analyse 5: Umsatz und Vermietungen nach Filmkategorie

SELECT
    df.category,
    SUM(fr.rental_count) AS rentals,
    SUM(fr.amount) AS revenue
FROM fact_rental fr
JOIN dim_film df
    ON fr.film_key = df.film_key
GROUP BY df.category
ORDER BY revenue DESC;


-- Analyse 6: Durchschnittlicher Umsatz pro Vermietung je Kategorie

SELECT
    df.category,
    COUNT(*) AS rentals,
    SUM(fr.amount) AS revenue,
    AVG(fr.amount) AS avg_revenue_per_rental
FROM fact_rental fr
JOIN dim_film df
    ON fr.film_key = df.film_key
GROUP BY df.category
ORDER BY avg_revenue_per_rental DESC;



-- Analyse 7: Umsatz nach Filiale

SELECT
    ds.store_id,
    ds.city,
    ds.country,
    SUM(fr.rental_count) AS rentals,
    SUM(fr.amount) AS revenue
FROM fact_rental fr
JOIN dim_store ds
    ON fr.store_key = ds.store_key
GROUP BY
    ds.store_id,
    ds.city,
    ds.country
ORDER BY revenue DESC;



-- Analyse 8: Umsatz nach Filiale und Jahr

SELECT
    d.year,
    ds.store_id,
    ds.city,
    SUM(fr.rental_count) AS rentals,
    SUM(fr.amount) AS revenue
FROM fact_rental fr
JOIN dim_date d
    ON fr.date_key = d.date_key
JOIN dim_store ds
    ON fr.store_key = ds.store_key
GROUP BY
    d.year,
    ds.store_id,
    ds.city
ORDER BY
    d.year,
    ds.store_id;




-- Analyse 9: Top 10 Kunden nach Umsatz

SELECT
    dc.customer_id,
    dc.first_name,
    dc.last_name,
    dc.city,
    dc.country,
    COUNT(*) AS rentals,
    SUM(fr.amount) AS revenue
FROM fact_rental fr
JOIN dim_customer dc
    ON fr.customer_key = dc.customer_key
GROUP BY
    dc.customer_id,
    dc.first_name,
    dc.last_name,
    dc.city,
    dc.country
ORDER BY revenue DESC
LIMIT 10;




-- Analyse 10: Top 10 Filme nach Vermietungen

SELECT
    df.film_id,
    df.title,
    df.category,
    COUNT(*) AS rentals,
    SUM(fr.amount) AS revenue
FROM fact_rental fr
JOIN dim_film df
    ON fr.film_key = df.film_key
GROUP BY
    df.film_id,
    df.title,
    df.category
ORDER BY rentals DESC, revenue DESC
LIMIT 10;




-- Analyse 11: Top 10 Filme nach Umsatz

SELECT
    df.film_id,
    df.title,
    df.category,
    COUNT(*) AS rentals,
    SUM(fr.amount) AS revenue
FROM fact_rental fr
JOIN dim_film df
    ON fr.film_key = df.film_key
GROUP BY
    df.film_id,
    df.title,
    df.category
ORDER BY revenue DESC
LIMIT 10;



-- Analyse 12: Durchschnittliche Vermietungsdauer nach Kategorie

SELECT
    df.category,
    COUNT(*) AS rentals,
    ROUND(AVG(fr.rental_duration), 2) AS avg_rental_duration
FROM fact_rental fr
JOIN dim_film df
    ON fr.film_key = df.film_key
WHERE fr.rental_duration IS NOT NULL
GROUP BY df.category
ORDER BY avg_rental_duration DESC;



-- Analyse 13: Umsatz nach Kundenland

SELECT
    dc.country,
    COUNT(*) AS rentals,
    SUM(fr.amount) AS revenue
FROM fact_rental fr
JOIN dim_customer dc
    ON fr.customer_key = dc.customer_key
GROUP BY dc.country
ORDER BY revenue DESC;


-- Analyse 14: Top 10 Länder nach Umsatz

SELECT
    dc.country,
    SUM(fr.rental_count) AS rentals,
    SUM(fr.amount) AS revenue
FROM fact_rental fr
JOIN dim_customer dc
    ON fr.customer_key = dc.customer_key
GROUP BY dc.country
ORDER BY revenue DESC
LIMIT 10;



-- Analyse 15: Monatliche Entwicklung nach Filmkategorie

SELECT
    d.year,
    d.month,
    df.category,
    SUM(fr.rental_count) AS rentals,
    SUM(fr.amount) AS revenue
FROM fact_rental fr
JOIN dim_date d
    ON fr.date_key = d.date_key
JOIN dim_film df
    ON fr.film_key = df.film_key
GROUP BY
    d.year,
    d.month,
    df.category
ORDER BY
    d.year,
    d.month,
    df.category;



-- Analyse 16: Umsatz mit ROLLUP

SELECT
    d.year,
    d.month,
    SUM(fr.amount) AS revenue
FROM fact_rental fr
JOIN dim_date d
    ON fr.date_key = d.date_key
GROUP BY ROLLUP (
    d.year,
    d.month
)
ORDER BY
    d.year NULLS LAST,
    d.month NULLS LAST;



-- Analyse 17: Umsatz mit CUBE nach Jahr und Filiale

SELECT
    d.year,
    ds.store_id,
    SUM(fr.amount) AS revenue
FROM fact_rental fr
JOIN dim_date d
    ON fr.date_key = d.date_key
JOIN dim_store ds
    ON fr.store_key = ds.store_key
GROUP BY CUBE (
    d.year,
    ds.store_id
)
ORDER BY
    d.year NULLS LAST,
    ds.store_id NULLS LAST;