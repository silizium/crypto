#!/usr/bin/env luajit
-- echo secretmessage|./diana.lua -p FUDEE -f otp-codes/alpha_donotuse.txt |block
require "ccrypt"
local getopt = require"posix.unistd".getopt
function loadotp(file,start)
	file=file or "otp-codes/alpha_donotuse.txt"
	local fp=assert(io.open(file))
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
	local a=string.byte("A")
	local v={text:byte(1,#text)} for i,_val in ipairs(v) do v[i]=v[i]-a end
	local p={password:byte(1,#text)} for i,_val in ipairs(p) do p[i]=p[i]-a end

	local t={}
	for i=1,#v do 
		t[i]=string.char(25-(v[i]+p[1+(i-1)%#password])%26+a)
	end
	return table.concat(t)
end

local password,start=nil,nil
local file="otp-codes/alpha_donotuse.txt"
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Diana cipher/OTP from Vietnam War era (CC)2023 H.Behrens DL7HH\n"
			.."use: %s\n"
			.."-h	print this help text\n"
			.."-o	one-time-pad (%s)\n"
			.."-s	start (%s) starts in OTP from that group, prints out that group, \n"
			.."\tif there is 5 in it, it will take the first 5 characters as start\n",
			arg[0], filename, start)
		)	
		os.exit(EXIT_FAILURE)
	end,
	["s"]=function(optarg, optind)
		start=optarg:upper():umlauts()
		if tonumber(start)~=nil then start=start:gsub("[%A]","") end -- filter valid characters
	end,
	["o"]=function(optarg, optind)
		file=optarg
	end,
	["?"]=function(optarg, optind)
		io.stderr:write(string.format("unrecognized option %s\n", arg[optind -1]))
		return true
	end,
}
-- quickly process options
for r, optarg, optind in getopt(arg, "o:s:h") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end

if start and tonumber(start)==nil then io.write(start) 
else
	if start then start=io.read(tonumber(start)) end
end
local otp=loadotp(file, start)

local password=otp:gsub("[%A]","") -- filter valid characters
local text=io.read("*a"):upper():umlauts()
text=text:gsub("[%A]","") -- filter valid characters
text=text:diana(password)
io.write(text)


