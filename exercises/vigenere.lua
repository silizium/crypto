#!/usr/bin/env luajit
function cesar(c, k)
	if c < string.byte("A") or string.byte("Z") < c then
		return c-65
	end
	return (c-65+k)%26
end

function vigenere(text, pass)
	text=text:upper()
	pass=pass:upper()
	local str=""
	local ip=1
	for i=1,#text do
		str=str..string.char(
			65+cesar(text:byte(i), 
				cesar(pass:byte(ip), 0)))
		ip=(ip%#pass)+1
	end
	return str
end

print(vigenere(arg[1], arg[2]))
