#!/usr/bin/env luajit
local file=assert(io.popen("john --stdout --wordlist " .. (arg[1] and arg[1] or "--rules:best64")))
local line=1
for pass in file:lines("*l") do
	io.write(string.format("%d Passwort: \"%s\"\n", line, pass))
	line=line+1
end
file:close()
