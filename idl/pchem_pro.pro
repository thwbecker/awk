PRO pchem_pro, model, printing
doubleread = 0
close, 1, 2, 3
dir = "$workdir/../subduct_dd/"+strcompress(string(model),/remove_all)+"/"
printnr = 0
openr, 1, dir + "field.new"
openr, 3, dir+"str.new"
init = 0
s = strarr(1)
marker = 0.0
time_old = -1
WHILE(NOT  eof(1))  DO  BEGIN 
   readf, 1, dims, m, n, nrnd, timestep, time, b
   readf, 1, s
   readf, 3, a, b, m, n, c, d, e
   readf, 3, s
   IF(NOT init )THEN BEGIN 
      x = dblarr(nrnd)
      y = dblarr(nrnd)
      u = dblarr(nrnd)
      v = dblarr(nrnd)
      t = dblarr(nrnd)
      comp = dblarr(nrnd)
      visc = dblarr(nrnd)
      u2 = dblarr(nrnd)
      v2 = dblarr(nrnd)
      t2 = dblarr(nrnd)
      comp2 = dblarr(nrnd)
      
   ENDIF 
   FOR i=0L, nrnd-1 DO BEGIN 
      readf, 1, j, x1, x2, vv, vv2, temperature, composition
      readf, 3, j, x1, x2, tzz, txz, p, viscosity
      x(i) = x1 &  y(i) = x2
      u(i) = vv &  v(i)=vv2 & t(i)=temperature
      comp(i) = composition
      visc(i) = viscosity
   ENDFOR 
   IF (NOT init)THEN BEGIN 
      xmax = max(x)
      ymax = max(y)
      aspect = xmax/ymax
      !p.multi = [0, 3, 0, 0]
      IF(printing)THEN BEGIN 
         set_plot, 'PS'
      ENDIF ELSE BEGIN 
         set_plot, 'X'
         window, 0, xsize=50+3*250*aspect, ysize=250
      ENDELSE
      init = 1
   ENDIF 
   rotfac = 4
   t = rotate(reform(t, n+1, m+1), rotfac)
   x = rotate(reform(x, n+1, m+1), rotfac)
   y = rotate(reform(y, n+1, m+1), rotfac)
   u = rotate(reform(u, n+1, m+1), rotfac)
   v = rotate(reform(v, n+1, m+1), rotfac)
   comp = rotate(reform(comp, n+1, m+1), rotfac)
   visc = rotate(reform(visc, n+1, m+1), rotfac)
   
   IF(printing)THEN device, filename=dir+strcompress(string(printnr), /remove_all)+".eps", $
     /encapsulated, xsize=3*4.5*aspect, ysize=5, /TIMES, /BOLD, bits_per_pixel=16, /landscape
   vel,u,v,length=10.0,nsteps=150,nvecs=25
   ;;myvel2, u, v, x, y, n, m,  overplot=0, cl=254, xtitle="max(abs(u)): "+string(max(abs(u))), title="", $
   ;;  ytitle="max(abs(v)): "+string(max(abs(v)))
   ;;SHADE_SURF, comp, AX = 025, AZ = 010, /SKIRT, XSTYLE = 4, YSTYLE = 4, ZSTYLE = 4, $
   ;;  title="compostion"
   contour, comp, x, y, title="composition, time "+string(time*u(m*3/4,n))
   contour, comp, x, y,levels=0.5, thick=2.0, /overplot
   shade_surf, alog10(visc), x, y,AX = 045, AZ = 015, $
                    xtitle="x", ytitle="z", ztitle="log!i10!n(!4l!3)", yticks=3,$
                    ytickv=[0.25*ymax, 0.5*ymax, 0.75*ymax], zcharsize=2.0
   ;;contour, alog10(visc), x, y, title="log!i10!n(viscosity)"
   ;;contour, alog10(visc), x, y,levels=[0.001, 0.01, 0.1, 1, 10, 100, 1000], /follow, /overplot
   
   ;;SHADE_SURF, comp, AX = 075, AZ = 015, /SKIRT, XSTYLE = 4, YSTYLE = 4, ZSTYLE = 4
   IF(time_old NE  -1)THEN marker = marker+ u(m*3/4,n)*(time-time_old)
   time_old = time
   ;;print, time*u(m*3/4,n), marker
   IF(printing)THEN BEGIN 
      device, /close
      print, "Printed to"+dir+strcompress(string(printnr), /remove_all)+".eps"
      printnr = printnr+1
   ENDIF 
   IF(NOT printing)THEN BEGIN 
      tmp = get_kbrd(1)
      IF(tmp EQ 'q')THEN stop
   ENDIF 
ENDWHILE 
close, 1, 2, 3
END 
