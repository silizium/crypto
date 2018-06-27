#!/usr/bin/env luajit
require 'dec2bin'
local bor=bit.bor

-- Holt die Bits von den Rad-Table
function rad(tab,i)
	return tab[(i-1)%#tab+1]
end

-- Fasst alle Bits einer fünfer Gruppe zusammen
function radG(t1, t2, t3, t4, t5, i)
	local e1=rad(t1,i)
	local e2=rad(t2,i)
	local e3=rad(t3,i)
	local e4=rad(t4,i)
	local e5=rad(t5,i)
	return e1*16+e2*8+e3*4+e4*2+e5
end

-- Stellt klar, ob die erste fünfer Gruppe fortgeschaltet wird
function motor(t7,i1) 
	return rad(t7,i1) 
end

local rad1 ={0,0,0,1,1, 1,0,0,1,1, 1,0,1,1,0, 0,1,0,1,0, 1,1,0,1,1, 0,1,0,0,1, 0,0,1,0,1, 0,1,0,1,0, 1,0,0,}
local rad2 ={1,1,0,1,0, 0,1,1,1,0, 0,0,0,0,1, 1,1,1,0,1, 0,0,1,0,1, 1,0,0,1,1, 0,1,0,1,0, 1,0,1,0,1, 0,1,1,0,1, 0,0,}
local rad3 ={1,0,0,1,0, 0,1,1,0,1, 1,1,0,0,0, 1,1,1,0,0, 0,0,1,1,1, 1,0,1,0,1, 0,1,1,0,0, 1,0,0,1,0, 1,0,1,0,1, 0,1,0,1,0, 1,}
local rad4 ={0,1,0,0,0, 0,1,0,0,1, 0,1,1,1,1, 1,0,1,1,0, 0,1,1,0,0, 1,1,0,0,0, 0,1,0,1,1, 0,1,0,1,0, 1,0,1,0,1, 0,1,1,0,0, 1,0,1,}
local rad5 ={1,0,1,0,1, 0,0,1,1,0, 0,1,1,0,1, 1,0,0,1,0, 0,0,1,0,0, 0,0,1,0,1, 1,0,1,1,1, 1,0,1,1,1, 0,0,1,0,1, 0,0,0,1,1, 0,1,0,1,0, 1,0,1,0,}

local rad6 ={0,1,0,1,0, 1,0,1,0,1, 0,1,0,1,0, 1,1,1,0,1, 0,1,0,0,1, 0,1,0,1,0, 1,0,1,1,1, 0,1}
local rad7 ={1,0,0,0,0, 1,1,0,0,0, 1,1,0,0,1, 1,0,1,1,1, 1,0,0,0,0, 1,1,0,0,0, 1,1,0,1,1, 0,1,0,1,1, 1,1,0,0,0, 1,1,0,0,1, 1,0,0,1,1, 0,1,0,1,1, 1,}

local rad8 ={0,1,1,1,1, 0,1,0,1,1, 0,1,0,1,1, 0,0,1,0,0, 1,1,0,1,0, 0,0,0,1,1, 0,0,0,0,1, 1,1,1,0,0, 0,}
local rad9 ={0,1,1,1,0, 0,0,0,1,0, 0,0,1,1,0, 1,0,1,0,0, 0,1,1,0,1, 1,1,0,0,1, 1,}
local rad10={1,1,0,0,1, 1,0,1,1,0, 0,1,1,1,0, 0,0,0,1,0, 0,1,1,0,1, 1,1,0,0,}
local rad11={1,1,1,1,0, 0,1,0,0,1, 1,0,0,1,0, 0,1,1,0,1, 0,0,1,1,0, 0,}
local rad12={0,1,1,1,0, 1,1,1,0,0, 0,1,0,0,1, 1,0,1,0,0, 0,1,0,}

local text=io.read("*a")

local i2=1
local i6=1
for i1=1,#text do
	local char=text:byte(i1)
	local rnd1=radG(rad8,rad9,rad10,rad11,rad12,2-i1)
	local rnd2=radG(rad1,rad2,rad3,rad4,rad5,i2)
	local crypt=bit.bxor(char,rnd1,rnd2)
	-- ***TEST print(dec2bin(char,5), dec2bin(rnd2, 5), dec2bin(rnd1, 5), dec2bin(crypt, 5), i2, i6, 2-i1, rad(rad6, i6), rad(rad7, 2-i1), bor(rad(rad6,i6), rad(rad7, 2-i1)))
	io.write(string.char(crypt))
-- Fortschaltung von Rad6 auf ersten Gruppenrad
	i2=i2-bor(rad(rad6,i6),1-rad(rad7,2-i1))
	i6=i6-motor(rad7,2-i1)
end
-- Made by Torben & Thu (with the help of Hanno Behrens)
