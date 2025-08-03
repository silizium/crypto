#!/usr/bin/env luajit
-- pipe_caesar.lua
require "ccrypt"
local getopt = require"posix.unistd".getopt
-- Aufruf mit pipe_caesar <key>
-- oder -key für Entschlüsselung
local key,alphabet,filter,english,german=13,"abcdefghijklmnopqrstuvwxyz",true,false,false
local password=alphabet
local file="otp-codes/alpha_donotuse.txt"
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Caesar cipher (CC)2025 H.Behrens DL7HH\n"
			.."use: %s\n"
			.."-h	print this help text\n"
			.."-f	filter (%s)	filter unknown characters\n"
			.."-e	english (%s)	translates numbers to English\n"
			.."-g	german (%s)	translates numbers to German\n"
			.."-a	alphabet (%s)\n"
			.."-p	password (%s)\n"
			.."-k	key (%d)\n",
			arg[0], filter, english, german, alphabet, password, key)
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
for r, optarg, optind in getopt(arg, "a:p:k:egfh") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end

local text=io.read("*a") -- STDIN einlesen
-- wir wandeln erstmal unseren Text in Großbuchstaben
text=text:umlauts():upper()
if english then	text=text:clean("english") end
if german then text=text:clean() end
-- auch die Sonderzeichen 
--	local toupper_tab=("äöü"):subst_table("ÄÖÜ")
--	text=text:substitute(toupper_tab)
-- und jetzt wandeln wir die Sonderzeichen in ASCII
--local enc_key={}
--enc_key.ß="SZ" enc_key.Ä="AE" enc_key.Ö="OE" enc_key.Ü="UE"
--text=text:substitute(enc_key)

--[[ jetzt verschlüsseln wir ihn mit klassischem Cäsar
wenn wir kein cipher-alphabet angeben, nimmt er das 
]]
alphabet=alphabet:upper()
password=password:upper()
if filter then text=text:gsub("[^"..alphabet.."]", "") end
local enc_key=alphabet:subst_table(password, key)
local encrypted=text:substitute(enc_key)
io.write(encrypted) -- verschlüsselter Text
