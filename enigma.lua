#!/usr/bin/env luajit
require 'ccrypt'
local getopt = require"posix.unistd".getopt

local key,decrypt,lang,verbose="AAA,1-1-1,B,123,1,",false,false,false
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Enigma cipher (CC)2025 H.Behrens DL7HH\n"
			.."use: %s -k <spruch>,<ring>,<ukw>,<walzen>,<stator>,<steck>\n"
			.."\t is %s\n"
			.."\texample: enigma.lua -k AAA,(NN-NN-NN|AAA),B,123,1,AE-FC-WI\n"
			.."\t  UKW A=old,B=M3B, C=M3C, D=M4B, E=M4C, Reichsbahn, Schweiz, Abwehr\n"
			.."\t  Walzen 1-8 B=beta G=Gamma\n"
			.."\t  Stator 1=standard, 2=Reichsbahn, Schweiz, Abwehr, 3=Enigma D\n"
			.."\t  Stecker in form AE-OU-CH etc.\n"
			.."\t  -l language german, english, french (%s)\n"
			.."\t  -v verbose\n"
			.."\t  -h print this help text\n",
			arg[0], key, lang)
		)	
		os.exit(EXIT_FAILURE)
	end,
	["l"]=function(optarg, optind)
		lang=optarg:lower()
	end,
	["k"]=function(optarg, optind)
		key=optarg:upper()
	end,
	["?"]=function(optarg, optind)
		io.stderr:write(string.format("unrecognized option %s\n", arg[optind -1]))
		return true
	end,
}
-- quickly process options
for r, optarg, optind in getopt(arg, "k:l:h") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end

-- Aufruf der Enigma Routinen

local text=io.read("*a")
if lang then text=text:clean(lang) end
local enigma = Enigma.new(key, verbose)
io.write(enigma:crypt(text))
