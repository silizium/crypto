#!/usr/bin/env luajit
require "ccrypt"
local text=io.read("*a")
local alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜß.,!"
local    runes="ᚪᛒᚲᛞᛖᚠᚷᚺᛇᛃᚴᛚᛗᛜᛟᛈᛩᚱᛊᚦᚢᚡᚹᛪᚤᛎᛅᚯᚣᛋ᛫᛭᛬"
local enc_key=alphabet:subst_table(runes) -- default key=0
local encrypted=text:substitute(enc_key)
io.write(encrypted)
