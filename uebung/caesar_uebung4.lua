-- caesar_uebung4.lua
function caesar(text, key)
	local char=string.char
	local A=("A"):byte() -- A=65
	local cipher={}
	for i=1,#text do
		cipher[i]=char((text:byte(i)-A+key)%26+A)
	end
	return table.concat(cipher)
end

local text="DERSCHATZLIEGTIMSILBERSEE"
print(text)
local key=13
local encrypt=caesar(text, key) 
print(encrypt)
local decrypt=caesar(encrypt, key)
print(decrypt)