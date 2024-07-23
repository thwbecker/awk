close, 1, 2
starttest = 1 & stoptest = 4 ;starttest

tstart = 10

printfile = 1

FOR test=starttest, stoptest DO BEGIN 
   filedir = "/home/datdyn/becker/finel/eff_modul/"+strtrim(test, 1)+"/"
   IF(test EQ 1)THEN tstop = 190
   IF(test EQ 2)THEN tstop = 490
   IF(test EQ 3)THEN tstop = 490
   IF(test EQ 4)THEN tstop = 140
   IF(test EQ 6)THEN tstop = 140
   IF(test EQ 7)THEN tstop = 200
   


   print, "Reading "+filedir+"meshe and meshn"
   openr, 1, filedir+"meshe"
   readf, 1, nrel, nen, tmp
   eps = dblarr(3*nrel)
   ncon = intarr((2+nen)*nrel)
   readf, 1, ncon
   close, 1
   ncon=reform(ncon,2+nen,nrel)
   ncon = ncon(1:nen, *)

   openr, 1, filedir+"meshn"
   readf, 1, nrnd, tmp
   nc = dblarr(3*nrnd)
   readf, 1, nc
   close, 1
   nc = reform(nc, 3, nrnd) &  nc = nc(1:2, *)
   ex = dblarr(nrel) &  ey=dblarr(nrel)
   FOR i=0, nrel-1 DO BEGIN
      x = 0.0d & y=0.0d
      FOR j=0, nen-1 DO BEGIN 
         x = x+ nc(0, ncon(j, i)-1)
         y = y+ nc(1, ncon(j, i)-1)
      ENDFOR
      ex(i) = x/nen
      ey(i) = y/nen
   ENDFOR 
   
   IF(printfile)THEN BEGIN 
      openw,2, filedir+"eps2val.dat"
      ;printf, 2, "# Zeit min(e12) mean(e12) max(e12) mean(abs(e12)) e12(5a-e,0) e12(-5a+e,0) "
      print, "Printing to "+filedir+"eps2val.dat"
      !p.multi = [0, 2, 1, 0]
   ENDIF 

   FOR time=tstart, tstop, 10 DO BEGIN 
      openr, 1, filedir+"epsfield."+strtrim(time, 1)+".bin"
      print, "Reading epsfield."+strtrim(time, 1)+".bin"
      readu, 1, eps
      close, 1
      eps = reform(eps, 3, nrel)
      print, "e2min: ", min(eps(1, *)), " e2max: ", max(eps(1, *)), " e2mean: ", $
        mittelwert(eps(1, *)), "mean(abs(e2)):", mittelwert(abs(eps(1, *)))
      
      triangulate,ex,ey,tr,b 
      nx = 100
      eps2=trigrid(ex, ey, eps(1, *),tr, $
                   [(max(ex)-min(ex))/nx, (max(ey)-min(ey))/nx],$
                   [MIN(ex), MIN(ey), MAX(ex), MAX(ey)])
      ;eps2 = smooth(eps2, 2)
      IF(printfile)THEN BEGIN 
         printf,2, strtrim(time, 1)+" "+strtrim(min(eps(1, *))*100.0, 1)+" "+strtrim(mittelwert(eps(1, *))*100.0, 1)+" "+$
           strtrim( max(eps(1, *))*100.0, 1)+" "+strtrim(mittelwert(abs(eps(1, *)))*100.0, 1)+" "+$
           strtrim( eps2(50, nx-2)*100.0, 1)+" "+strtrim( eps2(50, 1)*100.0, 1)
      ENDIF 
      
      IF(NOT printfile)THEN BEGIN 
         window, 0
         wset, 0
         contour, eps2, nlevels=29, /fill
         window, 1
         wset, 1
         plot, eps2(50,*), title="!7e!6!ixy!n bei x=0", xtitle="y"
         window, 2
         wset, 2
         plot, eps2(50,1:10),psym=7, title="!7e!6!ixy!n bei x=0", xtitle="y"
         oplot, eps2(50,1:10)
         print, "Any key besides 'S' to stop."
         tmp = get_kbrd(1)
         IF(tmp EQ 's')THEN stop
      ENDIF ELSE BEGIN 
         plot, eps2(50,nx-22:nx-2),psym=7, ytitle="!7e!6!ixy!n bei x=0", xtitle="y", title=strtrim(time, 1)
         oplot, eps2(50,nx-22:nx-2)
         plot, eps2(50, 2:nx-3)
      END
   ENDFOR 
   IF(printfile)THEN    close, 2


ENDFOR 





end
