#!/usr/bin/env luajit
-- pipe_caesar.lua
require "ccrypt"
local getopt = require"posix.unistd".getopt
-- Aufruf mit pipe_caesar <key>
-- oder -key für Entschlüsselung
local alphabet,filter,english,german,decrypt="abcdefghiklmnopqrstuvwxyz",true,false,false,false
local file="otp-codes/alpha_donotuse.txt"
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Bifid cipher (CC)2025 H.Behrens DL7HH\n"
			.."use: %s\n"
			.."-h	print this help text\n"
			.."-f	filter (%s)	filter unknown characters\n"
			.."-e	english (%s)	translates numbers to English\n"
			.."-g	german (%s)	translates numbers to German\n"
			.."-a	alphabet (%s)\n"
			.."-d	decrypt\n",
			arg[0], filter, english, german, alphabet, decrypt)
		)	
		os.exit(EXIT_FAILURE)
	end,
	["f"]=function(optarg, optind)
		filter=not filter
	end,
	["e"]=function(optarg, optind)
		english=not english
	end,
	["g"]=function(optarg, optind)
		german=not german
	end,
	["a"]=function(optarg, optind)
		alphabet=optarg:upper():remove_doublets()
		if not (#alphabet == 25 or #alphabet ==36) then 
			error("***FAILURE -a: alphabet has to be 25 or 36 characters in size, but has "..#alphabet.." - "..alphabet)
		end
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
for r, optarg, optind in getopt(arg, "a:egfdh") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end

local text=io.read("*a") -- STDIN einlesen
-- wir wandeln erstmal unseren Text in Großbuchstaben
text=text:umlauts():upper()
if english then	text=text:clean("english") end
if german then text=text:clean() end
alphabet=alphabet:upper()
if filter then text=text:gsub("[^"..alphabet.."]", "") end
--build the conversion table
local square=math.sqrt(#alphabet)
local cipher, cy, cx={},{},{}
for c in text:gmatch("["..alphabet.."]") do
	local pos=alphabet:find(c)
	if pos then
		cy[#cy+1]=math.floor((pos-1)/square)+1
		cx[#cx+1]=(pos-1)%square+1
	end
end
cipher=table.concat(cy)..table.concat(cx)
if decrypt then
	local tmp={}
	cipher=table.concat(cy)..table.concat(cx)
	for i=1,#cy do
		tmp[#tmp+1]=cipher:sub(i,i)
		tmp[#tmp+1]=cipher:sub(i+#cy,i+#cy)
	end
	cipher=table.concat(tmp)
	tmp={}
	local to=math.floor(#cipher/2) 
	for i=1,to do
		tmp[#tmp+1]=cipher:sub(i,i)
		tmp[#tmp+1]=cipher:sub(i+to, i+to)
	end
	cipher=table.concat(tmp)
end
-- back to characters in pairs y/x
citmp={}
for y,x in cipher:gmatch("(%d)(%d)") do
	local pos=tonumber(y-1)*square+tonumber(x)
	citmp[#citmp+1]=alphabet:sub(pos, pos)
end
text=table.concat(citmp)
io.write(text) -- verschlüsselter Text
