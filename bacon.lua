#!env luajit
require "ccrypt"
local getopt = require"posix.unistd".getopt

local decrypt,character=false,"AB"
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Bacon cipher (CC)2023 H.Behrens DL7HH\n"
			.."use: %s\n"
			.."-h	print this help text\n"
			.."-c	characters (%s)\n"
			.."-d	decrypt (%s)\n",
			arg[0], character, decrypt)
		)	
		os.exit(EXIT_FAILURE)
	end,
	["c"]=function(optarg, optind)
		character=optarg
	end,
	["d"]=function(optarg, optind)
		decrypt=true
	end,
	["?"]=function(optarg, optind)
		io.stderr:write(string.format("unrecognized option %s\n", arg[optind -1]))
		return true
	end,
}
-- quickly process options
for r, optarg, optind in getopt(arg, "c:dh") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end

local text=io.read("*a")
local v={}
local decode={}
local i=0
for c in character:utf8all() do decode[c]=i i=i+1 end
if not decrypt then
	text=text:upper():umlauts():filter("[^A-Z]")
	for c in text:gmatch(ccrypt.Unicode) do
		v[#v+1]=dec2bin(c:byte()-1,5,character)
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

