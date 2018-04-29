DROP TABLE IF EXISTS tickets;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS films;

CREATE TABLE films(
  id SERIAL4 PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  price DECIMAL(5,2) NOT NULL
  CONSTRAINT price_positive CHECK (price >= 0)
);

CREATE TABLE customers(
  id SERIAL4 PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  funds DECIMAL(7,2) NOT NULL
  CONSTRAINT funds_positive CHECK (funds >= 0)
);

CREATE TABLE tickets(
  id SERIAL4 PRIMARY KEY,
  customer_id INT4 REFERENCES customers(id) NOT NULL,
  film_id INT4 REFERENCES films(id) NOT NULL
);
