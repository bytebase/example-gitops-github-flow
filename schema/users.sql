CREATE TABLE public.users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    gender TEXT NOT NULL CHECK (gender IN('M', 'F')) NOT NULL
);
