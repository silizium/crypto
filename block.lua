#!/usr/bin/env luajit
require "ccrypt"
local block=arg[1] and tonumber(arg[1]) or 5
local line=arg[2] and tonumber(arg[2]) or 60
local pat=arg[3] or "[%s%c]+"

local str=io.read("*a")
str=str:filter(pat)
io.write(str:block(block, line))
