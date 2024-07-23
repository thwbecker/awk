close,1
openr,1,'stre11'
readf,1,nr
n=sqrt(nr)
stre11=dblarr(3,n,n)
readf,1,stre11
close,1
openr,1,'stre12'
readf,1,nr
n=sqrt(nr)
stre12=dblarr(3,n,n)
readf,1,stre12
close,1
openr,1,'stre22'
readf,1,nr
n=sqrt(nr)
stre22=dblarr(3,n,n)
readf,1,stre22
close,1

set_plot,'X'
window,0,xsize=1000,ysize=1000

;shade_surf,stre22(2,*,*)
;contour,min_curve_surf(stre22(2,*,*),/regular)
contour,stre12(2,*,*),nlevels=20
end


