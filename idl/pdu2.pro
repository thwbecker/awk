pro pdu2,nr
close,1
filedir="/datdyn/becker/finel/"

u=0.375 & a=50.0 
v= u/a

openr,1,filedir+"du_profil."+strtrim(nr,1)
n=0
x=dblarr(8)
while not eof(1) do begin
	readf,1,x
	n=n+1
end
close,1

du=dblarr(8,n)
openr,1,filedir+"du_profil."+strtrim(nr,1)
readf,1,du
close,1

ddu=dblarr(n)
soll=dblarr(n)
haben=dblarr(n)
for i=0,n-1 do begin
	w=sqrt(a^2 - (abs(du(0,i)-500))^2) * v
	ddu(i)= (((du(3,i) - w))/w) * 100.0
	
end
haben=du(3,sort(du(0,*)))
soll=sqrt(a^2 - (abs(du(0,sort(du(0,*)))-500))^2) * v
print,du(0,sort(du(0,*))),ddu(sort(du(0,*)))
print,mittelwert(ddu)

plot,soll,psym=4,yrange=[0,0.5]
oplot,haben,psym=5

end


