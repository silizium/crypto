#!/usr/bin/env luajit
function cesar(c, k)
	k=k and k or 13
	if c < string.byte("A") or string.byte("Z") < c then
		return c-65
	end
	return (c-65+k)%26
end

function vigenere(text, pass, decrypt)
	decrypt=decrypt and -1 or 1
	text=text:upper()
	pass=pass:upper()
	local str=""
	local ip=1
	for i=1,#text do
		local c=text:byte(i)
		if string.byte("A")<=c and c<=string.byte("Z") then
			str=str..string.char(
				65+cesar(c, 
					cesar(pass:byte(ip)*decrypt, 0)))
			ip=(ip%#pass)+1
		else
			str=str..string.char(c)
		end
	end
	return str
end

print(vigenere(arg[1], arg[2], arg[3]))
