#!/usr/bin/env luajit
-- pipe_caesar.lua
require "ccrypt"
local getopt = require"posix.unistd".getopt
--require"DataDumper" local dump=function(...) print(DataDumper(...),"\n---") end

local alpha="ABCDEFGHIKLMNOPQRSTUVWXYZ"
local top,bottom=alpha,alpha
local filter,english,german,decrypt=true,false,false,false
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Four-Square cipher (CC)2025 H.Behrens DL7HH\n"
			.."use: %s\n"
			.."-h	print this help text\n"
			.."-f	filter (%s)	filter unknown characters\n"
			.."-e	english (%s)	translates numbers to English\n"
			.."-g	german (%s)	translates numbers to German\n"
			.."-a	alphabet (%s) (%d)\n"
			.."-t	top-right square (%s) (%d)\n"
			.."-b	bottom-left square (%s) (%d)\n"
			.."-d	decrypt\n\n",
			arg[0], filter, english, german, 
			alpha, #alpha,  
			top, #top,
			bottom, #bottom,
			decrypt)
		)	
		os.exit(EXIT_FAILURE)
	end,
	["f"]=function(optarg, optind)
		filter=not filter
	end,
	["e"]=function(optarg, optind)
		english=not english
	end,
	["g"]=function(optarg, optind)
		german=not german
	end,
	["a"]=function(optarg, optind)
		alpha=optarg:upper():remove_doublets()
		if not (#alpha == 25 or #alpha ==36) then 
			error("***FAILURE -a: alphabet has to be 25 or 36 characters in size, but has "..#alpha.." - "..alpha)
		end
	end,
	["t"]=function(optarg, optind)
		top=optarg:upper():remove_doublets()
		if #top ~= #alpha then 
			error("***FAILURE -t: top has to be 25 or 36 characters in size, but has "..#top.." - "..top)
		end
	end,
	["b"]=function(optarg, optind)
		bottom=optarg:upper():remove_doublets()
		if #bottom ~= #alpha then 
			error("***FAILURE -b: bottom has to be 25 or 36 characters in size, but has "..#bottom.." - "..bottom)
		end
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
for r, optarg, optind in getopt(arg, "a:t:b:egfdh") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end

if alpha:sort() ~= top:sort() or alpha:sort() ~= bottom:sort() then
	error("*** FAILURE: alphabet top and bottom square do not have the same character sets")
end
math.randomseed(os.time()^5*os.clock())
local text=io.read("*a") -- STDIN einlesen
-- wir wandeln erstmal unseren Text in Großbuchstaben
text=text:umlauts():upper()
if english then	text=text:clean("english") end
if german then text=text:clean() end
alpha=alpha:upper()
if filter then text=text:gsub("[^"..alpha.."]", "") end
--calculate the conversion table size
local square=math.sqrt(#alpha)
local cipher
-- convert text to number pairs
function string.digraph(text, alpha)
	local di={}
	if #text%2==1 then 
		local rnd=math.random(#alpha)
		text=text..alpha:sub(rnd,rnd)
	end
	for c in text:gmatch("(%w%w)") do
		di[#di+1]=c	
	end
	return di
end
function string.square(alpha)
	local side=math.sqrt(#alpha)
	local sq={}
	for i=1,side do sq[i]={} end
	local x,y=1,1
	for c in alpha:gmatch("%w") do
		sq[y][x]=c
		x=x+1
		if x>side then
			x=1
			y=y+1
		end
	end
	return sq
end
local function cipher(di, at, ab, tt, tb)
	local function xy(pos, len)
		return (pos-1)%len+1,math.floor((pos-1)/len)+1
	end

	local len=math.sqrt(#alpha)
	c1,c2=di:match("(%w)(%w)")
	local post=at:find(c1)
	local x1,y1=xy(post, len)
	local posb=ab:find(c2)
	local x2,y2=xy(posb, len)
	return tt[y1][x2]..tb[y2][x1]
end



local dig=text:digraph(alpha)
local tsq=top:square()
local bsq=bottom:square()
local asq=alpha:square()
local tmp={}
for _,d in ipairs(dig) do
	if not decrypt then
		tmp[#tmp+1]=cipher(d, alpha, alpha, tsq, bsq)
	else
		tmp[#tmp+1]=cipher(d, top, bottom, asq, asq)
	end
end
text=table.concat(tmp)
io.write(text) -- verschlüsselter Text
