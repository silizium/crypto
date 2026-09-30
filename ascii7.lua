#!/usr/bin/env luajit
local bit = bit32 or require "bit"
require"ccrypt"
-- Usage:
--   cat text.txt | lua ascii7.lua encode > out.bin
--   cat out.bin  | lua ascii7.lua decode

local mode = arg[1]
if not (mode == "encode" or mode == "decode") then
  io.stderr:write("Usage: lua ascii7.lua [encode|decode]\n")
  os.exit(1)
end

-- read all input from stdin
local input = io.stdin:read("*all")

if mode == "encode" then
  for i = 1, #input do
    local c = input:byte(i)
    if c > 127 then
      io.stderr:write(string.format("Warning: non-ASCII byte %d ignored\n", c))
      c = c % 128
    end
    -- shift left by 1 to make room for an unused LSB (always 0)
	c=bit.tobit(c)
    local b = bit.lshift(c,1)
    io.stdout:write(dec2bin(string.char(b)))
  end

elseif mode == "decode" then
  for i = 1, #input do
    local b = input:byte(i)
	b=bit.tobit(b)
    -- shift right by 1 to drop the unused LSB
    local c = bit.rshift(b,1)
    io.stdout:write(string.char(c))
  end
end

