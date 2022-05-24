DROP TABLE IF EXISTS oseba;
DROP TABLE IF EXISTS predmet;
DROP TABLE IF EXISTS solanje;
DROP TABLE IF EXISTS termin;

-- CREATE TABLE oseba (
--     id SERIAL PRIMARY KEY,
--     ime TEXT NOT NULL,
--     priimek TEXT NOT NULL,
--     rojstvo DATE NOT NULL,
--     email TEXT NOT NULL UNIQUE,
--     telefon TEXT NOT NULL,
--     uporabnisko_ime TEXT NOT NULL UNIQUE,
--     geslo TEXT NOT NULL,
--     vloga TEXT NOT NULL
-- );








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
    geslo TEXT NOT NULL
);

DROP TABLE IF EXISTS vloga;
CREATE TABLE vloga (
    ime_vloge TEXT PRIMARY KEY
);

DROP TABLE IF EXISTS vloga_osebe;
CREATE TABLE vloga_osebe (
    oseba TEXT REFERENCES oseba(uporabnisko_ime),
    vloga TEXT REFERENCES vloga(ime_vloge),
    PRIMARY KEY (oseba,vloga)
);

DROP TABLE IF EXISTS predmet;
CREATE TABLE predmet (
    ime_predmeta TEXT PRIMARY KEY
);

DROP TABLE IF EXISTS podrocje;
CREATE TABLE podrocje (
    oseba TEXT REFERENCES oseba(uporabnisko_ime),
    predmet TEXT REFERENCES predmet(ime_predmeta),
    PRIMARY KEY (oseba,predmet)
);

DROP TABLE IF EXISTS letnik;
CREATE TABLE letnik (
    ime_letnika TEXT PRIMARY KEY
);

DROP TABLE IF EXISTS obiskuje;
CREATE TABLE obiskuje (
    oseba TEXT REFERENCES oseba(uporabnisko_ime),
    letnik TEXT REFERENCES letnik(ime_letnika),
    PRIMARY KEY (oseba,letnik)
);

DROP TABLE IF EXISTS termin;
CREATE TABLE termin (
    id_termina SERIAL PRIMARY KEY,
    instruktor TEXT REFERENCES oseba(uporabnisko_ime),
    stranka TEXT REFERENCES oseba(uporabnisko_ime),
    predmet TEXT REFERENCES predmet(ime_predmeta),
    lokacija TEXT NOT NULL,
    datum DATE NOT NULL,
    ura TIME NOT NULL
);

--primer osebe z vlogo (na roko vnešen v bazo)
INSERT INTO oseba VALUES ('Katja','Kranjec','123456789','katja@gmail.com','katjak','geslo');
INSERT INTO oseba VALUES ('Manca','Strah','987654321','manca@gmail.com','mancast','geslo');

INSERT INTO vloga VALUES ('stranka');
INSERT INTO vloga VALUES ('instruktor');

INSERT INTO vloga_osebe VALUES ('katjak','stranka');
INSERT INTO vloga_osebe VALUES ('mancast','instruktor');

INSERT INTO obiskuje VALUES ('katjak', '1. razred osnovne šole');

INSERT INTO predmet VALUES ('slo'), ('mat'), ('ang'), ('fiz'), ('kem'), ('bio');

INSERT INTO letnik VALUES ('1. razred osnovne šole'), ('2. razred osnovne šole'), ('3. razred osnovne šole'),
('4. razred osnovne šole'), ('5. razred osnovne šole'),
('6. razred osnovne šole'), ('7. razred osnovne šole'), ('8. razred osnovne šole'),
('9. razred osnovne šole'), ('1. letnik gimnazije'), ('2. letnik gimnazije'), ('3. letnik gimnazije'),
('4. letnik gimnazije'), ('1. letnik srednje strokovne šole'), ('2. letnik srednje strokovne šole'),
('3. letnik srednje strokovne šole'), ('4. letnik srednje strokovne šole');

INSERT INTO termin (instruktor,predmet,lokacija,datum,ura) VALUES ('mancast','slovenščina','nekje','2022-05-23','13:34:00');
INSERT INTO termin (instruktor,predmet,lokacija,datum,ura) VALUES ('mancast','matematika','nekje drugje','2022-05-22','12:34:00');
INSERT INTO termin (instruktor,predmet,lokacija,datum,ura) VALUES ('mancast','angleščina','nek','2022-05-21','12:00:00');
INSERT INTO termin (instruktor,predmet,lokacija,datum,ura) VALUES ('mancast','matematika','nekje','2022-05-27','17:00:00');
INSERT INTO termin (instruktor,predmet,lokacija,datum,ura) VALUES ('mancast','matematika','nek drget','2022-05-25','12:34:00');
INSERT INTO termin (instruktor,predmet,lokacija,datum,ura) VALUES ('mancast','matematika','kje','2022-05-30','12:00:00');

-- CREATE TABLE termin (
--     instruktor INTEGER REFERENCES oseba(id),
--     stranka INTEGER REFERENCES oseba(id),
--     predmet TEXT, 
--     -- a bi imeli predmeti svojo tabelo in svoje id-je (ne to, ki je že, kdo uči
--     -- kateri predmet, ampak kao 1 - SLO, 2, MAT ... Al bi blo odveč? Da se ne bo 
--     -- dogajalo npr. SLO, Slovenščina ... )

--     -- če že bi lahko bla tabela s kraticami pa predmeti pa je pol kratica primary key.
--     -- id po številkah je pa čist odveč
--     -- ampak pomoje je tud to čist odveč string 'slovenscina' čist dobr dela
--     lokacija TEXT NOT NULL,
--     ocena INTEGER,
--     datum_in_ura DATE NOT NULL
-- );

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
GRANT INSERT ON vloga_osebe TO javnost;
GRANT INSERT ON termin TO javnost;
GRANT INSERT ON podrocje TO javnost;
GRANT UPDATE ON termin TO javnost;

GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO javnost;