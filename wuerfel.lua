#!env luajit
require "ccrypt"
local getopt = require"posix.unistd".getopt


local decrypt,password,rows=false,"A",false
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Würfel square transposition encrypter (CC)2023 H.Behrens DL7HH\n"
			.."use: %s\n"
			.."-h	print this help text\n"
			.."-p	password (%s)\n"
			.."-r	rows (%s)\n"
			.."-d	decrypt (%s)\n",
			arg[0], alphabet, matrix, password, row, decrypt)
		)	
		os.exit(EXIT_FAILURE)
	end,
	["r"]=function(optarg, optind)
		rows=true
	end,
	["p"]=function(optarg, optind)
		password=optarg:upper():umlauts()
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
if not decrypt then
	if not rows then 
		text=text:wuerfelcol_encrypt(password) 
	else
		text=text:wuerfelrow_encrypt(password) 
	end
else
	if not rows then 
		text=text:wuerfelcol_decrypt(password) 
	else
		text=text:wuerfelrow_decrypt(password) 
	end
end
io.write(text)

