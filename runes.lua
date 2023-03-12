#!/usr/bin/env luajit
require "ccrypt"
local text=io.read("*a"):upper()
text=text:substitute(("äöü"):subst_table("ÄÖÜ"))
local alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜß.,!"
local    runes="ᚪᛒᚲᛞᛖᚠᚷᚺᛇᛃᚴᛚᛗᛜᛟᛈᛩᚱᛊᚦᚢᚡᚹᛪᚤᛎᛅᚯᚣᛋ᛫᛭᛬"

local enc_key,encrypted
if arg[1]=="-d" then
        enc_key=runes:subst_table(alphabet)
else
        enc_key=alphabet:subst_table(runes) -- default key=0
end
encrypted=text:substitute(enc_key)

io.write(encrypted)
