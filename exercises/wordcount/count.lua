#!/usr/bin/env luajit
text=io.read("*a")
text=text:gsub("%G", "")
count={}
for c in text:gmatch(".") do
	count[c]=count[c] and count[c]+1 or 1
end
sort={}
for k,v in pairs(count) do
	sort[#sort+1]={k,v}
end
table.sort(sort, function(a,b) return a[2]>b[2] end)
for k,v in ipairs(sort) do
	io.write(v[1],"=",v[2],"\t")
end

