#!/usr/bin/env luajit
require"ccrypt"
local fraktur="𝖆𝖇𝖈𝖉𝖊𝖋𝖌𝖍𝖎𝖏𝖐𝖑𝖒𝖓𝖔𝖕𝖖𝖗𝖘𝖙𝖚𝖛𝖜𝖝𝖞𝖟𝕬𝕭𝕮𝕯𝕰𝕱𝕲𝕳𝕴𝕵𝕶𝕷𝕸𝕹𝕺𝕻𝕼𝕽𝕾𝕿𝖀𝖁𝖂𝖃𝖄𝖅"
local frakturs="𝔞𝔟𝔠𝔡𝔢𝔣𝔤𝔥𝔦𝔧𝔨𝔩𝔪𝔫𝔬𝔭𝔮𝔯𝔰𝔱𝔲𝔳𝔴𝔵𝔶𝔷𝔄𝔅𝔆𝔇𝔈𝔉𝔊𝔋𝔌𝔍𝔎𝔏𝔐𝔑𝔒𝔓𝔔𝔕𝔖𝔗𝔘𝔙𝔚𝔛𝔜𝔝"
local alpha="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
local text=io.read("*a")
local text=text:gsub("st", "𝖘𝖙")
local text=text:gsub("(%a)ss(%a)", "%1𝖋𝖋%2")
local text=text:gsub("(%a)s([^s %p])", "%1𝖋%2")
local frak_tab=alpha:subst_table(fraktur)
text=text:substitute(frak_tab)
frak_tab={ä="𝖆̈", ö="𝖔̈", ü="𝖚̈", Ä="𝕬̈", Ö="𝕺̈", Ü="𝖀̈", ß="𝖋𝖟"}
text=text:gsub("("..ccrypt.Unicode..")", frak_tab)
io.write(text)
