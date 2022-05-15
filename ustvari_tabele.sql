DROP TABLE IF EXISTS oseba;
DROP TABLE IF EXISTS predmet;
DROP TABLE IF EXISTS solanje;
DROP TABLE IF EXISTS termin;

CREATE TABLE oseba (
    id SERIAL PRIMARY KEY,
    ime TEXT NOT NULL,
    priimek TEXT NOT NULL,
    rojstvo DATE NOT NULL,
    email TEXT NOT NULL UNIQUE,
    telefon TEXT NOT NULL,
    uporabnisko_ime TEXT NOT NULL UNIQUE,
    geslo TEXT NOT NULL
);

-- CREATE TABLE oseba (
-- id INTEGER PRIMARY KEY UNIQUE,
-- ime TEXT NOT NULL,
-- priimek TEXT NOT NULL,
-- uporabnisko_ime TEXT NOT NULL UNIQUE,
-- geslo TEXT NOT NULL
-- );

-- DROP TABLE IF EXISTS oseba;
-- CREATE TABLE oseba (
--     ime TEXT NOT NULL,
--     priimek TEXT NOT NULL,
--     telefon TEXT NOT NULL,
--     email TEXT NOT NULL UNIQUE,
--     uporabnisko_ime TEXT NOT NULL PRIMARY KEY,
--     geslo TEXT NOT NULL
-- );

CREATE TABLE predmet (
    id_osebe INTEGER REFERENCES oseba(id),
    predmet TEXT NOT NULL
);

CREATE TABLE solanje (
    id_osebe REFERENCES oseba(id),
    letnik TEXT NOT NULL,
    sola TEXT NOT NULL
);

CREATE TABLE termin (
    instruktor INTEGER REFERENCES oseba(id),
    stranka INTEGER REFERENCES oseba(id),
    predmet TEXT,
    lokacija TEXT NOT NULL,
    ocena INTEGER,
    datum_in_ura DATE NOT NULL
);

GRANT ALL ON DATABASE sem2022_katjak TO mancast WITH GRANT OPTION;
GRANT ALL ON SCHEMA public TO mancast WITH GRANT OPTION;
GRANT CONNECT ON DATABASE sem2022_mancast TO javnost;
GRANT USAGE ON SCHEMA public TO javnost;