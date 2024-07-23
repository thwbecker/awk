pro pcoulomb,nr,sur,okada,printing
if n_params() lt 4 then printing=0
if n_params() lt 3 then okada=0
if n_params() lt 2 then sur=0
if n_params() lt 1 then nr=1
plarrow=0
print,'Routine pcoulomb [nr surface okada printing]'
print,'Using values:    ',nr,sur,okada,printing

left=0&right=400
close, 1
if okada ne 1 then begin
	openr, 1, "coulomb."+strtrim(nr,1)+".xyz"
	print,'Reading ',"coulomb."+strtrim(nr,1)+".xyz"
end
if okada eq 1 then begin
	openr,1,"okcoulomb.xyz"
	print,'Reading ',"okcoulomb.xyz"
end
if (printing)then dev='PS' else dev='X'
print,dev
set_plot,dev

if dev eq 'PS' then begin
	loadct,13		
;	!p.multi=[0,2,2]
	device,filename="coulomb."+strtrim(nr,1)+".ps",bits_per_pixel=8,/color
	print,"Printing to ","coulomb."+strtrim(nr,1)+".ps"
end
if dev eq 'X' then begin
	!p.multi=0
	loadct,13		;for rainbow coloringset_plot,dev
	window,0
end

readf,1,m 
n=sqrt(m)

clb=fltarr(3,n*n)	
clbs=fltarr(n,n)
clbx=fltarr(n,n)
clby=fltarr(n,n)

readf, 1, clb
close,1

clbs(*,*)=clb(2,*)
clbx(*,*)=clb(0,*)
clby(*,*)=clb(1,*)
c1=0
if dev eq 'X' then wset,0
if(sur)then begin 
	;shade_surf,clbs,clbx,clby,shade=bytscl(-clbs),$
	;	ax=90,az=0,zstyle=4,xtitle='Coulomb stress',xrange=[left,right],$
	;	yrange=[left,right]
	contour,clbs,clbx,clby,nlevels=20,/fill
if(plarrow)then begin
	x0=200&y0=400
	x1=x0+sin(((nr-2)/8.0)*(3.141))*50
	y1=y0+cos(((nr-2)/8.0)*(3.141))*50
	arrow,x0,y0,x1,y1,/solid,thick=2.0,color=1
	x0=500&y0=150
	x1=x0+sin(((nr-2)/8.0)*(3.141))*50
	y1=y0+cos(((nr-2)/8.0)*(3.141))*50
	arrow,x0,y0,x1,y1,/solid,thick=2.0,color=1
	arrow,260,190,420,340,thick=1.0,color=50
	arrow,430,320,270,170,thick=1.0,color=50

	
;	plots,100,300,color=c1
;	plots,x1,x2,/continue,color=c1
end
	;surface,clbs
end

if(not sur)then begin
	contour,(clbs),clbx,clby,nlevels=10,xrange=[left,right],$
		yrange=[left,right],/follow

end
if(dev eq 'X')then print,"k to kill image, t to out a TIFF"

if dev eq 'PS' then device,/close
if dev eq 'PS' then tmp=''
if dev eq 'X' then tmp=get_kbrd(1)
if (dev eq 'X' and tmp eq 'k') then wdelete,0,1,2
if (dev eq 'X' and tmp eq 't')then begin
	common colors,r_orig,g_orig,b_orig,$
		r_con,g_con,b_con
	image=tvrd()
	tiff_write,"coulomb."+strtrim(nr,1)+".tiff",image,red=r_orig,$
		green=g_orig,blue=b_orig
	print,"Printing to ","coulomb."+strtrim(nr,1)+".tiff"
end
end









