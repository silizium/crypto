#!/usr/bin/env luajit
require "ccrypt"
local getopt = require"posix.unistd".getopt

function vigenere_make(password, alphabet)
	local t={}
	for c in password:gmatch("%w") do
		local from, to=alphabet:find(c)
		t[#t+1]=alphabet:sub(from,-1)..alphabet:sub(1,from-1)
	end
	return t
end

function string.vigenere_encrypt(text,password,alphabet,inc)
	local v,t={}
	t=vigenere_make(password,alphabet)
	-- encode vigenere
	local r,i,nr=0,0,0
	for c in text:gmatch(".") do
		local from,to=alphabet:find(c)
		if from then 
			nr=nr+1
			from=(from+i-1)%#alphabet+1
			v[#v+1]=t[r+1]:sub(from,from) 
			r=(r+1)%#password
			for _,move in ipairs(inc) do
				if nr>move.offset and (nr-move.offset)%move.step==0 then
					i=i+move.increment
				end
			end
		else 
			v[#v+1]=c
		end
	end
	return table.concat(v)
end

function string.vigenere_decrypt(text,password,alphabet,inc)
	local v,t={}
	t=vigenere_make(password,alphabet)
	-- decode vigenere
	local r,i,nr=0,0,0
	for c in text:gmatch(".") do
		local from,to=t[r+1]:find(c)
		if from then
			nr=nr+1
			from=(from+i-1)%#alphabet+1
			v[#v+1]=alphabet:sub(from,from)
			r=(r+1)%#password
			for _,move in ipairs(inc) do
				if nr>move.offset and (nr-move.offset)%move.step==0 then
					i=i-move.increment
				end
			end
		else
			v[#v+1]=c
		end
	end
	return table.concat(v)
end

local alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
local password,decrypt,randomize,clean,inc="SECRET",false,false,true,{}
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Vigenere cipher (CC)2023 H.Behrens DL7HH\n"
			.."use: %s\n"
			.."-h	print this help text\n"
			.."-a	alphabet (%s) \n\taccepts all non spaces\n"
			.."-p	password (%s) \n\taccepts all that are in alphabet\n"
			.."-r	randomize (%s) \n\taccepts \"time\" or seed number\n"
			.."-c	not clean text from non alphabet characters\n"
			.."-i	increment after each step <nr>s<steps>o<off>[,more]\n"
			.."\tincrement nr amount after steps starting with offset\n"
			.."\texample 1=every time 2s3 every thirt step by 2\n"
			.."-d	decrypt (%s)\n",
			arg[0], alphabet, password, randomize, decrypt)
		)	
		os.exit(EXIT_FAILURE)
	end,
	["a"]=function(optarg, optind)
		alphabet=optarg:upper():umlauts()
	end,
	["p"]=function(optarg, optind)
		password=optarg:upper():umlauts()
		password=password:gsub("[^"..alphabet.."]","") -- filter valid characters
	end,
	["r"]=function(optarg, optind)
		randomize=optarg
		local seed
		if optarg=="time" then
			seed=os.time()^5+os.clock()
		else
			seed=tonumber(optarg)
		end
		math.randomseed(seed)
		alphabet=alphabet:shuffle()
		io.stderr:write("random alphabet: ",alphabet," seed:",seed,"\n")
	end,
	["d"]=function(optarg, optind)
		decrypt=true
	end,
	["c"]=function(optarg, optind)
		clean=not clean
	end,
	["i"]=function(optarg, optind)
		for arg in optarg:gmatch("([%dso]+)") do
			local increment,step,offset=arg:match("(%d+)s*(%d*)o*(%d*)")
			inc[#inc+1]={
				increment=tonumber(increment),
				step=step and tonumber(step) or 1,
				offset=offset and tonumber(offset) or 0}
		end
	end,
	["?"]=function(optarg, optind)
		io.stderr:write(string.format("unrecognized option %s\n", arg[optind -1]))
		return true
	end,
}
-- quickly process options
for r, optarg, optind in getopt(arg, "a:p:r:i:cdh") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end

local text=io.read("*a"):upper():umlauts()
if clean then 
	text=text:gsub("[^"..alphabet.."]","") -- filter valid characters
end
if not decrypt then
	text=text:vigenere_encrypt(password,alphabet,inc)
else
	text=text:vigenere_decrypt(password,alphabet,inc)
end
io.write(text)


