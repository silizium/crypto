#!/usr/bin/env luajit
require "ccrypt"
local text=io.read("*a")
local alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜßabcdefghijklmnopqrstuvwxyzäöü0123456789.,!+-#;:-@|»«›‹„“'\"\\€¢µ"
local runes="🜀🜁🜂🜃🜄🜅🜆🜇🜈🜉🜊🜋🜌🜍🜎🜏🜐🜑🜒🜓🜔🜕🜖🜗🜘🜙🜚🜛🜜🜝🜞🜟🜠🜡🜢🜣🜤🜥🜦🜧🜨🜩🜪🜫🜬🜭🜮🜯🜰🜱🜲🜳🜴🜵🜶🜷🜸🜹🜺🜻🜼🜽🜾🜿🝀🝁🝂🝃🝄🝅🝆🝇🝈🝉🝊🝋🝌🝍🝎🝏🝐🝑🝒🝓🝔🝕🝖🝗🝘🝙🝚🝛🝜🝝🝞🝟🝠🝡🝢🝣🝤🝥🝦🝧🝨🝩🝪🝫🝬🝭🝮🝯🝰🝱🝲🝳"

local enc_key,encrypted
if arg[1]=="-d" then
	enc_key=runes:subst_table(alphabet)
else
	enc_key=alphabet:subst_table(runes) -- default key=0
end
encrypted=text:substitute(enc_key)

io.write(encrypted)
