CREATE INDEX email_idx ON "person" USING hash("email");

CREATE INDEX customer_rate_idx ON "customer" ("rate");

CREATE INDEX executor_rate_idx ON "executor" ("rate");

CREATE INDEX order_price_idx ON "order_request" ("price");