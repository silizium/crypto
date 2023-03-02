#!env luajit
-- echo -n "mission begins at dawn.travel to coordinates:30uxc55106318."|./otp.lua|block 5 15
-- https://www.youtube.com/watch?v=MzwpmbIWUNc
require"ccrypt"
local getopt = require"posix.unistd".getopt

local bookname,decrypt="codebooks/funkbuch.txt",false
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Codebook encrypter (CC)2023 H.Behrens DL7HH\n"
			.."use: %s\n"
			.."-h	print this help text\n"
			.."-b	codebook (%s)\n"
			.."-d	decrypt (%s)\n",
			arg[0], bookname, otpname, start, decrypt)
		)	
		os.exit(EXIT_FAILURE)
	end,
	["b"]=function(optarg, optind)
		bookname=optarg
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
for r, optarg, optind in getopt(arg, "b:dh") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end

local text=io.read("*a"):upper():umlauts()
local book=codebook.load(bookname)
local code
if not decrypt then
	code=text:codebook_encode(book)
else
	code=text:codebook_decode(book)
end
io.write(code)
