#!/usr/bin/env luajit
require 'dec2bin'
local bits=arg[1] and tonumber(arg[1]) or 8
local text=io.read("*a")
for i=1,#text do
	print(dec2bin(text:byte(i), bits, arg[2]))
end
