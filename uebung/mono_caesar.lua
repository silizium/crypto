#!/usr/bin/env luajit
-- mono_caesar.lua
require "ccrypt"

local text=[[Er stand auf seines Daches Zinnen,
Er schaute mit vergnügten Sinnen 
Auf das beherrschte Samos hin. 
«Dies alles ist mir untertänig»,
Begann er zu Ägyptens König, 
«Gestehe, dass ich glücklich bin.»
]]
local alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜß"
local key=13
-- wir wandeln erstmal unseren Text in Großbuchstaben
text=text:upper()
--[[ aber die Sonderzeichen wurden noch nicht gewandelt,
wir wandeln die kleinen Zeichen zu großen also
nur wandeln, nicht verschieben]]
toupper_tab=("äöü"):subst_table("ÄÖÜ")
text=text:substitute(toupper_tab)
print(text) -- Originaltext
print(alphabet, "Key="..key, "\n")
--[[ jetzt verschlüsseln wir ihn mit klassischem Cäsar
wenn wir kein cipher-alphabet angeben, nimmt er das 
]]
local enc_key=alphabet:subst_table(alphabet, key)
local encrypted=text:substitute(enc_key)
print(encrypted) -- verschlüsselter Text
--[[ zum Entschlüsseln kehren wir den key um und tauschen
das Alphabet gegen das Cipheralphabet aus (in diesem Falle ist
es das selbe]]
local dec_key=alphabet:subst_table(alphabet, -key)
local decrypted=encrypted:substitute(dec_key)
print(decrypted) -- entschlüsselter Text
