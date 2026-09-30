#!/usr/bin/env luajit
require "ccrypt"
local getopt = require"posix.unistd".getopt
local b = bit32 or require "bit"

local decrypt,character,input=false,"AB"
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Hiddden Bacon cipher (CC)2025 H.Behrens DL7HH\n"
			.."use: %s\n"
			.."-h	print this help text\n"
			.."-c	characters (%s)\n"
			.."-d	decrypt (%s)\n"
			.."-i	input stream (%s)\n",
			arg[0], character, decrypt, input)
		)	
		os.exit(EXIT_FAILURE)
	end,
	["c"]=function(optarg, optind)
		character=optarg
	end,
	["d"]=function(optarg, optind)
		decrypt=true
	end,
	["i"]=function(optarg, optind)
		input=optarg
	end,
	["?"]=function(optarg, optind)
		io.stderr:write(string.format("unrecognized option %s\n", arg[optind -1]))
		return true
	end,
}
-- quickly process options
for r, optarg, optind in getopt(arg, "c:di:h") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end

local text=io.read("*a")
local v={}
local i=0
if not decrypt then
	text=text:upper():umlauts():filter("[^A-Z]")
	local charpat={text:byte(1,#text)}
	local bitpat={}
	for k,v in ipairs(charpat) do
		local num=v-("A"):byte()+1
		for c=4,0,-1 do
			bitpat[#bitpat+1]=b.band(2^c,num)~=0 
			print(bitpat[#bitpat])
		end
	end
else
	local res,round=0,0
	for c in text:gmatch(ccrypt.Unicode) do
		if decode[c] then
			res=res*2+decode[c]
			round=round+1
			if round==5 then 
				round=0
				v[#v+1]=string.char(res+string.byte("A"))
				res=0
			end
		end
	end 
end
text=table.concat(v)
io.write(text)

