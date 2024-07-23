n = 151
tmp = dblarr(3, n, n)

comp_azi = 135.0 ;; for compressive axis
comp = 1.0 ;; compressive stress magnitude


;azi = -15.48
azi = 45.0 ;; for fault orientations for resolved coulomb stress


beta = dblarr(n, n)
PI = 3.14159265358979
tau0 = 0.0
cazi = ((45-azi)/180.0)*PI
comp_azir = (90.0-comp_azi)*(PI/180.0)



fmyu = 0.6
sdmyu = 0.5
nomyu = 0.6
hp = 0.0
off = 0.0



normv=dblarr(2) & tangv = dblarr(2)

openr, 1, "stre11"
readf, 1, tmp
s11 = tmp(2, *, *)
close, 1
openr, 1, "stre12"
readf, 1, tmp
s12 = tmp(2, *, *)
close, 1
openr, 1, "stre22"
readf, 1, tmp
s22 = tmp(2, *, *)
close, 1
x = reform(tmp(0, *, *), n, n)
y = reform(tmp(1, *, *), n, n)

IF(comp NE 0.0)THEN print, "adding compressive stress of", comp, ' at azimuth', comp_azi


s11 = reform(s11, n, n) - comp*0.5*(1.0+cos(2*comp_azir))
s12 = reform(s12, n, n) - comp*0.5*(1.0-cos(2*comp_azir))
s22 = reform(s22, n, n) - comp*0.5*cos(2*comp_azir)*tan(2*comp_azir)




;;ux = reform(ux, n, n)
;;uy = reform(uy, n, n)
;;uz = reform(uz, n, n)


print, "Caculating normal and tangential stresses along plane", (cazi/PI)*180
tangv=[sin(cazi),cos(cazi)]
normv(0) = tangv(1) & normv(1)= -tangv(0)
b = ( 2.0 * off ) / (sqrt(1.0 + fmyu^2) - fmyu)
a=( sqrt(1+fmyu^2) + fmyu )/ ( sqrt(1+fmyu^2) - fmyu )
cs=dblarr(n,n) & tcs=dblarr(n,n)
fms=dblarr(n,n) & sms=dblarr(n,n) & deg=dblarr(n,n)
sn= -sigma_n(s11,s12,s22,normv,tangv)
st= -sigma_t(s11,s12,s22,normv,tangv)

;; calculate major stresses 
 
cms, n, s11, s12, s22, fms, sms, deg
cs = cstress(fms,sms,a,hp,b)        - cstress(tau0,-tau0,a,hp,b)
tcs= cstress(st,sn,fmyu,hp,off) - $
  cstress(tau0*sin(2*(PI / 4-cazi)),-tau0*cos(2*(PI/4-cazi)),fmyu,hp,off) 

if(off ne 0.0)then begin
   pf= ((fms-sms) * fmyu * sqrt(((off^2)*(1+fmyu^2))/(fmyu^2))) / $
     (off*(2*off+fmyu*(fms+hp)+fmyu*(sms+hp) ))
end
if(off eq 0.0)then begin
   pf= (fmyu*(fms+sms+2*hp)) / ( sqrt(1+fmyu^2)*(fms-sms))
END

;FOR  i=0,n-1 do begin
;   FOR  j=0,n-1 do begin
;      IF  ((fms(i,j) + sms(i,j)+2.0*hp) ne 0.0)THEN  BEGIN 
;         beta(i, j) = (PI-asin(((fms(i,j)-sms(i,j))/2.0) / ((2.0*hp+fms(i,j)+sms(i,j))/2.0)))/2.0
 ;     ENDIF 
;   END 
;END 






levelvec = [-0.25, -0.2, -0.15, -0.1, -0.05, 0.0, 0.05, 0.1, 0.15, 0.2, 0.25]


window, 0, xsize=1500, ysize=500
!p.multi = [0, 3, 1, 0]
shade_surf,cs,x,y,shade=bytscl(cs),az=0,ax=90,zstyle=4, $
  xtitle="!6x", ytitle="y", xstyle=1, ystyle=1
contour, cs, x, y, /overplot, title="!7r!6!ic!n", levels=levelvec
contour, cs, x, y, /overplot, levels=[0.0], /follow

shade_surf, tcs, x,y,shade=bytscl(tcs),az=0,ax=90,zstyle=4, $
  xtitle="!6x", ytitle="y", xstyle=1, ystyle=1
contour, tcs, x, y, /overplot, title="!7r!6!ic!n(!7b!6="+string(azi), levels=levelvec
contour, tcs, x, y, /overplot, levels=[0.0], /follow


shade_surf, s12, x,y,shade=bytscl(s12),az=0,ax=90,zstyle=4, $
  xtitle="!6x", ytitle="y", xstyle=1, ystyle=1
contour, s12, x, y, /overplot, title="!7r!6!i12!n", levels=levelvec
contour, s12, x, y, /overplot, levels=[0.0], /follow
set_plot, "PS"
!p.multi = 0
device, file="cs.eps", /encapsulated, xsize=12, ysize=12, bits_per_pixel=16, /color
shade_surf,cs,x,y,shade=bytscl(cs),az=0,ax=90,zstyle=4, $
  xtitle="!6x", ytitle="y", xstyle=1, ystyle=1
contour, cs, x, y, /overplot, title="!7r!6!ic!n", levels=levelvec
contour, cs, x, y, /overplot, levels=[0.0], /follow
set_plot, 'X'















END 



