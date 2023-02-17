#!env luajit
-- echo -n "mission begins at dawn.travel to coordinates:30uxc55106318."|./otp.lua|block 5 15
-- https://www.youtube.com/watch?v=MzwpmbIWUNc
require"ccrypt"
local getopt = require"posix.unistd".getopt

function string.umlauts(text)
	local toupper_tab=("äöü"):subst_table("ÄÖÜ")
	text=text:substitute(toupper_tab)
	-- und jetzt wandeln wir die Sonderzeichen in ASCII
	local enc_key={}
	enc_key.ß="SZ" enc_key.Ä="AE" enc_key.Ö="OE" enc_key.Ü="UE"
	text=text:substitute(enc_key)
	return text
end

function loadbook(file)
	file=file or "otp-book.txt"
	local fp=io.open(file)
	local text=fp:read("*a")
	fp:close()
	text=text:upper():umlauts()
	local tab={}
	for c,w in text:gmatch("(%S+)%s+(%C+)\n") do
		if w=="<SPC>" then w=" " end
		if c and w then tab[#tab+1]={c,w} end
	end
	return tab
end

function figlet(book)
	local fig,let
	for _,v in ipairs(book) do
		if v[2]=="<FIG>" then fig=v[1] 
		elseif v[2]=="<LET>" then let=v[1]
		end
	end
	return fig,let
end
function string.codebook_encode(text,book)
	table.sort(book,function(a,b) return #a[2]>#b[2] or (#a[2]==#b[2] and #a[1]>#b[1]) end)
	--for _,b in ipairs(book) do print(b[1], b[2]) end 
	local enc={}
	local fig,let=figlet(book)
	local figures=false
	local i=1
	while i<=#text do
		local word=""
		for _,w in ipairs(book) do
			if text:sub(i,i+#w[2]-1)==w[2] then
				if w[2]:match("%d") and not figures then
					word=fig
					figures=true
				end
				if w[2]:match("%D") and figures then
					word=let
					figures=false
				end
				word=word..w[1]
				i=i+#w[2]-1
				break ::out::
			end
		end
		::out::
		enc[#enc+1]=word
		i=i+1
	end
	return table.concat(enc)
end

function string.codebook_decode(text,book)
	table.sort(book,function(a,b) return #a[1]>#b[1] or (#a[1]==#b[1] and #a[2]>#b[2]) end)
	--for _,b in ipairs(book) do print(b[1], b[2]) end 
	local dec={}
	local fig,let=figlet(book)
	local figures=false
	local i=1
	while i<=#text do
		local word=""
		local code,clear
		for _,w in ipairs(book) do
			code,clear=w[1],w[2]
			if text:sub(i,i+#code-1)==code then
				if code==fig then figures=true  i=i+1 goto out end
				if code==let then figures=false i=i+1 goto out end
				if clear:match("%d") and not figures then
					goto cont
				end
				if clear:match("%D") and figures then
					goto cont
				end
				word=clear
				i=i+#code-1
				goto out
			end
			::cont::
		end
		::out::
		dec[#dec+1]=word
		i=i+1
	end
	return table.concat(dec)
end


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

local bookname,otpname,decrypt,start="otp-book.txt","otp-codes.txt",false
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
local book=loadbook(bookname)
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
