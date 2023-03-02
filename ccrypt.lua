-- ccrypt.lua
require "stable_sort"
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

function string.genpat(word, known)
	known=known or {}
	local tab,have={},{}
	local found=0
	local nok={}
	for k,v in pairs(known) do
		nok[#nok+1]=k
	end
	nok=table.concat(nok)
	for c in word:utf8all() do
		if known[c] then
			tab[#tab+1]=c
		elseif not have[c] then
			found=found+1
			if found>1 then
				tab[#tab+1]="([^"
				tab[#tab+1]=nok
				for _,v in pairs(have) do
					if v<10 then
						tab[#tab+1]="%"
						tab[#tab+1]=tostring(v)
					end
				end
				tab[#tab+1]="])"
			else
				if nok~="" then
					tab[#tab+1]="([^"
					tab[#tab+1]=nok
					tab[#tab+1]="])"
				else
					tab[#tab+1]="(.)"
				end
			end
			have[c]=found
		else
			if have[c] < 10 then
				tab[#tab+1]="%"
				tab[#tab+1]=tostring(have[c])
			else
				tab[#tab+1]="."
			end
		end
	end
	return table.concat(tab)
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
		if line<0 then return t end
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

function string.utf8reverse(text)
	local t={}
	for c in text:utf8all() do
		t[#t+1]=c
	end
	for i=1,#t/2 do
		t[i], t[#t+1-i] = t[#t+1-i], t[i]
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
function string:clean(english)
	-- wir wandeln erstmal unseren Text in Großbuchstaben
	self=self:upper()
	-- auch die Sonderzeichen wandeln
	local toupper_tab=("äöü"):subst_table("ÄÖÜ")
	self=self:substitute(toupper_tab)
	-- und jetzt wandeln wir die Sonderzeichen in ASCII
	local enc_key
	if english then
		enc_key={
			["0"]="ZERO",["1"]="ONE",["2"]="TWO",["3"]="THREE",["4"]="FOUR",
			["5"]="FIVE",["6"]="SIX",["7"]="SEVEN",["8"]="EIGHT",["9"]="NINE",
			["ß"]="SZ",["Ä"]="AE",["Ö"]="OE",["Ü"]="UE",
			["."]="X", [","]="X", ["!"]="X", ["?"]="X", [";"]="X", --[" "]="X",
		}
	else
		enc_key={
			["0"]="NULL",["1"]="EINS",["2"]="ZWEI",["3"]="DREI",["4"]="VIER",
			["5"]="FUENF",["6"]="SECHS",["7"]="SIEBEN",["8"]="ACHT",["9"]="NEUN",
			["ß"]="SZ",["Ä"]="AE",["Ö"]="OE",["Ü"]="UE",
			["."]="X", [","]="X", ["!"]="X", ["?"]="X", [";"]="X", --[" "]="X",
		}
	end
	self=self:substitute(enc_key)
	--[[ Does cause invalid dechiffre but good idea
		text=text:gsub("C[HK]", "Q")	-- CH und CK wurden als Q ersetzt
	]]
	self=self:gsub("[%c%s%p]+", "") -- alles außer normale Zeichen weglöschen
	return self
end

function string.umlauts(text)
	local toupper_tab=("äöü"):subst_table("ÄÖÜ")
	text=text:substitute(toupper_tab)
	-- und jetzt wandeln wir die Sonderzeichen in ASCII
	local enc_key={}
	enc_key.ß="SZ" enc_key.Ä="AE" enc_key.Ö="OE" enc_key.Ü="UE"
	text=text:substitute(enc_key)
	return text
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
	
--[[
  Statistics
]]--

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
	table.sort(res, function(a,b) return a[2]==b[2] and a[1]<b[1] or a[2]>b[2] end)
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


--[[

Polybios implementation

]]--
function polybios_table(matrix,alphabet)
	local t={}
	for y=1,#matrix do
		for x=1,#matrix do
			t[alphabet:sub(x+#matrix*(y-1),x+#matrix*(y-1))]=matrix:sub(y,y)..matrix:sub(x,x)
		end
	end
	return t
end
function table.invert(t)
	local i={}
	for k,v in pairs(t) do
		i[v]=k
	end
	return i
end
function string.polybios_encrypt(text,matrix,alphabet)
	local t=polybios_table(matrix,alphabet)
	return text:substitute(t)
end
function string.polybios_decrypt(text,matrix,alphabet)
	local t=polybios_table(matrix,alphabet)
	t=table.invert(t)
	return text:substitute(t, "(["..matrix.."]["..matrix.."])")
end

--[[ 

Verwürfelung 

]]--


function sort_column_char(t, password)
	local r=1
	for c in password:gmatch("%w") do
		t[r]={char=c,code=t[r]}
		r=r+1
	end
	table.stable_sort(t,function(a,b) return a.char<b.char end)

	local v={}
	for i=1,#t do
		v[#v+1]=t[i].code
	end
	return table.concat(v)
end
function sort_column_nr(t)
	return table.stable_sort(t, function(a,b) return a.nr<b.nr end)
end

function text_iter(text)
	local nc=coroutine.create(function() 
		for c in text:gmatch("%w") do
			coroutine.yield(c)
		end
	end)
	return nc
end
function string.wuerfelrow_encrypt(text, row)
	local t,len,mod={},math.floor(#text/#row),#text%#row
	local start,ende=1,len

	for i=1,#row do
		if i<=mod then ende=ende+1 end
		t[i]=text:sub(start,ende)
		start=ende+1
		ende=start+len-1
	end
	return sort_column_char(t, row)
end
function string.wuerfelrow_decrypt(text, row)
	local t={}
	for i=1,#row do t[#t+1]={char=row:sub(i,i), nr=i, code=""} end
	
	table.stable_sort(t,function(a,b) return a.char<b.char end)
	
	local len,mod=math.floor(#text/#row),#text%#row
	local start,ende=1,len
	for i=1,#row do
		if t[i].nr<=mod then ende=ende+1 end
		t[i].code=text:sub(start,ende)
		start=ende+1
		ende=start+len-1
	end

	sort_column_nr(t)

	local v={}
	for i=1,#t do
		v[i]=t[i].code
	end
	return table.concat(v)
end
function string.wuerfelcol_encrypt(text,column)
	local t={}
	local r=0
	for c in text:gmatch("%w") do
		if not t[r+1] then t[r+1]={} end
		t[r+1][#t[r+1]+1]=c
		r=(r+1)%#column
	end
	for i,c in ipairs(t) do
		t[i]=table.concat(c)
	end
	return sort_column_char(t, column)
end
function string.wuerfelcol_decrypt(text,column)
	local t={}
	for i=1,#column do t[#t+1]={char=column:sub(i,i),nr=i,code={}} end

	table.stable_sort(t,function(a,b) return a.char<b.char end)

	local nextchar=text_iter(text)
	local r,min,mod=0,math.floor(#text/#column),#text%#column
	repeat
		local _,c=coroutine.resume(nextchar)
		if coroutine.status(nextchar)=="dead" then break end
		local cur=t[r+1]
		cur.code[#cur.code+1]=c
		if #cur.code >= min+(cur.nr<=mod and 1 or 0)  then 
			r=(r+1)%#column
		end
	until false

	sort_column_nr(t)

	local v={}
	local r=1
	while r<=min+1 do
		for i=1,#t do
			v[#v+1]=t[i].code[r]
		end
		r=r+1
	end
	return table.concat(v)
end


