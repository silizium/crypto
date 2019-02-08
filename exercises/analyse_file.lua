#!/usr/bin/env luajit
require"ccrypt"
local file=assert(io.open(arg[1] or io.stdin, "rb"))
local text=file:read("*a")
file:close()
local p=1
local tab={}
text=text:gsub("[^%s[%z\1-\127\194-\244][\128-\191]]","")
		:gsub("[%p%d\n\t\f'‘\x99\x94\x9d“]", " ")
		:gsub("%s%s+", " ")
		:lower()

-- local psi, sum, tab=text:psi("[^%s%p]+")
local psi, sum, tab=text:psi()
for k,v in ipairs(tab) do 
	io.write(v[2],"\t",string.format("%4.3f",100*v[2]/sum),"\t",v[1],"\n")
end
print("PSI", psi,"SUM",sum)
