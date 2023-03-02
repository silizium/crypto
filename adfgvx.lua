#!env luajit
require "ccrypt"
local getopt = require"posix.unistd".getopt

function string.umlauts(text)
	local toupper_tab=("äöü"):subst_table("ÄÖÜ")
	text=text:substitute(toupper_tab)
	-- und jetzt wandeln wir die Sonderzeichen in ASCII
	local enc_key={}
	enc_key.ß="SZ" enc_key.Ä="AE" enc_key.Ö="OE" enc_key.Ü="UE"
	text=text:substitute(enc_key)
	return text
end

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

function polybios_table(alphabet,matrix)
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
function string.polybios_encrypt(text,alphabet,matrix)
	local t=polybios_table(alphabet, matrix)
	return text:substitute(t)
end
function string.polybios_decrypt(text,alphabet,matrix)
	local t=polybios_table(alphabet, matrix)
	t=table.invert(t)
	return text:substitute(t, "(["..matrix.."]["..matrix.."])")
end

function string.adfgvx_encrypt(text, alphabet, matrix, column, row)
	text=text:polybios_encrypt(alphabet,matrix)
	if column then text=text:wuerfelcol_encrypt(column) end
	if row	  then text=text:wuerfelrow_encrypt(row) end
	return text
end

function string.adfgvx_decrypt(text, alphabet, matrix, column, row)
	if row then text=text:wuerfelrow_decrypt(row) end
	if column then text=text:wuerfelcol_decrypt(column) end
	text=text:polybios_decrypt(alphabet,matrix)
	return text
end

local alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
local matrix,decrypt,column,row="ADFGVX",false
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"AFDGVX encrypter (CC)2023 H.Behrens DL7HH\n"
			.."use: %s\n"
			.."-h	print this help text\n"
			.."-a	alphabet (%s)\n"
			.."-m	matrix (%s)\n"
			.."-c	column (%s)\n"
			.."-r	row (%s)\n"
			.."-d	decrypt (%s)\n",
			arg[0], alphabet, matrix, column, row, decrypt)
		)	
		os.exit(EXIT_FAILURE)
	end,
	["a"]=function(optarg, optind)
		alphabet=optarg:upper():umlauts()
	end,
	["m"]=function(optarg, optind)
		matrix=optarg:upper():umlauts()
	end,
	["r"]=function(optarg, optind)
		row=optarg:upper():umlauts()
	end,
	["c"]=function(optarg, optind)
		column=optarg:upper():umlauts()
	end,
	["d"]=function(optarg, optind)
		decrypt=true
	end,
	["?"]=function(optarg, optind)
		io.stderr:write(string.format("unrecognized option %s\n", arg[optind -1]))
		return true
	end,
}
-- quickly process options
for r, optarg, optind in getopt(arg, "a:m:c:r:dh") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end

local text=io.read("*a"):upper():umlauts()
if not decrypt then
	text=text:gsub("[^"..alphabet.."]","") -- filter valid characters
	text=text:adfgvx_encrypt(alphabet,matrix,column,row)
else
	text=text:gsub("[^"..matrix.."]","") -- filter valid characters
	text=text:adfgvx_decrypt(alphabet,matrix,column,row)
end
io.write(text)

