#!/usr/bin/env luajit
-- pipe_caesar.lua
require "ccrypt"
local getopt = require"posix.unistd".getopt

local alphabet,filter,english,german,decrypt="abcdefghiklmnopqrstuvwxyz",true,false,false,false
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
			.."-a	alphabet (%s) (%d)\n"
			.."-d	decrypt\n\n"
			.."	Example:\n	echo \"Der Agent heißt Jörg, und er ist 23 Jahre alt.\"| \\\n	./reduce.lua -r25|./bifid.lua -aSMBKUTHDOYLQFNZWRPEXCGVAI -g \\\n	|block|./bifid.lua -a SMBKUTHDOYLQFNZWRPEXCGVAI -g  -d|block\nDERAG ENTHE ISZTI OERGY UNDER\nISTZW EIDRE IIAHR EALTX \n",
			arg[0], filter, english, german, alphabet, #alphabet, decrypt)
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
--calculate the conversion table size
local square=math.sqrt(#alphabet)
local cipher
-- convert text to number pairs
local function text2numbers(text, alphabet)
	local cy,cx={},{}
	for c in text:gmatch("["..alphabet.."]") do
		local pos=alphabet:find(c)
		if pos then
			cy[#cy+1]=math.floor((pos-1)/square)+1
			cx[#cx+1]=(pos-1)%square+1
		end
	end
	return table.concat(cy)..table.concat(cx)
end
-- back to characters in pairs y/x
local function numbers2text(cipher, alphabet)
	tmp={}
	for y,x in cipher:gmatch("(%d)(%d)") do
		local pos=tonumber(y-1)*square+tonumber(x)
		tmp[#tmp+1]=alphabet:sub(pos, pos)
	end
	return table.concat(tmp)
end
-- unshuffle numbers
local function unshuffle(cipher)
	local tmp={}
	local len2=math.floor(#cipher/2)
	for i=1,len2 do
		tmp[#tmp+1]=cipher:sub(i,i)
		tmp[#tmp+1]=cipher:sub(i+len2,i+len2)
	end
	cipher=table.concat(tmp)
	tmp={}
	for i=1,len2 do
		tmp[#tmp+1]=cipher:sub(i,i)
		tmp[#tmp+1]=cipher:sub(i+len2, i+len2)
	end
	return table.concat(tmp)
end

cipher=text2numbers(text, alphabet)
if decrypt then cipher=unshuffle(cipher) end
text=numbers2text(cipher, alphabet)
io.write(text) -- verschlüsselter Text
