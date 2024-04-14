#!/usr/bin/env luajit
-- convert ascii to numbers
require"ccrypt"
local getopt = require"posix.unistd".getopt
local decode,seed=false,os.time()^5*os.clock()
math.randomseed(seed)
local fopt={
        ["h"]=function(optarg,optind) 
                io.stderr:write(
                        string.format(
                        "number code (CC)2024 H.Behrens DL7HH\n"
						.."converting A…Z to 1…26 and back\n"
                        .."use: %s\n"
                        .."-h   print this help text\n"
                        .."-d   decode\n"
                        , arg[0], seed)
                )
                os.exit(EXIT_FAILURE)
        end,
        ["d"]=function(optarg, optind)
                decode=not decode
        end,
        ["?"]=function(optarg, optind)
                io.stderr:write(string.format("unrecognized option %s\n", arg[optind -1]))
                return true
        end,
}
-- quickly process options
for r, optarg, optind in getopt(arg, "dh") do
        last_index = optind
        if fopt[r](optarg, optind) then break end
end

txt=io.read("a*"):upper():umlauts()
if decode then
	for c,o in txt:gmatch("(%d+)(%D+)") do 
		io.write(string.char(tonumber(c)+string.byte("A")-1))
		if o~=nil and o~="" then
			o=o:gsub("%s","")
			io.write(o)
		end
	end
else 
	for c in txt:gmatch("%g") do
		if c:match("%a") then
			io.write(string.byte(c)-string.byte("A")+1, " ") 
		else
			io.write(c, " ")
		end
	end
end
