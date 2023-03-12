#!env luajit
require "ccrypt"
local getopt = require"posix.unistd".getopt

function string.diana(text, password)
	v={text:byte(1,#text)}
	p={password:byte(1,#text)}
	t={}
	for i=1,#v do 
		t[i]=string.char((26-(v[i]+p[1+(i-1)%#password]))%26+string.byte("A"))
	end
	return table.concat(t)
end

local password="SECRET"
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Diana cipher from Vietnam War era (CC)2023 H.Behrens DL7HH\n"
			.."use: %s\n"
			.."-h	print this help text\n"
			.."-p	password (%s)\n",
			arg[0], password)
		)	
		os.exit(EXIT_FAILURE)
	end,
	["p"]=function(optarg, optind)
		password=optarg:upper():umlauts()
		password=password:gsub("[%A]","") -- filter valid characters
	end,
	["?"]=function(optarg, optind)
		io.stderr:write(string.format("unrecognized option %s\n", arg[optind -1]))
		return true
	end,
}
-- quickly process options
for r, optarg, optind in getopt(arg, "p:h") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end

local text=io.read("*a"):upper():umlauts()
text=text:gsub("[%A]","") -- filter valid characters
text=text:diana(password)
io.write(text)


