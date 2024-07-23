close, 1
checkok = 1
usegmt = 1
workdir = '/home/datdyn/becker/finel/feigl/'
pr = 1


fefac = 10000.0
virh = 15.0


IF(usegmt)THEN BEGIN 
   openr, 1, workdir+"ux.dat.xyz"
   readf, 1, n
   m = sqrt(n)
   uxx = dblarr(m, m)
   uxy = dblarr(m, m)
   uyx = dblarr(m, m)
   uyy = dblarr(m, m)
   uzx = dblarr(m, m)
   uzy = dblarr(m, m)
   ouxx = dblarr(m, m)
   ouxy = dblarr(m, m)
   ouyx = dblarr(m, m)
   ouyy = dblarr(m, m)
   ouzx = dblarr(m, m)
   ouzy = dblarr(m, m)

   ux = dblarr(m, m)
   uy = dblarr(m, m)
   uz = dblarr(m, m)
   oux = dblarr(m, m)
   ouy = dblarr(m, m)
   ouz = dblarr(m, m)
   
   tmp = dblarr(3, n)
   readf, 1, tmp
   close, 1

   uxx = reform(tmp(0, *), m, m)
   uxy = reform(tmp(1, *), m, m)
   ux = reform(tmp(2, *), m, m)*fefac
   
   openr, 1, workdir+"uy.dat.xyz"
   readf, 1, n
   tmp = dblarr(3, n) &  m = sqrt(n)
   readf, 1, tmp
   close, 1
   uyx = reform(tmp(0, *), m, m)
   uyy = reform(tmp(1, *), m, m)
   uy = reform(tmp(2, *), m, m)*fefac


   openr, 1, workdir+"uz.dat.xyz"
   readf, 1, n
   tmp = dblarr(3, n) &  m = sqrt(n)
   readf, 1, tmp
   close, 1
   uzx = reform(tmp(0, *), m, m)
   uzy = reform(tmp(1, *), m, m)
   uz = reform(tmp(2, *), m, m)*fefac*virh
   
   IF(checkok)THEN BEGIN
      openr, 1, workdir+"ux.ok.xyz"
      readf, 1, n
      tmp = dblarr(3, n) &  m = sqrt(n)
      readf, 1, tmp
      close, 1

      ouxx = reform(tmp(0, *), m, m)
      ouxy = reform(tmp(1, *), m, m)
      oux = reform(tmp(2, *), m, m)
      
      openr, 1, workdir+"uy.ok.xyz"
      readf, 1, n
      tmp = dblarr(3, n) &  m = sqrt(n)
      readf, 1, tmp
      close, 1
      ouyx = reform(tmp(0, *), m, m)
      ouyy = reform(tmp(1, *), m, m)
    
      ouy = reform(tmp(2, *), m, m)
      
      openr, 1, workdir+"uz.ok.xyz"
      readf, 1, n
      tmp = dblarr(3, n) &  m = sqrt(n)
      readf, 1, tmp
      close, 1

      ouzx = reform(tmp(0, *), m, m)
      ouzy = reform(tmp(1, *), m, m)
  
      ouz = reform(tmp(2, *), m, m)
      
   ENDIF 
ENDIF ELSE BEGIN 
   openr, 1, workdir+"ux.dat"  &  readf, 1, n &  tmp = dblarr(3, n)

   readf, 1, tmp
   triangulate,tmp(0,*),tmp(1,*),tr,b
   ux=trigrid(tmp(0,*),tmp(1,*),tmp(2,*),tr)
   close, 1

   openr, 1, workdir+"uy.dat" &  readf, 1, n &  tmp = dblarr(3, n)
   readf, 1, tmp
   triangulate,tmp(0,*),tmp(1,*),tr,b
   uy=trigrid(tmp(0,*),tmp(1,*),tmp(2,*),tr)
   close, 1

   openr, 1, workdir+"uz.dat" &  readf, 1, n &  tmp = dblarr(3, n)
   readf, 1, tmp
   triangulate,tmp(0,*),tmp(1,*),tr,b
   uz=trigrid(tmp(0,*),tmp(1,*),tmp(2,*),tr)
   close, 1

   IF(checkok)THEN BEGIN
      openr, 1, workdir+"ux.ok" &  readf, 1, n &  tmp = dblarr(3, n)
      readf, 1, tmp
      triangulate,tmp(0,*),tmp(1,*),tr,b
      oux=trigrid(tmp(0,*),tmp(1,*),tmp(2,*),tr)
      close, 1

      openr, 1, workdir+"uy.ok" &  readf, 1, n &  tmp = dblarr(3, n)
      readf, 1, tmp
      triangulate,tmp(0,*),tmp(1,*),tr,b
      ouy=trigrid(tmp(0,*),tmp(1,*),tmp(2,*),tr)
      close, 1

      openr, 1, workdir+"uz.ok" &  readf, 1, n &  tmp = dblarr(3, n)
      readf, 1, tmp
      triangulate,tmp(0,*),tmp(1,*),tr,b
      ouz=trigrid(tmp(0,*),tmp(1,*),tmp(2,*),tr)
      close, 1

   ENDIF 
