#!/usr/bin/env luajit
require "ccrypt"
local getopt = require"posix.unistd".getopt
--local iconv = require("iconv")
--local to_utf8 = iconv.new("UTF-8", "UTF-32")
--local to_utf32 = iconv.new("UTF-32", "UTF-8")

local from_str="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
local to_str="🃑🃒🃓🃔🃕🃖🃗🃘🃙🃚🃛🃝🃞🃁🃂🃃🃄🃅🃆🃇🃈🃉🃊🃋🃍🃎"
local decrypt=false

local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Alphabet Translate for Unicode (CC) 2025 H.Behrens DL7HH\n"
			.."use : %s\n"
			.."-h	print this help text\n"
			.."-f	from (%s)\n"
			.."-t	to (%s)\n"
			.."-d	decrypt\n"
			, arg[0],from_str,to_str)
		)
	end,
	["f"]=function(optarg, optind)
		from_str=tostring(optarg)
	end,
	["t"]=function(optarg, optind)
		to_str=tostring(optarg)
	end,
	["d"]=function(optarg, optind)
		decrypt=not decrypt
	end,
	["?"]=function(optarg, optind)
		print('unrecognized option', arg[optind -1])
		return true
	end,
}
-- quickly process options
for r, optarg, optind in getopt(arg, "f:t:dh") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end

assert(from_str:utf8len() == to_str:utf8len(), string.format("FAILURE: from and to string are not of same length, from = %d, to = %d.\n", from_str:utf8len(), to_str:utf8len()))

local text=io.read("*a")
if decrypt then from_str,to_str=to_str,from_str end
local key=from_str:subst_table(to_str)
text=text:substitute(key)
io.write(text)
