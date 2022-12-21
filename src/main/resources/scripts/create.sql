SET search_path TO s312431;

CREATE TYPE user_status AS ENUM ('active', 'banned');
CREATE TYPE order_status AS ENUM ('started', 'finished');
CREATE TYPE order_request_status AS ENUM ('opened', 'closed');
CREATE TYPE ticket_status AS ENUM ('opened', 'closed');
CREATE TYPE message_direction AS ENUM ('from_customer', 'to_customer', 'from_executor', 'to_executor');
CREATE TYPE client_type AS ENUM ('customer', 'executor');


CREATE TABLE IF NOT EXISTS "person" (
                                        "id" serial PRIMARY KEY,
                                        "email" varchar unique,
                                        "full_name" varchar,
                                        "password" varchar
);

CREATE TABLE IF NOT EXISTS "customer" (
                                          "id" serial PRIMARY KEY,
                                          "person_id" int unique,
                                          "rate" float4 default null,
                                          "status" user_status default 'active'
);

CREATE TABLE IF NOT EXISTS "executor" (
                                          "id" serial PRIMARY KEY,
                                          "person_id" int unique ,
                                          "rate" float4 default null,
                                          "status" user_status default 'active'
);

CREATE TABLE IF NOT EXISTS "competence" (
                                            "id" serial PRIMARY KEY,
                                            "competence" varchar unique
);

CREATE TABLE IF NOT EXISTS "executor_competence" (
                                                     "executor_id" int,
                                                     "competence_id" int,
                                                     PRIMARY KEY ("executor_id", "competence_id")
    );

CREATE TABLE IF NOT EXISTS "order_request" (
                                               "id" serial PRIMARY KEY,
                                               "customer_id" int not null,
                                               "created_at" timestamp default current_timestamp,
                                               "competence_id" int,
                                               "price" int not null,
                                               "description" text,
                                               "customer_default_agr" boolean default false,
                                               "status" order_request_status default 'opened'
);

CREATE TABLE IF NOT EXISTS "order_requests_executors" (
                                                          "order_request_id" int,
                                                          "executor_id" int,
                                                          "created_at" timestamp default current_timestamp,
                                                          "customer_agr" boolean,
                                                          "executor_agr" boolean,
                                                          PRIMARY KEY ("order_request_id", "executor_id")
    );

CREATE TABLE IF NOT EXISTS "order" (
                                       "id" serial PRIMARY KEY,
                                       "order_request_id" int unique,
                                       "customer_id" int,
                                       "executor_id" int,
                                       "created_at" timestamp default current_timestamp,
                                       "status" order_status default 'started'
);

CREATE TABLE IF NOT EXISTS "feedback" (
                                          "order_id" int,
                                          "author" client_type,
                                          "rate" float4,
                                          "feedback" text,
                                          "author_wants_ticket" boolean default false,
                                          "created_at" timestamp default current_timestamp,
                                          PRIMARY KEY ("order_id", "author")
    );

CREATE TABLE IF NOT EXISTS "moderator" (
                                           "id" serial PRIMARY KEY,
                                           "person_id" int
);

CREATE TABLE IF NOT EXISTS "ticket" (
                                        "order_id" int PRIMARY KEY,
                                        "moderator_id" int,
                                        "created_at" timestamp default current_timestamp,
                                        "status" ticket_status default 'opened'
);

CREATE TABLE IF NOT EXISTS "message" (
                                         "id" serial PRIMARY KEY,
                                         "created_at" timestamp default current_timestamp,
                                         "order_id" int,
                                         "mes_text" text,
                                         "mes_direction" message_direction
);

CREATE TABLE IF NOT EXISTS "message_images" (
                                                "id" serial PRIMARY KEY,
                                                "message_id" int,
                                                "img" bytea
);

CREATE TABLE IF NOT EXISTS "executor_documents" (
                                                    "id" serial PRIMARY KEY,
                                                    "executor_id" int,
                                                    "doc" bytea
);

CREATE TABLE IF NOT EXISTS "verdict" (
                                         "order_id" int PRIMARY KEY,
                                         "new_rate_for_executor" float4,
                                         "delete_feedback_about_executor" boolean,
                                         "ban_executor" boolean,
                                         "new_rate_for_customer" float4,
                                         "delete_feedback_about_customer" boolean,
                                         "ban_customer" boolean
);

ALTER TABLE "customer" ADD FOREIGN KEY ("person_id") REFERENCES "person" ("id");

ALTER TABLE "executor" ADD FOREIGN KEY ("person_id") REFERENCES "person" ("id");

ALTER TABLE "executor_competence" ADD FOREIGN KEY ("executor_id") REFERENCES "executor" ("id");

ALTER TABLE "executor_competence" ADD FOREIGN KEY ("competence_id") REFERENCES "competence" ("id");

ALTER TABLE "order_request" ADD FOREIGN KEY ("customer_id") REFERENCES "customer" ("id");

ALTER TABLE "order_request" ADD FOREIGN KEY ("competence_id") REFERENCES "competence" ("id");

ALTER TABLE "order_requests_executors" ADD FOREIGN KEY ("order_request_id") REFERENCES "order_request" ("id");

ALTER TABLE "order_requests_executors" ADD FOREIGN KEY ("executor_id") REFERENCES "executor" ("id");

ALTER TABLE "order" ADD FOREIGN KEY ("order_request_id") REFERENCES "order_request" ("id");

ALTER TABLE "order" ADD FOREIGN KEY ("customer_id") REFERENCES "customer" ("id");

ALTER TABLE "order" ADD FOREIGN KEY ("executor_id") REFERENCES "executor" ("id");

ALTER TABLE "feedback" ADD FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "moderator" ADD FOREIGN KEY ("person_id") REFERENCES "person" ("id");

ALTER TABLE "ticket" ADD FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "ticket" ADD FOREIGN KEY ("moderator_id") REFERENCES "moderator" ("id");

ALTER TABLE "message" ADD FOREIGN KEY ("order_id") REFERENCES "ticket" ("order_id");

ALTER TABLE "message_images" ADD FOREIGN KEY ("message_id") REFERENCES "message" ("id");

ALTER TABLE "executor_documents" ADD FOREIGN KEY ("executor_id") REFERENCES "executor" ("id");

ALTER TABLE "verdict" ADD FOREIGN KEY ("order_id") REFERENCES "ticket" ("order_id");

