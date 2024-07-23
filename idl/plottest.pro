close, 1
dev='X'
;dev='PS'
if dev eq 'PS' then loadct,0		;for B and W
if dev eq 'X' then loadct,13		;for rainbow coloring

n=10+1 	;regular 10+1 * 10+1 grid, der von convstrefield erzeugt wurde

; STRESS TENSOR ELEMENT 11
stre=fltarr(3,n*n)	
openr, 1, 'stre11.xyz'
readf, 1, stre
close, 1
stre11=fltarr(n,n)
stre11x=fltarr(n,n)
stre11y=fltarr(n,n)

stre11(*,*)=stre(2,*)
stre11x(*,*)=stre(0,*)
stre11y(*,*)=stre(1,*)
window,0,xsize=300,ysize=300,xpos=640,ypos=800
shade_surf,stre11,stre11x,stre11y,ax=90,az=0,zstyle=4,xtitle='TAU11'


; STRESS TENSOR ELEMENT 22
stre=fltarr(3,n*n)	

openr, 1, 'stre22.xyz'
readf, 1, stre
close, 1
stre22=fltarr(n,n)
stre22x=fltarr(n,n)
stre22y=fltarr(n,n)

stre22(*,*)=stre(2,*)
stre22x(*,*)=stre(0,*)
stre22y(*,*)=stre(1,*)
window,1,xsize=300,ysize=300,xpos=965,ypos=380
shade_surf,stre22,stre22x,stre22y,ax=90,az=0,zstyle=4,xtitle='TAU 22'

; STRESS TENSOR ELEMENT 12
stre=fltarr(3,n*n)	
openr, 1, 'stre12.xyz'
readf, 1, stre
close, 1
stre12=fltarr(n,n)
stre12x=fltarr(n,n)
stre12y=fltarr(n,n)

stre12(*,*)=stre(2,*)
stre12x(*,*)=stre(0,*)
stre12y(*,*)=stre(1,*)
window,3,xsize=300,ysize=300,xpos=965,ypos=800
shade_surf,stre12,stre12x,stre12y,ax=90,az=0,zstyle=4,xtitle='TAU12'


end



