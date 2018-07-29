-- mono_runes.lua
require "ccrypt"
local text=[[ER STAND AUF SEINES DACHES ZINNEN,
ER SCHAUTE MIT VERGNÜGTEN SINNEN]]
local alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜß.,!"
local    runes="ᚪᛒᚲᛞᛖᚠᚷᚺᛇᛃᚴᛚᛗᛜᛟᛈᛩᚱᛊᚦᚢᚡᚹᛪᚤᛎᛅᚯᚣᛋ᛫᛭᛬"
local enc_key=alphabet:subst_table(runes) -- default key=0
local encrypted=text:substitute(enc_key)
print("\n"..encrypted) 
local dec_key=runes:subst_table(alphabet)
print(encrypted:substitute(dec_key))
