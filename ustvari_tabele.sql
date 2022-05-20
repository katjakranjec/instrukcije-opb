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
    geslo TEXT NOT NULL,
    vloga TEXT NOT NULL
);



-- CREATE TABLE vloga (
--     id_vloge INTEGER PRIMARY KEY,
--     vloga TEXT NOT NULL
-- )




-- CREATE TABLE oseba (
-- id INTEGER PRIMARY KEY UNIQUE,
-- ime TEXT NOT NULL,
-- priimek TEXT NOT NULL,
-- uporabnisko_ime TEXT NOT NULL UNIQUE,
-- geslo TEXT NOT NULL
-- );

DROP TABLE IF EXISTS oseba;
CREATE TABLE oseba (
    ime TEXT NOT NULL,
    priimek TEXT NOT NULL,
    telefon TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    uporabnisko_ime TEXT NOT NULL PRIMARY KEY,
    geslo TEXT NOT NULL,
    vloga TEXT NOT NULL
);

--primer osebe z vlogo (na roko vnešen v bazo)
INSERT INTO oseba VALUES ('Katja','Kranjec','123456789','katja@gmail.com','katjak','geslo','stranka');
INSERT INTO oseba VALUES ('Manca','Strah','987654321','manca@gmail.com','mancast','geslo','instruktor');

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
    -- a bi imeli predmeti svojo tabelo in svoje id-je (ne to, ki je že, kdo uči
    -- kateri predmet, ampak kao 1 - SLO, 2, MAT ... Al bi blo odveč? Da se ne bo 
    -- dogajalo npr. SLO, Slovenščina ... )

    -- če že bi lahko bla tabela s kraticami pa predmeti pa je pol kratica primary key.
    -- id po številkah je pa čist odveč
    -- ampak pomoje je tud to čist odveč string 'slovenscina' čist dobr dela
    lokacija TEXT NOT NULL,
    ocena INTEGER,
    datum_in_ura DATE NOT NULL
);

GRANT ALL ON DATABASE sem2022_katjak TO mancast WITH GRANT OPTION;
GRANT ALL ON SCHEMA public TO mancast WITH GRANT OPTION;
GRANT CONNECT ON DATABASE sem2022_mancast TO javnost;
GRANT USAGE ON SCHEMA public TO javnost;

GRANT ALL ON ALL TABLES IN SCHEMA public TO katjak WITH GRANT OPTION;
GRANT ALL ON ALL TABLES IN SCHEMA public TO mancast WITH GRANT OPTION;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO katjak WITH GRANT OPTION;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO mancast WITH GRANT OPTION;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO javnost;

GRANT INSERT ON oseba TO javnost;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO javnost;