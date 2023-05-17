#!env luajit
require "ccrypt"
local getopt = require"posix.unistd".getopt

local code={
	[" "]=" ",
	A="dD", B="Dddd", C="DdDd", D="Ddd", E="d",
	F="ddDd", G="DDd", H="dddd", I="dd", J="dDDD",
	K="DdD", L="dDdd", M="DD", N="Dd", O="DDD",
	P="dDDd", Q="DDdD", R="dDd", S="ddd", T="D",
	U="ddD", V="dddD", W="dDD", X="DddD", Y="DdDD",
	Z="DDdd", ["Ä"]="dDdD", ["Ö"]="DDDd", ["Ü"]="ddDD",
	["ß"]="ddd-DDdd", 
	[","]="DDddDD", ["."]="dDdDdD", ["+"]="dDdDd",
	["/"]="DddDd", ["?"]="ddDDdd", ["'"]="dDDDDd",
	["\""]="dDddDd", ["@"]="dDDdDd", ["="]="DdddD",
	[";"]="DdDdDd", ["!"]="DdDdDD",
	["0"]="DDDDD", ["1"]="dDDDD", ["2"]="ddDDD", ["3"]="dddDD",	
	["4"]="ddddD", ["5"]="ddddd", ["6"]="Ddddd", ["7"]="DDddd", 
	["8"]="DDDdd", ["9"]="DDDDd",
	["Å"]="dDDdD", ["É"]="ddDdd", ["È"]="dDddD",
	["CH"]="DDDD", ["-"]="DddddD", ["("]="DdDDd", [")"]="DdDDdD",
	[":"]="DDDddd",
	["<KA>"]="DdDdD", ["<VE>"]="dddDd", ["<SK>"]="dddDdD",
	["&"]="dDddd", ["_"]="ddDDdD", ["$"]="ddDddD",
	["Ç"]="DdDdd", ["Ñ"]="DDdDD",
	["<SOS>"]="dddDDDddd", ["<ERR>"]="dddddddd"
}

local decode,mode=false
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Morse2txt (CC)2023 H.Behrens DL7HH\n"
			.."use: %s\n"
			.."-h	print this help text\n"
			.."-d	decode\n"
			.."-m	mode (%s)\n",
			arg[0], mode and "NORMAL" or "NORMAL")
		)	
		os.exit(EXIT_FAILURE)
	end,
	["d"]=function(optarg, optind)
		decode=not decode
	end,
	["m"]=function(optarg, optind)
		mode=optarg
	end,
	["?"]=function(optarg, optind)
		io.stderr:write(string.format("unrecognized option %s\n", arg[optind -1]))
		return true
	end,
}
-- quickly process options
for r, optarg, optind in getopt(arg, "m:dh") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end

local txt=io.read("*a")
txt=txt:substitute(("äöüåñç"):subst_table("ÄÖÜÅÑÇ"))

local t={}
if not decode then
	for c in txt:upper():utf8all() do
		if code[c] then
			if t[#t] and t[#t]:match("[dD]+") and not code[c]:match("[%s%c]+") then 
				t[#t+1]="-" 
			end
			t[#t+1]=code[c]
		else
			t[#t+1]=c
		end
	end
else
	decode={}
	for k,v in pairs(code) do
		decode[v]=k
	end
	for morse,space in txt:gmatch("([dD]+)([ -]*)") do
		t[#t+1]=decode[morse]
		if space:match("%s+") then t[#t+1]=space end
	end
end

io.write(table.concat(t))

