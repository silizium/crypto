function string.filter(input, pat, rep)
	pat = pat or "[%s%p%c]+"
	rep = rep or ""
	return input:gsub(pat, rep) 
end

function string.block(text, block, line)
	local block = block or 5
	local line = line or 60
	local len = 0
	local output = text:gsub(string.rep("%C", block), function(t) 
		len = len + #t+1
		if len>line then 
			len=0
			t = t.."\n"
		else 
			t = t.." " 
		end
		return t 
	end)
	return output
end
