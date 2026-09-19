-- ==========================================================
-- SCRIPT KHỞI TẠO CƠ SỞ DỮ LIỆU CHO HỆ THỐNG TOUR BOOKING
-- Hỗ trợ PostgreSQL 16+
-- ==========================================================

-- 1. DATABASE CHO USER SERVICE
DROP DATABASE IF EXISTS user_db;
CREATE DATABASE user_db;

\c user_db;

CREATE TABLE users (
    id          BIGSERIAL PRIMARY KEY,
    email       VARCHAR(100) NOT NULL UNIQUE,
    password    VARCHAR(255) NOT NULL,
    full_name   VARCHAR(100) NOT NULL,
    phone       VARCHAR(20),
    avatar_url  VARCHAR(500),
    role        VARCHAR(10) NOT NULL DEFAULT 'MEMBER'
                CHECK (role IN ('GUEST', 'MEMBER', 'ADMIN')),
    is_active   BOOLEAN DEFAULT TRUE,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tài khoản Admin mặc định (mật khẩu: admin123 - bcrypt)
INSERT INTO users (email, password, full_name, phone, role)
VALUES ('admin@tourapp.com', '$2a$10$wO0I7E9V6R4V0k9p8zJ7hOTkKq9jO4cZf0yG7lM1vB8xS2a.n5mK6', 'Quản Trị Viên', '0901234567', 'ADMIN');

-- 2. DATABASE CHO TOUR SERVICE
DROP DATABASE IF EXISTS tour_db;
CREATE DATABASE tour_db;

\c tour_db;

CREATE TABLE destinations (
    id          BIGSERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    description TEXT,
    image_url   VARCHAR(500),
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tours (
    id               BIGSERIAL PRIMARY KEY,
    title            VARCHAR(200) NOT NULL,
    description      TEXT,
    destination_id   BIGINT NOT NULL REFERENCES destinations(id),
    duration_days    INT NOT NULL,
    max_participants INT NOT NULL,
    price_adult      NUMERIC(12,0) NOT NULL,
    price_child      NUMERIC(12,0),
    thumbnail_url    VARCHAR(500),
    start_date       DATE NOT NULL,
    end_date         DATE NOT NULL,
    is_active        BOOLEAN DEFAULT TRUE,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tour_images (
    id          BIGSERIAL PRIMARY KEY,
    tour_id     BIGINT NOT NULL REFERENCES tours(id) ON DELETE CASCADE,
    image_url   VARCHAR(500) NOT NULL,
    caption     VARCHAR(200),
    sort_order  INT DEFAULT 0
);

CREATE TABLE tour_schedules (
    id          BIGSERIAL PRIMARY KEY,
    tour_id     BIGINT NOT NULL REFERENCES tours(id) ON DELETE CASCADE,
    day_number  INT NOT NULL,
    title       VARCHAR(200),
    description TEXT
);

CREATE TABLE reviews (
    id          BIGSERIAL PRIMARY KEY,
    tour_id     BIGINT NOT NULL REFERENCES tours(id) ON DELETE CASCADE,
    user_id     BIGINT NOT NULL,
    rating      INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment     TEXT,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seed dữ liệu mẫu cho Tour Service
INSERT INTO destinations (name, description, image_url) VALUES
('Đà Nẵng', 'Thành phố đáng sống với biển Mỹ Khê và Cầu Vàng Bà Nà Hills', 'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=800'),
('Phú Quốc', 'Đảo ngọc thiên đường với bãi biển trong xanh và hoàng hôn tuyệt đẹp', 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800'),
('Hà Giang', 'Vùng cao nguyên đá hùng vĩ với đèo Mã Pí Lèng và mùa hoa tam giác mạch', 'https://images.unsplash.com/photo-1528127269322-539801943592?w=800');

INSERT INTO tours (title, description, destination_id, duration_days, max_participants, price_adult, price_child, thumbnail_url, start_date, end_date) VALUES
('Tour Đà Nẵng - Hội An - Bà Nà Hills 3N2Đ', 'Khám phá thành phố biển đáng sống nhất Việt Nam, check-in Cầu Vàng và phố cổ Hội An rực rỡ đèn lồng.', 1, 3, 20, 3500000, 2500000, 'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=800', CURRENT_DATE + 5, CURRENT_DATE + 8),
('Tour Đảo Ngọc Phú Quốc 4N3Đ Trọn Gói', 'Nghỉ dưỡng resort biển cao cấp, lặn ngắm san hô tại quần đảo An Thới, thưởng thức hải sản tươi ngon.', 2, 4, 15, 5200000, 3800000, 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800', CURRENT_DATE + 7, CURRENT_DATE + 11);

-- 3. DATABASE CHO BOOKING SERVICE
DROP DATABASE IF EXISTS booking_db;
CREATE DATABASE booking_db;

\c booking_db;

CREATE TABLE bookings (
    id              BIGSERIAL PRIMARY KEY,
    booking_code    VARCHAR(20) NOT NULL UNIQUE,
    user_id         BIGINT NOT NULL,
    tour_id         BIGINT NOT NULL,
    num_adults      INT NOT NULL DEFAULT 1,
    num_children    INT DEFAULT 0,
    total_price     NUMERIC(15,0) NOT NULL,
    contact_name    VARCHAR(100) NOT NULL,
    contact_phone   VARCHAR(20) NOT NULL,
    contact_email   VARCHAR(100),
    special_request TEXT,
    status          VARCHAR(15) NOT NULL DEFAULT 'PENDING'
                    CHECK (status IN ('PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED')),
    payment_method  VARCHAR(15) NOT NULL DEFAULT 'CASH'
                    CHECK (payment_method IN ('CASH', 'BANK_TRANSFER', 'MOMO')),
    payment_status  VARCHAR(10) NOT NULL DEFAULT 'UNPAID'
                    CHECK (payment_status IN ('UNPAID', 'PAID', 'REFUNDED')),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
