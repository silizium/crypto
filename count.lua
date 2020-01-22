#!/usr/bin/env luajit
require "ccrypt"

local n=arg[1] and tonumber(arg[1]) or 1

local src=io.read("*a")
local tab=src:count_tuples(n)
for k,v in pairs(tab) do
	io.stderr:write(v[1],"=",v[2],"\t")
end
io.stderr:write("\n")
io.write(src)
