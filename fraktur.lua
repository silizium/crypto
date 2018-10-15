#!/usr/bin/env luajit
require"ccrypt"
local fraktur="𝖆𝖇𝖈𝖉𝖊𝖋𝖌𝖍𝖎𝖏𝖐𝖑𝖒𝖓𝖔𝖕𝖖𝖗𝖘𝖙𝖚𝖛𝖜𝖝𝖞𝖟𝕬𝕭𝕮𝕯𝕰𝕱𝕲𝕳𝕴𝕵𝕶𝕷𝕸𝕹𝕺𝕻𝕼𝕽𝕾𝕿𝖀𝖁𝖂𝖃𝖄𝖅"
local alpha="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
local text=io.read("*a")
local frak_tab=alpha:subst_table(fraktur)
text=text:substitute(frak_tab)
frak_tab={ä="𝖆̈", ö="𝖔̈", ü="𝖚̈", Ä="𝕬̈", Ö="𝕺̈", Ü="𝖀̈", ß="𝖋𝖟"}
text=text:gsub("("..ccrypt.Unicode..")", frak_tab)
io.write(text)
