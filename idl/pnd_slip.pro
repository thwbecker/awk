FOR couplingk=0.05,  1, 0.05 DO  BEGIN 

IF(couplingk EQ 0.6)THEN couplingk = 0.7
;wdelete, 0, 1
knd = '0.965000.'
kcpl = string(format='(f8.6)', couplingk)
;print, kcpl
;kcpl = '0.200000'
;kcpl = '1.000000'
;kcpl =  '1.500000'

kname = knd+kcpl
tmin = 0

scl = 10
printing = 1
;col = 33
col=1
close, 1

sdir = '100/'  
; limits for printing
pdim = 100
timelim = 1000-2


nusedprofiles = 200
IF(couplingk GE 0.2)THEN nusedprofiles = nusedprofiles + 100
IF(couplingk GE 0.3)THEN nusedprofiles = nusedprofiles + 100
IF(couplingk GE 0.4)THEN nusedprofiles = nusedprofiles + 100
IF(couplingk GE 0.7)THEN nusedprofiles = nusedprofiles + 100



!p.multi = 0
bc = 'open_bc/'
;bc = 'symmetric_bc/'
dir = '~becker/courses/nonlindym/project/multid/'
dir = dir + bc + sdir
filename= dir + kname + ".slip.bin.hdr"
openr, 1, filename, ERROR = err
IF (err EQ 0 AND NOT eof(1)) THEN BEGIN 
   readf, 1, dim, time, dt
   close, 1
   ;print, "reading header file", dim, time
   a = fltarr(dim, time)
   filename=dir+kname+".slip.bin"
   openr, 1, filename
   readu, 1, a
   close, 1
ENDIF ELSE BEGIN 
   close, 1
   a = fltarr(dim)
   time = 0
   filename=dir+kname+".slip.bin"
   openr, 1, filename
   WHILE NOT eof(1) DO BEGIN 
      ON_IOERROR, jump
      readu, 1, a
      time = time+1
   ENDWHILE 
   jump: 
   close, 1
   IF(time GT 1000)THEN BEGIN
      ;print, 'limitiing time to 1000'
      time = 1000
   ENDIF 
   a = fltarr(dim, time)
   openr, 1, filename
   readu, 1, a
   close, 1
   ;print, 'dimension', dim, ' time ', time
ENDELSE 



;a = shift(a, dim/2, 0)
;loadct, col

;print, 'extrema', min(a), max(a)


IF(printing)THEN set_plot, "PS" ELSE BEGIN 
   set_plot, 'X'
   window, 0
ENDELSE 

IF(printing)THEN device, filename=dir+"slipdef."+kname+".eps", /color, $
  /encapsulated, xsize=15, ysize=20, /TIMES, /BOLD, bits_per_pixel=16 
shade_surf,a(0:pdim-1, tmin:timelim),ax=90,az=0,ytickname=[string(tmin), string(timelim)], $
  zstyle=4,yticks=5, yminor=10,  $
  shade=127+(a(0:pdim-1, tmin:timelim)/scl)*128, charsize = 1.5, xstyle=4
plots, 0, time-nusedprofiles
plots, dim-1,  time-nusedprofiles, /continue
IF(NOT printing)THEN xyouts, dim/2, -75, "k!icpl!n="+kname, charsize=2.0, alignment=0.5
IF(printing)THEN BEGIN 
   device, /close
   set_plot, 'X'
ENDIF ELSE BEGIN 
   window, 2
ENDELSE 
;colorscl,-scl,scl,"slip deficit",0,1

FOR i=0, time-1 DO BEGIN 
   IF(abs(a(dim/2, i)) GT 1.0e-06)THEN BEGIN
      ;print, 'time needed to reach dim/2', i
      timepert = i
      GOTO, breakout
   ENDIF 
ENDFOR 

breakout:


if(NOT printing)THEN wset, 2
;loadct, 0

!p.multi = 0

fm = fltarr(dim/2-1)
cnt = 0
FOR i=time-nusedprofiles, time-1 DO BEGIN 
   fftp = abs(fft(a(0:dim-1,i)))
   fm = fm + fftp(1:dim/2-1)
   cnt = cnt+1
   IF(cnt EQ nusedprofiles)THEN BEGIN 
      index = sort(fm)
      ;print, 'highest peaks at', index(length(index)-3:length(index)-1)
      maximumi = index(length(index)-1)
      x = findgen(length(fm))
      moment = total(x*fm)/length(fm)
      if(NOT printing)then begin
         plot, fm/nusedprofiles, /ylog, xtitle='averaged spatial frequency', title=kcpl, yrange=[1.0e-4, 1]
         ;plots, moment, 0
         ;plots, moment, max(fm), /continue
         ;plots, maximumi, 0
         ;plots, maximumi, max(fm), /continue
         set_plot, 'PS'
         device, file=dir + kname + ".spacefft.eps", xsize=16, ysize=15
         plot, fm/nusedprofiles, /ylog, xtitle='averaged spatial frequency', title=kcpl, yrange=[1.0e-4, 1]
         ;plots, moment, 0
         ;plots, moment, max(fm), /continue
         ;plots, maximumi, 0
         ;plots, maximumi, max(fm), /continue
         device, /close
         set_plot, 'X'
         sumspatialfft = total(x*fm)/couplingk
      endif
      ;print, 'moment',  moment, 'maximum index', maximumi
      fm = fltarr(dim/2)
      cnt = 0
   ENDIF 
ENDFOR
timefft = fltarr(nusedprofiles/2)
FOR i=0, dim-1 DO BEGIN 
   timeffttmp=abs(fft(a(i,time-1-nusedprofiles:time-1)))
   ;;plot, timeffttmp(0:time/2-1)
   timefft = timefft+ timeffttmp(0:nusedprofiles/2-1)
ENDFOR 
IF(NOT printing)THEN BEGIN 
   plot, timefft/dim, /ylog, xtitle='average temporal frequency', title=kcpl, yrange=[1.0e-4, 1]
ENDIF 
set_plot, 'PS'
device, file=dir + kname + ".timefft.eps", xsize=16, ysize=15
plot, timefft/dim, /ylog, xtitle='average temporal frequency', title=kcpl, yrange=[1.0e-4, 1]
device, /close
set_plot, 'X'
print, kcpl, timepert, moment, maximumi, sumspatialfft/couplingk
   
   






ENDFOR 


END 
