close,1
pr=0

datadir="/datdyn/becker/finel"
;modeldir="/static_sngl_cracks/sngl_crack.1.5.0.200/"
modeldir="/"
filedir=datadir+modeldir

if (pr)then dev = 'PS' else dev='X'

openr,1,filedir+"csfield.dat"
	readf,1,n
	cs=dblarr(n,n) & clbx=dblarr(n,n) & clby=dblarr(n,n)

	readf,1,cs
close,1

openr,1,filedir+"clbx.dat"
	readf,1,clbx
close,1

openr,1,filedir+"clby.dat"
	readf,1,clby
close,1
css=rotate(cs,7)
set_plot,dev
if dev eq 'X' then begin
	window,0
end

if dev eq 'PS' then begin
		device,filename='profil.eps',bits_per_pixel=16,$
			 xsize=19.5,ysize=12.5,scale_factor=1.0,/encapsulated
		print,"Printing to",'profil.eps'
	end
if dev eq 'X' then begin
	wset,0
	;contour,css,clbx,clby,xrange=[300,700],yrange=[300,700],nlevels=29,/fill
	;contour,css,clbx,clby,levels=[0],/overplot,/follow
	plot,clbx,clby,/nodata,xrange=[400,600],yrange=[400,600]
		plots,450,500
		plots,550,500,/continue
end
xmax=max(clbx) & ymin=min(clby)
ymax=max(clby) & xmin=min(clbx)

xscl=double(n-1)/(xmax-xmin)
yscl=double(n-1)/(ymax-ymin)

m=200
l=5
cspa=dblarr(l,m)
deg=((indgen(m) * (360.0/double(m-1))-180.0)/180.0)*3.141592653
;print,deg
if dev eq 'X' then window,1

st=0
for delta=5.0,50.0,(45.0/double(l-1)) do begin
	xvec=450.0 - cos(deg) * delta
	yvec=500.0 - sin(deg) * delta
	print,delta,min(xvec),max(xvec),min(yvec),max(yvec)
	if dev eq 'X' then begin
		wset,0
		plots,xvec(0),yvec(0),/data
		for i=1,m-1 do begin
			plots,xvec(i),yvec(i),/continue,/data
		end
	end
	xvec=xvec*xscl
	yvec=yvec*yscl
	ip=interpolate(css,xvec,yvec) / 1.0e09
	cspa(st,*)=ip(*)
	if dev eq 'X' then wset,1
	plot,180.0*(deg/3.141592653),ip,/noerase,xstyle=1,$
		yrange=[-2,-1.5],xrange=[-200,320],$
		title="!17Richtungsabhaengigkeit der Riss-Aktivierung",$
		xtitle="!17Winkel zw. Neben- und Hauptriss / deg",$
		ytitle="!17Coulombspannung / GPa",linestyle=0,$
		xtickv=[-180,-90,0,90,180],xticks=4
	if((double(st/2.0)eq (st/2)))then xshift=10 else xshift = 0
	xyouts,190+xshift,ip(m-1),"!7D!17 = "+string(format='(g4.2)',delta/50.0),/data
	;plots,305,ip(m-1),/data & plots,350,ip(m-1),linestyle=st,/data,/continue
	st=st+1
	
end
	xyouts,-100,-0.68,"!7D!17: radialer Abstand vom Crack-Tip / a"




if dev eq 'PS' then device,/close
end