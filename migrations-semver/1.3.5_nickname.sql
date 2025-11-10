-- add nickname column for users_test_bytebase
ALTER TABLE IF EXISTS users_test_bytebase ADD COLUMN IF NOT EXISTS nickname VARCHAR(255) NOT NULL DEFAULT '';
