-- caesar_uebung3.lua
function caesar(text, key)
	local A=("A"):byte() -- A=65
	local cipher=""
	for i=1,#text do
		local c=(text:byte(i)-A+key)%26
		c=c+A   -- 0…25 -> 65…90 (ASCII)
		cipher=cipher..string.char(c)
	end
	return cipher
end

local text="DERSCHATZLIEGTIMSILBERSEE"
print(text)
--[[ key 13, A->N N->A heißt "invultorisch"
also umkehrbar. Alle anderen Schlüssel sind nicht 
umkehrbar, abgesehen vom Null-Schlüssel 0, der 
den unverschlüsselten Originaltext erhält z.B.
key=1 A->B aber B->C wir müssten hier key=-1
nehmen. 
]]
local key=13 -- Variablen nur einmal deklarieren!
local encrypt=caesar(text, key) 
print(encrypt)
local decrypt=caesar(encrypt, key)
print(decrypt)
-- nicht invultorischer Schlüssel
print("Nicht invultorisch")
key=1        -- nicht mehr deklariert!
print(text)
encrypt=caesar(text, key)
print(encrypt)
decrypt=caesar(encrypt, key)
print(decrypt)
print("Aber mit -key")
decrypt=caesar(encrypt, -key)
print(decrypt)
