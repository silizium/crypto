#!/usr/bin/env luajit
-- pipe_caesar.lua
require "ccrypt"
-- Aufruf mit pipe_caesar <key>
-- oder -key für Entschlüsselung
local key=arg[1] and tonumber(arg[1]) or 13
local text=io.read("*a") -- STDIN einlesen
local alphabet=arg[2]~=null and arg[2] or "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
-- wir wandeln erstmal unseren Text in Großbuchstaben
text=text:clean("english")
-- auch die Sonderzeichen 
local toupper_tab=("äöü"):subst_table("ÄÖÜ")
text=text:substitute(toupper_tab)
-- und jetzt wandeln wir die Sonderzeichen in ASCII
local enc_key={}
enc_key.ß="SZ" enc_key.Ä="AE" enc_key.Ö="OE" enc_key.Ü="UE"
text=text:substitute(enc_key)
--[[ jetzt verschlüsseln wir ihn mit klassischem Cäsar
wenn wir kein cipher-alphabet angeben, nimmt er das 
]]
local enc_key=alphabet:subst_table(alphabet, key)
local encrypted=text:substitute(enc_key)
io.write(encrypted) -- verschlüsselter Text
