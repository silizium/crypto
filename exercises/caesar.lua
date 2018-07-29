caesar={}
function caesar.encrypt(text, key, cipher)
	key = (key or 13) % 26
	cipher=cipher and cipher:upper() or "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	cipher=cipher:rep(2)
	-- build table
	local trans={}
	local A, a=('A'):byte(), ('a'):byte()
	for i=1,#cipher do
		trans[i-1]=cipher:byte(i)-A
	end
	-- do encryption
	local out={}
	for i=1,#text do
		local c=text:byte(i)
		local base = c>=a and a or A
		out[i]=trans[c-base+key]
		out[i]=out[i] and string.char(out[i]+base) or string.char(c)
	end
	return table.concat(out)
end

function caesar.decrypt(text, key, cipher)
	key = key or 13
	cipher=cipher and cipher:upper() or "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	local A=string.byte('A')
	local decipher={}
	for i=1,#cipher do
		decipher[cipher:byte(i)-A+1]=string.char(i-1+A)
	end
	decipher=table.concat(decipher)
	print("Decipher", decipher)
	return caesar.encrypt(text, key, decipher)
end

local text="ABCDEFGHIJKLMNOPQRSTUVWXYZ Eins Zwei Drei The quick brown fox jumps over the lazy dog."

require "shuffle"
math.randomseed(os.time()*os.clock())
key=("BACDEFGHIJKLMNOPQRSTUVWXYZ"):reverse() --:shuffle()
local start=os.clock()
local shift=3
t=caesar.encrypt(text, shift, key)
print(os.clock()-start)
print("Text   ", text)
print("Encrypt", t)
print("Key    ", key, shift)
print("Decrypt", caesar.decrypt(t, shift, key))
