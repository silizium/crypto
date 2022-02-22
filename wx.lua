#!env luajit
--[[
	read actual WX report and generate a report
	in telegraphy
]]

local station="EDDH"
local fp=io.popen("curl -s https://tgftp.nws.noaa.gov/data/observations/metar/stations/"..station..".TXT")
local report=fp:read("*a")
fp:close()
print(report)
