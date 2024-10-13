#!/usr/bin/env luajit
require 'ccrypt'
local getopt = require"posix.unistd".getopt
local bits,symb,decode=8,"○●",false
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Binary to Bytestring converter (CC) 2024 H.Behrens DL7HH\n"
			.."use : %s\n"
			.."-h	print this help text\n"
			.."-b	bits (%d)\n"
			.."-s	symbols (%s)\n"
			.."-d	decode (%s)\n",
			arg[0], bits, symb, decode)
		)
	end,
	["b"]=function(optarg, optind)
		bits=tonumber(optarg)
		bits=bits>8 and 8 or bits
	end,
	["s"]=function(optarg, optind)
		symb=optarg
	end,
	["d"]=function(optarg, optind)
		decode=not decode
	end,
	["?"]=function(optarg, optind)
		print('unrecognized option', arg[optind -1])
		return true
	end,
	}
-- quickly process options
for r, optarg, optind in getopt(arg, "b:s:dh") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end


local text=io.read("*a")
if not decode then
	for i=1,#text do
		print(dec2bin(text:byte(i), bits, symb))
	end
else
	text=text:gsub("[^"..symb.."]", "")
	for str in text:gmatch(("("..(".?"):rep(bits)..")")) do
		io.write(bin2dec(str, bits, symb))
	end
end
