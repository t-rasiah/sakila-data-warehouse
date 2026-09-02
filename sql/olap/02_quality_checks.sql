-- Anzahl Fakten

SELECT COUNT(*) AS fact_rows
FROM fact_rental;


-- Eindeutige Vermietungen

SELECT COUNT(DISTINCT rental_id) AS unique_rentals
FROM fact_rental;


-- Summe rental_count

SELECT SUM(rental_count) AS rental_count
FROM fact_rental;


-- Gesamtumsatz

SELECT SUM(amount) AS total_revenue
FROM fact_rental;


-- Fehlende Dimensionen prüfen

SELECT COUNT(*) AS invalid_customer_keys
FROM fact_rental f
LEFT JOIN dim_customer d
    ON f.customer_key = d.customer_key
WHERE d.customer_key IS NULL;


SELECT COUNT(*) AS invalid_film_keys
FROM fact_rental f
LEFT JOIN dim_film d
    ON f.film_key = d.film_key
WHERE d.film_key IS NULL;


SELECT COUNT(*) AS invalid_store_keys
FROM fact_rental f
LEFT JOIN dim_store d
    ON f.store_key = d.store_key
WHERE d.store_key IS NULL;


SELECT COUNT(*) AS invalid_date_keys
FROM fact_rental f
LEFT JOIN dim_date d
    ON f.date_key = d.date_key
WHERE d.date_key IS NULL;