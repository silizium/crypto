#!/usr/bin/env luajit
require 'ccrypt'
-- Objektorientierte Lösung
local Playfair={}
Playfair.__index = Playfair
local floor=math.floor

-- cleanup ist nicht Teil der Aufgabe aber so geht's
function Playfair.clean(self, text)
        -- wir wandeln erstmal unseren Text in Großbuchstaben
        text=text:upper()
        -- auch die Sonderzeichen und J wandeln
        local toupper_tab=("äöüJ"):subst_table("ÄÖÜI")
        text=text:substitute(toupper_tab)
        -- und jetzt wandeln wir die Sonderzeichen in ASCII
        local enc_key={
			["0"]="NULL",["1"]="EINS",["2"]="ZWEI",["3"]="DREI",["4"]="VIER",
			["5"]="FUENF",["6"]="SECHS",["7"]="SIEBEN",["8"]="ACHT",["9"]="NEUN",
			["ß"]="SZ",["Ä"]="AE",["Ö"]="OE",["Ü"]="UE"}
        text=text:substitute(enc_key)
		text=text:gsub("[%c%s%p]+", "") -- alles außer normale Zeichen weglöschen
        return text
end

function Playfair.init(self, pass)
	self.alpha="ABCDEFGHIKLMNOPQRSTUVWXYZ"
	self.table, self.rtable={},{}	-- table k,v und reverse table v,k
	local set={}					-- merken, ob schon Buchstaben benutzt wurden
	-- table aufbauen, erst das Passwort, Zeichen, die schon vorhanden ignorieren
	for c in pass:utf8all() do
		if not set[c] then
			set[c]=true
			self.table[#self.table+1]=c
		end
	end
	-- dann den Rest der Buchstaben, auslassen vorhandener Zeichen
	for c in self.alpha:utf8all() do
		if not set[c] then
			set[c]=true
			self.table[#self.table+1]=c
		end
	end
	-- reverse table aufbauen
	for k,v in ipairs(self.table) do
		self.rtable[v]=k
	end
	return table.concat(self.table)
end

function Playfair.char(self,x,y)
	return self.table[x+5*(y-1)]
end

function Playfair.xy(self, char)
	local pos=self.rtable[char]
	-- return x,y
	return (pos-1)%5+1, floor((pos-1)/5)+1
end

function Playfair.new(password)
	local self=setmetatable({}, Playfair)
	password=self:clean(password)
	self.pass=self:init(password)
	return self
end

function Playfair.encode(self, text, decode)
	text=self:clean(text)
	-- auffüllen auf gerade mit zufälligem Zeichen
	if #text%2 ~= 0 then
		math.randomseed(os.time()*os.clock())
		local rnd=math.random(#self.pass)
		text=text..self.pass:sub(rnd,rnd)
	end

	local cipher={}
	for pos=1,#text,2 do  -- für alle Zeichenpaare
		-- die nächsten beiden Chars aus dem Text holen
		local c1=text:sub(pos,pos)
		local c2=text:sub(pos+1, pos+1)
		local x1,y1=self:xy(c1)
		local x2,y2=self:xy(c2)
		if x1~=x2 and y1~=y2 then  	-- Quadratsituation
			c1=self:char(x2,y1)
			c2=self:char(x1,y2)
		elseif x1==x2 then			-- selbe Spalte
			if not decode then
				c1=self:char(x1,y1%5+1)
				c2=self:char(x2,y2%5+1)
			else
				c1=self:char(x1,(y1-2)%5+1)
				c2=self:char(x2,(y2-2)%5+1)
			end
		else						-- selbe Zeile
			if not decode then
				c1=self:char(x1%5+1,y1)
				c2=self:char(x2%5+1,y2)
			else
				c1=self:char((x1-2)%5+1,y1)
				c2=self:char((x2-2)%5+1,y2)
			end
		end
		cipher[#cipher+1]=c1
		cipher[#cipher+1]=c2
	end
	--[[
	for y=1,5 do
		for x=1,5 do
			io.write(self:char(x,y))
		end
		print()
	end
	print(text)
	--[[
	for c in self.pass:utf8all() do
		print(self:xy(c))
	end ]]
	return table.concat(cipher)
end

-- Aufruf der Playfair Routinen
local pass=arg[1] or "PLAYFAIR"
local decode=(arg[2] ~= nil) -- wenn 2tes Argument dekodieren

local text=io.read("*a")

pf = Playfair.new(pass)
print(pf:encode(text, decode))
