text=[[Wehe dem, der sein Geheimnis
Dem Papier anvertraut, ja, wehe
Tausendmal ihm! Denn die Schrift
Ist ein Stein, den aus den Haenden
Auf's Geratewohl man schleudert,
Und nicht weiss, wen er kann treffen.]]

author=[[Pedro Calderón de la Barca y Barreda González de Henao Ruiz de Blasco y Riaño, 
(1600 - 1681), spanischer Dichter]]
caesar={}
function caesar.encrypt(txt, alpha, cipher)
	local t={}
	local chiffre=""
	-- build cipher table
	for i=1,#alpha do
		t[alpha:sub(i,i)]=cipher:sub(i,i)
	end
	-- encrypt with table
	for i=1,#txt do
		chiffre=chiffre..(t[txt:sub(i,i)] or txt:sub(i,i))
	end
	return chiffre
end

function caesar.decrypt(txt, alpha, cipher)
	return caesar.encrypt(txt, cipher, alpha)
end

require "filter"
require "shuffle"

text=text:filter():block():upper()
print(text)

alpha="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
math.randomseed(os.time()*os.clock())
print(alpha)
ctext=alpha:shuffle()
print(ctext)
cipher=caesar.encrypt(text, alpha, ctext)
print(cipher)
retext=caesar.decrypt(cipher, alpha, ctext):lower()
print(retext)
print(author)
