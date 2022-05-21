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

skrivnost="NaJsKrIvNoStNeJsAsKrIvNoSt"

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

#__________________________________________________________________________________________________
# PRIJAVA

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

    #preverimo vlogo in ustrezno preusmerimo na profilno stran
    cur.execute("SELECT vloga FROM vloga_osebe WHERE oseba = %s", (username, ))
    vloga, = cur.fetchone()
    #print(vloga)
    if vloga == 'stranka':
        redirect(url('uporabnik'))
    if vloga == 'instruktor':
        redirect(url('instruktor'))


#___________________________________________________________________________________________________________
# REGISTRACIJA

@get('/registracija')
def registracija_get():
    napaka = nastaviSporocilo()
    return template('registracija.html', napaka=napaka)

@post('/registracija')
def registracija_post():
    ime = request.forms.ime
    priimek = request.forms.priimek
    email = request.forms.email
    telefon = request.forms.telefon
    username = request.forms.username
    password = request.forms.password
    password2 = request.forms.password2

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
    #print('lalaal')
    baza.commit() 
    cur.execute("INSERT INTO vloga_osebe (oseba, vloga) VALUES (%s, 'stranka')", (username,)) 
    baza.commit()
    redirect(url('uporabnik'))
 
#__________________________________________________________________________________________________
# ODJAVA

@get('/odjava')
def odjava_get():
    response.delete_cookie('username', path="/")
    redirect(url('index')) 

#___________________________________________________________________________________________________
# STRANI UPORABNIKA

@get('/uporabnik') 
def uporabnik():
    username = request.get_cookie('username', secret=skrivnost)
    cur = baza.cursor()
    cur.execute("SELECT instruktor,predmet,lokacija,datum,ura FROM termin WHERE stranka='{0}' AND datum>NOW() ".format(username))
    rez_termini=cur
    cur = baza.cursor()
    cur.execute("SELECT instruktor,predmet,lokacija,datum,ura FROM termin WHERE stranka='{0}' AND datum<NOW() ".format(username))
    pre_termini=cur
    return template('uporabnik.html', rez_termini=rez_termini, pre_termini=pre_termini)

@get('/uporabnik/mojprofil')
def mojprofil():
    username = request.get_cookie('username', secret=skrivnost)
    cur = baza.cursor()
    print('do sem pride')
    cur.execute("SELECT ime,priimek,telefon,email,uporabnisko_ime FROM oseba WHERE uporabnisko_ime='{0}'".format(username))

    return template('profil.html', oseba=cur)

@get('/uporabnik/rezerviraj')
def rezerviraj_get():
    #return 'Nekej se zgodi'
    return template('rezerviraj.html', napaka=None)

@post('/uporabnik/rezerviraj')
def rezerviraj_post():
    predmet = request.forms.predmet
    #print(predmet)
    datum = request.forms.datum
    cur = baza.cursor()
    if predmet != '':
        cur.execute("SELECT instruktor,predmet,lokacija,datum,ura FROM termin WHERE predmet='{0}'".format(predmet))
    else:
        cur.execute("SELECT instruktor,predmet,lokacija,datum,ura FROM termin WHERE stranka IS NULL")
    return template('prosti_termini.html', podatki=cur)

#_________________________________________________________________________________________________
# STRANI INŠTRUKTORJA

@get('/instruktor') 
def instruktor():
    return 'Prijavljen kot instruktor.'



######################################################################
# Glavni program

# priklopimo se na bazo
baza = psycopg2.connect(database=auth.db, host=auth.host, user=auth.user, password=auth.password, port=DB_PORT)
#conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT) # onemogočimo transakcije
cur = baza.cursor(cursor_factory=psycopg2.extras.DictCursor)

# poženemo strežnik na podanih vratih, npr. http://localhost:8080/
if __name__ == "__main__":
    run(host='localhost', port=SERVER_PORT, reloader=RELOADER)

