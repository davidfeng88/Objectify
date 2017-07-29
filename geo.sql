CREATE TABLE continents (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

CREATE TABLE countries (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  continent_id INTEGER,

  FOREIGN KEY(continent_id) REFERENCES continent(id)
);

CREATE TABLE cities (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  country_id INTEGER,

  FOREIGN KEY(country_id) REFERENCES country(id)
);

INSERT INTO
  continents (id, name)
VALUES
  (1, "Asia"), (2, "North America");

INSERT INTO
  countries (id, name, continent_id)
VALUES
  (1, "China", 1),
  (2, "Japan", 1),
  (3, "United States", 2),
  (4, "Canada", 2);

INSERT INTO
  cities (id, name, country_id)
VALUES
  (1, "Beijing", 1),
  (2, "Shanghai", 1),
  (3, "Tokyo", 2),
  (4, "New York", 3),
  (5, "Chicago", 3),
  (6, "Los Angeles", 3),
  (7, "Toronto", 4);
