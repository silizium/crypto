#!/usr/bin/env luajit
require"ccrypt"
local fraktur="𝖆𝖇𝖈𝖉𝖊𝖋𝖌𝖍𝖎𝖏𝖐𝖑𝖒𝖓𝖔𝖕𝖖𝖗𝖘𝖙𝖚𝖛𝖜𝖝𝖞𝖟𝕬𝕭𝕮𝕯𝕰𝕱𝕲𝕳𝕴𝕵𝕶𝕷𝕸𝕹𝕺𝕻𝕼𝕽𝕾𝕿𝖀𝖁𝖂𝖃𝖄𝖅"
local alpha="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
local text=io.read("*a")
local frak_tab=alpha:subst_table(fraktur)
text=text:substitute(frak_tab)
frak_tab={ä="̈̈𝖆", ö="̈𝖔", ü="̈𝖚", Ä="̈𝕬", Ö="̈𝕺", Ü="̈𝖀", ß="𝖅"}
text=text:gsub("("..ccrypt.Unicode..")", frak_tab)
io.write(text)