ENDELSE 


!p.multi = [0, 2, 0, 0]
charsize = 1.5


IF(pr)THEN BEGIN 
   set_plot, 'PS'
   device,filename=workdir+'ux.eps', bits_per_pixel=16,$
     ysize=18,xsize=26,scale_factor=1.0, /encapsulated, /portrait
ENDIF 
shade_surf,smooth(ux, 2),uxx, uxy, xtitle="east [km]",ytitle="north [km]",ztitle="u!ix!n [mm]",$
  title="plane stress",charsize=2
shade_surf,oux,ouxx, ouxy, xtitle="east [km]",ytitle="north [km]",ztitle="u!ix!n [mm]",$
  title="okada",charsize=2
IF(pr)THEN device, /close


IF(pr)THEN BEGIN 
   set_plot, 'PS'
   device,filename=workdir+'uy.eps', bits_per_pixel=16,$
     ysize=18,xsize=26,scale_factor=1.0, /encapsulated, /portrait
ENDIF 
shade_surf,smooth(uy, 2),uyx, uyy, xtitle="east [km]",ytitle="north [km]",ztitle="u!iy!n [mm]",$
  title="plane stress",charsize=2
shade_surf,ouy,ouyx, ouyy, xtitle="east [km]",ytitle="north [km]",ztitle="u!iy!n [mm]",$
  title="okada",charsize=2
IF(pr)THEN device, /close


IF(pr)THEN BEGIN 
   set_plot, 'PS'
   device,filename=workdir+'uz.eps', bits_per_pixel=16,$
     ysize=18,xsize=26,scale_factor=1.0, /encapsulated, /portrait
ENDIF 
shade_surf,smooth(uz, 2),uzx, uzy, xtitle="east [km]",ytitle="north [km]",ztitle="u!iz!n [mm]",$
  title="plane stress",charsize=2
shade_surf,ouz,ouzx, ouzy, xtitle="east [km]",ytitle="north [km]",ztitle="u!iz!n [mm]",$
  title="okada",charsize=2
IF(pr)THEN BEGIN 
   device, /close
ENDIF 


!p.multi = 0
IF(pr)THEN BEGIN 
   set_plot, 'PS'
   device,filename=workdir+'pro_ux.eps', bits_per_pixel=16,$
     ysize=16,xsize=15,scale_factor=1.0, /encapsulated
ENDIF 
plot, ouxy(50, *), oux(50, *), title="profile at x=50km", xtitle="y [km]", ytitle="u!ix!n [mm]"
oplot, uxy(50, *), ux(50, *), linestyle=2
xyouts, 80, 200, "Okada" &  plots, 90, 200 & plots, 95, 200, /continue
xyouts, 80, 180, "FE" &  plots, 90, 180 & plots, 95, 180, linestyle=2, /continue

IF(pr)THEN device, /close
IF(pr)THEN BEGIN 
   set_plot, 'PS'
   device,filename=workdir+'pro_uy.eps', bits_per_pixel=16,$
     ysize=16,xsize=15,scale_factor=1.0, /encapsulated
ENDIF 
plot, ouyx(*, 50), ouy(*, 50), title="profile at y=50km", xtitle="x [km]", ytitle="u!iy!n [mm]"
oplot, uyx(*, 50), uy(*, 50), linestyle=2
xyouts, 80, 150, "Okada" &  plots, 90, 150 & plots, 95, 150, /continue
xyouts, 80, 120, "FE" &  plots, 90, 120 & plots, 95, 120, linestyle=2, /continue

IF(pr)THEN device, /close


IF(pr)THEN BEGIN 
   set_plot, 'PS'
   device,filename=workdir+'pro_uz.eps', bits_per_pixel=16,$
     ysize=16,xsize=15,scale_factor=1.0, /encapsulated
ENDIF 
plot,ouzx(*, 49), ouz(*, 49), title="profile at y=49km", xtitle="x [km]", ytitle="u!iz!n [mm]"
oplot, uzx(*, 49), uz(*, 49), linestyle=2
xyouts, 80, 150, "Okada" &  plots, 90, 150 & plots, 95, 150, /continue
xyouts, 80, 120, "FE" &  plots, 90, 120 & plots, 95, 120, linestyle=2, /continue

IF(pr)THEN device, /close




!p.multi = 0
set_plot, 'X'

END 


