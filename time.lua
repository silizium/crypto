#!/usr/bin/env luajit
-- input time in 13:43:34 and with every RETURN the actual time comes up
local now=os.date("*t") 
now.hour,now.min,now.sec=arg[1]:match("(%d*)[:]?(%d*)[:]?(%d*)")
--print(now.hour, now.min, now.sec)
diff=os.difftime(os.time(now),os.time()) 
repeat 
	local stamp=os.date("%H:%M",os.time()+diff)
	local f=assert(io.popen("xsel --clipboard --input", "w"))
		f:write(stamp)
	f:close()
	io.write(stamp) 
	io.read("*l") 
until false

