CREATE TABLE players (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  team_id INTEGER,

  FOREIGN KEY(team_id) REFERENCES team(id)
);

CREATE TABLE teams (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  conference_id INTEGER,

  FOREIGN KEY(conference_id) REFERENCES conference(id)
);

CREATE TABLE conferences (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

INSERT INTO
  conferences (id, name)
VALUES
  (1, "WEST"), (2, "EAST");

INSERT INTO
  teams (id, name, conference_id)
VALUES
  (1, "Warriors", 1),
  (2, "Lakers", 1),
  (3, "Knicks", 2),
  (4, "Bulls", 2);

INSERT INTO
  players (id, name, team_id)
VALUES
  (1, "Curry", 1),
  (2, "Durant", 1),
  (3, "Bryant", 2),
  (4, "Anthony", 3),
  (5, "Rose", 3),
  (6, "Wade", 4);
