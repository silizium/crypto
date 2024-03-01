#!/usr/bin/env luajit
require "ccrypt"
local getopt = require"posix.unistd".getopt

function string.remove_doublets(text)
	local t,set={},{}
	for c in text:gmatch("%w") do
		if not set[c] then
			t[#t+1]=c
			set[c]=true
		end
	end
	return table.concat(t)
end

local alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
local password, randomize="", ""
local column
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Alphabet generator (CC)2023 H.Behrens DL7HH\n"
			.."use: %s\n"
			.."-h	print this help text\n"
			.."-a	alphabet (%s) %d\n"
			.."-w	write out alphabet to /dev/stderr\n"
			.."-p	passwort (%s)\n"
			.."-r	reverse alphabet\n"
			.."-t	column transpose (%s)\n"
			.."-s	shuffle (%s)\n",
			arg[0], alphabet, #alphabet, password, column, randomize)
		)	
		os.exit(EXIT_FAILURE)
	end,
	["a"]=function(optarg, optind)
		alphabet=optarg:upper():umlauts():remove_doublets()
	end,
	["p"]=function(optarg, optind)
		password=optarg:upper():umlauts():remove_doublets()
		password=password:gsub("[^"..alphabet.."]", "")
		alphabet=password..alphabet:gsub("["..password.."]","")
	end,
	["r"]=function(optarg, optind)
		alphabet=alphabet:reverse()
	end,
	["w"]=function(optarg, optind)
		io.stderr:write(alphabet,"\n")
	end,
	["t"]=function(optarg, optind)
		column=optarg:upper():umlauts()
		alphabet=alphabet:wuerfelcol_encrypt(column)
	end,
	["s"]=function(optarg, optind)
		randomize=optarg
		if optarg=="time" then 
			math.randomseed(os.time()^5*os.clock())
		else
			math.randomseed(tonumber(optarg))
		end
		alphabet=alphabet:shuffle()
	end,
	["?"]=function(optarg, optind)
		io.stderr:write(string.format("unrecognized option %s\n", arg[optind -1]))
		return true
	end,
}
-- quickly process options
for r, optarg, optind in getopt(arg, "a:p:s:t:rwh") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end
io.write(alphabet)

