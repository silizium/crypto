-- zahlensysteme_uebung1.lua
-- Zahlensysteme in Lua
a=0xaa
b=192
c=11
print(a, b, c)
-- wir können die Ausgabe formatieren
print(string.format("%02X %02X %02X", a, b, c))
print(string.format("%x %x %x", a, b, c))