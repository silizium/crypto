#!/usr/bin/env luajit
require 'ccrypt'

function help()
		io.stderr:write("use: enigma.lua <spruch>,<ring>,<ukw>,<walzen>,<stator>,<steck>\n"..
			"\texample: enigma.lua AAA,(NN-NN-NN|AAA),B,123,1,AE-FC-WI\n"..
			"\t  UKW A=old,B=M3B, C=M3C, D=M4B, E=M4C, Reichsbahn, Schweiz, Abwehr\n"..
			"\t  Walzen 1-8 B=beta G=Gamma\n"..
			"\t  Stator 1=standard, 2=Reichsbahn, Schweiz, Abwehr, 3=Enigma D\n"..
			"\t  Stecker in form AE-OU-CH etc.\n"..
			"\t  -e english numbers\n"..
			"\t  -v verbose\n")
		os.exit()
end

-- Aufruf der Enigma Routinen
if arg[1]=="--help" or arg[1]=="-h" then help() end
local key,decrypt,english,verbose="AAA,1-1-1,B,123,1,",false,false,false
for i=1,#arg do
	if arg[i]=="-d" then
		decrypt=true
	elseif arg[i]=="-e" then
		english=true
	elseif arg[i]=="-v" then
		verbose=true
	else
		key=arg[i]
	end
end

local text=io.read("*a")
text=text:clean(english)
local enigma = Enigma.new(key, verbose)
io.write(enigma:crypt(text))
