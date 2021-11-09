#!/usr/bin/env luajit
require"ccrypt"
local ffi=require"ffi"
local p = require "posix"
local getopt=require"posix.unistd".getopt
local b = bit32 or require "bit"
ffi.cdef[[
	typedef union{
		struct{
		unsigned int b0:2;
		unsigned int b1:2; 
		unsigned int b2:2; 
		unsigned int b3:2; 
		};
		unsigned char byte;
	}bchar;
]]

-- Loopback UDP test, IPV4 and IPV6
function send_udp(data, server, port)
	server = server or "255.255.255.255"
	port = port or 7373
	local fd = p.socket(p.AF_INET, p.SOCK_DGRAM, 0)
	p.setsockopt(fd, p.SOL_SOCKET, p.SO_BROADCAST, 1)
	--local fd = p.socket(p.AF_INET, p.SO_BROADCAST, 0)
	--p.bind(fd, { family = p.AF_INET, addr = "::", port = port })
	--p.sendto(fd, "Test ipv4", { family = p.AF_INET, addr = server, port = port })
	--p.sendto(fd, "Test ipv6", { family = p.AF_INET6, addr = "::", port = 9999 })
	--[[for i = 1, 2 do
		local ok, r = p.recvfrom(fd, 1024)
		if ok then
			print(ok, r.addr, r.port)
		else
			print(ok, r)
		end
	end ]]
	p.sendto(fd, data, {family=p.AF_INET, addr=server, port=port})
	p.close(fd)
end


-- ternery code space 0 dot 1 dash 2
local morse={
	["A"]="12",		["B"]="2111",	["C"]="2121",	["D"]="211",	
	["E"]="1",		["F"]="1121",	["G"]="221",	["H"]="1111",	
	["I"]="11",		["J"]="1222",	["K"]="212",	["L"]="1211",	
	["M"]="22",		["N"]="21",		["O"]="222",	["P"]="1221",	
	["Q"]="2212",	["R"]="121",	["S"]="111",	["T"]="2",		
	["U"]="112",	["V"]="1112",	["W"]="122",	["X"]="2112",
	["Y"]="2122",	["Z"]="2211",	
	["0"]="22222",	["1"]="12222",	["2"]="11222",	["3"]="11122",	["4"]="11112",	
	["5"]="11111",	["6"]="21111",	["7"]="22111",	["8"]="22211",	["9"]="22221",	
	["."]="121212",	[","]="221122",	["?"]="112211",	["'"]="122221",	["!"]="212122",	
	["/"]="21121",	["("]="21221",	[")"]="212212",	
	["&"]="12111",	[":"]="222111",	[";"]="212121",	["="]="21112",	["+"]="12121",	
	["-"]="211112",	["_"]="112212",	["\""]="121121",["$"]="1112112",["@"]="122121",
	["Ä"]="1212", ["Ö"]="2221", ["Ü"]="1122",["ß"]="1112211",
	["È"]="12112", ["É"]="11211", 
	["<CH>"]="2222",	["<SOS>"]="111222111",["<SMS>"]="11122111",
	["<ERR>"]="11111111", ["<KN>"]="21221",
	["<VE>"]="11121",["<AS>"]="12111" --[[Wait]],
	["<KA>"]="21212",["<SK>"]="111212",
	["À"]="12212", ["Ç"]="21211",["Ð"]="11221",["Ĝ"]="22121",["Ĵ"]="12221",
	["Ñ"]="22122", ["Ś"]="1112111",["Þ"]="12211",["Ź"]="221121",["Ż"]="22112",
	--[""]="",
}
local imorse={} for k,v in pairs(morse) do imorse[v]=k end
function string.morse(text)
	local t,tmp={}
	for c in text:utf8all() do
		-- <prosigns>
		if c=="<" or tmp then
			tmp=(tmp or "")..c
			if c==">" then
				c=tmp
				tmp=nil
			else
				goto iter -- iterate until end of prosign
			end
		end
		-- normal char 
		local m=morse[c]
		if c==" " or c=="\n" then m="3" end
		if m then 
			if m=="3" then
				if t[#t]=="0" then
					t[#t]=m
				else
					t[#t+1]=m
				end
			else
				t[#t+1]=m 
				t[#t+1]="0"
			end
		end
	::iter::
	end
	--t[#t]="3"
	return table.concat(t)
end
function string.imorse(text)
	local t={}
	for m,sp in text:gmatch("([12]+)([03]+)") do
		local c=imorse[m]
		if c then
			t[#t+1]=c
			if sp:match("3+") then
				t[#t+1]=" "
			end
		end
	end
	return table.concat(t)
end
function make_header(protocol, serial, wpm)
	local header={}
	header[#header+1]=tostring(protocol)
	serial=b.tobit(serial)
	for i=3,1,-1 do
		header[#header+1]=string.char(b.band(b.rshift(serial,2*(i-1)),3)+48)
	end
	for i=3,1,-1 do
		header[#header+1]=string.char(b.band(b.rshift(wpm,2*(i-1)),3)+48)
	end
	return table.concat(header)
end

local decode, binary, wpm, server, port=false,false,15,"255.255.255.255",7373
for r, optarg, optind in getopt(arg, "hdbw:s:p:") do
	if r == '?' then
		return print('unrecognized option', arg[optind -1])
	end
	last_index = optind
	if r=='h' then
		print("-h	print this help text\n"
			.."-d	decode\n"
			.."-b	bitstream\n"
			.."-w	wpm <5-60>\n"
			.."-s	<server>\n"
			.."-p	<port>"
		)
		os.exit(1)
	elseif r == 'd' then
		decode=true
	elseif r == 'b' then
		binary=true
	elseif r=="w" then
		wpm=tonumber(optarg)
	elseif r=="s" then
		server=optarg
	elseif r=="p" then
		port=tonumber(optarg)
	end
end
local text=io.read"*a":upper():filter("[%c]+")
text=text:gsub("[%z\1-\127\194-\244][\128-\191]*",{["ä"]="Ä",["ö"]="Ö",["ü"]="Ü",
	["è"]="È", ["é"]="É",
	["à"]="À", ["ç"]="Ç",["ð"]="Ð",["ĝ"]="Ĝ",["ĵ"]="Ĵ",
	["ñ"]="Ñ", ["ś"]="Ś",["þ"]="Þ",["ź"]="Ź",["ż"]="Ż",
})
if decode then
	text=text:imorse()
else
	text=text:morse()
	if binary then
		local stream,t={},{}
		local bchar=ffi.new("bchar")
		local protocol,serial=1,0
		local header=make_header(protocol,serial,wpm)
		text=header..text:gsub("3","3"..header)
		text=text:sub(1,#text-1).."3"
		for word in text:gmatch("%d%d%d%d%d%d%d[012]+3") do
			for i=1,#word,4 do
				bchar.b3=word:byte(i) or 48-48
				bchar.b2=word:byte(i+1) or 48-48
				bchar.b1=word:byte(i+2) or 48-48
				bchar.b0=word:byte(i+3) or 48-48
				stream[#stream+1]=string.char(bchar.byte)
			end
			t[#t+1]=table.concat(stream)
			send_udp(t[#t],server,port)
			stream={}
		end
		text=table.concat(t)
	end
end
io.write(text)
