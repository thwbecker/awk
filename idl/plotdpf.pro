pro plotdpf,gmted,ok,printing
print,'plotpdf [GMTED OKADA PRINTING]'
if n_params() lt 3 then printing=0
if n_params() lt 2 then ok=0
if n_params() lt 1 then gmted=1
if printing then  dev='PS' else dev='X'
close, 1

print,'Ausgabe :',dev

ngmt=50+1
finelfac=1e-04
epsilon=0.0001
left=0&right=400

set_plot,dev
if dev eq 'PS' then begin
	device,filename='dpf.ps',xoffset=0.5,yoffset=0,xsize=21.,ysize=25.7
	loadct,13		
	!p.multi=[0,2,3]
end
if dev eq 'X' then begin
	!p.multi=0
	loadct,13		
	window,0,xsize=300,ysize=300,xpos=640,ypos=800
	window,1,xsize=300,ysize=300,xpos=965,ypos=800
	window,2,xsize=300,ysize=300,xpos=640,ypos=380
	window,3,xsize=300,ysize=300,xpos=965,ypos=380
	window,4,xsize=300,ysize=300,xpos=640,ypos=0
	window,5,xsize=300,ysize=300,xpos=965,ypos=0
end
if (gmted eq 0) then begin
	print,'assuming regular Data.'
	if( ok eq 0)then begin
		print,'Using FINEL data in dpfield'
		openr, 1, 'dpfield'
		fac=finelfac
	endif else begin
		print,'Using OKADA data in okdpfield'
		openr,1,'okdpfield'
		fac=1
	end
	readf,1, numnp
	n=sqrt(numnp)
	profil1=dblarr(4,n)
	profil2=dblarr(4,n)
	dpv=dblarr(4,n,n)
	readf,1,dpv
	close,1
endif else begin
	print,'Using gmted FINEL data from disp1.xyz and disp2.xyz'
	print,'   assuming a ',ngmt,' * ',ngmt,' grid.'
	profil1=dblarr(4,ngmt)
	profil2=dblarr(4,ngmt)
	dpv=dblarr(4,ngmt,ngmt)
	disp1=dblarr(3,ngmt,ngmt)
	disp2=dblarr(3,ngmt,ngmt)
	openr,1,'disp1.xyz'
	readf,1,disp1
	close,1
	openr,1,'disp2.xyz'
	readf,1,disp2
	close,1
	for i=0,ngmt-1 do begin
		for j=0,ngmt-1 do begin
			if((disp1(0,i,j) ne disp2(0,i,j))$
				or(disp1(1,i,j) ne disp2(1,i,j)))$
			then print,'Not the same gridding coordinates!'
		end
	end 
	dpv(0,*,*)=disp1(0,*,*)
	dpv(1,*,*)=disp1(1,*,*)
	dpv(2,*,*)=disp1(2,*,*)
	dpv(3,*,*)=disp2(2,*,*)
	n=ngmt
	fac=1
end	

k=0&l=0
for i=0,n-1 do begin
	for j=0,n-1 do begin
		if (abs(dpv(1,i,j)- 200.0) lt epsilon) then begin
			profil1(*,k)=dpv(*,i,j)
			k=k+1
		end
		if (abs(dpv(0,i,j)-200.0)lt epsilon) then begin
			profil2(*,l)=dpv(*,i,j)
			l=l+1
		end
	end
end


print,'Maximales UX:',max(dpv(2,*,*))/fac
print,'Maximales UY:',max(dpv(3,*,*))/fac

if dev eq 'X' then wset,0
contour,dpv(2,*,*),nlevels=10,title='Verschiebung-x'
;shade_surf,dpv(3,*,*),az=0,ax=90

if dev eq 'X' then wset,1
contour,dpv(3,*,*),nlevels=10,title='Verschiebung-y'
;shade_surf,dpv(2,*,*),az=0,ax=90
if dev eq 'X' then wset,2
plot,profil1(0,*),profil1(2,*)/fac,title='Horizontales Profil, UX',$
	xrange=[left,right]
if dev eq 'X' then wset,3
plot,profil1(0,*),profil1(3,*)/fac,title='Horizontales Profil, UY',$
	xrange=[left,right]
if dev eq 'X' then wset,4
plot,profil2(1,*),profil2(2,*)/fac,title='Vertikales Profil, UX',$
	xrange=[left,right]
if dev eq 'X' then wset,5
plot,profil2(1,*),profil2(3,*)/fac,title='Vertikales Profil, UY',$
	xrange=[left,right]


if dev eq 'X' then begin
	tmp=get_kbrd(1)
	if tmp eq 'k' then wdelete,0,1,2,3,4,5
end
if dev eq 'PS' then begin
	device,/close
	set_plot,'X'
end
end









