#!/usr/bin/env luajit
require"ccrypt"
function Encrypt( _msg, _key )    
    local msg = { _msg:upper():byte( 1, -1 ) }
    local key = { _key:upper():byte( 1, -1 ) }    
    local enc = {}
 
    local j, k = 1, 1
    for i = 1, #msg do    
        if msg[i] >= string.byte('A') and msg[i] <= string.byte('Z') then
            enc[k] = ( msg[i] + key[j] - 2*string.byte('A') ) % 26 + string.byte('A')
 
            k = k + 1
            if j == #key then j = 1 else j = j + 1 end
        end
    end
 
    return string.char( unpack(enc) )
end
 
function Decrypt( _msg, _key )
    local msg = { _msg:byte( 1, -1 ) }
    local key = { _key:upper():byte( 1, -1 ) }      
    local dec = {}
 
    local j = 1
    for i = 1, #msg do            
       dec[i] = ( msg[i] - key[j] + 26 ) % 26 + string.byte('A')
 
       if j == #key then j = 1 else j = j + 1 end
    end    
 
    return string.char( unpack(dec) )
end
 
 
-- original = "Beware the Jabberwock, my son! The jaws that bite, the claws that catch!"
local text=io.read("*a"):upper()
text=text:substitute(("äöü"):subst_table("ÄÖÜ"))
local enc_key={["ß"]="SZ", ["Ä"]="AE", ["Ö"]="OE", ["Ü"]="UE"}
text=text:substitute(enc_key)
local key = arg[1] and arg[1] or "VIGENERECIPHER"
 
encrypted = arg[2]=='-d' and Decrypt(text, key) or Encrypt( text, key )
 
io.write( encrypted )
-- print( decrypted )
