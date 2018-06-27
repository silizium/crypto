#!/usr/bin/env luajit
-- pipe_caesar.lua
require "ccrypt"

-- cleanup ist nicht Teil der Aufgabe aber so geht's
function string.cleanup(text)
	-- wir wandeln erstmal unseren Text in Großbuchstaben
	text=text:upper()
	-- auch die Sonderzeichen und JV wandeln
	local toupper_tab=("äöüJU"):subst_table("ÄÖÜIV")
	text=text:substitute(toupper_tab)
	-- und jetzt wandeln wir die Sonderzeichen in ASCII
	local enc_key={}
	enc_key.ß="SZ" enc_key.Ä="AE" enc_key.Ö="OE" enc_key.Ü="VE"
	text=text:substitute(enc_key)
	return text
end

function string.trithemius(text, key)
	key = key or 1
	local alphabet = "ABCDEFGHIKLMNOPQRSTVXYZW"
	text=text:cleanup() -- Text säubern für Trithemius
	-- Codetabelle aufbauen
	local code, alpha={}, {}
	for c in alphabet:utf8all() do
		code[c]=#alpha
		alpha[#alpha+1]=c
	end
	-- Ver- und Entschlüsselung
	local cipher={}
	local position=0
	for c in text:utf8all() do
		-- print(c, code[c], key, position,#alpha, cipher[#cipher])
		if code[c] then		-- gültige Zeichen
				-- Verschlüsseln und Entschlüsseln
			cipher[#cipher+1]=alpha[(code[c]+position)%#alpha+1]
		else	-- unbekannten Buchstaben einfach übernehmen
			cipher[#cipher+1]=c
		end
		position=(position+key) -- Position hoch oder runterzählen
	end
	return table.concat(cipher)
end

--[[ Verschlüsseln mit klassischem Trithemius
  Aufruf mit ./trithemius <key>
  	oder -key für Entschlüsselung, default ist 1
]]
local key=arg[1] and tonumber(arg[1]) or 1
local text=io.read("*a") -- STDIN einlesen
io.write(text:trithemius(key)) -- verschlüsselter Text
