CREATE TABLE "public"."testtable" (
    "id" serial,
    "name" text NOT NULL,
    "created_at" timestamptz DEFAULT now(),
    CONSTRAINT "testtable_pkey" PRIMARY KEY (id)
);

