#!/usr/bin/env luajit
require "ccrypt"
--[[ function string.shuffle(text)
	local t={text:byte(1,-1)}
	local random=math.random
	for i=#t,1,-1 do
		local rnd=random(i)
		t[i], t[rnd] = t[rnd], t[i]
	end
	return string.char(unpack(t))
end
]]

--[[
local s="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
math.randomseed(os.time()*os.clock())
local t=s:shuffle()
print(t)
]]
local text=io.read("*a")
local start=arg[1] and tonumber(arg[1]) or os.time()*os.clock()
math.randomseed(start)
text=text:filter()
text=text:upper()
local toupper_tab=("äöü"):subst_table("ÄÖÜ")
text=text:substitute(toupper_tab)
text=text:gsub(ccrypt.Unicode, {["ß"]="SS"})
text=(text:shuffle())
print(text:block())
