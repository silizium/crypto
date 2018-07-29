local rnd, seed=math.random, math.randomseed
local startwert=arg[1] and tonumber(arg[1]) or os.time()
seed(startwert)
for i=1,10 do
	io.write(rnd(2)-1, "\t")
end
print()
