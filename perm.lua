#!/usr/bin/env luajit
require"ccrypt"
local function permutation(a, n, cb)
	if n == 0 then
		cb(a)
	else
		for i = 1, n do
			a[i], a[n] = a[n], a[i]
			permutation(a, n - 1, cb)
			a[i], a[n] = a[n], a[i]
		end
	end
end
 
--Usage
local function callback(a)
	print(table.concat(a))
end

if not pcall(debug.getlocal, 4,1) then	--main script
	local tab={}
	if not arg[1] then
		io.stderr:write(string.format(
			"Permutations (CC)2025 Hanno Behrens DL7HH\n"		
			.."use %s <string>\n", arg[0]))
		os.exit(EXIT_FAILURE)
	end
	for c in arg[1]:utf8all() do
		tab[#tab+1]=c
	end
	permutation(tab, #tab, callback)
else -- as library
	return permutation
end 

