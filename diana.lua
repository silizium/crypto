#!/usr/bin/env luajit
-- echo secretmessage|./diana.lua -p FUDEE -f otp-codes/alpha_donotuse.txt |block
require "ccrypt"
local getopt = require"posix.unistd".getopt
function loadotp(file,start)
	file=file or "otp-code/alpha_donotuse.txt"
	local fp=io.open(file)
	if not fp then return nil end
	local text=fp:read("*a"):upper()
	fp:close()
	if start then 
		local s,e=text:find(start)
		if s then text=text:sub(e+1,-1) end
	end
	return text:upper():umlauts()
end

function string.diana(text, password)
	v={text:byte(1,#text)}
	p={password:byte(1,#text)}
	t={}
	a=string.byte("A")
	for i=1,#v do 
		t[i]=string.char(25-(v[i]+p[1+(i-1)%#password])%26+a)
	end
	return table.concat(t)
end

local password,start=nil,nil
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Diana cipher/OTP from Vietnam War era (CC)2023 H.Behrens DL7HH\n"
			.."use: %s\n"
			.."-h	print this help text\n"
			.."-f	filename (%s)\n"
			.."-s	start (%s)\n",
			arg[0], filename, start)
		)	
		os.exit(EXIT_FAILURE)
	end,
	["s"]=function(optarg, optind)
		start=optarg:upper():umlauts()
		start=start:gsub("[%A]","") -- filter valid characters
	end,
	["f"]=function(optarg, optind)
		if start then io.write(start) 
		else
			start=io.read(5)
		end
		local otp=loadotp(optarg, start)
		password=otp:gsub("[%A]","") -- filter valid characters
	end,
	["?"]=function(optarg, optind)
		io.stderr:write(string.format("unrecognized option %s\n", arg[optind -1]))
		return true
	end,
}
-- quickly process options
for r, optarg, optind in getopt(arg, "f:s:h") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end

local text=io.read("*a"):upper():umlauts()
text=text:gsub("[%A]","") -- filter valid characters
text=text:diana(password)
io.write(text)


