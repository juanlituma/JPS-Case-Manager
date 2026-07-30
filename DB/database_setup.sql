-- ============================================================
--  JPS Case Management — MySQL Database Setup Script
--  Run this once to create the database and all tables.
--  Usage: mysql -u root -p < database_setup.sql
-- ============================================================

-- 1. Create the database
CREATE DATABASE IF NOT EXISTS jps_case_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE jps_case_db;

-- ============================================================
--  2. Users table
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    id                INT          NOT NULL AUTO_INCREMENT,
    username          VARCHAR(100) NOT NULL,
    email             VARCHAR(255) NOT NULL,
    full_name         VARCHAR(255)     NULL,
    hashed_password   VARCHAR(255) NOT NULL,
    is_active         TINYINT(1)   NOT NULL DEFAULT 1,
    created_at        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        DATETIME         NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    UNIQUE  KEY uq_users_username (username),
    UNIQUE  KEY uq_users_email    (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
--  3. Cases table
-- ============================================================
CREATE TABLE IF NOT EXISTS cases (
    id              INT          NOT NULL AUTO_INCREMENT,
    title           VARCHAR(255) NOT NULL,
    description     TEXT             NULL,
    solution            TEXT             NULL,
    delivery_provider   ENUM('Uber','DoorDash','GrabHub','Self Delivery') NULL,
    complaint_type      ENUM('not_receive_food','food_bad_quality','missing_item','received_wrong_order') NULL,
    status          ENUM('open', 'in_progress', 'resolved', 'closed') NOT NULL DEFAULT 'open',
    created_by_id   INT          NOT NULL,
    assigned_to_id  INT              NULL,
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    KEY idx_cases_status        (status),
    KEY idx_cases_created_by    (created_by_id),
    KEY idx_cases_assigned_to   (assigned_to_id),

    CONSTRAINT fk_cases_created_by
        FOREIGN KEY (created_by_id)  REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT fk_cases_assigned_to
        FOREIGN KEY (assigned_to_id) REFERENCES users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
--  4. Optional: seed an admin account
--  Password below is:  Admin@1234
--  (bcrypt hash — change this after first login!)
-- ============================================================
INSERT IGNORE INTO users (username, email, full_name, hashed_password)
VALUES (
    'admin',
    'admin@jps.local',
    'System Administrator',
    '$2b$12$KIXBp/8D7kFbSEMdMzLdGOi0EnGJPGboHuOuqRmXU8WZW4UMxcKze'
);

-- ============================================================
--  5. Migration: add solution column to existing databases
--     Run this block if the cases table already exists.
-- ============================================================
-- ALTER TABLE cases ADD COLUMN solution TEXT NULL AFTER description;
-- ALTER TABLE cases ADD COLUMN delivery_provider ENUM('Uber','DoorDash','GrabHub','Self Delivery') NULL AFTER solution;
-- ALTER TABLE cases ADD COLUMN complaint_type ENUM('not_receive_food','food_bad_quality','missing_item','received_wrong_order') NULL AFTER delivery_provider;

-- ============================================================
--  6. Verify
-- ============================================================
SHOW TABLES;
SELECT id, username, email FROM users;
