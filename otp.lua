#!env luajit
-- echo -n "mission begins at dawn.travel to coordinates:30uxc55106318."|./otp.lua|block 5 15
-- https://www.youtube.com/watch?v=MzwpmbIWUNc
require"ccrypt"
local getopt = require"posix.unistd".getopt



function loadotp(file,start)
	file=file or "otp-codes.txt"
	local fp=io.open(file)
	if not fp then return nil end
	local text=fp:read("*a")
	fp:close()
	if start then 
		local s,e=text:find(start)
		if s then text=text:sub(e+1,-1) end
	end
	return text
end
function otp_iter(otp)
	return coroutine.create(function()
		if not otp then repeat coroutine.yield(0) until false return end
		--io.stderr:write(otp)
		for digit in otp:gmatch("%d") do
			coroutine.yield(tonumber(digit))
		end
		return
	end)
end

function string.otp_encrypt(text, otp)
	local otpnext = otp_iter(otp)
	local res,otpnum,err={}
	for w in text:gmatch("%d") do
		if coroutine.status(otpnext)=="suspended" then
			err,otpnum=coroutine.resume(otpnext)
		else
			otpnum=0
		end
		w=tonumber(w)-otpnum
		if w<0 then w=w+10 end
		res[#res+1]=tostring(w)
	end
	return table.concat(res)
end
function string.otp_decrypt(text, otp)
	local otpnext = otp_iter(otp)	
	local res,otpnum,err={}
	for w in text:gmatch("%d") do
		if coroutine.status(otpnext)=="suspended" then
			err,otpnum=coroutine.resume(otpnext)
		else
			otpnum=0
		end
		w=tonumber(w)+otpnum
		if w>9 then w=w-10 end
		res[#res+1]=tostring(w)
	end
	return table.concat(res)
end

local bookname,otpname,decrypt,start="codebooks/funkbuch.txt","otp-codes/test_donotuse.txt",false
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"One-Time-Pad encrypter (CC)2023 H.Behrens DL7HH\n"
			.."use: %s\n"
			.."-h	print this help text\n"
			.."-b	codebook (%s)\n"
			.."-o	one-time-pad (%s)\n"
			.."-s	start at (%s)\n"
			.."-d	decrypt (%s)\n",
			arg[0], bookname, otpname, start, decrypt)
		)	
		os.exit(EXIT_FAILURE)
	end,
	["b"]=function(optarg, optind)
		bookname=optarg
	end,
	["o"]=function(optarg, optind)
		otpname=optarg
	end,
	["s"]=function(optarg, optind)
		start=optarg
	end,
	["d"]=function(optarg, optind)
		decrypt=true
	end,
	["?"]=function(optarg, optind)
		io.stderr:write(string.format("unrecognized option %s\n", arg[optind -1]))
		return true
	end,
}
-- quickly process options
for r, optarg, optind in getopt(arg, "b:o:s:dh") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end

local text=io.read("*a"):upper():umlauts()
local book=codebook.load(bookname)
local otp=loadotp(otpname,start)
local code
if not decrypt then
	code=text:codebook_encode(book)
	code=code:otp_encrypt(otp)
	if start then code=start..code end
else
	if start and text:find(start)==1 then text=text:sub(#start+1,-1) end
	text=text:otp_decrypt(otp)
	code=text:codebook_decode(book)
end
io.write(code)
