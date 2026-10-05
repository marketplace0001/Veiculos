-- ============================================================
-- AUTOMARKETPLACE
-- Estrutura inicial do PostgreSQL
-- ============================================================

-- ============================================================
-- 1. CIDADES
-- ============================================================

CREATE TABLE IF NOT EXISTS cities (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    state VARCHAR(2) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE
);


-- ============================================================
-- 2. LOJAS / LOCADORAS
-- ============================================================

CREATE TABLE IF NOT EXISTS stores (
    id BIGSERIAL PRIMARY KEY,

    name VARCHAR(255) NOT NULL,
    cnpj VARCHAR(255) UNIQUE,

    phone VARCHAR(255),
    whatsapp VARCHAR(255),
    address VARCHAR(500),
    description VARCHAR(3000),

    active BOOLEAN NOT NULL DEFAULT TRUE,

    type VARCHAR(50) NOT NULL DEFAULT 'DEALER',

    city_id BIGINT NOT NULL,

    CONSTRAINT fk_stores_city
        FOREIGN KEY (city_id)
        REFERENCES cities(id)
);


-- ============================================================
-- 3. USUÁRIOS
-- ============================================================

CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,

    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(500) NOT NULL,
    phone VARCHAR(255),

    role VARCHAR(50) NOT NULL DEFAULT 'CUSTOMER',

    store_id BIGINT,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_users_store
        FOREIGN KEY (store_id)
        REFERENCES stores(id)
);


-- ============================================================
-- 4. VEÍCULOS PARA VENDA
-- ============================================================

CREATE TABLE IF NOT EXISTS vehicles (
    id BIGSERIAL PRIMARY KEY,

    brand VARCHAR(255) NOT NULL,
    model VARCHAR(255) NOT NULL,
    version VARCHAR(255),

    year_manufacture INTEGER,
    year_model INTEGER,

    price NUMERIC(19,2) NOT NULL,

    mileage INTEGER,

    transmission VARCHAR(100),
    fuel VARCHAR(100),
    color VARCHAR(100),

    image_url VARCHAR(2000),
    description VARCHAR(3000),

    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',

    store_id BIGINT NOT NULL,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_vehicles_store
        FOREIGN KEY (store_id)
        REFERENCES stores(id)
);


-- ============================================================
-- 5. VEÍCULOS PARA LOCAÇÃO
-- ============================================================

CREATE TABLE IF NOT EXISTS rental_vehicles (
    id BIGSERIAL PRIMARY KEY,

    brand VARCHAR(255) NOT NULL,
    model VARCHAR(255) NOT NULL,
    version VARCHAR(255),

    year_model INTEGER,

    category VARCHAR(255),
    transmission VARCHAR(100),
    fuel VARCHAR(100),
    color VARCHAR(100),

    seats INTEGER,

    air_conditioning BOOLEAN DEFAULT FALSE,

    daily_rate NUMERIC(19,2) NOT NULL,
    weekly_rate NUMERIC(19,2),
    monthly_rate NUMERIC(19,2),
    deposit_amount NUMERIC(19,2),

    unlimited_mileage BOOLEAN NOT NULL DEFAULT TRUE,
    mileage_limit_per_day INTEGER,

    minimum_age INTEGER DEFAULT 21,

    image_url VARCHAR(2000),

    rental_rules VARCHAR(3000),

    status VARCHAR(50) NOT NULL DEFAULT 'AVAILABLE',

    store_id BIGINT NOT NULL,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_rental_vehicles_store
        FOREIGN KEY (store_id)
        REFERENCES stores(id)
);


-- ============================================================
-- 6. LEADS
-- ============================================================

CREATE TABLE IF NOT EXISTS leads (
    id BIGSERIAL PRIMARY KEY,

    name VARCHAR(255) NOT NULL,
    phone VARCHAR(255) NOT NULL,
    email VARCHAR(255),

    type VARCHAR(50),
    status VARCHAR(50) NOT NULL DEFAULT 'NE
