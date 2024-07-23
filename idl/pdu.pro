;Plotten eines Fault Displacement-Profils
;pro pdu,fault,it,dn,dt,dist

print,"Profil-File Format beachten !"

fault= 1 & it = 1
ny=0.25
e=5.0e10
tau_unend=2.0e8

dtref=((1.0 - ny^2)/e)*tau_unend*4.0
dev='X'
;dev='PS'

static=1


delta= 0
stress= 0
disp= 1

close,1
plotstatic=1

modeldir=""
file_name=modeldir
filedir="/datdyn/becker/finel/"+modeldir

file=filedir+"profil.flt"+strtrim(fault,1)+"."+strtrim(it,1)
print,'Reading ',file
openr,1,file
n=0
while not eof(1) do begin
	readf,1,x1,x2,x3,x4,x5,x6,x7,x8
	n=n+1
end
close,1
du=dblarr(8,n)
openr,1,file
readf,1,du
close,1

xmin=min(du(0,*)) & xmax=max(du(0,*))
ymin=min(du(1,*)) & ymax=max(du(1,*))
fvec=dblarr(2) & nfvec=dblarr(2)
fvec(0)=xmax-xmin & fvec(1)=ymax-ymin
length=betrag(fvec)
fvec = fvec / length
nfvec(0)= -fvec(1) & nfvec(1)=fvec(0) 
a=(sqrt((xmin-xmax)^2 + (ymin-ymax)^2))/2.0
print,'Fault ',fault,'(',fvec,')',a
duref=dtref*a

dist=dblarr(n)
dist(*)=(sqrt((du(0,*)-xmin)^2 + (du(1,*)-ymin)^2)-a)/a
du=du(*,sort(dist))
dist=dist(sort(dist))

dn=dblarr(n) & dnm=dblarr(n)
dt=dblarr(n) & dtm=dblarr(n) & st=dblarr(n) & sn=dblarr(n)
dn=du(2,*)/duref & dnm =du(3,*)
dt=du(4,*) & dtm =du(5,*)
st=du(6,*) & sn=du(7,*)

xleft=0.0 & ydown=0.0
set_plot,dev
if dev eq 'PS' then begin
	device,filename='du.eps', bits_per_pixel=8,$
		/encapsulated,xsize=19,ysize=14,scale_factor=1.0
;		/color,/landscape
	xleft=xleft-0.5
	print,'Output in du.eps'
end



;!p.multi=[0,2,0,0]

ref=dblarr(n)
for i=0,1*n do begin
	ref=(dtref*sqrt(a^2 - (dist * a)^2))/duref
end

mederror=mittelwert(abs(abs(dn) - ref))
stab=((sqrt( total((abs(abs(dn)-ref) - mederror)^2) / (n-1)))/sqrt(n))^2
meddist=(2.0*a)/n


print,'duref',duref,'max(dn)',max(abs(dn)),'Mederror',mederror
	if (plotstatic eq 1) then begin
		plot,dist,abs(dn),$
			title="!17Tangentialer Versatz",$
			xtitle= "!6(x-500 m) / a",ytitle="!7d!6u / !7d!6u(Max.)!ianalyt.!n",$
			yrange=[0,1.2],charsize=2.0
			;oplot,dist,abs(dn)

			oplot,dist,ref,linestyle=2
			oplot,dist,abs(abs(dn)-ref)
			xyouts,-0.4,1.1,"Risslaenge 2a = "+strtrim(2.0*a,2)+" m"

			xc=findgen(n)
			xc(*)=mederror
		oplot,dist,xc,linestyle=1
		xc(*)=1.0
		oplot,dist,xc,linestyle=1
		;xyouts,0.2+xleft,0.15+ydown,'Varianz(Fehler) :  '+strtrim(stab,2)
		xyouts,0.2+xleft,0.2+ydown, '<Fehler> :           '+strtrim(mederror,2)
		xyouts,0.2+xleft,0.25+ydown,'Fehler(x=0) :        '+strtrim(max(abs(dn)-1.0),2)		
		xyouts,0.2+xleft,0.3+ydown,"Modell: "+file_name
		
	end



if dev eq 'PS' then device,/close
end


