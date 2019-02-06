#!/usr/bin/env luajit
require "ccrypt"

text="ES GIBT EIN SCHWERES PROBLEM MIT UNSERER FAHRZEUGKOLONNE. BRAUCHEN DRINGEND EINEN MECHANIKER. UNS GEHT DAS WASSER AUS."
--text="THERE IS A SEVERE PROBLEM WITH OUR VEHICLE COLUMN. URGENT NEED OF A MECHANIC. WE RUN OUT OF WATER."

count, sum={},{}
text=text:filter("[%p%c%s]+")
--[[for i=1,3 do
	count[i], sum[i]=text:count_tuples(i)
end	

for i=1,3 do
	for k,v in ipairs(count[i]) do
		print(k, v[1], v[2])
	end
	print("Sum", sum[i])
end
print(#text)]]
print(text)

local num=5
local psi, sum, tab
for i=1,num do
	psi, sum, tab=text:psi(i)
	print(i, psi, sum, #tab)
end

