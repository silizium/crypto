#!/usr/bin/env luajit
require "ccrypt"
local seed=arg[1] and tonumber(arg[1]) or os.time()*os.clock()
math.randomseed(seed)
local str
for	str in io.lines() do
	str=str:shuffle()
	print(str)
end
