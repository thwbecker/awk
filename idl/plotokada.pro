pro plotokada,printing,compare,field
print,'PLOTOKADA [PRINTING COMPARE FIELD]'

if n_params() lt 3 then field=0
if n_params() lt 2 then compare=0
if n_params() lt 1 then printing=0
if printing then  dev='PS' 
if printing eq 0 then dev='X'


fac=1.0e-04 
left=50&right=350


close, 1 & close,2
print,'Ausgabe: ',dev
set_plot,dev
if dev eq 'PS' then begin
	device,filename='okadacomp.ps',xoffset=0.5,yoffset=0,$
		xsize=21.,ysize=25.7
	loadct,13		
	!p.multi=[0,2,3]
end
if dev eq 'X' then begin
	!p.multi=0
	loadct,13		
	if(compare eq 1)then begin
		window,0,xsize=600,ysize=300
		window,1,xsize=600,ysize=300
	end
	if(compare eq 0)then begin
		window,2,xsize=300,ysize=300,xpos=0,ypos=800
		window,3,xsize=300,ysize=300,xpos=315,ypos=800
		window,5,xsize=300,ysize=300,xpos=315,ypos=390
		window,4,xsize=300,ysize=300,xpos=0,ypos=390
	end
end

if(field eq 1)then begin
	print,'Extracting  data from dpfield.'
	openr, 1, 'dpfield'
	readf,1, numnp
	n=sqrt(numnp)
	profil1=dblarr(4,n)
	profil2=dblarr(4,n)
	dpv=dblarr(4,n,n)
	readf,1,dpv
	close,1
	k=0&l=0
	for i=0,n-1 do begin
		for j=0,n-1 do begin
			if dpv(1,i,j) eq 50 then begin
				profil1(*,k)=dpv(*,i,j)
				k=k+1
			end
			if dpv(0,i,j) eq 50 then begin
				profil2(*,l)=dpv(*,i,j)
				l=l+1
			end
		end
	end
end

if(field eq 0)then begin
	print,'Using data from the disp_profilx files.'
	openr,1,'disp_profil1'
	readf,1,n
	profil1=dblarr(4,n)
	readf,1,profil1
	close,1
	openr,1,'disp_profil2'
	readf,1,n
	profil2=dblarr(4,n)
	readf,1,profil2
	close,1
end

openr,1,'alongstrike' & openr,2,'antistrike'
readf,1,nr1 & readf,2,nr2
okprofil1=dblarr(4,nr1) & okprofil2=dblarr(4,nr2)
readf,1,okprofil1 & readf,2,okprofil2
close,1 & close,2

if(compare eq 0)then begin
	if dev eq 'X' then wset,2
	plot,profil1(0,*),profil1(3,*)/fac,title='Horizontales Profil, Uy',$
		psym=7,xrange=[left,right]
	if dev eq 'X' then wset,3
	plot,profil2(1,*),profil2(2,*)/fac,title='Vertikales Profil, Ux',$
		psym=7,xrange=[left,right]
	if dev eq 'X' then wset,4
	plot,okprofil1(0,*),okprofil1(3,*),title='Ok:Horizontales Profil, Uy',$
		xrange=[left,right]
	if dev eq 'X' then wset,5
	plot,okprofil2(1,*),okprofil2(2,*),title='Ok:Vertikales Profil, Ux',$
		xrange=[left,right]
end
if compare eq 1 then begin
	if dev eq 'X' then  wset,0	
	plot,okprofil1(0,*),okprofil1(3,*),title='Horizontales Profil, UY',$
		xrange=[left,right]
	oplot,profil1(0,*),profil1(3,*)/fac,psym=7

	if dev eq 'X' then wset,1
	plot,okprofil2(1,*),okprofil2(2,*),title='Vertikales Profil, UX',$
		xrange=[left,right]
	oplot,profil2(1,*),profil2(2,*)/fac,psym=7
end

if dev eq 'X' then begin
	tmp=get_kbrd(1)
	if tmp eq 'k' then wdelete,0,1,2,3,4,5
end
if dev eq 'PS' then begin
	device,/close
	set_plot,'X'
end
end









