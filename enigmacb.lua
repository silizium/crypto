#!/usr/bin/env luajit
require 'ccrypt'
local getopt = require"posix.unistd".getopt

local model,book,kg,key,day="B","codebooks/mrhs_enigma.txt",nil,nil,nil
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Enigma codebook reader (CC)2025 H.Behrens DL7HH\n"
			.."use: %s\n"
			.."\t-m model (%s)\n" 
			.."\t-d day (%s)\n" 
			.."\t-g kenngruppe (%s)\n"
			.."\t-k key (%s)\n"
			.."\t-b book (%s)\n"
			.."\t-h print this help text\n",
			arg[0], model, day, kg, key, book)
		)	
		os.exit(EXIT_FAILURE)
	end,
	["b"]=function(optarg, optind)
		book=optarg
	end,
	["m"]=function(optarg, optind)
		model=optarg:upper()
	end,
	["d"]=function(optarg, optind)
		day=tonumber(optarg)
	end,
	["g"]=function(optarg, optind)
		kg=optarg:upper()
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
for r, optarg, optind in getopt(arg, "b:m:d:g:k:h") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end

-- Aufruf der Enigma Routinen
local roman={
	["I"]="1",["II"]="2",["III"]="3",["IV"]="4",["V"]="5",
	["VI"]="6",["VII"]="7",["VIII"]="8",["IX"]="9",["X"]="10",
	["?"]="0"
}
--"AAA,1-1-1,B,123,1,"
--31	V   III I	25 15 06	AS BF CZ DO EV GT HQ KN MU XY	???		BNV ZNK KR?

local cb={}
local mtc="(%d+)[%s|]+([IVX%?]+)[%s|]+([IVX%?]+)[%s|]+"
		.."([IVX%?]+)[%s|]+([%u%d]+)[%s]*([%u%d]+)[%s]*([%u%d]+)[%s|]+"
		.."("..("[%a%?][%a?][%s]+"):rep(9).."[%a%?][%a%?]"..")"
		.."[%s|]+([%u%?]+)[%s|]+"
		.."([%u%?%s]+)"
--	print(mtc)
for line in io.lines(book) do
	line=line:upper()
	local day,w1, w2, w3,r1,r2,r3,steck,code,kg=
		line:match(mtc)
--	print(		code, r1,r2,r3, model, roman[w1],roman[w2],roman[w3], steck)
	if day then
		day=tonumber(day)
		cb[day]={}
		steck=steck:gsub(" ", "-"):gsub("\t","")
		code=key or code

		cb[day].para=string.format("%3s,%s-%s-%s,%s,%s%s%s,1,%s",
			code, r1,r2,r3, model, roman[w1],roman[w2],roman[w3], steck)
		cb[day]["kg"]=kg
	end
end
if not kg then 
	if day then
		io.write(cb[day].para)
	else
		for i=1,#cb do 
			io.write(cb[i].para,"\n")
		end
	end
else
	for i=1,#cb do
		if cb[i]["kg"]:match(kg) then
			io.write(cb[i].para,"\n")
		end
	end
end

