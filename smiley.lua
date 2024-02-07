#!/usr/bin/env luajit
require "ccrypt"

local getopt = require"posix.unistd".getopt
local decode,seed=false,os.time()^5*os.clock()
math.randomseed(seed)
local fopt={
        ["h"]=function(optarg,optind) 
                io.stderr:write(
                        string.format(
                        "smiley (CC)2024 H.Behrens DL7HH\n"
                        .."use: %s\n"
                        .."-h   print this help text\n"
                        .."-d   decode\n"
                        .."-r   randomseed (%u)\n",
                        arg[0], seed)
                )
                os.exit(EXIT_FAILURE)
        end,
        ["d"]=function(optarg, optind)
                decode=not decode
        end,
        ["r"]=function(optarg, optind)
                seed=tonumber(optarg)
				math.randomseed(seed)
        end,
        ["?"]=function(optarg, optind)
                io.stderr:write(string.format("unrecognized option %s\n", arg[optind -1]))
                return true
        end,
}
-- quickly process options
for r, optarg, optind in getopt(arg, "r:dh") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end

local function shuffle(t)
	local random=math.random
	for i=#t,1,-1 do
		local rnd=random(i)
		t[i], t[rnd] = t[rnd], t[i]
	end
	return t
end

local text=io.read("*a")
local alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜßabcdefghijklmnopqrstuvwxyzäöü0123456789.,!?+-#;:-@|»«›‹„“'\"\\€¢µ"
local smile={":grinning:", ":smiley:", ":smile:", ":grin:", ":laughing:", 
	":face_holding_back_tears:", ":sweat_smile:", ":joy:", ":rofl:", 
	":smiling_face_with_tear:", ":relaxed:", ":blush:", ":innocent:", 
	":slight_smile:", ":upside_down:", ":wink:", ":relieved:", ":heart_eyes:", 
	":smiling_face_with_3_hearts:", ":kissing_heart:", ":kissing:", 
	":kissing_smiling_eyes:", ":kissing_closed_eyes:", ":yum:", ":stuck_out_tongue:", 
	":stuck_out_tongue_closed_eyes:", ":stuck_out_tongue_winking_eye:", ":zany_face:", 
	":face_with_raised_eyebrow:", ":face_with_monocle:", ":nerd:", ":sunglasses:", 
	":disguised_face:", ":star_struck:", ":partying_face:", ":smirk:", ":unamused:", 
	":disappointed:", ":pensive:", ":worried:", ":confused:", ":slight_frown:", 
	":persevere:", ":confounded:", ":tired_face:", ":weary:", ":pleading_face:", 
	":cry:", ":sob:", ":triumph:", ":angry:",
	":rage:", ":face_with_symbols_over_mouth:", ":exploding_head:", ":flushed:", 
	":hot_face:", ":cold_face:", ":face_in_clouds:", ":scream:", ":fearful:", 
	":cold_sweat:", ":disappointed_relieved:", ":sweat:", ":hugging:", ":thinking:", 
	":face_with_peeking_eye:", ":face_with_hand_over_mouth:", 
	":face_with_open_eyes_and_hand_over_mouth:", ":saluting_face:", ":shushing_face:", 
	":melting_face:", ":lying_face:", ":no_mouth:", ":dotted_line_face:", 
	":neutral_face:", ":face_with_diagonal_mouth:", ":expressionless:", ":shaking_face:", 
	":grimacing:", ":rolling_eyes:", ":hushed:", ":frowning:", ":anguished:", 
	":open_mouth:", ":astonished:", ":yawning_face:", ":sleeping:", 
	":drooling_face:", ":sleepy:", ":face_exhaling:", ":dizzy_face:", 
	":face_with_spiral_eyes:", ":face_vomiting:"  }

local enc_key,encrypted={}
local i=1
shuffle(smile)
for c in alphabet:utf8all() do
	local s=smile[i]
	i=i+1
	if decode then
		enc_key[s]=c
	else
		enc_key[c]=s
	end
end
if decode then
	encrypted=text:substitute(enc_key, ":[a-z0-9_]+:")
else
	encrypted=text:substitute(enc_key)
end

io.write(encrypted)
