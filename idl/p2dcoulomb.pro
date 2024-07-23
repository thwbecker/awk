pr = 0
   mu_zero = 0.6
   animate = 0
   inf =  1.0e20
   hp = 0.0
   off = 0.0
   tau0 = 0.0
   nyu = 0.25
   
   filedir = '/home/becker/courses/static_stress/'

   openr, 1, filedir+"stress.dat"
   readf, 1, m
   n = sqrt(m)
   stress = dblarr(8,m)
   readf, 1, stress
   close, 1
   csense = 0
   sense = 4
   x = rotate(reform(stress(0, *, *), n, n), csense)
   y = rotate(reform(stress(1, *, *), n, n), csense)
   sxx = rotate(reform(stress(2, *, *), n, n), sense)
   sxy = rotate(reform(stress(3, *, *), n, n), sense)   
   syy = rotate(reform(stress(4, *, *), n, n), sense)
   close, 1
   FOR i=1, n-2 DO BEGIN 
      FOR j=1, n-2 DO BEGIN
         IF(sxx(i, j) EQ inf)THEN BEGIN 
            count = 0.0
            sxx(i, j) = 0.0
            IF(sxx(i, j+1) NE inf)THEN $
              sxx(i, j) = sxx(i, j) + sxx(i, j+1) &  count=count+1.0
            IF(sxx(i, j-1) NE inf)THEN $
              sxx(i, j) = sxx(i, j) + sxx(i, j-1) &  count=count+1.0
            IF(sxx(i+1, j) NE inf)THEN $
              sxx(i, j) = sxx(i, j) + sxx(i+1, j) &  count=count+1.0
            IF(sxx(i-1, j) NE inf)THEN $
              sxx(i, j) = sxx(i, j) + sxx(i-1, j) &  count=count+1.0
            IF(count NE 0.0)THEN sxx(i, j) = sxx(i, j) / count 
         ENDIF 
      IF(sxy(i, j) EQ inf)THEN BEGIN 
            count = 0.0
            sxy(i, j) = 0.0
            IF(sxy(i, j+1) NE inf)THEN $
              sxy(i, j) = sxy(i, j) + sxy(i, j+1) &  count=count+1.0
            IF(sxy(i, j-1) NE inf)THEN $
              sxy(i, j) = sxy(i, j) + sxy(i, j-1) &  count=count+1.0
            IF(sxy(i+1, j) NE inf)THEN $
              sxy(i, j) = sxy(i, j) + sxy(i+1, j) &  count=count+1.0
            IF(sxy(i-1, j) NE inf)THEN $
              sxy(i, j) = sxy(i, j) + sxy(i-1, j) &  count=count+1.0
            IF(count NE 0.0)THEN sxy(i, j) = sxy(i, j) / count 
         ENDIF 
      IF(syy(i, j) EQ inf)THEN BEGIN 
            count = 0.0
            syy(i, j) = 0.0
            IF(syy(i, j+1) NE inf)THEN $
              syy(i, j) = syy(i, j) + syy(i, j+1) &  count=count+1.0
            IF(syy(i, j-1) NE inf)THEN $
              syy(i, j) = syy(i, j) + syy(i, j-1) &  count=count+1.0
            IF(syy(i+1, j) NE inf)THEN $
              syy(i, j) = syy(i, j) + syy(i+1, j) &  count=count+1.0
            IF(syy(i-1, j) NE inf)THEN $
              syy(i, j) = syy(i, j) + syy(i-1, j) &  count=count+1.0
            IF(count NE 0.0)THEN syy(i, j) = syy(i, j) / count 
         ENDIF 
      ENDFOR 
   ENDFOR 
         

   fms=dblarr(n,n) & sms=dblarr(n,n) & deg=dblarr(n,n)
   mu = dblarr(n, n) & temp=dblarr(100, 100)
   mu = mu_zero
   ms = (sxx+syy)/2.0
   
   b = ( 2.0 * off ) / (sqrt(1.0 + mu^2) - mu)
   a=( sqrt(1+mu^2) + mu )/ ( sqrt(1+mu^2) - mu )
   cms, n, sxx, sxy, syy, fms, sms, deg
   cs = cstress(fms,sms,a,hp,b)
   tacs = cstress(sxy, syy, mu, hp, off)
 
   openr, 1, "/home/becker/courses/static_stress/a.dat"
   temp = dblarr(100, 100)
  
   IF(animate)THEN BEGIN 
       window, 0, xsize=1200, ysize=600 
       !p.multi = [0, 2, 0, 0]
       WHILE NOT eof(1) DO BEGIN 
         readu, 1, temp
        
         mu = congrid(temp, n, n)
         contour,mu, /follow
         a=( sqrt(1+mu^2) + mu )/ ( sqrt(1+mu^2) - mu )
         
         contour,sxy - mu * syy,max_value=10,levels=[-.1,0,.1], /follow
         tmp = get_kbrd(1)
         IF(tmp EQ 'q')THEN BEGIN 
            close, 1
            stop 
         ENDIF 
      ENDWHILE 
   ENDIF ELSE BEGIN 
      mu = 1.0
      window, 0, xsize=1200, ysize=600 
      !p.multi = [0, 2, 0, 0]
      ;;tacs = cstress(sxy, syy, mu, hp, off)
      tcs = sxy - mu * syy
      tacs= sxy - mu * sxx
      tcc = 2.0*(sxy+mu*(sxx+syy)/2.0)
      ;;set_plot, "PS"
      ;;device, file=filedir+"cs.eps", /encapsulated, xsize=20, ysize=11, bits_per_pixel=16, /color
      ;;loadct, 0
      shade_surf,tcs,x,y,shade=bytscl(tcs),ax=90,az=0,zstyle=4, $
        xtitle="!6x/a", ytitle="y/a", xstyle=1, ystyle=1
      contour,tcs,x,y,levels=[-0.3, -0.2,-0.1,0.1,0.2, 0.3],/overplot,/follow   
      contour,tcs,x,y,levels=[0.0],/overplot,/follow, /downhill,$
        title="!7r!6!ic!n for "
      shade_surf,tacs,x,y,shade=bytscl(tacs),ax=90,az=0,zstyle=4, $
        xtitle="!6x/a", ytitle="y/a", xstyle=1, ystyle=1
      contour,tacs,x,y,levels=[-0.3, -0.2,-0.1,0.1,0.2, 0.3],/overplot,/follow   
      contour,tacs,x,y,levels=[0.0],/overplot,/follow  , /downhill
      ;;device, /close
      
    

   ENDELSE  
   
   close, 1



  
   set_plot, 'X'
END








