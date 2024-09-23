#!/usr/bin/env luajit
local cw=require"libcw"
local ffi=require"ffi"

ffi.cdef[[
int printf(const char *fmt, ...);
]]


cw.cw_license()
--print(cw.cw_version())

cw.cw_generator_new(cw.CW_AUDIO_SOUNDCARD,nil);
cw.cw_generator_start()
--cw.cw_set_send_speed(20)
--cw.cw_send_string("test ")
--[[
cw.cw_set_frequency(800)
cw.cw_send_dot()
cw.cw_send_dot()
cw.cw_send_dot()
cw.cw_set_frequency(750)
cw.cw_send_dash()

cw.cw_wait_for_tone_queue()
cw.cw_generator_stop()
cw.cw_generator_delete()
]]

local buf=ffi.new("char[?]",cw.cw_get_character_count()+1)
local c=ffi.new("char[?]", 1, "B")
local err=ffi.new("int[?]", 1)
ffi.cdef[[ char *cp; ]]
--cw.cw_lookup_procedural_character(c[0], buf, err)
--print(err[0])
--print(ffi.string(buf))
cw.cw_lookup_character(c[0], buf)
print(ffi.string(buf))
