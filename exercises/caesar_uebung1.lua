-- caesar_uebung1.lua
text="DERSCHATZLIEGTIMSILBERSEE"
-- wandle das erste Zeichen des Strings
print("1:", string.byte(text, 1))
-- diese Formulierung tut das selbe, aber einfacher
print("2:", text:byte(1))
--[[ in einer Schleife kriegen wir alle	die for-Schleife läuft 
von 1 bis zur Länge des Strings #text, wir benutzen hier 
io.write(), was	das selbe wie print() ist, aber ohne
Zeilenvorschübe]]
io.write("3:\t")
for i=1,#text do
	io.write(text:byte(i), " ")
end
print()
-- wir wandeln ASCII in A=0, B=1… Z=25
io.write("4:\t")
local A=("A"):byte() -- A=65
for i=1,#text do
	io.write(text:byte(i)-A, " ")
end
print()
-- wir addieren unseren Schlüssel
io.write("5:\t")
local key=13
for i=1,#text do
	io.write(text:byte(i)-A+key, " ")
end
print()
--[[ um die Werte "umzuklappen" benutzt man in der Regel die 
"Modulo" Operation, das ist der Rest einer Division z.B. 
10%3 -> 1 (10/3=3 Rest 1) Ein x%26 klappt die Werte also immer
auf 0…25
]]
io.write("6:\t")
for i=1,#text do
	io.write((text:byte(i)-A+key)%26, " ")
end
print()
