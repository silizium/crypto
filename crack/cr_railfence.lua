#!/usr/bin/env luajit
require "ccrypt"

local bigrams={["TH"]=3.56, ["HE"]=3.07, ["IN"]=2.43, ["ER"]=2.05, ["AN"]=1.99, 
	["RE"]=1.85, ["ON"]=1.76, ["AT"]=1.49, ["EN"]=1.45, ["ND"]=1.35, ["TI"]=1.34, 
	["ES"]=1.34, ["OR"]=1.28, ["TE"]=1.20, ["OF"]=1.17, ["ED"]=1.17, ["IS"]=1.13, 
	["IT"]=1.12, ["AL"]=1.09, ["AR"]=1.07, ["ST"]=1.05, ["TO"]=1.05, ["NT"]=1.04,
	["NG"]=0.95, ["SE"]=0.93, ["HA"]=0.93, ["AS"]=0.87, ["OU"]=0.87, ["IO"]=0.83, 
	["LE"]=0.83, ["VE"]=0.83, ["CO"]=0.79, ["ME"]=0.79, ["DE"]=0.76, ["HI"]=0.76, 
	["RI"]=0.73, ["RO"]=0.73, ["IC"]=0.70, ["NE"]=0.69,	["EA"]=0.69, ["RA"]=0.69, 
	["CE"]=0.65,
}
local trigrams={
	["THE"]=1.81, ["AND"]=0.73, ["THA"]=0.33, ["ENT"]=0.42, ["ING"]=0.72, 
	["ION"]=0.42, ["TIO"]=0.31, ["FOR"]=0.34, ["OFT"]=0.22, ["STH"]=0.21,
}
function gram_rating(text)
	if #text<2 then return 0 end
	local birate=0
	-- bigrams
	for i=1,#text-1 do
		local bi=text:sub(i,i+1)
		local val=bigrams[bi]
		birate=birate+(val and val or 0)
	end
	birate=birate/(#text-1)

	if #text<3 then return birate end
	local trirate=0
	-- bigrams
	for i=1,#text-2 do
		local tri=text:sub(i,i+1)
		local val=trigrams[tri]
		trirate=trirate+(val and val or 0)
	end
	trirate=trirate/(#text-2)

	return birate+trirate
end

local text=io.read("*a"):upper():umlauts():gsub("[^%w]", "") -- read STDIN 

local max,max_key,max_decrypt=0,0,""
local list={}
for rails=1,#text do
	local decrypt=text:railfence_decrypt(rails)
	local rating=gram_rating(decrypt)
	list[#list+1]={rail=rails,weight=rating,text=decrypt}
	if rating>max then
		max=rating
		max_decrypt=decrypt
		max_key=rails
	end
end
--sorted list
table.sort(list, function(a, b) return a.weight>b.weight end)
--print the first best 30%

local percent=arg[1] or tonumber(arg[1]) or 0.7
for _,v in ipairs(list) do 
	if v.weight<percent*max then break end
	io.stderr:write(string.format("%2d %1.2f %s", v.rail, v.weight, v.decrypt))
end
--best guess
io.stderr:write("\nBest guess - Key: ",max_key," rating: ",max, "\n")
io.write(max_decrypt)

