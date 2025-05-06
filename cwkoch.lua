#!/usr/bin/env luajit
--[[
	cwkoch is a small koch trainer for cw/telegraphy learning
	it needs the ccrypt library, the luaposix library and the 
	cw package under Linux or anything else that will transform 
	text to morse sound.
	CC 2022 Hanno Behrens
	Dependencies:
	git pull https://github.com/silizium/crypto
	sudo luarocks install luaposix
	sudo apt install cw luajit
	Example: https://photos.app.goo.gl/VqdiwpthPs8d7hnN7
]]
local getopt = require"posix.unistd".getopt
local cc = require"ccrypt"
math.randomseed(os.time()^5*os.clock())
--               1         11        21        31        41        51         60
local alphabet={"elv0aqst2cod5/ir9gxf4nu7h,=.bkp3myjwz168?-@:;!_+()'\"AOUZHKVTES", --koch
                "kmuresnaptlwi.jz=foy,vg5/q92h38b?47c1d60x-AOUZHE+@:;!_()'\"KVTS", --lcwo
				"teanois14rhdl25ucmw36?fypg79/bvkj80=xqz.,-AOUZHE+@:;!_()'\"KVTS", --m32
				"adfgxvel0qst2co5/ir94nu7h,=.bkp3myjwz168?-@:;!_+()'\"AOUZHKVTES", --adfgvx
}
local amethod={"Koch/E13", "LCWO", "M32", "ADGVX"}
local prefix="vvv[ka]"
local postfix="+"
local special={["K"]="[ka]", ["V"]="[ve]", ["T"]="[sk]", ["S"]="[sos]", ["E"]="[hh]",
	["A"]="[aa]", ["O"]="[oe]", ["U"]="[ut]", ["Z"]="[sz]", ["H"]="[ot]"}
local method=1
local choice,percent,number,koch, blk, newline, gap=100,true,50,#alphabet[method],5,5,0
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Percentage Koch generator (CC) 2023 H.Behrens DL7HH\n"
			.."use : %s\n"
			.."-h	print this help text\n"
			.."-a	alphabet (%s)\n"
			.."-k	kochlevel (%d)\n"
			.."-c	choice <num>[%%] (%d%s)\n"
			.."-m	method (%d:%s)\n"
			.."-n	number (%d)\n"
			.."-b	block,newline (%d,%d)\n"
			.."-p	prefix (%s)\n"
			.."-e	postfix (%s)\n"
			.."-g	gap (%d)\n"
			.."\n	Default alphabets (-m):\n",
			arg[0],alphabet[method]:sub(1,koch), koch, choice, percent and "%" or "", 
			method, amethod[method],number,blk,newline,prefix,postfix,gap)
		)
		for i=1,#alphabet do
			io.stderr:write(
				string.format("	%d:%s\n",i, amethod[i])
			)
		end
		--os.exit(1)
	end,
	["a"]=function(optarg, optind)
		alphabet[method]=optarg
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
	["m"]=function(optarg, optind)
		method=tonumber(optarg)
		if method < 1 then method=1 end
		if method > #alphabet then method=#alphabet end
	end,
	["n"]=function(optarg, optind)
		number=tonumber(optarg)
	end,
	["b"]=function(optarg, optind)
		blk,newline=optarg:match("(%d+),(%-?%d*)")
		blk,newline=tonumber(blk),tonumber(newline)
	end,
	["p"]=function(optarg, optind)
		prefix=optarg
	end,
	["e"]=function(optarg, optind)
		postfix=optarg
	end,

	["?"]=function(optarg, optind)
		print('unrecognized option', arg[optind -1])
		return true
	end,
	}
-- quickly process options
for r, optarg, optind in getopt(arg, "a:k:c:m:n:b:p:e:h") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end
alphabet=alphabet[method]
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
t=table.concat(t):block(blk,newline)
t=t:gsub(".",special):upper()
--if newline and newline>0 then t=t:gsub("("..("[^ ]+%s+"):rep(newline)..")","%1\n") end
t=(#prefix>0 and prefix.."\n" or "")..t..(#postfix>0 and postfix.."\n" or "")
io.write(t)
