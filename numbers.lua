#!/usr/bin/env luajit
-- convert ascii to numbers
txt=io.read("a*"):upper()
if arg[1]=="-d" then
	for c in txt:gmatch("%d+") do 
		io.write(string.char(tonumber(c)+string.byte("A")-1)) 
	end
else 
	for c in txt:gmatch("%a") do 
		io.write(string.byte(c)-string.byte("A")+1, " ") 
	end
end
