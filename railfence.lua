#!env luajit
require "ccrypt"
local getopt = require"posix.unistd".getopt

local decrypt,rails=false,2
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Railfence cipher (CC)2023 H.Behrens DL7HH\n"
			.."use: %s\n"
			.."-h	print this help text\n"
			.."-r	rows (%d)\n"
			.."-d	decrypt (%s)\n",
			arg[0], rails, decrypt)
		)	
		os.exit(EXIT_FAILURE)
	end,
	["r"]=function(optarg, optind)
		rails=tonumber(optarg)
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
local last_index=1
for r, optarg, optind in getopt(arg, "r:dh") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end
if arg[last_index] then rails=tonumber(arg[last_index]) end

local text=io.read("*a"):upper():umlauts()
text=text:gsub("[^%w]", "")
if not decrypt then
	text=text:railfence_encrypt(rails) 
else
	text=text:railfence_decrypt(rails) 
end
io.write(text)

