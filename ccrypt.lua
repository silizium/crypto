-- ccrypt.lua
require "stable_sort"
--local dump=require "jit.dump"
--require"DataDumper"
--function dump(...) print(DataDumper(...), "\n---") end

ccrypt={}
ccrypt.Unicode="[%z\1-\127\194-\244][\128-\191]*"
local Unicode="("..ccrypt.Unicode..")"
local rshift,lshift,band=bit.rshift,bit.lshift,bit.band

function string.utf8all(text)
	return text:gmatch(Unicode)
end
function string.utf8len(str)
	return select(2, str:gsub(Unicode, ""))
end

function dec2bin(num, bits, symb)
	local Unicode="([%z\1-\127\194-\244][\128-\191]*)"
	bits=bits or 8
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
function bin2dec(txt, bits, symb)
	bits=bits or 8
	symb=symb or "○●"
	local res=0
	txt=txt:gsub("[^"..symb.."]+","")
	for c in txt:utf8all() do
		res=lshift(res,1)
		res=res+(c==symb:match(Unicode,2) and 1 or 0)
	end
	return string.char(res)
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

function string.remove_doublets(text)
	local t,set={},{}
	for c in text:gmatch("%w") do
		if not set[c] then
			t[#t+1]=c
			set[c]=true
		end
	end
	return table.concat(t)
end

function string.sort(text)
	local set={}
	for c in text:utf8all() do
		set[#set+1]=c
	end
	table.sort(set)
	return table.concat(set)
end

function string.filter(input, pat, rep)
	pat = pat or "[%s%p%c]+"
	rep = rep or ""
	return (input:gsub(pat, rep))
end

function string.block(text, blk, lf)
	local blk = blk or 5
	local lf = lf or 5
	local len = 0
	local output = text:gsub("("..ccrypt.Unicode:rep(blk)..")", function(t) 
		len = len + 1
		if lf<0 then return t end
		if lf==0 then return t.." " end
		if len<lf then 
			t = t.." " 
		else 
			t = t.."\n"
			len=0
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
		if s and e and not substitution[a] then 
			substitution[a]=cipher:sub(s,e)
			s=e+1
		end
	end
	return substitution
end

function string.substitute(text, sub_table, pattern)
	sub_table= sub_table or string.sub_table() -- default: caesar
	pattern = pattern or Unicode
	return (string.gsub(text, pattern, sub_table))
end

function string.reduce(text, chars, pattern)
	pattern = pattern or Unicode
	local rtab={}
	local num,extra=chars:upper():match("(%d+)(%a*)")
	num=tonumber(num)
	if tonumber(chars:match("(%d+)"))<=26 then 
		local enc_key={}
		enc_key.ß="SZ" enc_key.Ä="AE" enc_key.Ö="OE" enc_key.Ü="UE" enc_key.Å="AO"
		text=text:substitute(enc_key)
	end
	if num<=25 then 
		if extra=="Q" then
			rtab["Q"]="C"
		else
			rtab["J"]="I" 
		end
	end
	if num<=24 then rtab["U"]="V" end
	if num<=23 then rtab["W"]="VV" end
	if num<=22 then rtab["X"]="CS" end
	if num<=21 then rtab["Y"]="I" end
	if num<=20 then rtab["K"]="C" end
	return (string.gsub(text, pattern, rtab))
end

function string:clean(lang)
	-- wir wandeln erstmal unseren Text in Großbuchstaben
	self=self:upper()
	-- auch die Sonderzeichen wandeln
	local toupper_tab=("äöüéèĉçñ"):subst_table("ÄÖÜÉÈĈÇÑ")
	self=self:substitute(toupper_tab)
	-- und jetzt wandeln wir die Sonderzeichen in ASCII
	local enc_key
	if lang=="english" then
		enc_key={
			["0"]="ZERO",["1"]="ONE",["2"]="TWO",["3"]="THREE",["4"]="FOUR",
			["5"]="FIVE",["6"]="SIX",["7"]="SEVEN",["8"]="EIGHT",["9"]="NINE",
			["ß"]="SZ",["Ä"]="AE",["Ö"]="OE",["Ü"]="UE",["É"]="EE",
			["È"]="E",["Ĉ"]="C", ["Ç"]="C", ["Ñ"]="N",
			["."]="X", [","]="Y", ["!"]="X", ["?"]="X", [";"]="X", --[" "]="X",
		}
	elseif lang=="french" then
		enc_key={
			["0"]="ZERO",["1"]="UN",["2"]="DEUX",["3"]="TROIS",["4"]="QUATRE",
			["5"]="CINQ",["6"]="SIX",["7"]="SEPT",["8"]="HUIT",["9"]="NEUF",
			["ß"]="SZ",["Ä"]="AE",["Ö"]="OE",["Ü"]="UE",["É"]="EE",
			["È"]="E",["Ĉ"]="C", ["Ç"]="C", ["Ñ"]="N",
			["."]="X", [","]="Y", ["!"]="X", ["?"]="X", [";"]="X", --[" "]="X",
		}
	else
		enc_key={
			["0"]="NULL",["1"]="EINS",["2"]="ZWEI",["3"]="DREI",["4"]="VIER",
			["5"]="FUENF",["6"]="SECHS",["7"]="SIEBEN",["8"]="ACHT",["9"]="NEUN",
			["ß"]="SZ",["Ä"]="AE",["Ö"]="OE",["Ü"]="UE",["É"]="EE",
			["È"]="E",["Ĉ"]="C", ["Ç"]="C", ["Ñ"]="N",
			["."]="X", [","]="Y", ["!"]="X", ["?"]="X", [";"]="X", --[" "]="X",
		}
	end
	self=self:substitute(enc_key)
	--[[ Does cause invalid dechiffre but good idea
		text=text:gsub("C[HK]", "Q")	-- CH und CK wurden als Q ersetzt
	]]
	self=self:gsub("[%c%p]+", "") -- alles außer normale Zeichen weglöschen
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

Verwürfelung - transposition

]]--

function sort_column_input()
	table.sort(v,function(a,b) return a.input<b.input end)
end
function sort_column_output()
	table.sort(v,function(a,b) return a.output<b.output end)
end

function table.concat_char(t)
	u={}
	for i=1,#t do
		u[#u+1]=t[i].char
	end
	return table.concat(u)
end

function table.railfence_input_output(rails, length)
	local v={}
	for i=1,rails do v[i]={} end
	local r,inc=1,1
	for i=1,length do
		v[r][(#v[r])+1]={input=i}
		r=r+inc
		if r>rails or r<1 then inc=-inc r=r+inc*2 end
		i=i+1
	end
	-- collapse and place cipher-index
	local u={}
	local i=1
	for k1,v1 in ipairs(v) do
		for k2,v2 in ipairs(v1) do
			v2.output=i
			u[#u+1]=v2
			i=i+1
		end
	end
	return u
end
function string.railfence_encrypt(text,rails)
	if rails<=1 then return text end
	local v=table.railfence_input_output(rails,#text)
	table.stable_sort(v,function(a,b) return a.input<b.input end)
	local i=1
	for c in text:utf8all() do
		v[i].char=c
		i=i+1
	end
	table.stable_sort(v,function(a,b) return a.output<b.output end)
	return table.concat_char(v)
end
function string.railfence_decrypt(text,rails)
	if rails<=1 then return text end
	local v=table.railfence_input_output(rails,#text)
	table.stable_sort(v,function(a,b) return a.output<b.output end)
	local i=1
	for c in text:utf8all() do
		v[i].char=c
		i=i+1
	end
	table.stable_sort(v,function(a,b) return a.input<b.input end)
	return table.concat_char(v)
end

--[[

Würfel cipher

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
	return table.sort(t, function(a,b) return a.nr<b.nr end)
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

--[[

Codebooks

]]--

codebook={}
function codebook.load(file)
	file=file or "otp-book.txt"
	local fp=assert(io.open(file))
--	local text=fp:read("*a")
	local tab={}
	local c,w
	for line in fp:lines() do 
		line=line:upper():umlauts()
		c,w = line:match("^(%S+)%s+(%C+)") 
		if w=="<SPC>" then w=" " end
		if c and w then tab[#tab+1]={code=c,clear=w} end
	end
	fp:close()
	return tab
end

function codebook.figlet(book)
	local fig,let
	for _,v in ipairs(book) do
		if v.clear=="<FIG>" then fig=v.code
		elseif v.clear=="<LET>" then let=v.code
		end
	end
	return fig,let
end

function string.codebook_encode(text,book)
	table.sort(book,function(a,b) 
		return #a.clear>#b.clear or (#a.clear==#b.clear and #a.code>#b.code) 
	end)
--io.stderr:write(dump(book), "\n")
	--for _,b in ipairs(book) do print(b[1], b[2]) end 
	local enc={}
	local fig,let=codebook.figlet(book)
	local figures=false
	local i=1
	while i<=#text do
		local word=""
		for _,w in ipairs(book) do
--io.stderr:write(w.code,"\t",w.clear,"\t",text:sub(i,i+#w.clear-1),"\t",tostring(w.clear==text:sub(i,i+#w.clear-1)),"\n")
			if text:sub(i,i+#w.clear-1)==w.clear then
				if w.clear:match("%d") and not figures then
					word=fig
					figures=true
				end
				if w.clear:match("%D") and figures then
					word=let
					figures=false
				end
				word=word..w.code
				i=i+#w.clear-1
				goto out
			end
		end
		::out::
		enc[#enc+1]=word
		i=i+1
	end
	return table.concat(enc)
end

function string.codebook_decode(text,book)
	table.sort(book,function(a,b) return #a.code>#b.code or (#a.code==#b.code and #a.clear>#b.clear) end)
	--for _,b in ipairs(book) do print(b[1], b[2]) end 
	local dec={}
	local fig,let=codebook.figlet(book)
	local figures=false
	local i=1
	while i<=#text do
		local word=""
		local code,clear
		for _,w in ipairs(book) do
			code,clear=w.code,w.clear
			if text:sub(i,i+#code-1)==code then
				if code==fig then figures=not figures i=i+1 goto out end
				if code==let then figures=false i=i+1 goto out end
				if clear:match("%d") and not figures then
					goto cont
				end
				if clear:match("%D") and figures then
					goto cont
				end
				word=clear
				i=i+#code-1
				goto out
			end
			::cont::
		end
		::out::
		dec[#dec+1]=word
		i=i+1
	end
	return table.concat(dec)
end


-- ENIGMA
-- Objektorientierte Lösung
-- Rad Objekt
local Rad={}
Rad.__index = Rad
setmetatable(Rad, {
  __call = function (cls, ...)
    return cls.new(...)
  end,})
function Rad.new(stellung, ring, coding)	-- Argument "A", "1" zum Beispiel
	local self=setmetatable({}, Rad)
	self.rad={
--       ABCDEFGHIJKLMNOPQRSTUVWXYZ
		"EKMFLGDQVZNTOWYHXUSPAIBRCJ",		-- Rotor 1
		"AJDKSIRUXBLHWTMCQGZNPYFVOE",		-- Rotor 2
		"BDFHJLCPRTXVZNYEIWGAKMUSQO",		-- Rotor 3
		"ESOVPZJAYQUIRHXLNFTGKDCMWB",		-- Rotor 4
		"VZBRGITYUPSDNHLXAWMJQOFECK",		-- Rotor 5
		"JPGVOUMFYQBENHZRDKASXLICTW",		-- Rotor 6
		"NZJHGRCXMYSWBOUFAIVLPEKQDT",		-- Rotor 7
		"FKQHTLXOCBJSPDZRAMEWNIUYGV",		-- Rotor 8
		["B"]="LEYJVCNIXWPBQMDRTAKZGFUHOS", -- Rotor "beta"
		["G"]="FSOKANUERHMBTIYCWLQPZXVGJD", -- Rtoor "gamma"
	}
	self.knocktab={
		-- Royal Flags Wave Kings Above (3xAN)
		{18},{6},{23},{11},{1},{1,14},{1,14},{1,14}
	}
	self:set(stellung) -- Buchstaben->1-26
	self:setring(ring) -- Ringstellung->0-25 (subtrahiert)
	self.coding=self.rad[coding] or coding
	self.knock=self.knocktab[tonumber(coding)] or {}
	return self
end
function Rad:setring(ring)
	self.ring=string.byte(ring)-string.byte("A")
end
function Rad:set(stellung)
	self.stellung=string.byte(stellung)-string.byte("A")+1
end
function Rad:get()
	return string.char(self.stellung+string.byte("A")-1)
end
function Rad:step(step)
	self.stellung=self.stellung+step
	if self.stellung > #self.coding then 
		self.stellung=self.stellung-#self.coding
	elseif self.stellung < 1 then
		self.stellung=self.stellung+#self.coding
	end
	for i=1,#self.knock do
		if self.stellung==self.knock[i] then
			return step,self.stellung
		end
	end
	return 0,self.stellung
end
function Rad:crypt(char)
	local pos=self.stellung-self.ring+string.byte(char)-string.byte("A")
	if pos>#self.coding then
		pos=pos-#self.coding
	elseif pos<1 then
		pos=pos+#self.coding
	end
	char=self.coding:sub(pos,pos)
	pos=string.byte(char)-self.stellung+self.ring+1
	if pos>string.byte("Z") then
		pos=pos-26
	elseif pos<string.byte("A") then
		pos=pos+26
	end
	return string.char(pos)
end
function Rad:rcrypt(char)
	char=string.byte(char)+self.stellung-self.ring-1
	if char<string.byte("A") then 
		char=char+26
	elseif char>string.byte("Z") then
		char=char-26
	end
	pos=self.coding:find(string.char(char))-self.stellung+self.ring+string.byte("A")
	if pos<string.byte("A") then
		pos=pos+26
	elseif pos>string.byte("Z") then
		pos=pos-26
	end
	return string.char(pos)
end

-- Enigma Objekt
Enigma={}
Enigma.__index = Enigma
setmetatable(Enigma, {
  __call = function (cls, ...)
    return cls.new(...)
  end,})
function Enigma.buildsubst(code)
	-- "DE-HA-GI" -> {D="E", E="D", H="A", A="H", G="I", I="G"}
	local steck,control={},{}
	local alpha="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	for c in alpha:gmatch("%u") do
		steck[c]=c
	end
	for c1,c2 in code:gmatch("(%u)(%u)") do
		steck[c1]=c2
		steck[c2]=c1
		if not (control[c1] or control[c2]) then
			control[c1]=true
			control[c2]=true
		else
			error("FAILURE: letter exchange used a second time "..c1.."-"..c2)
		end
	end
	return steck
end
function Enigma.new(password, options)
	local self=setmetatable({}, Enigma)
	self.ukwset={
		Enigma.buildsubst("AE-BJ-CM-DZ-FL-GY-HX-IV-KW-NR-OQ-PU-ST"), -- alt, selten verwendet
		Enigma.buildsubst("AY-BR-CU-DH-EQ-FS-GL-IP-JX-KN-MO-TZ-VW"), -- M3 B
		Enigma.buildsubst("AF-BV-CP-DJ-EI-GO-HY-KR-LZ-MX-NW-QT-SU"), -- M3 C
		Enigma.buildsubst("AE-BN-CK-DQ-FU-GY-HW-IJ-LO-MP-RX-SZ-TV"), -- M4 dünn B
		Enigma.buildsubst("AR-BD-CO-EJ-FN-GT-HK-IV-LM-PW-QZ-SX-UY"), -- M5 dünn C
		Enigma.buildsubst("AQ-BY-CH-DO-EG-FN-IV-JP-KU-LZ-MT-RX-SW"), -- Reichsbahn
		Enigma.buildsubst("AI-BM-CE-DT-FG-HR-JY-KS-LQ-NZ-OX-PW-UV"), -- Schweizer
		Enigma.buildsubst("AR-BU-CL-DQ-EM-FZ-GJ-HS-IY-KO-NT-PW-VX"), -- Abwehr
	}
	self.statorset={
		"ABCDEFGHIJKLMNOPQRSTUVWXYZ",	-- Standard
		"QWERTZUIOASDFGHJKPYXCVBNML",	-- Reichsbahn+Schweizer+Abwehr
		"JWULCMNOHPQZYXIRADKEGVBTSF",	-- Enigma D
	}
	self.verbose=options
	self.rad={}
	password=password:upper()
	local spruch,ring,ukw,walzen,stator,steck=password:match("(%u-),([%w-]-),(%u),(%w-),(%d),(.*)")
	if not(spruch and ring and stator and walzen and ukw and steck) then help()	end

	-- DEBUG
	if self.verbose then io.stderr:write("Stellung: ",spruch," Ring: ",ring," UKW: ",ukw," Walzen: ",walzen," Stator: ",stator, " Stecker: ", steck, "\n") end
	-- END DEBUG
	if ring:match("%d") then
		local a,b,c=ring:match("([%d]*)-([%d]*)-([%d]*)")
		local d=ring:match("[%d]*-[%d]*-[%d]*-([%d]*)")
		if d then
			ring=string.char(64+a,64+b,64+c,64+d)
		else
			ring=string.char(64+a,64+b,64+c)
		end
	end
	for i=1,#spruch do
		walze=walzen:sub(i,i)
		walze=tonumber(walze) or walze
		self.rad[i]=Rad.new(spruch:sub(i,i),ring:sub(i,i),walze)
	end
	self.stator=Rad.new("A","A",self.statorset[tonumber(stator)])
	self.ukw=tonumber(string.byte(ukw)-string.byte("A")+1)
	self.steck=Enigma.buildsubst(steck)
	self.doublestep=false
	return self
end
function Enigma:crypt(text)
	local v={}
	for char in text:gmatch("%a") do
		-- weiterschalten
		local step=1
		for i=#self.rad,#self.rad-2,-1 do
			if i==#self.rad-1 then
				for _,k in ipairs(self.rad[i].knock) do
					local nextstop=self.rad[i].stellung+1
					if nextstop>#self.rad[i].coding then 
						nextstop=nextstop-#self.rad[i].coding 
					end
					if k == nextstop then
						step=1
					end
				end
			end
			step=self.rad[i]:step(step)
		end

		if self.verbose then 
			for i=1,#self.rad do
				io.stderr:write(self.rad[i]:get())
			end
			io.stderr:write("=",char,":") 
		end
			-- Steckbrett
			char=self.steck[char]
		if self.verbose then io.stderr:write(char) end
			-- Stator
			char=self.stator:crypt(char)
		if self.verbose then io.stderr:write(char) end
			-- Hinweg
			for i=#self.rad,1,-1 do
				char=self.rad[i]:crypt(char)
		if self.verbose then io.stderr:write(",R",i,"=",char) end
			end
			-- Reflektor
			char=self.ukwset[self.ukw][char]
		if self.verbose then io.stderr:write(",UKW=",char) end
			-- Rückweg
			for i=1,#self.rad do
				char=self.rad[i]:rcrypt(char)
		if self.verbose then io.stderr:write(",R",i,"=",char) end
			end
			-- Stator -1
			char=self.stator:rcrypt(char)
		if self.verbose then io.stderr:write(char) end
			-- Steckbrett die zweite
			char=self.steck[char]
		if self.verbose then io.stderr:write(char,"\n") end
		v[#v+1]=char
	end
	return table.concat(v)
end


