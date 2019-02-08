#!/usr/bin/env luajit
require "ccrypt"
local printf=function(fmt, ...) return io.write(string.format(fmt, ...)) end
count, sum={},{}
local psi, sum, tab
psi, sum, tab=("aaaaaaa"):psi(1)
local fmt="%6.3f %6d %6d\t%s\n"
printf(fmt, psi, sum, #tab, "a:rep7")
psi, sum, tab=(("a"):rep(1000).."b"):psi(1)
printf(fmt, psi, sum, #tab, "a:rep100b")
psi, sum, tab=("aaaaaab"):psi(1)
printf(fmt, psi, sum, #tab, "AAAAAAB")
psi, sum, tab=("ab"):psi(1)
printf(fmt, psi, sum, #tab, "ab")
psi, sum, tab=("ab"):rep(100):psi(1)
printf(fmt, psi, sum, #tab, "ab:rep100")
psi, sum, tab=("abcdefg"):psi(1)
printf(fmt, psi, sum, #tab, "abcdefg")
local txt="" for i=0,255 do txt=txt..string.char(i) end
psi, sum, tab=txt:psi(1)
printf(fmt, psi, sum, #tab, "GESAMTERGEBNIS")
-- worte
txt="der schöne, schöne Tag ist schön."
psi, sum, tab=txt:lower():psi("[^%s%p]+")
printf(fmt, psi, sum, #tab, txt)
--for _,v in ipairs(tab) do print(v[1], v[2]) end
txt="der verzückende, berauschende Tag ist freudig."
psi, sum, tab=txt:lower():psi("[^%s%p]+")
printf(fmt, psi, sum, #tab, txt)
--for _,v in ipairs(tab) do print(v[1], v[2]) end
