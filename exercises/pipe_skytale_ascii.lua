#!/usr/bin/env luajit
function skytale(text, key)
	local tab={}  -- leere Tabelle
	local pos=0
	for i=0,#text-1 do -- von 0 bis #text-1 weil besser mit modulo
		local korrektur=math.floor((key*i)/#text) --das +1 bei Überlauf
		local npos=(pos+korrektur)%#text+1 --Zeichenposition berechnen
		tab[i+1]=text:sub(npos,npos)
		pos=(pos+key)%#text
	end
	return table.concat(tab)
end

local key=arg[1] and tonumber(arg[1]) or 2 -- Gartenzaun
local text=io.read("*a")
if key>#text then key=key%#text end
if key<0 then 
	key=math.floor(#text/-key)
elseif key==0 then 
	key=1
end
text=text..("x"):rep(-(#text%-key))
local enc=skytale(text, key)
io.write(enc)
