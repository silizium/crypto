#!/usr/bin/env luajit
-- inserts random errors into a "codegroup" transmission
-- echo This is a test.|codegroup|./errors.lua|codegroup -d
local err=arg[1] and arg[1] or 3
err=err/100
local alpha="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
local txt=io.read("*a"):upper()
math.randomseed(os.time()^5*os.clock())
txt=txt:gsub("([%a]*)%s", function(s)
	if s~="ZZZZZ" and s~="WWWWW" then
		s=s:gsub("%a", function(c)
			if math.random()<=err then
				local pick=math.random(#alpha)
				c=alpha:sub(pick, pick)
			end
			return c
		end)
	end
	return s.." "
end)
io.write(txt)
