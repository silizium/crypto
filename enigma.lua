#!/usr/bin/env luajit
require 'ccrypt'

-- Objektorientierte Lösung
-- Rad Objekt
local Rad={}
Rad.__index = Rad
setmetatable(Rad, {
  __call = function (cls, ...)
    return cls.new(...)
  end,})
function Rad.new(stellung, ring, coding)	-- Argument "A", "1" zum Beispiel
	local self=setmetatable({}, Rad)
	self.rad={
--       ABCDEFGHIJKLMNOPQRSTUVWXYZ
		"EKMFLGDQVZNTOWYHXUSPAIBRCJ",		-- Rotor 1
		"AJDKSIRUXBLHWTMCQGZNPYFVOE",		-- Rotor 2
		"BDFHJLCPRTXVZNYEIWGAKMUSQO",		-- Rotor 3
		"ESOVPZJAYQUIRHXLNFTGKDCMWB",		-- Rotor 4
		"VZBRGITYUPSDNHLXAWMJQOFECK",		-- Rotor 5
		"JPGVOUMFYQBENHZRDKASXLICTW",		-- Rotor 6
		"NZJHGRCXMYSWBOUFAIVLPEKQDT",		-- Rotor 7
		"FKQHTLXOCBJSPDZRAMEWNIUYGV",		-- Rotor 8
		["B"]="LEYJVCNIXWPBQMDRTAKZGFUHOS", -- Rotor "beta"
		["G"]="FSOKANUERHMBTIYCWLQPZXVGJD", -- Rtoor "gamma"
	}
	self.knocktab={
		-- Royal Flags Wave Kings Above (3xAN)
		{18},{6},{23},{11},{1},{1,14},{1,14},{1,14}
	}
	self:set(stellung) -- Buchstaben->1-26
	self:setring(ring) -- Ringstellung->0-25 (subtrahiert)
	self.coding=self.rad[coding] or coding
	self.knock=self.knocktab[tonumber(coding)] or {}
	return self
end
function Rad:setring(ring)
	self.ring=string.byte(ring)-string.byte("A")
end
function Rad:set(stellung)
	self.stellung=string.byte(stellung)-string.byte("A")+1
end
function Rad:get()
	return string.char(self.stellung+string.byte("A")-1)
end
function Rad:step(step)
	self.stellung=self.stellung+step
	if self.stellung > #self.coding then 
		self.stellung=self.stellung-#self.coding
	elseif self.stellung < 1 then
		self.stellung=self.stellung+#self.coding
	end
	for i=1,#self.knock do
		if self.stellung==self.knock[i] then
			return step,self.stellung
		end
	end
	return 0,self.stellung
end
function Rad:crypt(char)
	local pos=self.stellung-self.ring+string.byte(char)-string.byte("A")
	if pos>#self.coding then
		pos=pos-#self.coding
	elseif pos<1 then
		pos=pos+#self.coding
	end
	char=self.coding:sub(pos,pos)
	pos=string.byte(char)-self.stellung+self.ring+1
	if pos>string.byte("Z") then
		pos=pos-26
	elseif pos<string.byte("A") then
		pos=pos+26
	end
	return string.char(pos)
end
function Rad:rcrypt(char)
	char=string.byte(char)+self.stellung-self.ring-1
	if char<string.byte("A") then 
		char=char+26
	elseif char>string.byte("Z") then
		char=char-26
	end
	pos=self.coding:find(string.char(char))-self.stellung+self.ring+string.byte("A")
	if pos<string.byte("A") then
		pos=pos+26
	elseif pos>string.byte("Z") then
		pos=pos-26
	end
	return string.char(pos)
end

-- Enigma Objekt
local Enigma={}
Enigma.__index = Enigma
setmetatable(Enigma, {
  __call = function (cls, ...)
    return cls.new(...)
  end,})
