;; routine for plotting standard conman temperture field
workdir = '/wrk/arthur/becker/conman/thermal/'
model = 'r1e04/'
print = 1
printnr = 1
wait = 0
every = 1
filestat = fstat(1) & IF(filestat.open EQ 1)THEN close, 1
filestat = fstat(2) & IF(filestat.open EQ 1)THEN close, 2
workdir = workdir+model+'/'
openr, 1, workdir+'field.new_hdr'
WHILE NOT eof(1) DO BEGIN 
   readf, 1, i, j, k, m, n, nrnd, timestep, time, l, o, p
ENDWHILE 
nrframes = i/every + 1
close, 1
openr, 1, workdir+'field.new_hdr'
openr, 2, workdir+'field.new'
first = 1
i = 0
IF(print)THEN set_plot, "PS" ELSE set_plot, "X"
WHILE NOT eof(1) DO BEGIN 
   readf, 1, i, j, k, m, n, nrnd, timestep, time, xmax, ymax, p
   n = n+1 & m=m+1
   IF(first)THEN BEGIN 
      xmax = (m-1)/(n-1)
      IF(NOT print)THEN BEGIN 
         xinteranimate,set=[xmax*300,300,nrframes]
         window, 0, xsize=xmax*300, ysize=300
         wset, 0
      ENDIF 
      tmp = fltarr(3, nrnd)
      first = 0
      rotfac = 4
      loadct, 4
   ENDIF 
   readu, 2, tmp
   IF((i-1.0)/every EQ fix((i-1.0)/every))THEN BEGIN 
      u = rotate(reform(tmp(0, *), n, m), rotfac)
      v = rotate(reform(tmp(1, *), n, m), rotfac)
      t = rotate(reform(tmp(2, *), n, m), rotfac)
      IF(print)THEN $
        device, file=workdir+"t"+strcompress(string(printnr), /remove_all)+".eps",$
        bits_per_pixel=8, xsize=27.5, ysize=7.375,/TIMES, /BOLD, /color, /encapsulated, $
        /landscape, yoffset=25
      printnr = printnr + 1
      TVLCT, [0,0], [0,0], [0,0], !D.N_COLORS-1
      greenColor = !D.N_COLORS-1 
      POLYFILL, [1,1,0,0,1], [1,0,0,1,1], /NORMAL, COLOR=greenColor
      shade_surf,t,shade=bytscl(t),az=0,ax=90,zstyle=4, xstyle=4, ystyle=4, /noerase


      IF(0)THEN BEGIN 
         xyouts, 80, 128+11, string(time), /data, charsize = 3, color=200
         xyouts, 120, -15-10, model, charsize = 3, color=200
      ENDIF ELSE BEGIN 
         xyouts, 80, 64+11, string(time), /data, charsize = 3, color=200
         xyouts, 120, -15, model, charsize = 3, color=200
      ENDELSE 
      

      IF(wait)THEN BEGIN 
         tmp_ke = get_kbrd(1)
         IF(tmp_ke EQ 'q')THEN stop
      ENDIF 
      IF(print)THEN BEGIN 
         device, /close 
         print, workdir+"t"+strcompress(string(printnr), /remove_all)+".eps"
      ENDIF ELSE BEGIN 
         xinteranimate,frame=fix((i-1.0)/every),window=[0, 100, 0, xmax*300-150,300]
      ENDELSE 
   ENDIF 
ENDWHILE 
close, 1, 2
IF(NOT print)THEN xinteranimate
END 
