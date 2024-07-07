CREATE TABLE people (
    id INTEGER,
    name varchar(255),
    surname varchar(255),
    age int,

    PRIMARY KEY (id)
);

CREATE TABLE animals (
    id INTEGER,
    owner_id INTEGER,
    name VARCHAR(255),
    race VARCHAR(255),
    color VARCHAR(255),

    PRIMARY KEY (id),
    FOREIGN KEY (owner_id) REFERENCES people (id)
);

CREATE table toys (
    id INTEGER,
    owner_id INTEGER,
    name VARCHAR(255),

    PRIMARY KEY (id),
    FOREIGN KEY (owner_id) REFERENCES animals (id)
);

INSERT INTO
    people (id, name, surname, age)
VALUES
    (NULL, 'Estevan', 'Daltes', 201),
    (NULL, 'Enrique', 'Daltes', 300);

INSERT INTO
    animals (id, owner_id, name, race, color)
VALUES
    (NULL, 1, 'Tomas', 'dog1', 'blue'),
    (NULL, 2, 'Max', 'dog1', 'red');

INSERT INTO
    toys (id, owner_id, name)
VALUES
    (NULL, 1, 'Lanzallamas')
