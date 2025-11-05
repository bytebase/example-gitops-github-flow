COMMENT ON SCHEMA "public" IS 'standard public schema';

CREATE TABLE "public"."audit" (
    "id" serial,
    "operation" text NOT NULL,
    "query" text,
    "user_name" text NOT NULL,
    "changed_at" timestamptz DEFAULT now(), 
    CONSTRAINT "audit_pkey" PRIMARY KEY (id)
);

CREATE INDEX "idx_audit_changed_at" ON ONLY "public"."audit" (changed_at);

CREATE INDEX "idx_audit_operation" ON ONLY "public"."audit" (operation);

CREATE INDEX "idx_audit_username" ON ONLY "public"."audit" (user_name);

CREATE TABLE "public"."department" (
    "dept_no" text NOT NULL,
    "dept_name" text NOT NULL,
    created_at timestamptz DEFAULT now(),
    CONSTRAINT "department_pkey" PRIMARY KEY (dept_no),
    CONSTRAINT "department_dept_name_key" UNIQUE (dept_name)
);

CREATE TABLE "public"."dept_emp" (
    "emp_no" integer NOT NULL,
    "dept_no" text NOT NULL,
    "from_date" date NOT NULL,
    "to_date" date NOT NULL,
    CONSTRAINT "dept_emp_pkey" PRIMARY KEY (emp_no, dept_no),
    CONSTRAINT "dept_emp_dept_no_fkey" FOREIGN KEY ("dept_no") REFERENCES "public"."department" ("dept_no") ON DELETE CASCADE,
    CONSTRAINT "dept_emp_emp_no_fkey" FOREIGN KEY ("emp_no") REFERENCES "public"."employee" ("emp_no") ON DELETE CASCADE
);

CREATE TABLE "public"."dept_manager" (
    "emp_no" integer NOT NULL,
    "dept_no" text NOT NULL,
    "from_date" date NOT NULL,
    "to_date" date NOT NULL,
    CONSTRAINT "dept_manager_pkey" PRIMARY KEY (emp_no, dept_no),
    CONSTRAINT "dept_manager_dept_no_fkey" FOREIGN KEY ("dept_no") REFERENCES "public"."department" ("dept_no") ON DELETE CASCADE,
    CONSTRAINT "dept_manager_emp_no_fkey" FOREIGN KEY ("emp_no") REFERENCES "public"."employee" ("emp_no") ON DELETE CASCADE
);

CREATE TABLE "public"."employee" (
    "emp_no" serial,
    "birth_date" date NOT NULL,
    "first_name" text NOT NULL,
    "last_name" text NOT NULL,
    "gender" text NOT NULL,
    "hire_date" date NOT NULL,
    "nickname" text,
    CONSTRAINT "employee_pkey" PRIMARY KEY (emp_no),
    CONSTRAINT "employee_gender_check" CHECK (gender = ANY (ARRAY['M'::text, 'F'::text]))
);

CREATE INDEX "idx_employee_hire_date" ON ONLY "public"."employee" (hire_date);

CREATE TABLE "public"."salary" (
    "emp_no" integer NOT NULL,
    "amount" integer NOT NULL,
    "from_date" date NOT NULL,
    "to_date" date NOT NULL,
    CONSTRAINT "salary_pkey" PRIMARY KEY (emp_no, from_date),
    CONSTRAINT "salary_emp_no_fkey" FOREIGN KEY ("emp_no") REFERENCES "public"."employee" ("emp_no") ON DELETE CASCADE
);

CREATE INDEX "idx_salary_amount" ON ONLY "public"."salary" (amount);

CREATE TABLE "public"."title" (
    "emp_no" integer NOT NULL,
    "title" text NOT NULL,
    "from_date" date NOT NULL,
    "to_date" date,
    CONSTRAINT "title_pkey" PRIMARY KEY (emp_no, title, from_date),
    CONSTRAINT "title_emp_no_fkey" FOREIGN KEY ("emp_no") REFERENCES "public"."employee" ("emp_no") ON DELETE CASCADE
);

CREATE VIEW "public"."current_dept_emp" AS SELECT l.emp_no,
    d.dept_no,
    l.from_date,
    l.to_date
   FROM (public.dept_emp d
     JOIN public.dept_emp_latest_date l ON (((d.emp_no = l.emp_no) AND (d.from_date = l.from_date) AND (l.to_date = d.to_date))));

CREATE VIEW "public"."dept_emp_latest_date" AS SELECT emp_no,
    max(from_date) AS from_date,
    max(to_date) AS to_date
   FROM public.dept_emp
  GROUP BY emp_no;

CREATE OR REPLACE FUNCTION public.log_dml_operations()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO audit (operation, query, user_name)
        VALUES ('INSERT', current_query(), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit (operation, query, user_name)
        VALUES ('UPDATE', current_query(), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO audit (operation, query, user_name)
        VALUES ('DELETE', current_query(), current_user);
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$function$;

