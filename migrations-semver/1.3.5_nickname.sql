-- add nickname column for users
ALTER TABLE IF EXISTS users ADD COLUMN IF NOT EXISTS nickname VARCHAR(255) NOT NULL DEFAULT '';
