-- ccrypt.lua
ccrypt={}
ccrypt.Unicode="[%z\1-\127\194-\244][\128-\191]*"
local Unicode="("..ccrypt.Unicode..")"
local rshift,lshift,band=bit.rshift,bit.lshift,bit.band

function dec2bin(num, bits, symb)
	local Unicode="([%z\1-\127\194-\244][\128-\191]*)"
	bits=bits or 32
	symb=symb or "○●"
	res={}
	local test=lshift(1,bits-1)
	for i=1,bits do
		if band(test,num)~=0 then
			res[#res+1]=symb:match(Unicode, 2)
		else
			res[#res+1]=symb:match(Unicode, 1)
		end
		test=rshift(test,1)
	end
	return table.concat(res)
end

function string.utf8all(text)
	return text:gmatch(Unicode)
end

function string.utf8len(str)
	return select(2, str:gsub(Unicode, ""))
end

function string.filter(input, pat, rep)
	pat = pat or "[%s%p%c]+"
	rep = rep or ""
	return (input:gsub(pat, rep))
end

function string.block(text, block, line)
	local block = block or 5
	local line = line or 60
	local len = 0
	local output = text:gsub("("..ccrypt.Unicode:rep(block)..")", function(t) 
		len = len + t:utf8len()+1
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

function string.shuffle(text)
	local random=math.random
	local t={}
	for c in text:utf8all() do
		t[#t+1]=c
	end
	for i=#t,1,-1 do
		local rnd=random(i)
		t[i], t[rnd] = t[rnd], t[i]
	end
	return table.concat(t)
end

function string.subst_table(alphabet, cipher, key)
	alphabet = alphabet or "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	cipher = cipher or alphabet
	key = key or 0
	key = key % alphabet:utf8len()
	local substitution={}
	-- rotate cipher alphabet
	if key>0 then
		local tmp=cipher:match("("..Unicode:rep(key)..")")
		cipher=cipher:sub(#tmp+1, -1)..tmp
	end
	local s,e
	for a in alphabet:utf8all() do
		s,e = cipher:find(Unicode, s)
		substitution[a]=cipher:sub(s,e)
		s=e+1
	end
	return substitution
end

function string.substitute(text, sub_table, pattern)
	sub_table= sub_table or string.sub_table() -- default: caesar
	pattern = pattern or Unicode
	return (string.gsub(text, pattern, sub_table))
end

function string.utf8tuples(text, chars)
	chars=chars or 1
	local yield=coroutine.yield
	return coroutine.wrap(
	function()
		for skip=0,chars-1 do
			local len=#text:match(Unicode:rep(skip))
			for tpl in text:sub(len+1,-1):gmatch("("..Unicode:rep(chars)..")") do
				yield(tpl)
			end
		end
	end)
end
	
function string.count_tuples(text, num)
	if num==nil or type(num)=="number" then num=num or 1 end
	local cnt={}
	local sum=0
	if type(num)=="number" then
		for tpl in text:utf8tuples(num) do
			cnt[tpl]=cnt[tpl] and cnt[tpl]+1 or 1
			sum=sum+1
		end
	else
		for tpl in text:gmatch(num) do
			cnt[tpl]=cnt[tpl] and cnt[tpl]+1 or 1
			sum=sum+1
		end
	end
	local res={}
	for k,v in pairs(cnt) do
		res[#res+1]={k,v}
	end
	table.sort(res, function(a,b) return a[2]>b[2] end)
	return res, sum
end

function string.psi(text, num)
	local tab, sum, psi
	tab, sum=text:count_tuples(num)
	local psi=0
	for k,v in pairs(tab) do
		psi=psi+v[2]^2
	end
	psi=psi/sum^2
	return psi, sum, tab
end

