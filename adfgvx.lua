#!env luajit
require "ccrypt"
local getopt = require"posix.unistd".getopt

function string.adfgvx_encrypt(text, alphabet, matrix, column, row)
	text=text:polybios_encrypt(matrix,alphabet)
	if column then text=text:wuerfelcol_encrypt(column) end
	if row	  then text=text:wuerfelrow_encrypt(row) end
	return text
end

function string.adfgvx_decrypt(text, alphabet, matrix, column, row)
	if row then text=text:wuerfelrow_decrypt(row) end
	if column then text=text:wuerfelcol_decrypt(column) end
	text=text:polybios_decrypt(matrix,alphabet)
	return text
end

local alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
local matrix,decrypt,column,row="ADFGVX",false
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"AFDGVX encrypter (CC)2023 H.Behrens DL7HH\n"
			.."use: %s\n"
			.."-h	print this help text\n"
			.."-a	alphabet (%s)\n"
			.."-m	matrix (%s)\n"
			.."-c	column (%s)\n"
			.."-r	row (%s)\n"
			.."-d	decrypt (%s)\n",
			arg[0], alphabet, matrix, column, row, decrypt)
		)	
		os.exit(EXIT_FAILURE)
	end,
	["a"]=function(optarg, optind)
		alphabet=optarg:upper():umlauts()
	end,
	["m"]=function(optarg, optind)
		matrix=optarg:upper():umlauts()
		if (#matrix)^2 < #alphabet then
			io.stderr:write("WARNING: matrix has ",(#matrix)^2," and is smaller then the alphabet ",alphabet,"\n")
		elseif (#matrix)^2 > #alphabet then
			io.stderr:write("ERROR: matrix is ",(#matrix)^2," is larger than alphabet ",#alphabet,"\n")
			io.exit(EXIT_FAILURE)
		end
	end,
	["r"]=function(optarg, optind)
		row=optarg:upper():umlauts()
	end,
	["c"]=function(optarg, optind)
		column=optarg:upper():umlauts()
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
for r, optarg, optind in getopt(arg, "a:m:c:r:dh") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end

local text=io.read("*a"):upper():umlauts()
if not decrypt then
	text=text:gsub("[^"..alphabet.."]","") -- filter valid characters
	text=text:adfgvx_encrypt(alphabet,matrix,column,row)
else
	text=text:gsub("[^"..matrix.."]","") -- filter valid characters
	text=text:adfgvx_decrypt(alphabet,matrix,column,row)
end
io.write(text)

