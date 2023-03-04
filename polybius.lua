#!env luajit
require "ccrypt"
local getopt = require"posix.unistd".getopt

local alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
local matrix,decrypt,column,row="ADFGVX",false
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Polybius encrypter (CC)2023 H.Behrens DL7HH\n"
			.."use: %s\n"
			.."-h	print this help text\n"
			.."-a	alphabet (%s)\n"
			.."-m	matrix (%s)\n"
			.."-d	decrypt (%s)\n",
			arg[0], alphabet, matrix, decrypt)
		)	
		os.exit(EXIT_FAILURE)
	end,
	["a"]=function(optarg, optind)
		alphabet=optarg:upper():umlauts()
	end,
	["m"]=function(optarg, optind)
		matrix=optarg:upper():umlauts()
		if (#matrix)^2 < #alphabet then
			io.stderr:write("WARNING: matrix is ",(#matrix)^2," and is smaller than the alphabet ",alphabet,"\n")
		elseif (#matrix)^2 > #alphabet then
			io.stderr:write("WARNING: matrix is ",(#matrix)^2," and is larger than the alphabet ",#alphabet,"\n")
		end

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
for r, optarg, optind in getopt(arg, "a:m:dh") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end

local text=io.read("*a"):upper():umlauts()
if not decrypt then
	text=text:gsub("[^"..alphabet.."]","") -- filter valid characters
	text=text:polybios_encrypt(matrix,alphabet)
else
	text=text:gsub("[^"..matrix.."]","") -- filter valid characters
	text=text:polybios_decrypt(matrix,alphabet)
end
io.write(text)

