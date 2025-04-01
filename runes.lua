#!/usr/bin/env luajit
require "ccrypt"
local getopt = require"posix.unistd".getopt

local futhark={
	--"ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜß.,!"
	my="ᚪᛒᚲᛞᛖᚠᚷᚺᛇᛃᚴᛚᛗᛜᛟᛈᛩᚱᛊᚦᚢᚡᚹᛪᚤᛎᛅᚯᚣᛋ᛫᛭᛬",
	elder="ᚨᛒᚲᛞᛖᚠᚷᚺᛁᛃᚲᛚᛗᚾᛟᛈᚲᚱᛊᛏᚢᚢᚹᚲᛊᛁᛉᛖᛟᚢᛋ᛫᛭᛬",
	younger="ᛅᛒᚴᛏᛁᚠᚴᚼᛁᛁᚴᛚᛘᚾᚬᛒᚴᚱᛋᛏᚢᚢᚢᚴᛋᛁᛋᛅᚬᚢᛋ᛫᛭᛬",
	shorttwig="ᛆᛓᚴᛐᛁᚠᚴᚽᛁᛁᚴᛚᛙᚿᚭᛓᚴᚱᛌᛐᚢᚢᚢᚴᛌᛁᛌᛆᚭᚢᛋ᛫᛭᛬",
	staveless="⸝ިᛍ⸍ᛁᛙᛍᚽᛁᛁᛍ⸌⠃⸜ˎިᛍ◟╵⸍╮╮╮ᛍ╵ᛁ╵⸝Ö╮ᛋ᛫᛭᛬",
	medival="ᛆᛒᛌᛑᛂᚠᚵᛡᛁᛁᚴᛚᛉᚿᚮᛔᚴᚱᛍᛐᚢᚡᚡᚴᛍᚤZᛆᚮᚤᛋ᛫᛭᛬",
	anglo="ᚪᛒᚳᛞᛖᚠᚷᚻᛁᛄᚳᛚᛗᚾᚩᛈᚳᚱᛋᛏᚢᚠᚹᚳᛋᛁᛋᛠᛡᚢᛋ᛫᛭᛬"
}
local set,decrypt="my",false
local fopt={
	["h"]=function(optarg,optind) 
		io.stderr:write(
			string.format(
			"Rune Converter (CC) 2024 H.Behrens DL7HH\n"
			.."use : %s\n"
			.."-h	print this help text\n"
			.."-d	decrypt (%s)\n"
			.."-t	type of rune (%s)\n\nRunesets: ",
			arg[0],decrypt,set)
		)
		for k,v in pairs(futhark) do
			io.stderr:write(k, " ")
		end
		io.stderr:write("\n")
	end,
	["d"]=function(optarg, optind)
		decrypt=not decrypt
	end,
	["t"]=function(optarg, optind)
		set=optarg
	end,
	["?"]=function(optarg, optind)
		print('unrecognized option', arg[optind -1])
		return true
	end,
	}
-- quickly process options
for r, optarg, optind in getopt(arg, "dt:h") do
	last_index = optind
	if fopt[r](optarg, optind) then break end
end




local text=io.read("*a"):upper()
text=text:substitute(("äöü"):subst_table("ÄÖÜ")):reduce(20)
local alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
local enc_key,encrypted

if decrypt then
        enc_key=futhark[set]:subst_table(alphabet)
else
        enc_key=alphabet:subst_table(futhark[set])
end
encrypted=text:substitute(enc_key)

io.write(encrypted)
