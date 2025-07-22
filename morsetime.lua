#!/usr/bin/env luajit
require "ccrypt"
local getopt = require"posix.unistd".getopt

local function printf(str, ...) return io.stderr:write(string.format(str, ...)) end

local symbols={ ["<KA>"]="␂", ["<SK>"]="␂", ["<ERR>"]="␂", 
	["<SOS>"]="␇", ["<VE>"]="␆", ["<AS>"]="␅" }

local code={
	[" "]=" ",
	A="dD", B="Dddd", C="DdDd", D="Ddd", E="d",
	F="ddDd", G="DDd", H="dddd", I="dd", J="dDDD",
	K="DdD", L="dDdd", M="DD", N="Dd", O="DDD",
	P="dDDd", Q="DDdD", R="dDd", S="ddd", T="D",
	U="ddD", V="dddD", W="dDD", X="DddD", Y="DdDD",
	Z="DDdd", ["Ä"]="dDdD", ["Ö"]="DDDd", ["Ü"]="ddDD",
	["ß"]="ddd DDdd", 
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
	["␂"]="DdDdD", ["␆"]="dddDd", ["␂"]="dddDdD",
	["&"]="dDddd", ["_"]="ddDDdD", ["$"]="ddDddD",
	["Ç"]="DdDdd", ["Ñ"]="DDdDD",
	["␇"]="dddDDDddd", ["␂"]="dddddddd", ["␅"]="dDddd"
}

local dit, dah, pause=1, 3, 7
local wpm, cpm=false, false
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Morsetime (CC)2025 H.Behrens DL7HH\n"
			.."use: %s\n"
			.."-h	print this help text\n"
			.."-w	words per minute\n"
			.."-c	characters per minute\n"
			.."-d	length of dit (%d)\n"
			.."-D	length of Dah (%d)\n"
			.."-p	length of pause (%d)\n",
			arg[0], dit, dah, pause)
		)	
		os.exit(EXIT_FAILURE)
	end,
	["w"]=function(optarg, optind)
		wpm=tonumber(optarg)
	end,
	["c"]=function(optarg, optind)
		cpm=tonumber(optarg)
	end,
	["d"]=function(optarg, optind)
		dit=tonumber(optarg)
	end,
	["D"]=function(optarg, optind)
		dah=tonumber(optarg)
	end,
	["p"]=function(optarg, optind)
		pause=tonumber(optarg)
	end,
	["?"]=function(optarg, optind)
		io.stderr:write(string.format("unrecognized option %s\n", arg[optind -1]))
		return true
	end,
}
-- quickly process options
for r, optarg, optind in getopt(arg, "w:c:d:D:p:h") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end




local length={}
-- build length table
local p=0
for k,v in pairs(code) do
	local len=0
	for c in v:gmatch(".") do
		if 		c=="d" then len=len+dit+1
		elseif 	c=="D" then len=len+dah+1
		else len=len+pause-5 end
	end
	len=len+2
	length[k]=len
end
--for k,v in pairs(length) do
--	print(k,v)
--end
local file=io.read("*a"):upper()
txt=file:substitute(("äöüåñç[]\r\n\t"):subst_table("ÄÖÜÅÑÇ<>   "))
txt=txt:gsub("<%a+>",symbols)

local message=0
for c in txt:utf8all() do 
	local len=length[c]
	message=message+len
end

io.write(file)

printf("length in dits: %d\n", message)
if wpm then printf("at %d wpm: %.1f secs/%.1f min\n", wpm, message*1.2/wpm, message*1.2/wpm/60) end
if cpm then printf("at %d cpm: %.1f secs/%.1f min\n", cpm, message*1.2/(cpm/5), message*1.2/wpm/60) end

