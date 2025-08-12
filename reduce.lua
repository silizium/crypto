#!/usr/bin/env luajit
require "ccrypt"
local getopt = require"posix.unistd".getopt

local nr=25
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Alphabet Reduction 26-20 (CC) 2024 H.Behrens DL7HH\n"
			.."use : %s\n"
			.."-h	print this help text\n"
			.."-r	reduce (%d)\n\n"
			.."26: reduce Umlauts, down the ladder of historical alphabets\n"
			.."24: U to V\n"
			.."25: J to I\n"
			.."25Q: no Q\n"
			.."23: W to VV\n"
			.."22: X to CS\n"
			.."21: Y to I\n"
			.."20: K to C original roman alphabet\n",
			arg[0],nr)
		)
		os.exit(EXIT_FAILURE)
	end,
	["r"]=function(optarg, optind)
		nr=optarg
	end,
	["?"]=function(optarg, optind)
		print('unrecognized option', arg[optind -1])
		return true
	end,
	}
-- quickly process options
for r, optarg, optind in getopt(arg, "dr:h") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end

local text=io.read("*a"):upper()
text=text:substitute(("äöü"):subst_table("ÄÖÜ")):reduce(nr)
io.write(text)
