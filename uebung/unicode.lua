function string.allunicode(text)
	return text:gmatch("([%z\1-\127\194-\244][\128-\191]*)")
end

--[[
	Benutzen wie folgt:
	
	require "unicode"
	txt="Köhlerhütte"
	for c in txt:allunicode() do
		print(c)
	end
]]