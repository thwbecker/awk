pro plotstressgmt,sur,printing
if n_params() lt 2 then printing=0
if n_params() lt 1 then sur=1

print,'Routine PLOTSTRESSGMT [surface printing]'


filedir="/datdyn/becker/finel/"
close, 1,2,3

j=100


openr, 1, filedir+'stre11.xyz'
openr, 2, filedir+'stre12.xyz'
openr, 3, filedir+'stre22.xyz'


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
	window,0,xsize=300,ysize=300,xpos=640,ypos=800,title="TAU 11"
	window,1,xsize=300,ysize=300,xpos=965,ypos=380,title="TAU 22"
	window,2,xsize=300,ysize=300,xpos=965,ypos=800,title="TAU 12"
	window,3,xsize=300,ysize=300,xpos=640,ypos=380,title="CSTR"
end
readf,1,m
readf,2,m
readf,3,m
m=sqrt(m)


stre11=dblarr(3,m,m)
stre12=dblarr(3,m,m)
stre22=dblarr(3,m,m)

; STRESS TENSOR ELEMENT 11

	readf, 1, stre11
	close,1
	stre11(2,*,*)= -stre11(2,*,*)
	if dev eq 'X' then wset,0
		shade_surf,stre11(2,*,*),stre11(0,*,*),stre11(1,*,*),$
			shade=bytscl(stre11(2,*,*)),$
			ax=90,az=0,zstyle=4,xtitle='TAU11'


; STRESS TENSOR ELEMENT 12

	readf, 2, stre12
	close,2
	stre12(2,*,*)= -stre12(2,*,*)
	if dev eq 'X' then wset,2

		shade_surf,stre12(2,*,*),stre12(0,*,*),stre12(1,*,*),$
			shade=bytscl(stre12(2,*,*)),$
			ax=90,az=0,zstyle=4,xtitle='TAU12'



; STRESS TENSOR ELEMENT 22

	readf, 3, stre22
	close,3
	stre22(2,*,*)= -stre22(2,*,*)
	if dev eq 'X' then wset,1
	if(sur)then begin 
		shade_surf,stre22(2,*,*),stre22(0,*,*),stre22(1,*,*),$
			shade=bytscl(stre22(2,*,*)),$
			ax=90,az=0,zstyle=4,xtitle='TAU22'
	end
;COULOMB STRESS
	if dev eq 'X' then wset,3


if dev eq 'PS' then device,/close
if dev eq 'X' then tmp=get_kbrd(1)
if (dev eq 'X')and(tmp eq 'k') then wdelete,0,1,2

end









