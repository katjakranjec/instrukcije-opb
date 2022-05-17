# kopirano iz datoteke z vaj

#!/usr/bin/python
# -*- encoding: utf-8 -*-

# uvozimo bottle.py
from bottleext import *

# uvozimo ustrezne podatke za povezavo
import auth_public as auth

# uvozimo psycopg2
import psycopg2, psycopg2.extensions, psycopg2.extras
psycopg2.extensions.register_type(psycopg2.extensions.UNICODE) 
# se znebimo problemov s šumniki

import os
import hashlib

skrivnost="skrivnost"

# privzete nastavitve
SERVER_PORT = os.environ.get('BOTTLE_PORT', 8080)
RELOADER = os.environ.get('BOTTLE_RELOADER', True)
DB_PORT = os.environ.get('POSTGRES_PORT', 5432)

#debug(True)

######################################################################
# ostalo

def nastaviSporocilo(sporocilo = None):
    # global napakaSporocilo
    staro = request.get_cookie("sporocilo", secret=skrivnost)
    if sporocilo is None:
        response.delete_cookie('sporocilo') #če funkciji ne podamo ničesar, izbriše piškotek z imenom sporočilo
    else:
        response.set_cookie('sporocilo', sporocilo, path="/", secret=skrivnost)
    return staro

def geslo_hash(s):
    """Vrni SHA-512 hash danega UTF-8 niza. Gesla vedno spravimo v bazo
       kodirana s to funkcijo."""
    h = hashlib.sha512()
    h.update(s.encode('utf-8'))
    return h.hexdigest()

#_____________________________________________________________

@get('/')
def index():
    return template('index.html', napaka=None)

#_PRIJAVA______________________________________________

@get('/prijava') 
def prijava_get():
    return template('prijava.html', napaka=None)

@post('/prijava')
def prijava_post():
    username = request.forms.username
    geslo = request.forms.password
    if username is None or geslo is None:
        nastaviSporocilo('Uporabniško ime in geslo morata biti neprazna') 
        redirect(url('prijava_get'))
    cur = baza.cursor()
    hgeslo = None
    try: 
        cur.execute("SELECT geslo FROM oseba WHERE uporabnisko_ime = %s", (username, ))
        hgeslo, = cur.fetchone()
    except:
        hgeslo = None
    if hgeslo is None:
        nastaviSporocilo('Uporabniško ime ali geslo nista pravilna')
        redirect(url('prijava_get'))
        return
    if geslo != hgeslo:
        nastaviSporocilo('Uporabniško ime ali geslo nista pravilna') 
        redirect(url('prijava_get'))
        return
    response.set_cookie('username', username, path="/", secret=skrivnost)
    redirect(url('uporabnik'))

@get('/uporabnik') 
def uporabnik():
    return 'Dela.'

# REGISTRACIJA
@get('/registracija')
def registracija_get():
    # napaka = nastaviSporocilo()
    return template('registracija.html', napaka=None)

@post('/registracija')
def registracija_post():
    ime = request.forms.get('ime')
    priimek = request.forms.get('priimek')
    email = request.forms.get('email')
    telefon = request.forms.get('telefon')
    username = request.forms.get('username')
    password = request.forms.get('password')
    password2 = request.forms.get('password2')

    #preverimo, ce je izbrani username ze zaseden
    cur = baza.cursor()
    cur.execute("SELECT * FROM oseba WHERE uporabnisko_ime=%s", (username,))
    upor = cur.fetchone()
    if upor is not None:
        return template('registracija.html',  ime=ime, priimek=priimek, username=username,
                                email=email, napaka="Uporabniško ime je že zasedeno!")
        

    # preverimo, ali se gesli ujemata
    if password != password2:
        return template("registracija.html", ime=ime, priimek=priimek, username=username,
                                email=email, napaka="Gesli se ne ujemata!")
        
    #preverimo, ali ima geslo vsaj 4 znake

    if len(password) < 4:
        return template("registracija.html", ime=ime, priimek=priimek, username=username,
                                email=email, napaka="Geslo mora imeti vsaj 4 znake!")
        

    #ce pridemo, do sem, je vse uredu in lahko vnesemo zahtevek v bazo
    response.set_cookie('username', username, path="/", secret=skrivnost) #vemo, da je oseba registrirana in jo kar prijavimo
    cur.execute("INSERT INTO oseba (ime, priimek, telefon, email, uporabnisko_ime, geslo) VALUES (%s, %s, %s, %s, %s, %s)", (ime, priimek, telefon, email, username, password))
    baza.commit()  
    redirect(url('uporabnik'))
 
  


######################################################################
# Glavni program

# priklopimo se na bazo
baza = psycopg2.connect(database=auth.db, host=auth.host, user=auth.user, password=auth.password, port=DB_PORT)
#conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT) # onemogočimo transakcije
cur = baza.cursor(cursor_factory=psycopg2.extras.DictCursor)

# poženemo strežnik na podanih vratih, npr. http://localhost:8080/
if __name__ == "__main__":
    run(host='localhost', port=SERVER_PORT, reloader=RELOADER)

