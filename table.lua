#!/usr/bin/env luajit
for i=1,26 do
	io.write(string.char(i+64),"=",i,"\t")
	if i%5==0 then io.write("\n") end
end
