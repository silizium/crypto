#!/usr/bin/env luajit
local rshift,lshift,band=bit.rshift,bit.lshift,bit.band
function dec2bin(num, bits, symb)
	local Unicode="([%z\1-\127\194-\244][\128-\191]*)"
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
--[[
local num=arg[1] and tonumber(arg[1])
if not arg[1] then
	print("use: "..arg[0].." <num> <bits> <symbols>")
	os.exit()
end
local bits=arg[2] and tonumber(arg[2])
print(dec2bin(num, bits, arg[3]))
]]
