#!/usr/bin/env luajit
local code=arg[1] and tonumber(arg[1]) or 1337
math.randomseed(code)
local src=io.read("*a")
local rnd=math.random
local write, char=io.write, string.char
local xor, band=bit.bxor, bit.band
for i=1,#src do
	local enc=xor(src:byte(i), rnd(32)-1)
	write(char(enc))
end

