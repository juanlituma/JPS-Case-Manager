-- =============================================================================
-- JPS Case Management — Database Setup Script
-- Usage: mysql -u root -p < database_setup.sql
-- =============================================================================

CREATE DATABASE IF NOT EXISTS jps_case_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE jps_case_db;

-- =============================================================================
-- TABLE: users  (iOS app accounts)
-- =============================================================================
CREATE TABLE IF NOT EXISTS users (
    id              INT          NOT NULL AUTO_INCREMENT,
    username        VARCHAR(100) NOT NULL,
    email           VARCHAR(255) NOT NULL,
    full_name       VARCHAR(255)     NULL,
    hashed_password VARCHAR(255) NOT NULL,
    is_active       TINYINT(1)   NOT NULL DEFAULT 1,
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME         NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    UNIQUE KEY uq_users_username (username),
    UNIQUE KEY uq_users_email    (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================================================
-- TABLE: employees  (Windows app accounts — completely separate from users)
-- Employees have their own username/password and are NOT linked to the users table.
-- =============================================================================
CREATE TABLE IF NOT EXISTS employees (
    id              INT          NOT NULL AUTO_INCREMENT,
    -- Login credentials (independent of the users table)
    username        VARCHAR(100) NOT NULL,
    email           VARCHAR(255) NOT NULL,
    full_name       VARCHAR(255)     NULL,
    hashed_password VARCHAR(255) NOT NULL,
    is_active       TINYINT(1)   NOT NULL DEFAULT 1,
    -- Employee-specific information
    employee_number VARCHAR(50)  NOT NULL,
    department      VARCHAR(100)     NULL,
    phone           VARCHAR(50)      NULL,
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME         NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    UNIQUE KEY uq_employees_username        (username),
    UNIQUE KEY uq_employees_email           (email),
    UNIQUE KEY uq_employees_employee_number (employee_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================================================
-- TABLE: cases
-- created_by_id is nullable — iOS users set it; Windows employees leave it NULL.
-- =============================================================================
CREATE TABLE IF NOT EXISTS cases (
    id             INT          NOT NULL AUTO_INCREMENT,
    title          VARCHAR(255) NOT NULL,
    description    TEXT             NULL,
    solution           TEXT             NULL,
    delivery_provider  ENUM('Uber','DoorDash','GrabHub','Self Delivery') NULL,
    complaint_type     ENUM('not_receive_food','food_bad_quality','missing_item','received_wrong_order') NULL,
    status         ENUM('open','in_progress','resolved','closed') NOT NULL DEFAULT 'open',
    created_by_id  INT              NULL,
    assigned_to_id INT              NULL,
    created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    INDEX idx_cases_status        (status),
    INDEX idx_cases_created_by_id (created_by_id),
    CONSTRAINT fk_cases_created_by  FOREIGN KEY (created_by_id)  REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_cases_assigned_to FOREIGN KEY (assigned_to_id) REFERENCES employees(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================================================
-- MIGRATION COMMANDS (run these if you already have an existing database)
-- Skip if running on a fresh database — the CREATE TABLE above is already correct.
-- =============================================================================

-- Step 1: Drop the old employees table (which had a user_id FK column)
-- DROP TABLE IF EXISTS employees;

-- Step 2: Re-run the CREATE TABLE employees block above.

-- Step 3: Make cases.created_by_id nullable (if upgrading an existing cases table):
-- ALTER TABLE cases MODIFY COLUMN created_by_id INT NULL;
-- ALTER TABLE cases DROP FOREIGN KEY fk_cases_created_by;
-- ALTER TABLE cases ADD CONSTRAINT fk_cases_created_by
--     FOREIGN KEY (created_by_id) REFERENCES users(id) ON DELETE SET NULL;

-- Step 4: Add new columns to existing cases table:
-- ALTER TABLE cases ADD COLUMN solution TEXT NULL AFTER description;
-- ALTER TABLE cases ADD COLUMN delivery_provider ENUM('Uber','DoorDash','GrabHub','Self Delivery') NULL AFTER solution;
-- ALTER TABLE cases ADD COLUMN complaint_type ENUM('not_receive_food','food_bad_quality','missing_item','received_wrong_order') NULL AFTER delivery_provider;