function Enigma.new(password, options)
	local self=setmetatable({}, Enigma)
	self.ukwset={
		buildsubst("AE-BJ-CM-DZ-FL-GY-HX-IV-KW-NR-OQ-PU-ST"), -- alt, selten verwendet
		buildsubst("AY-BR-CU-DH-EQ-FS-GL-IP-JX-KN-MO-TZ-VW"), -- M3 B
		buildsubst("AF-BV-CP-DJ-EI-GO-HY-KR-LZ-MX-NW-QT-SU"), -- M3 C
		buildsubst("AE-BN-CK-DQ-FU-GY-HW-IJ-LO-MP-RX-SZ-TV"), -- M4 dünn B
		buildsubst("AR-BD-CO-EJ-FN-GT-HK-IV-LM-PW-QZ-SX-UY"), -- M5 dünn C
		buildsubst("AQ-BY-CH-DO-EG-FN-IV-JP-KU-LZ-MT-RX-SW"), -- Reichsbahn
		buildsubst("AI-BM-CE-DT-FG-HR-JY-KS-LQ-NZ-OX-PW-UV"), -- Schweizer
		buildsubst("AR-BU-CL-DQ-EM-FZ-GJ-HS-IY-KO-NT-PW-VX"), -- Abwehr
	}
	self.statorset={
		"ABCDEFGHIJKLMNOPQRSTUVWXYZ",	-- Standard
		"QWERTZUIOASDFGHJKPYXCVBNML",	-- Reichsbahn+Schweizer+Abwehr
		"JWULCMNOHPQZYXIRADKEGVBTSF",	-- Enigma D
	}
	self.verbose=options
	self.rad={}
	password=password:upper()
	local spruch,ring,ukw,walzen,stator,steck=password:match("(%u-),(%u-),(%u),(%w-),(%d),(.*)")
	if not(spruch and ring and stator and walzen and ukw and steck) then help()	end

	-- DEBUG
	if self.verbose then io.stderr:write("Stellung: ",spruch," Ring: ",ring," UKW: ",ukw," Walzen: ",walzen," Stator: ",stator, " Stecker: ", steck, "\n") end
	-- END DEBUG
	
	for i=1,#spruch do
		walze=walzen:sub(i,i)
		walze=tonumber(walze) or walze
		self.rad[i]=Rad.new(spruch:sub(i,i),ring:sub(i,i),walze)
	end
	self.stator=Rad.new("A","A",self.statorset[tonumber(stator)])
	self.ukw=tonumber(string.byte(ukw)-string.byte("A")+1)
	self.steck=buildsubst(steck)
	self.doublestep=false
	return self
end
function help()
		io.stderr:write("use: enigma.lua <spruch>,<ring>,<ukw>,<walzen>,<stator>,<steck>\n"..
			"\texample: enigma.lua AAA,AAA,B,123,1,AE-FC-WI\n"..
			"\t  UKW A=old,B=M3B, C=M3C, D=M4B, E=M4C, Reichsbahn, Schweiz, Abwehr\n"..
			"\t  Walzen 1-8 B=beta G=Gamma\n"..
			"\t  Stator 1=standard, 2=Reichsbahn, Schweiz, Abwehr, 3=Enigma D\n"..
			"\t  Stecker in form AE-OU-CH etc.\n")
		os.exit()
end
function buildsubst(code)
	-- "DE-HA-GI" -> {D="E", E="D", H="A", A="H", G="I", I="G"}
	local steck={}
	for c in ("ABCDEFGHIJKLMNOPQRSTUVWXYZ"):gmatch("%u") do
		steck[c]=c
	end
	for c1,c2 in code:gmatch("(%u)(%u)") do
		steck[c1]=c2
		steck[c2]=c1
	end
	return steck
end
function Enigma:crypt(char)
	-- weiterschalten
	local step=1
	for i=#self.rad,#self.rad-2,-1 do
		if i==#self.rad-1 then
			for _,k in ipairs(self.rad[i].knock) do
				local nextstop=self.rad[i].stellung+1
				if nextstop>#self.rad[i].coding then 
					nextstop=nextstop-#self.rad[i].coding 
				end
				if k == nextstop then
					step=1
				end
			end
		end
		step=self.rad[i]:step(step)
	end

if self.verbose then 
	for i=1,#self.rad do
		io.stderr:write(self.rad[i]:get())
	end
	io.stderr:write("=",char,":") 
end
	-- Steckbrett
	char=self.steck[char]
if self.verbose then io.stderr:write(char) end
	-- Stator
	char=self.stator:crypt(char)
if self.verbose then io.stderr:write(char) end
	-- Hinweg
	for i=#self.rad,1,-1 do
		char=self.rad[i]:crypt(char)
if self.verbose then io.stderr:write(",R",i,"=",char) end
	end
	-- Reflektor
	char=self.ukwset[self.ukw][char]
if self.verbose then io.stderr:write(",UKW=",char) end
	-- Rückweg
	for i=1,#self.rad do
		char=self.rad[i]:rcrypt(char)
if self.verbose then io.stderr:write(",R",i,"=",char) end
	end
	-- Stator -1
	char=self.stator:rcrypt(char)
if self.verbose then io.stderr:write(char) end
	-- Steckbrett die zweite
	char=self.steck[char]
if self.verbose then io.stderr:write(char,"\n") end
	return char
end

-- Aufruf der Enigma Routinen
if arg[1]=="--help" then help() end
local key,decrypt,english,verbose="AAA,AAA,B,123,1,",false,false,false
for i=1,#arg do
	if arg[i]=="-d" then
		decrypt=true
	elseif arg[i]=="-e" then
		english=true
	elseif arg[i]=="-v" then
		verbose=true
	else
		key=arg[i]
	end
end

local text=io.read("*a")
text=text:clean(english)
local enigma = Enigma.new(key, verbose)
for i=1,#text do
	io.write(enigma:crypt(text:sub(i,i)))
end
