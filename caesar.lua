#!/usr/bin/env luajit
-- pipe_caesar.lua
require "ccrypt"
local getopt = require"posix.unistd".getopt
-- Aufruf mit pipe_caesar <key>
-- oder -key für Entschlüsselung
local key,alphabet,filter,lang=13,"abcdefghijklmnopqrstuvwxyz",true,false
local password=alphabet
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Caesar cipher (CC)2025 H.Behrens DL7HH\n"
			.."use: %s\n"
			.."-h	print this help text\n"
			.."-f	filter (%s)	filter unknown characters\n"
			.."-l	language (%s)	translates numbers to english, german, french\n"
			.."-a	alphabet (%s)\n"
			.."-p	password (%s)\n"
			.."-k	key (%d)\n",
			arg[0], filter, lang, alphabet, password, key)
		)	
		os.exit(EXIT_FAILURE)
	end,
	["f"]=function(optarg, optind)
		filter=not filter
	end,
	["l"]=function(optarg, optind)
		lang=optarg:lower()
	end,
	["a"]=function(optarg, optind)
		alphabet=optarg
	end,
	["p"]=function(optarg, optind)
		password=optarg
	end,
	["k"]=function(optarg, optind)
		key=tonumber(optarg)
	end,
	["?"]=function(optarg, optind)
		io.stderr:write(string.format("unrecognized option %s\n", arg[optind -1]))
		return true
	end,
}
-- quickly process options
for r, optarg, optind in getopt(arg, "a:p:k:l:fh") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end

local text=io.read("*a") -- STDIN einlesen
-- wir wandeln erstmal unseren Text in Großbuchstaben
text=text:umlauts():upper()
if lang then text=text:clean(lang) end
alphabet=alphabet:upper()
password=password:upper()
if filter then text=text:gsub("[^"..alphabet.."]", "") end
local enc_key=alphabet:subst_table(password, key)
local encrypted=text:substitute(enc_key)
io.write(encrypted) -- verschlüsselter Text
