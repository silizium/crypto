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
function send_udp(data, server, port, broadcast)
	server = server or "255.255.255.255"
	port = port or 7373
	local fd = p.socket(p.AF_INET, p.SOCK_DGRAM, 0)
	if broadcast then p.setsockopt(fd, p.SOL_SOCKET, p.SO_BROADCAST, 1) end
	--[[
	p.bind(fd, { family = p.AF_INET6, addr = "::", port = port })
	p.sendto(fd, "Test ipv4", { family = p.AF_INET, addr = server, port = port })
	p.sendto(fd, "Test ipv6", { family = p.AF_INET6, addr = "::", port = 9999 })
	for i = 1, 2 do
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
function listen_udp(server, port, broadcast)
	server = server or "255.255.255.255"
	port = port or 7373
	local fd = p.socket(p.AF_INET, p.SOCK_DGRAM, 0)
	if broadcast then p.setsockopt(fd, p.SOL_SOCKET, p.SO_BROADCAST, 1) end
	p.bind(fd, { family = p.AF_INET, addr = server, port = port })
	--[[
	p.sendto(fd, "Test ipv4", { family = p.AF_INET, addr = server, port = port })
	p.sendto(fd, "Test ipv6", { family = p.AF_INET6, addr = "::", port = 9999 })
	for i = 1, 2 do
		local ok, r = p.recvfrom(fd, 1024)
		if ok then
			print(ok, r.addr, r.port)
		else
			print(ok, r)
		end
	end ]]
	--p.sendto(fd, data, {family=p.AF_INET, addr=server, port=port})
	--p.close(fd)
	return fd
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
--[[ binary header creation for Morserino-32 MOPP
	2bit protocol version
	6bit serial number
	6bit speed 5-60
]]
function make_header(protocol, serial, wpm)
	protocol=tostring(protocol)
	serial=b.tobit(serial)
	local tmp={}
	for i=3,1,-1 do
		tmp[#tmp+1]=string.char(b.band(b.rshift(wpm,2*(i-1)),3)+48)
	end
	wpm=table.concat(tmp)
	tmp=nil
	return function()
		local header={}
		header[#header+1]=protocol
		for i=3,1,-1 do
			header[#header+1]=string.char(b.band(b.rshift(serial,2*(i-1)),3)+48)
		end
		header[#header+1]=wpm
		serial=serial+1
		return table.concat(header)
	end
end

-- Options
local 	decode, binary, wpm, server, 			port, broadcast=
		false,	false,	15,	"255.255.255.255",	7373,  false	
local fopt={
	["h"]=function(optarg,optind) 
		print("-h	print this help text\n"
			.."-d	decode\n"
			.."-b	bitstream\n"
			.."-w	wpm <5-60>\n"
			.."-s	<server>\n"
			.."-p	<port>\n"
			.."-B	Broadcast\n"
		)
		os.exit(1)
	end,
	["d"]=function(optarg, optind)
		decode=true
	end,
	["b"]=function(optarg, optind)
		binary=true
	end,
	["w"]=function(optarg, optind)
		wpm=tonumber(optarg)
	end,
	["s"]=function(optarg, optind)
		server=optarg
	end,
	["p"]=function(optarg, optind)
		port=tonumber(optarg) 
	end,
	["B"]=function(optarg, optind)
		broadcast=true 
	end,
	["?"]=function(optarg, optind)
		print('unrecognized option', arg[optind -1])
		return true
	end,
	}
-- quickly process options
for r, optarg, optind in getopt(arg, "hdbw:s:p:B") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end
if decode then
	if binary then
		local fd=listen_udp(server,port,broadcast)
		repeat
			local ok, r=p.recv(fd, 1024) -- ok=meg, r.addr, r.port, r.family, r.rec
			--print(r.addr, r.port, r.family, r.rec)
			if ok then
				local t={}
				for i=1,#ok do
					local c=b.tobit(ok:byte(i))
					for j=3,0,-1 do
						t[#t+1]=string.char(b.band(b.rshift(c,j*2),3)+48)
					end
				end
				t=table.concat(t)
				t=t:sub(8,-1)..(t:sub(-2,-1)=="3" or "" and "3")
				t=t:imorse()
				io.stdout:flush()
				io.stdout:write(t)
				io.stdout:flush()
			end
		until not ok
		p.close(fd)
	else
		text=text:imorse()
	end
else -- encoding
	-- read all text
	repeat
		text=io.read"*l"
		if not text then break end
		text=text:upper():filter("[%c]+")
	-- convert all chars to uppercase
		text=text:gsub("[%z\1-\127\194-\244][\128-\191]*",{["ä"]="Ä",["ö"]="Ö",["ü"]="Ü",
			["è"]="È", ["é"]="É",
			["à"]="À", ["ç"]="Ç",["ð"]="Ð",["ĝ"]="Ĝ",["ĵ"]="Ĵ",
			["ñ"]="Ñ", ["ś"]="Ś",["þ"]="Þ",["ź"]="Ź",["ż"]="Ż",
		})
		text=text:morse()
		if binary then
			local stream,t={},{}
			local bchar=ffi.new("bchar")
			local protocol,serial=1,0
			local header=make_header(protocol, serial, wpm)
			for word in text:gmatch("([^3]+)") do
				--io.stderr:write(word,"\n")
				word=word:gsub("[03]$","").."3"
				--io.stderr:write(word,"\n")
				word=header()..word
				for i=1,#word,4 do
					bchar.b3=word:byte(i) or 48-48
					bchar.b2=word:byte(i+1) or 48-48
					bchar.b1=word:byte(i+2) or 48-48
					bchar.b0=word:byte(i+3) or 48-48
					stream[#stream+1]=string.char(bchar.byte)
				end
				word=table.concat(stream)
				send_udp(word,server,port,broadcast)
				stream={}
				io.write(word)
			end
		else
			io.write(text)
		end
	until false
end
