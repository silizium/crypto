#!/usr/bin/env luajit
require"ccrypt"
-- ternery code space 0 dot 1 dash 2
local morse={
	["A"]="12",		["B"]="2111",	["C"]="2121",	["D"]="211",	
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
	["Ä"]="1212", ["Ö"]="2221", ["Ü"]="1122",["ß"]="1112211",
	["<CH>"]="2222",	["<SOS>"]="111222111",["<SMS>"]="11122111",
	["<ERR>"]="1111111", ["<KN>"]="21221",
	["\f"]="12121",["<VE>"]="11121",["<WAIT>"]="12111",
	["<KA>"]="21212",["<SK>"]="111212",
	--[""]="",
}
local imorse={} for k,v in pairs(morse) do imorse[v]=k end
function string.morse(text)
	local t,tmp={},""
	for c in text:utf8all() do
		if c=="<" or #tmp>0 then
			tmp=tmp..c
			if c==">" then
				c=tmp
				tmp=""
			else
				goto iter
			end
		end
		local m=morse[c]
		if c==" " or c=="\n" then m="3" end
		if m then 
			if m=="3" then
				if t[#t]=="0" then
					t[#t]=m
				else
					t[#t+1]=m
				end
			else
				t[#t+1]=m 
				t[#t+1]="0"
			end
		end
	::iter::
	end
	return table.concat(t)
end
function string.imorse(text)
	local t={}
	for m,sp in text:gmatch("([12]+)([03]+)") do
		local c=imorse[m]
		if c then
			t[#t+1]=c
			if sp:match("3+") then
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
