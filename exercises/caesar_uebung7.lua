-- caesar_uebung7.lua
function caesar_table(text, key)
	cipher={}
	for i=1, #text do
		cipher[i]=key[text:sub(i,i)]
	end
	return table.concat(cipher)
end

function caesar_gsub(text, key)
	return string.gsub(text, ".", key)
end

function caesar_gsub_unicode(text, key)
	return string.gsub(text, "([%z\1-\127\194-\244][\128-\191]*)", key)
end

local tab={
	A="N", B="O", C="P", D="Q", E="R", F="S", 
	G="T", H="U", I="V", J="W", K="X", L="Y", M="Z",
	N="A", O="B", P="C", Q="D", R="E", S="F", 
	T="G", U="H", V="I", W="J", X="K", Y="L", Z="M"}
local text=("ABCDEFGHIJKLMNOPQRSTUVWXYZ"):rep(1e6)
local clock=os.clock
local start=clock()
local a=caesar_table(text, tab)
print("       Table Variante:", clock()-start, "sec")
print(a:sub(1,52))

clock=os.clock
start=clock()
local b=caesar_gsub(text, tab)
print("        Gsub Variante:", clock()-start, "sec")
print(b:sub(1,52))

clock=os.clock
start=clock()
local c=caesar_gsub_unicode(text, tab)
print("Unicode-Gsub Variante:", clock()-start, "sec")
print(c:sub(1,52))
