sur = 1 &  printing= 0 &  sur=1 

close, 1,2,3, 4, 5, 6
datadir="/home/geodyn/becker/finel/results/healtests/"

j=100


	;openr, 1, datadir+'stre11.f1fault.newroutine'
;	openr, 2, datadir+'stre12.f1fault.newroutine'
;	openr, 3, datadir+'stre22.f1fault.newroutine'
;        openr, 4, datadir+'stre11.f1nofault.newroutine'
;	openr, 5, datadir+'stre12.f1nofault.newroutine'
;	openr, 6, datadir+'stre22.f1nofault.newroutine'


        openr, 1, datadir+'stre11.ygfault.a1'
	openr, 2, datadir+'stre12.ygfault.a1'
	openr, 3, datadir+'stre22.ygfault.a1'
        openr, 4, datadir+'stre11.ygnofault.a1'
	openr, 5, datadir+'stre12.ygnofault.a1'
	openr, 6, datadir+'stre22.ygnofault.a1'


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


   FOR i=1, 6 DO BEGIN 
      readf,i,m
   ENDFOR 


stre=dblarr(3,m)	
stref11=dblarr(m)
stref12=dblarr(m)
stref22=dblarr(m)
strenf11=dblarr(m)
strenf12=dblarr(m)
strenf22=dblarr(m)



; STRESS TENSOR ELEMENT 11

	readf, 1, stre
	close,1
	stre(2,*)= -stre(2,*)
	triangulate,stre(0,*),stre(1,*),tr,b
	cl=trigrid(stre(0,*),stre(1,*),stre(2,*),tr,$
		[(max(stre(0,*))-min(stre(0,*)))/float(j),$
		(max(stre(1,*))-min(stre(1,*)))/float(j)])
	stref11=cl

        readf, 4, stre
	close,1
	stre(2,*)= -stre(2,*)
	triangulate,stre(0,*),stre(1,*),tr,b
	cl=trigrid(stre(0,*),stre(1,*),stre(2,*),tr,$
		[(max(stre(0,*))-min(stre(0,*)))/float(j),$
		(max(stre(1,*))-min(stre(1,*)))/float(j)])
	strenf11=cl

        



	if dev eq 'X' then wset,0
	if(sur)then begin 
		shade_surf,cl,shade=bytscl(cl),$
		ax=90,az=0,zstyle=4,xtitle='TAU11'
	end
	if(not sur)then begin
		contour,cl,nlevels=29,/fill
		contour,cl,nlevels=10,/follow,overplot
	end


; STRESS TENSOR ELEMENT 12

	readf, 2, stre
	close,2
	stre(2,*)= -stre(2,*)
	triangulate,stre(0,*),stre(1,*),tr,b
	cl=trigrid(stre(0,*),stre(1,*),stre(2,*),tr,$
		[(max(stre(0,*))-min(stre(0,*)))/float(j),$
		(max(stre(1,*))-min(stre(1,*)))/float(j)])
	stref12=cl
        readf, 5, stre
	close,2
	stre(2,*)= -stre(2,*)
	triangulate,stre(0,*),stre(1,*),tr,b
	cl=trigrid(stre(0,*),stre(1,*),stre(2,*),tr,$
		[(max(stre(0,*))-min(stre(0,*)))/float(j),$
		(max(stre(1,*))-min(stre(1,*)))/float(j)])
	strenf12=cl
        




	if dev eq 'X' then wset,1
	if(sur)then begin 
		shade_surf,cl,shade=bytscl(cl),$
		ax=90,az=0,zstyle=4,xtitle='TAU12'
	end

	if(not sur)then begin
		contour,cl,nlevels=29,/fill	
		contour,cl,nlevels=10,/follow,/overplot
	end

; STRESS TENSOR ELEMENT 22

	readf, 3, stre
	close,3
	stre(2,*)= -stre(2,*)
	triangulate,stre(0,*),stre(1,*),tr,b
	cl=trigrid(stre(0,*),stre(1,*),stre(2,*),tr,$
		[(max(stre(0,*))-min(stre(0,*)))/float(j),$
		(max(stre(1,*))-min(stre(1,*)))/float(j)])
	stref22=cl

	readf, 6, stre
	close,6
	stre(2,*)= -stre(2,*)
	triangulate,stre(0,*),stre(1,*),tr,b
	cl=trigrid(stre(0,*),stre(1,*),stre(2,*),tr,$
		[(max(stre(0,*))-min(stre(0,*)))/float(j),$
		(max(stre(1,*))-min(stre(1,*)))/float(j)])
	strenf22=cl

        





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









