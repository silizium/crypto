-- caesar_uebung5.lua
function caesar_modulo(text, key)
	local char=string.char
	local A=("A"):byte() -- A=65
	local cipher={}
	for i=1,#text do
		cipher[i]=char((text:byte(i)-A+key)%26+A)
	end
	return table.concat(cipher)
end
function caesar_if(text, key)
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
local text=("ABCDEFGHIJKLMNOPQRSTUVWXYZ"):rep(1e6)
local clock=os.clock
local start=clock()
local a=caesar_if(text, key)
print("IF Variante:", clock()-start, "sec")
start=clock()
local b=caesar_modulo(text, key)
print("Modulo Variante:", clock()-start, "sec")

	