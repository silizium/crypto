#!/usr/bin/env luajit
local caesar=require"caesar_fast"
local encrypt, decrypt = caesar.encrypt, caesar.decrypt


local text="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
text=text:rep(1e6)

require "shuffle"
local start=os.clock()
t=encrypt(text, 13)
print(os.clock()-start)


if #arg < 1 then 
	print(string.format("usage: %s <key> [decrypt]", arg[0]))
	os.exit(0)
end
local key=tonumber(arg[1]) or 13
local operate=arg[2]=="decrypt" and decrypt or encrypt
local text=io.read("*a")
local output=operate(text, key)

print("Text", text)
print("Output", output)	
print("Inverse", operate==encrypt and decrypt(output, key) or encrypt(output, key))

