PRO MYVEL2,u, v, x, y, n, m, LENGTH=length, nvecs = nvecs, title = title,  $
           xtitle = xtitle, ytitle = ytitle, overplot=overplot, cl=cl, fac=fac, $
           csz=csz
on_error,2                      ;Return to caller if an error occurs
if n_elements(Nvecs) le 0 then nvecs=600
if n_elements(title) le 0 then title=''
if n_elements(xtitle) le 0 then xtitle=''
if n_elements(ytitle) le 0 then ytitle=''
IF n_elements(overplot) LE 0 THEN overplot = 0
IF n_elements(cl) LE 0 THEN cl = 0
IF ((n_elements(fac) LE 0) OR (fac EQ 0.0)) THEN fac = 0.045*(xmax-xmin)/max(sqrt(u^2+v^2))
IF n_elements(csz) LE 0 THEN csz = 1.0

xmax = max(x) & xmin = min(x)
ymin = min(y) & ymax = max(y)
IF (NOT overplot)THEN $
  plot, u, /nodata, xrange=[xmin, xmax], yrange=[ymin, ymax], xtitle=xtitle, ytitle=ytitle, charsize = csz, title=title 
;;ELSE $
  ;;axis, xrange=[xmin, xmax], yrange=[ymin, ymax], xtitle=xtitle, ytitle=ytitle, charsize = csz

j = fix(randomu(seed,nvecs)*n) & k = fix(randomu(seed,nvecs)*m)
x0 = x(j, k) &  y0=y(j, k)
x1 = x0 + u(j, k) * fac &  y1 = y0 + v(j, k)*fac
FOR i=0, nvecs-1 DO BEGIN 
   IF(x1(i) GE  xmax)THEN x1(i) = xmax
   IF(x1(i) LE  xmin)THEN x1(i) = xmin
   IF(y1(i) GE  ymax)THEN y1(i) = ymax
   IF(y1(i) LE  ymin)THEN y1(i) = ymin
ENDFOR 
arrow, x0, y0, x1, y1, /data, hsize=-.1, color=cl



END 
