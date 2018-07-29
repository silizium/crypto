-- zahlensysteme_uebung2.lua
a="W" -- Klartext
ax=string.byte(a)-65
print(string.format("*%s = %02x", a, ax))
b="C" -- Schlüssel
bx=string.byte(b)-65
print(string.format(" %s = %02x", b, bx))
cx=bit.bxor(ax,bx) -- verschlüsseln
print(string.format(" %s = %02x", string.char(cx+65), cx))
dx=bit.bxor(cx,bx) -- entschlüsseln
print(string.format("*%s = %02x", string.char(dx+65), dx))
