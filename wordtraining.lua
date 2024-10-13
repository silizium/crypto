#!/usr/bin/env luajit
local getopt = require"posix.unistd".getopt
local cc = require"ccrypt"

local toupper_tab=("äöü"):subst_table("ÄÖÜ")
print("vvv[ka]")
local words,pattern,file=20,".*","/home/hanno/Documents/text/wordlist/Wordlist/german.utf8"
local seed=os.time()^5*os.clock()
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Word generator (CC) 2024 H.Behrens DL7HH\n"
			.."use : %s\n"
			.."-h	print this help text\n"
			.."-n	number of words (%d)\n"
			.."-p	pattern (%s)\n"
			.."-f	file (%s)\n"
			.."-s	seed (%d)\n",
			arg[0],words,pattern,file,seed)
		)
	end,
	["n"]=function(optarg, optind)
		words=tonumber(optarg)
	end,
	["p"]=function(optarg, optind)
		pattern=optarg
	end,
	["f"]=function(optarg, optind)
		file=optarg
	end,
	["s"]=function(optarg, optind)
		seed=tonumber(optarg)
	end,
	["?"]=function(optarg, optind)
		print('unrecognized option', arg[optind -1])
		return true
	end,
	}
-- quickly process options
for r, optarg, optind in getopt(arg, "n:p:f:s:h") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end
math.randomseed(seed)

local list={} 
for word in io.lines(file) do 
	-- wir wandeln erstmal unseren Text in Großbuchstaben
	word=word:upper()
	-- auch die Sonderzeichen wandeln
	word=word:substitute(toupper_tab)
	if word:match(pattern) then
		list[#list+1]=word:gsub("CH","[OT]") 
	end
end 
--shuffle
for i=#list,1,-1 do 
	local rnd=math.random(i) 
	list[i],list[rnd]=list[rnd],list[i] 
end 
for i=1,words do 
	io.write(list[i]," ") 
end
print("+")
