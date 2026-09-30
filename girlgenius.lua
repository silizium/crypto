#!/usr/bin/env luajit
require "ccrypt"
local getopt = require"posix.unistd".getopt

local password,decrypt,randomize,clean,inc="A",false,false,true,{}
local alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZ*#@^$+%&"
local wheel={
	"A2D+CTL1ISX%R5MN^FW0B7O8&9GUPK#J4VHYQ6@*ZE3$",
	"AX@1NCM5R6K8*+WH9%0QGJ7V#4USPYBL^Z$3OEIF2&TD",
	"A@FDB3#I278L1&5V%9PS*Z0UN+ERHGTCWYXK^OQ4MJ$6"
}
local control="*#@^$+%&"
local wheels="*#@"
local target="^" -- from
local source="$" -- to
local clock="+" -- clock
local counter="%" -- counter
local ignore="&" -- comment

function vigenere_make(password, alphabet)
	local t={}
	for c in password:gmatch("%w") do
		local from, to=alphabet:find(c)
		t[#t+1]=alphabet:sub(from,-1)..alphabet:sub(1,from-1)
	end
	return t
end
local function readOnly(t)
	local proxy={}
	local mt={
		__index=t,
		__newindex=function(t,k,v)
			error("attempt to write to read-only table", 2)
		end
	}
	setmetatable(proxy, mt)
	return proxy
end

local function state(wheel,control)
	local case=readOnly({NORMAL=1, TARGET=2, SOURCE=3, CLOCK=4, COUNTER=5, IGNORE=6})
	local function wheels(c)
		local w=control:find(c)
		if state==state.TARGET then
			from=wheel[w]
		elseif state==state.SOURCE then
			to=wheel[w]
		end
	end
	local state=case.NORMAL
	local from,to,nxt=nil,nil,nil
	local r,i,nr=0,0,0
	local action={
		wheels, wheels, wheels,
		function(c)	-- src
			state=case.TARGET
		end, 
		function(c)  -- dst
			state=case.SOURCE
		end,
		function(c)	-- clock
			state=case.CLOCK
		end,
		function(c) -- counter
			state=case.COUNTER
		end,
		function(c) -- comment
			state=case.IGNORE
		end
	}
	local function step(c)
		if not control:match(c) then return c end
		return c
	end
	return step
end

function string.gg_encrypt(text,password,alphabet,inc)
	local v,t={}
	t=vigenere_make(password,alphabet)
	-- encode vigenere
	local step=state(wheel, control)
	local r,i,nr,lc=0,0,0,nil
	for c in text:gmatch(".") do
		local from,to=alphabet:find(c)
		if from then 
			nr=nr+1
			from=(from+i-1)%#alphabet+1
			v[#v+1]=t[r+1]:sub(from,from) 
			r=(r+1)%#password
			step(c)
			for _,move in ipairs(inc) do
				if (nr-move.offset)%move.step==0 then
					i=i+move.increment
				end
			end
		else 
			v[#v+1]=c
		end
	end
	return table.concat(v)
end

function string.gg_decrypt(text,password,alphabet,inc)
	local v,t={}
	t=vigenere_make(password,alphabet)
	-- decode vigenere
	local r,i,nr=0,0,0
	for c in text:gmatch(".") do
		local from,to=t[r+1]:find(c)
		if from then
			nr=nr+1
			from=(from+i-1)%#alphabet+1
			v[#v+1]=alphabet:sub(from,from)
			r=(r+1)%#password
			for _,move in ipairs(inc) do
				if (nr-move.offset)%move.step==0 then
					i=i-move.increment
				end
			end
		else
			v[#v+1]=c
		end
	end
	return table.concat(v)
end


local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"GirlGenius cipher (CC)2025 H.Behrens DL7HH\n"
			.."\thttps://www.girlgeniusonline.com/funextras/decoder.php\n"
			.."\tpage http://home.hiwaay.net/~lkseitz/comics/girlgenius/\n"
			.."use: %s\n"
			.."-h	print this help text\n"
			.."-a	alphabet (%s) \n\taccepts all non spaces\n"
			.."-p	password (%s) \n\taccepts all that are in alphabet\n"
			.."-r	randomize (%s) \n\taccepts \"time\" or seed number\n"
			.."-c	not clean text from non alphabet characters\n"
			.."-i	increment after each step <nr>s<steps>o<off>[,more]\n"
			.."\tincrement nr amount after steps starting with offset\n"
			.."\texample 1=every time 2s3 every thirt step by 2\n"
			.."-d	decrypt (%s)\n",
			arg[0], alphabet, password, randomize, decrypt)
		)	
		os.exit(EXIT_FAILURE)
	end,
	["a"]=function(optarg, optind)
		alphabet=optarg:upper():umlauts()
	end,
	["p"]=function(optarg, optind)
		password=optarg:upper():umlauts()
		password=password:gsub("[^"..alphabet.."]","") -- filter valid characters
	end,
	["r"]=function(optarg, optind)
		randomize=optarg
		local seed
		if optarg=="time" then
			seed=os.time()^5+os.clock()
		else
			seed=tonumber(optarg)
		end
		math.randomseed(seed)
		alphabet=alphabet:shuffle()
		io.stderr:write("random alphabet: ",alphabet," seed:",seed,"\n")
	end,
	["d"]=function(optarg, optind)
		decrypt=true
	end,
	["c"]=function(optarg, optind)
		clean=not clean
	end,
	["i"]=function(optarg, optind)
		for arg in optarg:gmatch("([%-%dso]+)") do
			local increment,step,offset=arg:match("(%-?%d+)s*(%d*)o*(%-?%d*)")
			inc[#inc+1]={
				increment=tonumber(increment),
				step=step and tonumber(step) or 1,
				offset=offset and tonumber(offset) or 0}
		end
	end,
	["?"]=function(optarg, optind)
		io.stderr:write(string.format("unrecognized option %s\n", arg[optind -1]))
		return true
	end,
}
-- quickly process options
for r, optarg, optind in getopt(arg, "a:p:r:i:cdh") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end


local text=io.read("*a"):upper():umlauts()
if clean then 
	text=text:gsub("[^"..alphabet.."]","") -- filter valid characters
end
if not decrypt then
	text=text:gg_encrypt(password,alphabet,inc)
else
	text=text:gg_decrypt(password,alphabet,inc)
end
io.write(text)


