CREATE SCHEMA IF NOT EXISTS "testschema";

COMMENT ON SCHEMA "testschema" IS 'test schema for testing purposes';

CREATE TABLE "testschema"."testtable" (
    "id" serial,
    "name" text NOT NULL,
    "created_at" timestamptz DEFAULT now(),
    CONSTRAINT "testtable_pkey" PRIMARY KEY (id)
);

