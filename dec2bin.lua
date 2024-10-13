#!/usr/bin/env luajit
local rshift,lshift,band=bit.rshift,bit.lshift,bit.band
local Unicode="([%z\1-\127\194-\244][\128-\191]*)"
function dec2bin(num, bits, symb)
	bits=bits or 32
	symb=symb or "○●"
	res={}
	local test=lshift(1,bits-1)
	for i=1,bits do
		if band(test,num)~=0 then
			res[#res+1]=symb:match(Unicode, 2)
		else
			res[#res+1]=symb:match(Unicode, 1)
		end
		test=rshift(test,1)
	end
	return table.concat(res)
end
function bin2dec(txt, bits, symb)
	bits=bits or 32
	symb=symb or "○●"
	local res=0
	txt=txt:gsub("[^"..symb.."]+","")
	for c in txt:gmatch(Unicode) do
		print(c,txt,res)
		res=lshift(res,1)
		res=res+(c==symb:match(Unicode,2) and 1 or 0)
	end
	return string.char(res)
end
--[[
local num=arg[1] and tonumber(arg[1])
if not arg[1] then
	print("use: "..arg[0].." <num> <bits> <symbols>")
	os.exit()
end
local bits=arg[2] and tonumber(arg[2])
print(dec2bin(num, bits, arg[3]))
]]
