CREATE TABLE people (
    id INTEGER PRIMARY KEY,
    name varchar(255),
    surname varchar(255),
    age int
);

CREATE TABLE animals (
  id INTEGER PRIMARY KEY ,
  name VARCHAR(255),
  race VARCHAR(255),
  color VARCHAR(255)
);

INSERT INTO
    people (id, name, surname, age)
VALUES
    (NULL, 'Lucas', 'blanco', 28),
    (NULL, 'Fede', 'blanco', 30);

INSERT INTO
    animals (id, name, race, color)
VALUES
    (NULL, 'Tomas', 'dog1', 'blue'),
    (NULL, 'Max', 'dog1', 'red');