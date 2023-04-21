#!env luajit
require "ccrypt"
local getopt = require"posix.unistd".getopt

local code={
	[" "]="/",
	A="DIDAH", B="DADIDIDIT", C="DADIDADIT", D="DADIDIT", E="DIT",
	F="DIDIDADIT", G="DADADIT", H="DIDIDIDIT", I="DIDIT", J="DIDADADAH",
	K="DADIDAH", L="DIDADIDIT", M="DADAH", N="DADIT", O="DADADAH",
	P="DIDADADIT", Q="DADADIDAH", R="DIDADIT", S="DIDIDIT", T="DAH",
	U="DIDIDAH", V="DIDIDIDAH", W="DIDADAH", X="DADIDIDAH", Y="DADIDADAH",
	Z="DADADIDIT", ["Ä"]="DIDADIDAH", ["Ö"]="DADADADIT", ["Ü"]="DIDIDADAH",
	["ß"]="DIDIDIT DADADIDIT", 
	[","]="DADADIDIDADAH", ["."]="DIDADIDADIDAH", ["+"]="DIDADIDADIT",
	["/"]="DADIDIDADIT", ["?"]="DIDIDADADIDIT", ["'"]="DIDADADADADIT",
	["\""]="DIDADIDIDADIT", ["@"]="DIDADADIDADIT", ["="]="DADIDIDIDAH",
	[";"]="DADIDADIDADIT", ["!"]="DADIDADIDADAH",
	["0"]="DADADADADAH", ["1"]="DIDADADADAH", ["2"]="DIDIDADADAH", ["3"]="DIDIDIDADAH",	
	["4"]="DIDIDIDIDAH", ["5"]="DIDIDIDIDIT", ["6"]="DADIDIDIDIT", ["7"]="DADADIDIDIT", 
	["8"]="DADADADIDIT", ["9"]="DADADADADIT",
	["Å"]="DIDADADIDAH", ["É"]="DIDIDADIDIT", ["È"]="DIDADIDIDAH",
	["CH"]="DADADADAH", ["-"]="DADIDIDIDIDAH", ["("]="DADIDADADIT", [")"]="DADIDADADIDAH",
	[":"]="DADADADIDIDIT",
	["<KA>"]="DADIDADIDAH", ["<VE>"]="DIDIDIDADIT", ["<SK>"]="DIDIDIDADIDAH",
	["<SOS>"]="DIDIDIDADADADIDIDIT", ["<ERR>"]="DIDIDIDIDIDIDIDIT"
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

local txt=io.read("*a"):upper()
txt=txt:substitute(("äöüå"):subst_table("ÄÖÜÅ"))

local t={}
if not decode then
	for c in txt:utf8all() do
		if code[c] then
			t[#t+1]=code[c]:lower()
			t[#t+1]=" "
		else
			t[#t+1]=c
		end
	end
else
	decode={}
	for k,v in pairs(code) do
		decode[v]=k
	end
	for morse in txt:gmatch("[DIA]*[TH/]") do
		t[#t+1]=decode[morse]
	end
end

io.write(table.concat(t))

