datadir = "/home/datdyn2/becker/finel/feigl/"
filedir = datadir+"/"
emodul = 5e10
nyu = 0.25
virh = 1.0
faultread = 1
mapscale = 0.1
ps = 1

start = 1 & stop=1
IF(faultread)THEN BEGIN 
   openr, 1, filedir+"faultcoord"
   readf, 1, nrflt
   fltcoord = dblarr(4, nrflt)
   readf, 1, fltcoord
   close, 1
ENDIF 
FOR test=start,  stop DO BEGIN 

   openr, 1, filedir+"realdispx."+strtrim(test, 1)+".xyz"
   openr, 2, filedir+"realdispy."+strtrim(test, 1)+".xyz"
   readf, 1, m
   readf, 2, m
   n = sqrt(m)
   x = dblarr(n, n)
   y = dblarr(n, n)
   dux = dblarr(n, n)
   duy = dblarr(n, n)
   temp = dblarr(3, m)
   readf, 1, temp
   x = reform(temp(0, *), n, n)
   y = reform(temp(1, *), n, n)
   dux = reform(temp(2, *), n, n)

   readf, 2, temp
   duy = reform(temp(2, *), n, n)

   close, 1, 2
   openr, 1, filedir+"stre11."+strtrim(test, 1)+".xyz"
   openr, 2, filedir+"stre12."+strtrim(test, 1)+".xyz"
   openr, 3, filedir+"stre22."+strtrim(test, 1)+".xyz"
   readf, 1, a1, fmyu, a2, a3, hp, a5 & readf, 1, m
   readf, 2, a1, fmyu, a2, a3, hp, a5 & readf, 2, m
   readf, 3, a1, fmyu, a2, a3, hp, a5 & readf, 3, m
   readf, 1, temp
   IF(sqrt(m) NE n)THEN BEGIN 
      print, "Array size mismatch between stresses and displacements !"
      print, n, sqrt(m)
   ENDIF 
   n = sqrt(m)
   s11 = reform(temp(2, *), n, n)
   readf, 2, temp
   s12 = reform(temp(2, *), n, n)
   readf, 3, temp
   s22 = reform(temp(2, *), n, n)
   close, 1, 2, 3
   duz = virh*(-(nyu/emodul)*(s11+s22))

ENDFOR 

IF(ps)THEN BEGIN 
   set_plot, 'PS'
   device, file=filedir+"uz.eps", /encapsulated, xsize=15, ysize=15, bits_per_pixel=16, /color
ENDIF ELSE BEGIN 
   set_plot, 'X'
   window, 0
ENDELSE 
   

loadct, 32
shade_surf,smooth(duz,2),x*mapscale,y*mapscale,ax=90,az=0,shade=bytscl(smooth(duz,2)),zstyle=4, xtitle="x [km]", $
  ytitle="y [km]"
xyouts,40,90,"!6u!iz!n [AU]",/data,charsize=2.0
FOR i=0, nrflt-1 DO BEGIN 
   plots, fltcoord(0, i)*mapscale, fltcoord(1, i)*mapscale
   plots, fltcoord(2, i)*mapscale, fltcoord(3, i)*mapscale, /continue, color=0, thick=2.0
ENDFOR 

IF(ps)THEN device, /close ELSE set_plot, 'X'
end


