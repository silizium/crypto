#!/usr/bin/env luajit
require 'ccrypt'

local floor,ceil=math.floor, math.ceil

function skytale(text, key)
	local tab={}  -- leere Tabelle
	local pos=0
	local input={}
	for c in text:utf8all() do
		input[#input+1]=c
	end
	-- Berechnen des Komplementär-Keys, Sicherheit
	if key>#input then key=key%#input end
	if key<0 then 
		key=ceil(#input/-key)
	elseif key==0 then 
		key=1
	end
	-- Auffüllen auf teilbar 
	--for i=1,-(#input%-key) do input[#input+1]=input[#input] end
	-- Matrix-Umordnung
	local x,y=0,0
	for x=0,key-1 do
		for y=0,floor(#input/key)*key,key do
			if input[x+y+1] then tab[#tab+1]=input[x+y+1] end
		end
	end
	return table.concat(tab)
end

local key=arg[1] and tonumber(arg[1]) or 2 -- Gartenzaun
local text=io.read("*a")
local enc=skytale(text, key)
io.write(enc)
