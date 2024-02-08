#!/usr/bin/env luajit
require "ccrypt"

local getopt = require"posix.unistd".getopt
local decode,seed=false,os.time()^5*os.clock()
math.randomseed(seed)
local fopt={
        ["h"]=function(optarg,optind) 
                io.stderr:write(
                        string.format(
                        "achmed code (CC)2024 H.Behrens DL7HH\n"
                        .."use: %s\n"
                        .."-h   print this help text\n"
                        .."-d   decode\n"
                        .."-r   randomseed (%u)\n"
						.."\t input as ADFGVX does a Achmed the dead terrorist-code\n",
                        arg[0], seed)
                )
                os.exit(EXIT_FAILURE)
        end,
        ["d"]=function(optarg, optind)
                decode=not decode
        end,
        ["r"]=function(optarg, optind)
                seed=tonumber(optarg)
				math.randomseed(seed)
        end,
        ["?"]=function(optarg, optind)
                io.stderr:write(string.format("unrecognized option %s\n", arg[optind -1]))
                return true
        end,
}
-- quickly process options
for r, optarg, optind in getopt(arg, "r:dh") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end

local function shuffle(t)
	local random=math.random
	for i=#t,1,-1 do
		local rnd=random(i)
		t[i], t[rnd] = t[rnd], t[i]
	end
	return t
end

local text=io.read("*a")
local alphabet="ADFGVX"
local owo={":bomb:", ":girl:", ":star_and_crescent:", ":skull:", ":fire:", ":scream:"}

local enc_key,encrypted={}
local i=1
shuffle(owo)
for c in alphabet:utf8all() do
	local s=owo[i]
	i=i+1
	if decode then
		enc_key[s]=c
	else
		enc_key[c]=s
	end
end
if decode then
	encrypted=text:substitute(enc_key, ":[a-z0-9_]+:")
else
	encrypted=text:substitute(enc_key)
end

io.write(encrypted)
