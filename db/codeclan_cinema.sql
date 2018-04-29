DROP TABLE IF EXISTS tickets;
DROP TABLE IF EXISTS showings;
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

CREATE TABLE showings(
  id SERIAL4 PRIMARY KEY,
  capacity INT4 NOT NULL
  CONSTRAINT capacity_positive CHECK (capacity >= 0),
  film_id INT4 REFERENCES films(id) ON DELETE CASCADE,
  date_time TIMESTAMP NOT NULL
);

CREATE TABLE tickets(
  id SERIAL4 PRIMARY KEY,
  customer_id INT4 REFERENCES customers(id) ON DELETE CASCADE,
  --film_id INT4 REFERENCES films(id) ON DELETE CASCADE,
  showing_id INT4 REFERENCES showings(id) ON DELETE CASCADE
);
