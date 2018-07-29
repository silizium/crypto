local text="DERSCHATZLIEGTIMSILBERSEE"
print(text)
local A=("A"):byte() -- A=65
local key=13         -- "Standard" Cäsar
for i=1,#text do
	-- unsere Formel von Übung 1
	local c=(text:byte(i)-A+key)%26
	c=c+A   -- 0…25 -> 65…90 (ASCII)
	io.write(string.char(c))
end
print()