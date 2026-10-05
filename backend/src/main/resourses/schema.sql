CREATE TABLE IF NOT EXISTS cities (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    state VARCHAR(2) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS stores (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    cnpj VARCHAR(255) UNIQUE,
    phone VARCHAR(255),
    whatsapp VARCHAR(255),
    address VARCHAR(255),
    description VARCHAR(3000),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    type VARCHAR(50) NOT NULL DEFAULT 'DEALER',
    city_id BIGINT,
    CONSTRAINT fk_store_city
        FOREIGN KEY (city_id)
        REFERENCES cities(id)
);

CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(255),
    role VARCHAR(50) NOT NULL,
    store_id BIGINT,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_user_store
        FOREIGN KEY (store_id)
        REFERENCES stores(id)
);

CREATE TABLE IF NOT EXISTS vehicles (
    id BIGSERIAL PRIMARY KEY,
    brand VARCHAR(255) NOT NULL,
    model VARCHAR(255) NOT NULL,
    version VARCHAR(255),
    year_manufacture INTEGER,
    year_model INTEGER,
    price NUMERIC(15,2) NOT NULL,
    mileage INTEGER,
    transmission VARCHAR(255),
    fuel VARCHAR(255),
    color VARCHAR(255),
    image_url VARCHAR(1000),
    description VARCHAR(3000),
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    store_id BIGINT NOT NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    CONSTRAINT fk_vehicle_store
        FOREIGN KEY (store_id)
        REFERENCES stores(id)
);

CREATE TABLE IF NOT EXISTS rental_vehicles (
    id BIGSERIAL PRIMARY KEY,
    brand VARCHAR(255) NOT NULL,
    model VARCHAR(255) NOT NULL,
    version VARCHAR(255),
    year_model INTEGER,
    category VARCHAR(255),
    transmission VARCHAR(255),
    fuel VARCHAR(255),
    color VARCHAR(255),
    seats INTEGER,
    daily_rate NUMERIC(15,2) NOT NULL,
    weekly_rate NUMERIC(15,2),
    monthly_rate NUMERIC(15,2),
    deposit_amount NUMERIC(15,2),
    unlimited_mileage BOOLEAN NOT NULL DEFAULT TRUE,
    mileage_limit_per_day INTEGER,
    minimum_age INTEGER DEFAULT 21,
    image_url VARCHAR(1000),
    rental_rules VARCHAR(3000),
    status VARCHAR(50) NOT NULL DEFAULT 'AVAILABLE',
    store_id BIGINT NOT NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    CONSTRAINT fk_rental_vehicle_store
        FOREIGN KEY (store_id)
        REFERENCES stores(id)
);

CREATE TABLE IF NOT EXISTS leads (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    type VARCHAR(50),
    status VARCHAR(50),
    vehicle_id BIGINT,
    store_id BIGINT,
    city_id BIGINT,
    notes VARCHAR(3000),
    created_at TIMESTAMP,
    CONSTRAINT fk_lead_vehicle
        FOREIGN KEY (vehicle_id)
        REFERENCES vehicles(id),
    CONSTRAINT fk_lead_store
        FOREIGN KEY (store_id)
        REFERENCES stores(id),
    CONSTRAINT fk_lead_city
        FOREIGN KEY (city_id)
        REFERENCES cities(id)
);

CREATE TABLE IF NOT EXISTS rental_requests (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(255),
    email VARCHAR(255),
    rental_vehicle_id BIGINT NOT NULL,
    store_id BIGINT NOT NULL,
    city_id BIGINT NOT NULL,
    pickup_date DATE,
    return_date DATE,
    days INTEGER,
    estimated_total NUMERIC(15,2),
    status VARCHAR(50) NOT NULL DEFAULT 'NEW',
    notes VARCHAR(2500),
    created_at TIMESTAMP,
    CONSTRAINT fk_rental_request_vehicle
        FOREIGN KEY (rental_vehicle_id)
        REFERENCES rental_vehicles(id),
    CONSTRAINT fk_rental_request_store
        FOREIGN KEY (store_id)
        REFERENCES stores(id),
    CONSTRAINT fk_rental_request_city
        FOREIGN KEY (city_id)
        REFERENCES cities(id)
);
