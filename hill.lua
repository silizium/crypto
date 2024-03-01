#!/usr/bin/env luajit
--hill cipher
require"ccrypt"
local key,decrypt,english="GYBNQKURP",false,false
for i=1,#arg do
	if arg[i]=="-d" then
		decrypt=true
	elseif arg[i]=="-e" then
		english=true
	else
		key=arg[i]
	end
end
local text=io.read("*a")
function string:totable()
	local tab={}
	for i=1,#self do
		tab[#tab+1]=self:byte(i)-('A'):byte()
	end
	return tab
end
function table.char(self)
	local tab={}
	local A=("A"):byte()
	for i=1,#self do
		tab[i]=string.char(self[i]+A)
	end
	return table.concat(tab)
end
local matrix={}
function matrix.new(i, j, tab, fill)
	j=j or i
	fill=fill or 0
	local m={}
	for y=1,i do
		m[y]={}
		for x=1,j do
			m[y][x]=tab[x+i*(y-1)] or fill
		end
	end
	return m
end
function matrix.print(t)
	table.foreach(t, function(i) print(table.concat(t[i],",")) end)
end
function matrix.mul(m, n)
	local r={}
	if type(n)=="number" then
		for y=1,#m do
			r[y]={}
			for x=1,#m[y] do
				r[y][x]=(m[y][x]*n)%26
			end
		end
		return r
	end
	local k=1
	local sum
	for k=1,#n,#m do
		for j=1,#m do
			sum=0
			for i=1,#m do
					sum=sum+m[(k+j-2)%#m+1][i]*(n[k+i-1] or 23)
					--print(":",m[(k-1)%#m+1][i],n[k+i-1],sum,sum%26)
			end
			r[k+j-1]=sum%26
		end
	end
	return r
end
function matrix.det3(m)
	return m[1][1]*m[2][2]*m[3][3]+m[1][2]*m[2][3]*m[3][1]+m[1][3]*m[2][1]*m[3][2]
		-m[1][1]*m[2][3]*m[3][2]-m[1][2]*m[2][1]*m[3][3]-m[1][3]*m[2][2]*m[3][1]
end
function matrix.det2(a,b,c,d)
	return a*d-b*c
end
function invmod(a, b)
	b=b>0 and b or -b
	a=a>0 and a or b-(-a%b)
	local r,t,nt,nr=b,0,1,a%b
	while nr~=0 do
		local q=math.floor(r/nr)
		t,nt=nt,t-q*nt
		r,nr=nr,r-q*nr
	end
	if r>1 then return -1 end
	if t<0 then t=t+b end
	return t
end
-- adjugate matrix
function matrix.adj(m, mod)
	local a={{},{},{}}
	mod=mod or 26
	a[1][1]= matrix.det2(m[2][2],m[2][3],m[3][2],m[3][3])%mod
	a[1][2]=-matrix.det2(m[1][2],m[1][3],m[3][2],m[3][3])%mod
	a[1][3]= matrix.det2(m[1][2],m[1][3],m[2][2],m[2][3])%mod
	a[2][1]=-matrix.det2(m[2][1],m[2][3],m[3][1],m[3][3])%mod
	a[2][2]= matrix.det2(m[1][1],m[1][3],m[3][1],m[3][3])%mod
	a[2][3]=-matrix.det2(m[1][1],m[1][3],m[2][1],m[2][3])%mod
	a[3][1]= matrix.det2(m[2][1],m[2][2],m[3][1],m[3][2])%mod
	a[3][2]=-matrix.det2(m[1][1],m[1][2],m[3][1],m[3][2])%mod
	a[3][3]= matrix.det2(m[1][1],m[1][2],m[2][1],m[2][2])%mod
	return a
end
-- cofactor
function matrix.cofactor(m, mod)
	local a={{},{},{}}
	mod=mod or 26
	a[1][1]= matrix.det2(m[2][2],m[2][3],m[3][2],m[3][3])%mod
	a[1][2]=-matrix.det2(m[2][1],m[2][3],m[3][1],m[3][3])%mod
	a[1][3]= matrix.det2(m[2][1],m[2][2],m[3][1],m[3][2])%mod
	a[2][1]=-matrix.det2(m[1][2],m[1][3],m[3][2],m[3][3])%mod
	a[2][2]= matrix.det2(m[1][1],m[1][3],m[3][1],m[3][3])%mod
	a[2][3]=-matrix.det2(m[1][1],m[1][2],m[3][1],m[3][2])%mod
	a[3][1]= matrix.det2(m[1][2],m[1][3],m[2][2],m[2][3])%mod
	a[3][2]=-matrix.det2(m[1][1],m[1][3],m[2][1],m[2][3])%mod
	a[3][3]= matrix.det2(m[1][1],m[1][2],m[2][1],m[2][2])%mod
	return a
end

text=text:clean(english)
key=key:clean(english)
local tkey=key:totable()
local mkey=matrix.new(3,3,tkey)
--print(matrix.print(mkey))

if decrypt then
	mkey=matrix.mul(matrix.adj(mkey),invmod(matrix.det3(mkey),26))
end
local decode=matrix.mul(mkey,text:totable())
io.write(table.char(decode))
