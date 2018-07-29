-- mono_modify.lua
require "ccrypt"

local alpha="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
local CARONBELOW="\xCC\xAC" -- n̬
local RINGABOVE="\xCC\x87" -- n̊
local X="\xCD\x93" -- n͓
local LOWLINE="\xCC\xB1" -- n̲
local APICAL="\xCC\xBA" -- n̺
local cipher=CARONBELOW.."bcd"..RINGABOVE.."fgh"..
	X.."jklmn"..LOWLINE.."pqrst"..APICAL.."vwxyz"

text=[[Durch diese hohle Gasse muss er kommen. 
	Es fuehrt kein andrer Weg nach Kuessnacht.]]
key=0
text=text:upper():filter()
local enc=alpha:subst_table(cipher, key)
encrypt=text:substitute(enc)
print(encrypt, "\n")
