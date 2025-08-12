#!/usr/bin/env luajit
require 'ccrypt'
local getopt = require"posix.unistd".getopt

local key,decrypt,lang="PLAYFAIR",false,false

local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Playfair cipher (CC)2025 H.Behrens DL7HH\n"
			.."use: %s\n"
			.."-h	print this help text\n"
			.."-l	language (%s) translates numbers to language\n"
			.."-k	key (%s) (%d)\n"
			.."-d	decrypt\n\n",
			arg[0], lang, key, #key,
			decrypt)
		)	
		os.exit(EXIT_FAILURE)
	end,
	["l"]=function(optarg, optind)
		lang=optarg:lower()
	end,
	["k"]=function(optarg, optind)
		key=optarg:upper():remove_doublets()
	end,
	["d"]=function(optarg, optind)
		decrypt=true
	end,
	["?"]=function(optarg, optind)
		io.stderr:write(string.format("unrecognized option %s\n", arg[optind -1]))
		return true
	end,
}
-- quickly process options
for r, optarg, optind in getopt(arg, "k:l:dh") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end



-- Objektorientierte Lösung
local Playfair={}
Playfair.__index = Playfair
local floor=math.floor

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
	if not pos then error("*** FAILURE: unknown character: "..char) end
	return (pos-1)%5+1, floor((pos-1)/5)+1
end

function Playfair.new(password, lang)
	local self=setmetatable({}, Playfair)
	password=password:clean(lang)
	self.pass=self:init(password)
	return self
end

function Playfair.encode(self, text, decode, lang)
	text=text:clean(lang)
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
	return table.concat(cipher)
end

-- Aufruf der Playfair Routinen

local text=io.read("*a"):upper():clean():filter()

pf = Playfair.new(key, lang)
print(pf:encode(text, decrypt, lang))
