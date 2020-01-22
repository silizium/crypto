#!/usr/bin/env luajit
-- pattern.lua
require "ccrypt"
-- Aufruf mit pattern <word>
local word=arg[1] or "wetter"
local pat=word:genpat({w=true})
print(pat, word:match(pat))
