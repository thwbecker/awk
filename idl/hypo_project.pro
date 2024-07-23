; projects hypocenters onto a slice centered at lon0 lat0
; spherical geometry is not taken into account for projection


PRO hypo_project, file, n, lon0, lat0, azi, $
                  maxd, symbol, col, size

print, 'might not be failsafe for 180 crossings and the like'

print, 'lon ', lon0,' lat ', lat0, ' azi ', azi, ' width ', maxd

;; lon0 lat0 azi and maxd all in degrees!
f1 = 3.14159265358979323/180.0

width   =  maxd*f1
azimuth =   azi*f1

x1 = sin(azimuth) 
x2 = cos(azimuth)

loc = fltarr(4, n)
close, 1
openr, 1, file
print, 'reading ', file
print, n, ' hypocenters'
readf, 1, loc
close, 1
FOR i=0L, n-1 DO BEGIN 
    IF(loc(0, i) LT 0)THEN loc(0, i) = 360+loc(0, i)
ENDFOR 

y1 = (loc(0, *)-lon0)*f1
y2 = (loc(1, *)-lat0)*f1
r = 6371-loc(2, *)

   alpha = (y1*x1+y2*x2)
   d1 = y1 - alpha*x1
   d2 = y2 - alpha*x2
   d = sqrt(d1^2+d2^2)

   plotted = 0
   FOR i=0L, n-1 DO BEGIN 
      ; angle to hypocenter from west east line anticlockwise
      IF(d(i) LE width)THEN BEGIN 
         plots, r(i) * sin(alpha(i)), r(i) * cos(alpha(i)), $
           psym=symbol, color=col, symsize=size, noclip = 0
         plotted= plotted+1
      ENDIF 
   ENDFOR 
   print, 'plotted ', plotted
   
   
END 
