#!/usr/bin/env luajit
require "ccrypt"
local from=arg[1] or "abcdefghijklmnopqrstuvwxyzäöü"
local to=arg[2] or "ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜ"
local text=io.read("*a") -- STDIN einlesen
local tab=from:subst_table(to)
text=text:substitute(tab)
io.write(text) -- verschlüsselter Text
