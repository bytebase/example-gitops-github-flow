CREATE TABLE client_account
(
    id                         BIGINT PRIMARY KEY AUTO_INCREMENT,
    client_account_id          VARCHAR(20)  NOT NULL UNIQUE,
    client_account_name        VARCHAR(100) NOT NULL,
    address                    VARCHAR(250),
    country                    VARCHAR(3),
    state                      VARCHAR(50),
    city                       VARCHAR(50),
    postcode                   BIGINT,
    phone_country_code         VARCHAR(20),
    phone                      VARCHAR(20),
    email_address              VARCHAR(70),
    status                     VARCHAR(1),
    start_date                 DATETIME     NOT NULL,
    contact_name               VARCHAR(100),
    contact_phone_country_code VARCHAR(20),
    contact_phone              VARCHAR(20),
    contact_email_address      VARCHAR(70),
    client_common_db_name      VARCHAR(255) NOT NULL UNIQUE,
    created_date               DATETIME,
    created_by                 VARCHAR(36),
    updated_date               DATETIME,
    updated_by                 VARCHAR(36)
);


CREATE TABLE company
(
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    client_id       BIGINT       NOT NULL,
    company_code    VARCHAR(50)  NOT NULL,
    it_company_code varchar(100) DEFAULT '' NOT NULL,
    company_name    VARCHAR(255) NOT NULL,
    status          VARCHAR(1),
    company_db_name VARCHAR(255) NOT NULL UNIQUE,
    created_date    DATETIME,
    created_by      VARCHAR(36),
    updated_date    DATETIME,
    updated_by      VARCHAR(36),
    CONSTRAINT uk_company_code_client_id UNIQUE (company_code, client_id)
);

ALTER TABLE company
    ADD CONSTRAINT fk_client_account FOREIGN KEY (client_id) REFERENCES client_account (id)
        ON UPDATE CASCADE;