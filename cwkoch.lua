#!env luajit
--[[
	cwkoch is a small koch trainer for cw/telegraphy learning
	it needs the ccrypt library, the luaposix library and the 
	cw package under Linux or anything else that will transform 
	text to morse sound.
	2022 Hanno Behrens
	Dependencies:
	git pull https://github.com/silizium/crypto
	sudo luarocks install luaposix
	sudo apt install cw luajit
	Example: https://photos.app.goo.gl/VqdiwpthPs8d7hnN7
]]
local getopt = require"posix.unistd".getopt
local cc = require"ccrypt"
math.randomseed(os.time()^5*os.clock())
--              1         11        21        31        41        51         60
local alphabet="elv0aqst2cod5/ir9gxf4nu7h,=.bkp3myjwz168?-+@:;!_()'\"AOUZKVTES"
local prefix="vvv[ka]"
local special={["K"]="[ka]", ["V"]="[ve]", ["T"]="[sk]", ["S"]="[sos]", ["E"]="[hh]",
	["A"]="[aa]", ["O"]="[oe]", ["U"]="[ue]", ["Z"]="[sz]"}
local choice,percent,number,koch, block, newline=100,true,50,#alphabet,5,5
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Percentage Koch generator ©2022 H.Behrens DL7HH\n"
			.."use : %s\n"
			.."-h	print this help text\n"
			.."-a	alphabet (%s)\n"
			.."-k	kochlevel (%d)\n"
			.."-c	choice <num>[%%] (%d%s)\n"
			.."-n	number (%d)\n"
			.."-b	block,newline (%d,%d)\n"
			.."-p	prefix (%s)\n",
			arg[0], alphabet:sub(1,koch), koch, choice, percent and "%" or "", 
			number,block,newline or 5, prefix)
		)
		--os.exit(1)
	end,
	["a"]=function(optarg, optind)
		alphabet=optarg
	end,
	["k"]=function(optarg, optind)
		koch=tonumber(optarg)
		koch=koch<1 and 1 or koch
	end,
	["c"]=function(optarg, optind)
		choice=tonumber(optarg:match("%d*"))
		choice=choice<0 and 0 or choice
		percent=optarg:match("%d*%%") and true or false
	end,
	["n"]=function(optarg, optind)
		number=tonumber(optarg)
	end,
	["b"]=function(optarg, optind)
		block,newline=optarg:match("(%d+),*(%d*)")
		block,newline=tonumber(block),tonumber(newline)
	end,
	["p"]=function(optarg, optind)
		prefix=optarg
	end,

	["?"]=function(optarg, optind)
		print('unrecognized option', arg[optind -1])
		return true
	end,
	}
-- quickly process options
for r, optarg, optind in getopt(arg, "a:k:c:n:b:p:h") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end
koch=koch>#alphabet and #alphabet or koch
alphabet=alphabet:sub(1,koch)
alphabet=alphabet:shuffle()
alphabet=alphabet:sub(1,percent and #alphabet*choice/100 or choice>#alphabet and #alphabet or choice)
--io.stderr:write(alphabet, " ", koch, " ", percent, " ", number, " ", block, "\n")  -- debug
local rnd
local t={}
for i=1,number do
	rnd=math.random(1,#alphabet)
  	t[#t+1]=alphabet:sub(rnd,rnd)
end
t=table.concat(t):block(block,(newline or 0)*(block or 0))
t=t:gsub(".",special):upper()
--if newline and newline>0 then t=t:gsub("("..("[^ ]+%s+"):rep(newline)..")","%1\n") end
t=prefix.."\n"..t.."+\n"
io.write(t)
