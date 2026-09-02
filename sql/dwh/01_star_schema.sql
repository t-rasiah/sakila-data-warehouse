CREATE TABLE dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    day INTEGER NOT NULL,
    month INTEGER NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    quarter INTEGER NOT NULL,
    year INTEGER NOT NULL,
    day_of_week VARCHAR(20) NOT NULL
);

CREATE TABLE dim_customer (
    customer_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INTEGER NOT NULL UNIQUE,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    city VARCHAR(50),
    country VARCHAR(50),
    active BOOLEAN
);

CREATE TABLE dim_film (
    film_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    film_id INTEGER NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    category VARCHAR(50),
    rating VARCHAR(10),
    rental_rate NUMERIC(4,2),
    length INTEGER
);

CREATE TABLE dim_store (
    store_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    store_id INTEGER NOT NULL UNIQUE,
    city VARCHAR(50),
    country VARCHAR(50)
);

CREATE TABLE fact_rental (
    rental_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    rental_id INTEGER NOT NULL,

    date_key INTEGER NOT NULL,
    customer_key INTEGER NOT NULL,
    film_key INTEGER NOT NULL,
    store_key INTEGER NOT NULL,

    rental_count INTEGER NOT NULL DEFAULT 1,
    amount NUMERIC(10,2),
    rental_duration INTEGER,

    CONSTRAINT fk_fact_rental_date
        FOREIGN KEY (date_key)
        REFERENCES dim_date(date_key),

    CONSTRAINT fk_fact_rental_customer
        FOREIGN KEY (customer_key)
        REFERENCES dim_customer(customer_key),

    CONSTRAINT fk_fact_rental_film
        FOREIGN KEY (film_key)
        REFERENCES dim_film(film_key),

    CONSTRAINT fk_fact_rental_store
        FOREIGN KEY (store_key)
        REFERENCES dim_store(store_key)
);

