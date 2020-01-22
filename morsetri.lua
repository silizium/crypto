#!/usr/bin/env luajit
require"ccrypt"
-- ternery code space 0 dot 1 dash 2
local morse={
	[" "]="",		["A"]="12",		["B"]="2111",	["C"]="2121",	["D"]="211",	
	["E"]="1",		["F"]="1121",	["G"]="221",	["H"]="1111",	["I"]="11",	
	["J"]="1222",	["K"]="212",	["L"]="1211",	["M"]="22",		["N"]="21",	
	["O"]="222",	["P"]="1221",	["Q"]="2212",	["R"]="121",	["S"]="111",
	["T"]="2",		["U"]="112",	["V"]="1112",	["W"]="122",	["X"]="2112",
	["Y"]="2122",	["Z"]="2211",	["0"]="22222",	["1"]="12222",	["2"]="11222",
	["3"]="11122",	["4"]="11112",	["5"]="11111",	["6"]="21111",	["7"]="22111",
	["8"]="22211",	["9"]="22221",	["."]="121212",	[","]="221122",	["?"]="112211",	
	["'"]="122221",	["!"]="212122",	["/"]="21121",	["("]="21221",	[")"]="212212",	
	["&"]="12111",	[":"]="222111",	[";"]="212121",	["="]="21112",	["+"]="12121",	
	["-"]="211112",	["_"]="112212",	["\""]="121121",["$"]="1112112",["@"]="122121",	
	["CH"]="2222",	["SOS"]="111222111",["SMS"]="11122111",
	["END"]="111212",["ERR"]="1111111",
	["START"]="21212",	["\f"]="12121",["ACK"]="11121",["WAIT"]="12111",
	--[""]="",
}
local imorse={} for k,v in pairs(morse) do imorse[v]=k end
function string.morse(text)
	local t={}
	for c in text:utf8all() do
		local m=morse[c]
		if m then 
			t[#t+1]=m 
			t[#t+1]="0"
		end
	end
	return table.concat(t)
end
function string.imorse(text)
	local t={}
	for m,sp in text:gmatch("([12]+)([0]+)") do
		local c=imorse[m]
		if c then
			t[#t+1]=c
			if sp:match("00+") then
				t[#t+1]=" "
			end
		end
	end
	return table.concat(t)
end
local text=io.read"*a":upper():filter("[%c]+")
if arg[1]~="-d" then
	text=text:morse()
else
	text=text:imorse()
end
print(text)
