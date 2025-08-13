#!/usr/bin/env luajit
-- pipe_caesar.lua
require "ccrypt"
local getopt = require"posix.unistd".getopt
require"DataDumper" dump=function(...) print(DataDumper(...).."\n---") end
local function printf(fmt, ...) io.stderr:write(string.format(fmt,...)) end

local alphabet,block,lang,decr="ABCDEFGHIJKLMNOPQRSTUVWXYZ+",5,false,false
local key=alphabet
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Trifid cipher (CC)2025 H.Behrens DL7HH\n"
			.."\ta French cipher from Félix Delastelle from 1902\n"
			.."use: %s\n"
			.."-h	print this help text\n"
			.."-l	language (%s) translates numbers to english, german, french\n"
			.."-a	alphabet (%s) (%d)\n"
			.."-b	blocksize (%d)\n"
			.."-d	decrypt\n\n"
			.."	Example:\n	echo \"aide-toi, le ciel t'aidera\"| \\\n\t./trifid.lua -a felixmariedelastelle |(tee|block 4) >/dev/stderr |\\\n\t./trifid.lua -a felixmariedelastelle -d|block 4\b",
			arg[0], lang, key, #alphabet, block, decrypt)
		)	
		os.exit(EXIT_FAILURE)
	end,
	["l"]=function(optarg, optind)
		lang=optarg:lower()
	end,
	["a"]=function(optarg, optind)
		key=(optarg..alphabet):upper():remove_doublets()
		if #key ~= 27  then 
			error("***FAILURE -a: alphabet has to be 27 in size, but has "..#key.." - "..key)
		end
	end,
	["b"]=function(optarg, optind)
		block=tonumber(optarg)
		if block%3==0  then 
			error("***FAILURE -b: blocksize is not coprime to 3: "..block)
		end
	end,
	["d"]=function(optarg, optind)
		decr=true
	end,
	["?"]=function(optarg, optind)
		io.stderr:write(string.format("unrecognized option %s\n", arg[optind -1]))
		return true
	end,
}
-- quickly process options
for r, optarg, optind in getopt(arg, "a:l:b:dh") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end

local text=io.read("*a") -- STDIN einlesen
-- wir wandeln erstmal unseren Text in Großbuchstaben
text=text:umlauts():upper()
if lang then text=text:clean(lang) end
key=key:upper()
text=text:gsub("[^"..key.."]", "") -- filter all non valid chars out 
--calculate the conversion table size
local cipher
-- convert text to number pairs
local function tables(key)
	local enc, dec={},{}
	local i=0
	for c in key:gmatch("["..key.."]") do
		local s1=math.floor(i/9)+1
		local s2=math.floor(i%9/3)+1
		local s3=math.floor(i%3)+1
		local tri=tonumber(s1)..tonumber(s2)..tonumber(s3)
		enc[c]=tri
		dec[tri]=c
		i=i+1
	end
	return enc, dec
end
local function encode(text,enc)
	local cipher=text:gsub("["..key.."]",enc)
	return cipher
end
local function decode(cipher,dec)
	local text=cipher:gsub("%d%d%d",dec)
	return text
end
local function encrypt(cipher,block)
	local res={}
	for i=1,#cipher,block*3 do
		local l1,l2,l3={},{},{}
		local part=cipher:sub(i,i+block*3-1)
		for c1,c2,c3 in part:gmatch("(%d)(%d)(%d)") do
			l1[#l1+1]=c1
			l2[#l2+1]=c2
			l3[#l3+1]=c3
		end
		res[#res+1]=table.concat(l1)..table.concat(l2)..table.concat(l3)
	end
	return table.concat(res)
end
local function decrypt(cipher,block)
	-- org:131 121 133 112 212.311121113112221.121112113212131.121133112132131
	-- enc:111 123 231 111 322.311121211211321.111212111312321.111112313313221
	local res={}
	for i=1,#cipher,block*3 do
		local l={}
		for i=1,block do l[i]={} end
		local part=cipher:sub(i,i+block*3-1)
		local i=0
		for c in part:gmatch("(%d)") do
			local mod=i%(#part/3)+1
			l[mod][#l[mod]+1]=c
			i=i+1
		end
		for i=1,block do
			res[#res+1]=table.concat(l[i])
		end
	end
	return table.concat(res)
end

local enc,dec=tables(key)
local cipher=encode(text,enc,key)
if not decr then
	cipher=encrypt(cipher,block)
else
	cipher=decrypt(cipher,block)
end
text=decode(cipher,dec)
io.write(text) -- verschlüsselter Text
