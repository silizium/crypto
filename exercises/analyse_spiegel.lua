#!/usr/bin/env luajit
require"ccrypt"
local http=require"socket.http"
body,c,l,h=http.request("http://www.spiegel.de/politik/ausland/brexit-theresa-may-hat-keinen-plan-b-und-kapituliert-vor-dem-parlament-a-1249172.html")
--[[
local htmlparser=require"htmlparser"
local root=htmlparser.parse(body)
local elements=root:select("p")
for _,e in ipairs(elements) do
	--print(e.name)
	local text=e:getcontent() -- :gsub("%b<>", "")
	print(text)
end
]]
local p=1
local tab={}
for text in body:gmatch("<p>(.-)</p>") do
	if p>2 then
		text=text:gsub("%b<>",""):gsub("[^%s[%z\1-\127\194-\244][\128-\191]]","")
			:gsub("[%p\n]", " ")
			:gsub("%s%s+", " ")
			:gsub("©.+", "")
		tab[#tab+1]=text
	else
		p=p+1
	end
end
local text=table.concat(tab)

psi, sum, tab=text:lower():psi("[^%s%p]+")
for k,v in ipairs(tab) do 
	io.write(v[2],"\t",string.format("%4.3f",100*v[2]/sum),"\t",v[1],"\n")
end
print("PSI", psi,"SUM",sum)
