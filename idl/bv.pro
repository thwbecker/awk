close,1

yr=intarr(1)
mo=intarr(1)
da=intarr(1)
hrmin=intarr(1)
qual=''
mmin=3.5
mmax=9.0
dm=20


msp=(mmax-mmin)/double(dm)
n=intarr(dm)
dn=dindgen(dm+1)*msp+mmin
print,dn
openr,1,"HD1:Dokumente:Uni:seis.dat"
while not eof(1) do begin
	readf,1,FORMAT = '(I4,i3,i3,i5,f8.4,3f10.4,f7.2,a5)',$
		yr,mo,da,hrmin,sec,lat,lon,dep,mag,qual
	if((mag gt mmin)and(mag lt mmax))then begin
		n(fix((mag-mmin)/msp))=n(fix((mag-mmin)/msp))+1
	end
end
j=0
for i=0,n_elements(n)-1 do begin
	if(n(i) ne 0)then j=j+1	
end
x=dblarr(j)
y=dblarr(j)
k=0
for i=0,j-1 do begin
	if(n(i) ne 0)then begin
		x(k)=dn(i)
		y(k)=alog10(n(i))
		k=k+1
	end
end

plot,x,y,xrange=[mmin-msp,mmax+msp],xstyle=1,psym=1,$,
	yrange=[alog10(min(n)),alog10(max(n))],$
	xtitle="!6Magnitude",ytitle="!6N",$
	title="!6Magnituden-Haeufigkeitsrelation"

W = REPLICATE(1.0, N_ELEMENTS(Y))
result = REGRESS(X, Y, W, yfit, A0, /relative_weight)
oplot,x,yfit
	
end
