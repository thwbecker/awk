;pro plotstress,sur,okada,printing
if n_params() lt 3 then printing=0
if n_params() lt 2 then okada=0
if n_params() lt 1 then sur=1

print,'Routine PLOTSTRESS [surface okada printing]'
print,'Using values:  ',sur,okada,printing


close, 1,2,3
datadir="/home/datdyn2/becker/finel/"

j=100
okn=51
if okada eq 1 then begin
	print,'Using OKADA Data in okstreXX.'
	openr,1,'okstre11'
	openr,2,'okstre22'
	openr,3,'okstre12'
endif else begin
	openr, 1, datadir+'stre11.fin'
	openr, 2, datadir+'stre22.fin'
	openr, 3, datadir+'stre12.fin'
end

if (printing)then dev='PS' else dev='X'
print,dev
set_plot,dev

if dev eq 'PS' then begin
	loadct,13		
	!p.multi=[0,2,2]
	device,filename="tau.ps",bits_per_pixel=8,/color
end

if dev eq 'X' then begin
	!p.multi=0
	loadct,13		;for rainbow coloringset_plot,dev
	window,0,xsize=300,ysize=300,xpos=640,ypos=720,title="TAU 11"
	window,1,xsize=300,ysize=300,xpos=965,ypos=380,title="TAU 22"
	window,2,xsize=300,ysize=300,xpos=965,ypos=720,title="TAU 12"
end

if(okada ne 1)then begin
   readf,1,m
   readf,2,m
   readf,3,m
end
if(okada eq 1)then begin
   readf,1,m
   readf,2,m
   readf,3,m
end

stre=dblarr(3,m)	
stre11=dblarr(m)
stre12=dblarr(m)
stre22=dblarr(m)



; STRESS TENSOR ELEMENT 11

	readf, 1, stre
	close,1
	stre(2,*)= -stre(2,*)
	triangulate,stre(0,*),stre(1,*),tr,b
	cl=trigrid(stre(0,*),stre(1,*),stre(2,*),tr,$
		[(max(stre(0,*))-min(stre(0,*)))/float(j),$
		(max(stre(1,*))-min(stre(1,*)))/float(j)])
	stre11=cl
	if dev eq 'X' then wset,0
	if(sur)then begin 
		shade_surf,cl,shade=bytscl(cl),$
		ax=90,az=0,zstyle=4,xtitle='TAU11'
	end

	if(not sur)then begin
		contour,cl,nlevels=29,/fill
		contour,cl,nlevels=10,/follow,overplot
	end

; STRESS TENSOR ELEMENT 22

	readf, 2, stre
	close,2
	stre(2,*)= -stre(2,*)
	triangulate,stre(0,*),stre(1,*),tr,b
	cl=trigrid(stre(0,*),stre(1,*),stre(2,*),tr,$
		[(max(stre(0,*))-min(stre(0,*)))/float(j),$
		(max(stre(1,*))-min(stre(1,*)))/float(j)])
	stre22=cl
	if dev eq 'X' then wset,1
	if(sur)then begin 
		shade_surf,cl,shade=bytscl(cl),$
		ax=90,az=0,zstyle=4,xtitle='TAU22'
	end

	if(not sur)then begin
		contour,cl,nlevels=29,/fill	
		contour,cl,nlevels=10,/follow,/overplot
	end

; STRESS TENSOR ELEMENT 12

	readf, 3, stre
	close,3
	stre(2,*)= -stre(2,*)
	triangulate,stre(0,*),stre(1,*),tr,b
	cl=trigrid(stre(0,*),stre(1,*),stre(2,*),tr,$
		[(max(stre(0,*))-min(stre(0,*)))/float(j),$
		(max(stre(1,*))-min(stre(1,*)))/float(j)])
	stre12=cl
	if dev eq 'X' then wset,2
	if(sur)then begin 
		shade_surf,cl,shade=bytscl(cl),$
		ax=90,az=0,zstyle=4,xtitle='TAU12'
	end

	if(not sur)then begin
		contour,cl,nlevels=29,/fill
		contour,cl,nlevels=10,/follow,/overplot
	end


if dev eq 'PS' then device,/close
if dev eq 'X' then tmp=get_kbrd(1)
if (dev eq 'X')and(tmp eq 'k') then wdelete,0,1,2

end









