-- mono_20letter.lua
require "ccrypt"
local text=[[ER STAND AUF SEINES DACHES ZINNEN,
ER SCHAUTE MIT VERGNÜGTEN SINNEN 
AUF DAS BEHERRSCHTE SAMOS HIN. 
«DIES ALLES IST MIR UNTERTÄNIG»,
BEGANN ER ZU ÄGYPTENS KÖNIG, 
«GESTEHE, DASS ICH GLÜCKLICH BIN.»
]]
local alphabet="ABCDEFGHIJKLMNOPQRSTUVYZ"
local   cipher="ABCDEFGHIICLMNOPQRSTVVIZ"
local enc_key=alphabet:subst_table(cipher) -- default key=0
enc_key.X="CS" enc_key.ß="SZ" enc_key.W="VV"
enc_key.Ä="AE" enc_key.Ö="OE" enc_key.Ü="UE"
local encrypted=text:substitute(enc_key)
print(encrypted) 
