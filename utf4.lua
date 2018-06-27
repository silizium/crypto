#!/usr/bin/env luajit
-- require "ccrypt"
local trickle=require "trickle"
utf4={}
local tab={
--   12345678
	" enisrat",
	"bcdfghjk"..
	"lmopquvw"..
	"xyz.,?!:"..
	"01234567"..
	"89+-*/&="..
	"()[]{}<>"..
	"~;^|#%'\""..
	"\\DSEIWKA",
--   1234567812345678123456781234567812345678123456781234567812345678
	"\0\1\2\3\4\5\6\7\8\9\10\11\13\14\15\16"..
	"\17\18\19\20\21\22\23\24\25\26\27\28\29\30\31\255"..
	"BCFGHJLMNOPQRTUVXYZ_`°@¡¤¦§¨©ª¬­®¯°±´µ¶·¸u"..
	"…«»„”‟’‚″‹›‼‽⁇⁈".. -- Anführungszeichen
	"$€¢£¥₠₣₤₥₦₧₨₩₪€₯₰₱₲₳₴₵₸₹₺₻₽₿".. -- Währungen
	"¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ"..
	"º¹²³⁴⁵⁶⁷⁸⁹₀₁₂₃₄₅₆₇₈₉⅐¼½¾⅑⅒⅓⅔⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞⅟".. -- spezielle Zahlen
	"ĀāĂăĄąĆćĈĉĊċČčĎďĐđĒēĔĕĖė"..
	"ĳĲŒœӔӕﬀﬁﬂﬃﬄﬅﬆ" -- Ligaturen
}
local band, bor, lshift, rshift=bit.band, bit.bor, bit.lshift, bit.rshift
local byte, char=string.byte, string.char
local Unicode="[%z\1-\127\194-\244][\128-\191]*"
function string.utf8all(text)
	return text:gmatch("("..Unicode..")")
end
function utf4.encode(src)
	local dst={}
	for c in src:utf8all() do
		local i=(tab[1]:find(c, 1, true))
		if i then 
			i=i-1 
		elseif (tab[2]:find(c, 1, true)) then
			i=(tab[2]:find(c, 1, true))-1
			i=bor(band(i,0x7), lshift(band(i,0x38),1),0x8)
		elseif (tab[3]:find(c, 1, true)) then
			i=-1 --=(tab[3]:find(c, 1, true))-1
			for uni in tab[3]:utf8all() do i=i+1 if uni==c then break end end
			i=bor(band(i,0x7), lshift(band(i,0x38),1), lshift(band(i, 0x1C0), 2),0x88)
		else	-- Standard Unicode
			i=c:byte(1)
			i=bor(band(i,0x7), lshift(band(i,0x38),1), lshift(band(i, 0x1c0), 2),0x888)
			i={i, c:sub(2)}
		end
		dst[#dst+1]=i
	end
	local stream=trickle.create()
	for k,v in ipairs(dst) do
		if type(v)=="number" then
			if v<0x8 then
				stream:writeBits(v, 4)
			elseif v<0x80 then
				stream:writeBits(v, 8)
			else
				stream:writeBits(v, 12)
			end
		else -- normal Unicode
			stream:writeBits(v[1], 12)
			for i=1,#v[2] do stream:writeBits(v[2]:byte(i),8) end
		end
	end
	return tostring(stream)
end
function utf4.decode(src)
	local dst={}
	local stream=trickle.create(src)
	while #stream.str>0 do
		local v=stream:readBits(4)
		if v<8 then
			dst[#dst+1]=tab[1]:sub(v+1,v+1)
		else
			local v1=stream:readBits(4)
			if v1<0x8 then
				local i=bor(band(v,0x7), lshift(v1, 3))+1
				dst[#dst+1]=tab[2]:sub(i,i)
			else
				local v2=stream:readBits(4)
				local i=bor(band(v,0x7), 
					lshift(band(v1,0x7), 3), 
					lshift(v2,6))+1
				if v2<0x8 then
					local s,e=1,0
					for y=1,i do s,e=tab[3]:find(Unicode, e+1) end
					dst[#dst+1]=tab[3]:sub(s,e)
				else
					local mask=0x40
					dst[#dst+1]=char(band(i-1,0xFF))
					while band(mask,i)~=0 do
						dst[#dst+1]=char(stream:readBits(8))
						mask = rshift(mask,1)
					end
				end
			end
		end
	end
	return table.concat(dst)
end

-- Austesten
-- for _, i in ipairs(tab) do print(i:utf8len(), i) end os.exit()

local encode, decode=utf4.encode, utf4.decode
local src=io.read("*a")

if arg[1]~="-d" then
	src=encode(src)
else
	src=decode(src)
end
io.write(src)

--[[
0	SPACE	C	/	0
1	E		G	J	1
2	N		M	Y	2
3	D		O	X	3
4	I		B	Q	4
5	R		W	LF	5
6	A		F	=	6
7	T		K	(	7
8	S		Z	)	8
9	H		P	!	9
A	U		V	:	+
B	L		,	;	-
C	.		GR0	GR0	GR0
D	GR1		?	GR1	GR1
E	GR2		GR2	"	GR2
F	GR3		GR3	GR3	% ]]
