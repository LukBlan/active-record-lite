CREATE TABLE people (
    name varchar(255),
    surname varchar(255),
    age int
);

CREATE TABLE animals (
  name VARCHAR(255),
  race VARCHAR(255),
  color VARCHAR(255)
);

INSERT INTO
    people (name, surname, age)
VALUES
    ('Lucas', 'blanco', 28),
    ('Fede', 'blanco', 30);

INSERT INTO
    animals (name, race, color)
VALUES
    ('Tomas', 'dog1', 'blue'),
    ('Max', 'dog1', 'red')