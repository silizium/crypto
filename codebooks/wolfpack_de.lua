local codebook={
figlet=function()
end,
encode=function(text)
	table.sort(book,function(a,b) 
		return #a.clear>#b.clear or (#a.clear==#b.clear and #a.code>#b.code) 
	end)
	local enc={}
	local fig,let=codebook.figlet(book)
	local figures=false
	local i=1
	while i<=#text do
		local word=""
		for _,w in ipairs(book) do
			if text:sub(i,i+#w.clear-1)==w.clear then

				if w.clear:match("%d") and not figures then
					word=fig
					figures=true
				end
				if w.clear:match("%D") and figures then
					word=let
					figures=false
				end
				word=word..w.code
				i=i+#w.clear-1
				break ::out::
			end
		end
		::out::
		enc[#enc+1]=word
		i=i+1
	end
	return table.concat(enc)
end,
decode=function(text)
end,

	book={
	{ code="A", clear="A"},
	{ code="E", clear="E"},
	{ code="N", clear="N"},
	{ code="I", clear="I"},
	{ code="S", clear="S"},
	{ code="R", clear="R"},
	{ code="A", clear="A"},
	{ code="T", clear="T"},
	{ code="D", clear="D"},
	{ code="H", clear="H"},
	{ code="U", clear="U"},
	{ code="L", clear="L"},
	{ code="C", clear="C"},
	{ code="G", clear="G"},
	{ code="M", clear="M"},
	{ code="O", clear="O"},
	{ code="B", clear="B"},
	{ code="W", clear="W"},
	{ code="F", clear="F"},
	{ code="K", clear="K"},
	{ code="Z", clear="Z"},
	{ code="P", clear="P"},
	{ code="V", clear="V"},
	{ code="J", clear="J"},
	{ code="Y", clear="Y"},
	{ code="XX", clear="X"},
	{ code="QQ", clear="Q"},
	{ code="XA", clear="ICH"},
	{ code="XB", clear="EIN"},
	{ code="XC", clear="UND"},
	{ code="XD", clear="DER"},
	{ code="XE", clear="NDE"},
	{ code="XF", clear="SCH"},
	{ code="XG", clear="DEN"},
	{ code="XH", clear="DIE"},
	{ code="XI", clear="END"},
	{ code="XJ", clear="CHT"},
	{ code="XK", clear="VON"},
	{ code="XL", clear="DAS"},
	{ code="XM", clear="MIT"},
	{ code="XN", clear="ION"},
	{ code="XO", clear="EUR"},
	{ code="XP", clear="SICH"},
	{ code="XQ", clear="UNG"},
	{ code="XR", clear="NICHT"},
	{ code="XS", clear="SIE"},
	{ code="XT", clear="DIE"},
	{ code="XU", clear="IST"},
	{ code="XV", clear="DES"},
	{ code="XW", clear="SICH"},
	{ code="XY", clear="AUCH"},
	{ code="XZ", clear="NACH"},

	-- Enemy reports
	{ code="CCGG${POS}", clear="FEIND STEHT %W+"}

	} -- End book
}
return codebook
