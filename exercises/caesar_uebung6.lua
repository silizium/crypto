-- caesar_uebung6.lua
function caesar_string(text, key)
	key=key%26  -- key ist immer positiv
	local char=string.char
	local A=("A"):byte() -- A=65
	local cipher=""
	for i=1,#text do
		local c=(text:byte(i)-A+key)
		if c>25 then c=c-26 end
		cipher=cipher..char(c+A)
	end
	return cipher
end
function caesar_concat(text, key)
	key=key%26  -- key ist immer positiv
	local char=string.char
	local A=("A"):byte() -- A=65
	local cipher={}
	for i=1,#text do
		local c=(text:byte(i)-A+key)
		if c>25 then c=c-26 end
		cipher[i]=char(c+A)
	end
	return table.concat(cipher)
end

local key=13
local text=("ABCDEFGHIJKLMNOPQRSTUVWXYZ"):rep(1e5)
local clock=os.clock
local start=clock()
local a=caesar_concat(text, key)
print("Concat Variante:", clock()-start, "sec")
start=clock()
local b=caesar_string(text, key)
print("String Variante:", clock()-start, "sec")
