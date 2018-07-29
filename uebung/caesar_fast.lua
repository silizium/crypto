local caesar={}
local memo = {}

function caesar.make_table(k)
    local t = {}
    local a, A = ('a'):byte(), ('A'):byte()
 
    for i = 0,25 do
        local  c = a + i
        local  C = A + i
        local rc = a + (i+k) % 26
        local RC = A + (i+k) % 26
        t[c], t[C] = rc, RC
    end
 
    return t
end
 
function caesar.encrypt(str, k)
    --k = (decode and -k or k) % 26
	local key = k or 13 
	key = key % 26
 
    local t = memo[key]
    if not t then
        t = caesar.make_table(key)
        memo[key] = t
    end
 
    --local res_t = { str:byte(1,-1) }
	local res_t={}
	for i=1,#str do
		res_t[i]=str:byte(i)
	end
	
    for i,c in ipairs(res_t) do
        res_t[i] = string.char(t[c] or c)
    end
    --return string.char(unpack(res_t))
	return table.concat(res_t)
end

function caesar.decrypt(str, k)
	local key = k or -13 
	return caesar.encrypt(str, -key)
end

return caesar
