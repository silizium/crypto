#!env luajit
--[[
	read actual WX report and generate a report
	in telegraphy
]]
local decode={
	--intensity
	["-"]={"schwach"}, [" "]="mäßig", ["+"]="stark", ["VC"]="in der Nähe", ["RE"]="kürzlich",
	--descriptor
	["ME"]="flach", ["PR"]="stellenweise", ["BC"]="einzelne Schwaden", ["DR"]="fegend", ["BL"]="treibend", ["SH"]="Schauer", ["TS"]="Gewitter", ["FZ"]="gefrierend", ["WS"]="Windscherung",
	--precipitation
	["DZ"]="Sprühregen", ["RA"]="Regen", ["SN"]="Schnee", ["SG"]="Schneegriesel", ["IC"]="Eisnadeln", ["PL"]="Eiskörner", ["GR"]="Hagel", ["GS"]="Reif", ["UP"]="unbestimmter Niederschlag",
	--obscuration
	["BR"]="feuchter Dunst",["FG"]="Nebel", ["FU"]="Rauch", ["VA"]="vulkanische Asche", ["DU"]="verbreitet Staub", ["gA"]="Sand", ["HZ"]="trockener Dunst", ["PY"]="Sprühnebel",
	--other
	["PO"]="Staub- und Sandwirbel", ["SQ"]="Böen", ["FC"]="Trombe/Windhose", ["SS"]="Sandsturm", ["DS"]="Staubsturm",
	-- cloud
	["SKC"]="menschlicher Report", 
	["NCD"]="nicht bewölkt", ["CLR"]="klar", ["NSC"]="kaum bewölkt", 
	["FEW"]="gering bewölkt", ["SCT"]="vereinzelt bewölkt", ["BKN"]="gebrochen bewölkt", 
	["OVC"]="bewölkt", 
	["TCU"]="turmhafte Cumuluswolken", ["CB"]="Cumulonimbus", 
	["VV"]="Wolken nicht sichtbar wegen geringer Sichtweite",
	-- trend
	["NOSIG"]="keine Änderungen",
	["BECMG"]="veränderlich",
	["TEMPO"]="kurzfristige Änderung",
}

local station="EDDH"
local fp=io.popen("curl -s https://tgftp.nws.noaa.gov/data/observations/metar/stations/"..station..".TXT")
local report=fp:read("*a")
--[[
 EDDH 100850Z AUTO 21008KT 180V260 9999 FEW046 20/10 Q1021 NOSIG
 2022/10/25 07:20
 EDDH 250720Z AUTO 22008KT 9999 SCT012 OVC019 13/12 Q1011 NOSIG
]]--
fp:close()
report=report:gsub("%u%u",function(x) print(x) end)
print(report)
