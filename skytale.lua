#!env luajit
require "ccrypt"
local getopt = require"posix.unistd".getopt

local decrypt,password=false,2
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Skytale transposition encrypter (CC)2023 H.Behrens DL7HH\n"
			.."use: %s\n"
			.."-h	print this help text\n"
			.."-p	passwort (%d)\n"
			.."-d	decrypt (%s)\n",
			arg[0], password, decrypt)
		)	
		os.exit(EXIT_FAILURE)
	end,
	["p"]=function(optarg, optind)
		password=tonumber(optarg:upper())
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
for r, optarg, optind in getopt(arg, "p:rdh") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end

local text=io.read("*a"):upper():umlauts()
text=text:gsub("[^%w]", "")
password=("A"):rep(password)
if not decrypt then
	text=text:wuerfelcol_encrypt(password) 
else
	text=text:wuerfelcol_decrypt(password) 
end
io.write(text)

