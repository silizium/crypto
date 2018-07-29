#!/usr/bin/env luajit
Schuler={
	{user="deniz", name="Ayaz", vorname="Deniz", klasse="9c"},
	{user="amadou", name="Barrow", vorname={"Amadou", "Christopher"}, klasse="9a"},
	{user="moritz", name="Camp", vorname="Moritz", klasse="9c"},
	{user="kiyann", name="Celebi", vorname="Kiyann", klasse="9c"},
	{user="burak", name="Duman", vorname="Burak", klasse="9b"},
	{user="jan", name="Endeward", vorname={"Jan", "Florian"}, klasse="9b"},
	{user="bilal", name="Farouk", vorname="Bilal", klasse="9c"},
	{user="torben", name="Güting", vorname={"Torben", "Gerhard"}, klasse="9b"},
	{user="mingqi", name="Han", vorname="Mingqi", klasse="9c"},
	{user="pascal", name="Hielscher", vorname="Pascal", klasse="9c"},
	{user="hannah", name="Jiménez Cuevas", vorname={"Hannah", "Sophie"}, klasse="9a"},
	{user="bastian", name="Koch", vorname="Bastian", klasse="9b"},
	{user="hanna", name="Ronhaar", vorname={"Hanna", "Charlotte"}, klasse="9c"},
	{user="fabian", name="Schulz", vorname="Fabian", klasse="9c"},
	{user="leo", name="Shuhani", vorname="Leo-Laith", klasse="9c"},
	{user="alexander", name="Skowron", vorname="Alexander", klasse="9c"},
	{user="jerome", name="Stotzem", vorname={"Jerome", "Paul"}, klasse="9b"},
	{user="jonas", name="Tandioy Chasoy", vorname={"Jonas", "Yandu"}, klasse="9a"},
	{user="diana", name="Tracz", vorname="Diana", klasse="9c"},
	{user="zsofia", name="Ujvary-Menyhart", vorname="Zsofia", klasse="9a"},
	{user="thu", name="VuAnh", vorname="Thu", klasse="9b"},
	{user="victor", name="Waap", vorname="Victor", klasse="9c"},
	{user="mario", name="Waldau Orellana", vorname="Mario", klasse="9a"},
	{user="victoria", name="Wedig", vorname="Victoria", klasse="9c"},
	{user="maria", name="Weigert", vorname={"Maria-Pia", "Malou"}, klasse="9a"},
	{user="michael", name="Zaika", vorname="Michael", klasse="9a"},
	{user="tom", name="Züll", vorname={"Tom", "Tizian"}, klasse="9c"}
}

Schulerliste={}
local mt={
	__index=function(_, k) if k=="print" then return printout end end
}

function printout(o)
	for k,v in ipairs(o) do 
		io.write(k, "  ", v.user, ", ", v.name, ", ")
		if type(v.vorname)=="string" then
			io.write(v.vorname, ", ")
		else
			for _,vname in ipairs(v.vorname) do
				io.write(vname, ", ")
			end
		end
		io.write(v.klasse)
		io.write("\n")
	end
end
	
function Schulerliste.new(o)
	local list=o or Schuler
	setmetatable(list, mt)
	list.print=mt.print
	return list
end

local liste=Schulerliste.new()
--for k,v in pairs(getmetatable(liste)) do print(k,v) end
table.sort(liste, function(a, b) if a.klasse==b.klasse then return a.name < b.name end return a.klasse < b.klasse end)
liste:print()
