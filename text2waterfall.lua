#!/usr/bin/env luajit
local radio = require('radio')
require 'ccrypt'
local getopt = require"posix.unistd".getopt


function help()
		io.stderr:write("use: %s", arg[0])
		os.exit()
end

-- Aufruf der Enigma Routinen
local frequency,rate,volume,input,output,typeface=1e3,8e3,100,nil, nil, nil
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Waterfall Text Generator (CC) 2024 H.Behrens DL7HH\n"
			.."use : %s\n"
			.."-h	print this help text\n"
			.."-f	frequency (%d)\n"
			.."-s	samples (%d)\n"
			.."-v	volume (%d)\n"
			.."-i	input (%s)\n"
			.."-o	output (%s)\n"
			.."-t	typeface (%s)\n",
			arg[0],frequency,samples,input,output,typeface)
		)
	end,
	["f"]=function(optarg, optind)
		frequency=tonumber(optarg)
	end,
	["s"]=function(optarg, optind)
		rate=tonumber(optarg)
	end,
	["v"]=function(optarg, optind)
		volume=tonumber(optarg)
	end,
	["i"]=function(optarg, optind)
		input=optarg
	end,
	["o"]=function(optarg, optind)
		output=optarg
	end,
	["t"]=function(optarg, optind)
		typeface=optarg
	end,

	["?"]=function(optarg, optind)
		print('unrecognized option', arg[optind -1])
		return true
	end,
	}
-- quickly process options
for r, optarg, optind in getopt(arg, "f:s:v:i:o:t:h") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end


-- Blocks
local source = radio.SignalSource('cosine',frequency,rate,{amplitude=volume/100})
--local af_filter = radio.LowpassFilterBlock(128, bandwidth)
--local hilbert = radio.HilbertTransformBlock(129)
--local conjugate = radio.ComplexConjugateBlock()
--local sb_filter = radio.ComplexBandpassFilterBlock(129, (sideband == "lsb") and {-bandwidth, 0}
--                                                                             or {0, bandwidth})
local sink = radio.PulseAudioSink(1)

-- Connections
local top = radio.CompositeBlock()
top:connect(source, sink)

top:run()
