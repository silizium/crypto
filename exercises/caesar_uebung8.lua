-- caesar_uebung8.lua
require "ccrypt"

local text="ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜß ZWÖLF BOXKÄMPFER JAGEN EVA QUER ÜBER DEN GROßEN SYLTER A\xCC\xA4DEICH."
local clock=os.clock
math.randomseed(os.time()*os.clock())
local alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜß\xCC\xA4"
local cipher=alphabet:shuffle()
local key=math.random(alphabet:utf8len()-1)
print(alphabet)
print(cipher, "Key="..key)
local enc_sub=alphabet:subst_table(key, cipher)
local encrypt=text:substitute(enc_sub)
local dec_sub=cipher:subst_table(-key, alphabet)
local decrypt=encrypt:substitute(dec_sub)
print(text)
print(encrypt)
print(decrypt)
print(encrypt:filter():block())


