#!/usr/bin/env luajit
local function tri2bin()
	local t={}
	local cnt,num=0,0
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
local function bin2tri()
	local t={}
	local cnt,num=0,0
	repeat
		c=io.read(1)
		if not c or cnt>=4 then
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
	print(tri2bin())
else
	print(bin2tri())
end
