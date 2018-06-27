#!/usr/bin/env luajit
require "ccrypt"
local block=arg[1] and tonumber(arg[1]) or 5
local line=arg[2] and tonumber(arg[2]) or 60

local str=io.read("*a")
str=str:filter()
io.write(str:block(block, line))
