#!/usr/bin/env luajit
local t,cnt,num={},0,0
local function tri2hex()
	repeat
		c=tonumber(io.read(1))
		if not c or cnt>=40 then
			cnt=0
			t[#t+1]=string.format("%x",num)
			num=0
		end
		if c then
			num=num*3+c
			cnt=cnt+1
		end
	until not c
	return table.concat(t," ")
end
local function hex2tri()
	repeat
		c=io.read(1):upper():match("[0-9A-F ]")
		if not c or c==" " then
			cnt=0
			t[#t+1]=num
			num=0
		end
		if c then
			num=num*3+c
			cnt=cnt+1
		end
	until not c
	return table.concat(t," ")
end
if arg[1]~="-d" then
	print(tri2hex())
else
	print(hex2tri())
end
