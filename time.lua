#!/usr/bin/env luajit
-- input time in 13:43:34 and with every RETURN the actual time comes up
local socket=require("socket")
local now=os.date("*t") 
now.hour,now.min,now.sec,update=arg[1]:match("(%d*)[:]?(%d*)[:]?(%d*)[u]?(%d*)")
--print(now.hour, now.min, now.sec)
diff=os.difftime(os.time(now),os.time()) 
repeat 
	if update==nil or update=="" or update==0 then 
		local stamp=os.date("%H:%M",os.time()+diff)
		local f=assert(io.popen("xsel --clipboard --input", "w"))
		f:write(stamp)
		f:close()
		io.write(stamp) 
		io.read("*l")
	else
		local stamp=os.date("%H:%M:%S",os.time()+diff)
		io.write(stamp) 
		socket.sleep(tonumber(update))
	end
until false

