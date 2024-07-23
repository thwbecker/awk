kcpl = '0.900000.0.050000'
;kcpl = '0.960000.0.500000'
;kcpl = '0.960000.0.050000'
tmin = 0

printing = 1
col = 33
;col = 13
close, 1
;sdir = '50/' & dim=50
textcolor = 255
sdir = '100/' &  dim=100

dir = '~becker/courses/nonlindym/project/multid/2D/'
dir = dir + sdir

;filename= dir + kcpl + ".slip.2D.bin.hdr"
;openr, 1, filename
; readf, 1, ndim, mdim, bw, time
;close, 1
;print, ndim, mdim, bw, time
ndim = dim
mdim = dim

a = fltarr(ndim, mdim)
filename=dir+kcpl+".slip.2D.bin"

loadct, col
openr, 1, filename
i = 0
IF(printing)THEN $
  set_plot, "PS" $
ELSE $
  set_plot, 'X'

WHILE(NOT(EOF(1)))DO BEGIN 
   readu, 1, a
   
   ;;a = shift(a, dim/2, 0)
   
   IF(printing)THEN device, filename=dir+"s."+strcompress(string(i), /remove_all)+".eps", /color, $
     /encapsulated, xsize=13, ysize=13, bits_per_pixel=16
   
   ;;shade_surf,a,ax=90,az=0, zstyle=4,yticks=1, yminor=1, $
   ;;  shade=127+(a/scl)*128, charsize = 1.5, xstyle=4
   
   shade_surf,a,ax=90,az=0, zstyle=4, $
     shade=128+a/max(abs(a))*150, xstyle=4, ystyle=4
   xyouts, 0.25*ndim, mdim*1.011, "time="+string(FORMAT = '(f8.1)', i*10.0), charsize=2.0, color=textcolor
   xyouts, 0, -5, "slip deficit", color=textcolor
   xyouts, 0, -10, "min="+string(FORMAT = '(f8.4)',min(a))+" max="+string(FORMAT = '(f8.4)',max(a)), color=textcolor
   IF(printing)THEN BEGIN 
      device, /close
      
   ENDIF 
   i = i+1
   ;;colorscl,-scl,scl,"slip deficit",0,1
ENDWHILE
close, 1


set_plot, 'X'
END 
