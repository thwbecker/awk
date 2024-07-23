close, 1, 2, 3
dir = "$workdir/../subduct_dd/internal_heating/"
openr, 1, dir + "field.new"
openr, 3, dir+"str.new"
init = 0
s = strarr(1)
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
   shade_surf, t, x, y, ax=90, az=0, shade=bytscl(t),zstyle=4
   ;;contour, t, x, y
   tmp = get_kbrd(1)
   IF(tmp EQ 'q')THEN stop

ENDWHILE 
close, 1, 2, 3
END 
