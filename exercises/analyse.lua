#!/usr/bin/env luajit
require "ccrypt"
count, sum={},{}
local psi, sum, tab
psi, sum, tab=("aaaaaaa"):psi(1)
print(psi, sum, #tab, "a:rep7")
psi, sum, tab=(("a"):rep(1000).."b"):psi(1)
print(psi, sum, #tab, "a:rep100b")
psi, sum, tab=("aaaaaab"):psi(1)
print(psi, sum, #tab, "AAAAAAB")
psi, sum, tab=("ab"):psi(1)
print(psi, sum, #tab, "ab")
psi, sum, tab=("ab"):rep(100):psi(1)
print(psi, sum, #tab, "ab:rep100")
psi, sum, tab=("abcdefg"):psi(1)
print(psi, sum, #tab, "abcdefg")
local txt="" for i=0,255 do txt=txt..string.char(i) end
psi, sum, tab=txt:psi(1)
print(psi, sum, #tab)
-- worte
txt="der schöne, schöne Tag ist schön."
psi, sum, tab=txt:lower():psi("[^%s%p]+")
print(psi, sum, #tab, txt)
--for _,v in ipairs(tab) do print(v[1], v[2]) end
txt="der verzückende, berauschende Tag ist freudig."
psi, sum, tab=txt:lower():psi("[^%s%p]+")
print(psi, sum, #tab, txt)
--for _,v in ipairs(tab) do print(v[1], v[2]) end
