#!/usr/bin/env luajit
require"ccrypt"
local text=io.read("*a")
print(text:utf8reverse())
