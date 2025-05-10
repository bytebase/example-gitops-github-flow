CREATE TABLE bak_users
(
    id                    BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id               VARCHAR(50)  NOT NULL UNIQUE,
    email                 VARCHAR(100) NOT NULL UNIQUE,
    password              VARCHAR(255)  NOT NULL UNIQUE,
    is_not_locked         BOOLEAN DEFAULT TRUE,
    is_temporary_password BOOLEAN DEFAULT TRUE,
    avatar                VARCHAR(255),
    created_date          DATETIME,
    created_by            VARCHAR(36),
    updated_date          DATETIME,
    updated_by            VARCHAR(36)
);