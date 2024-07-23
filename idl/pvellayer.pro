PRO pvellayer, profilenr, hormax, radmax, dir
   printing = 1
   loadct, 33 ; blue - red
   arrowcol = 254
   arrowthick = 1.5


   ;;loadct, 4
   ;;loadct, 13

   ;dir = '/home/becker/plates/flow_field/experiments/indonesia/'
   openr, 6, dir + 'pro.hdr'
   readf, 6, m, n, l, l1, l2
   r = dblarr(l)
   readf, 6, r
   close, 6
   print, n, m, l

   vx = dblarr(m, n)
   vy = dblarr(m, n)
   vz = dblarr(m, n)
   x = dblarr(m, n)
   y = dblarr(m, n)

   openr, 1, dir + 'vx.bin'
   readu, 1, vx
   close, 1
   openr, 2, dir + 'vy.bin'
   readu, 2, vy
   close, 2
   openr, 3, dir + 'vz.bin'
   readu, 3, vz
   close, 3
   openr, 7, dir + 'y.bin'
   readu, 7, y
   close, 7
    openr, 7, dir + 'x.bin'
   readu, 7, x
   close, 7
   
   
   xmin = min(x) & xmax=max(x)
   ymin = min(y) &  ymax=max(y)
   xrange = xmax-xmin &  yrange=ymax-ymin

   depth = 6371-r
   
   IF(NOT printing)THEN BEGIN 
      set_plot, 'X'
      wsize = 400
      window, ysize=wsize, xsize=2.1*wsize
      arrhs = 6
   ENDIF ELSE BEGIN 
      wsize = 10
      charsize = 2.0
      set_plot, 'PS'
      device, filename = strcompress(dir + "layer." + string(format='(i05)', profilenr) + ".eps",/remove_all), $
        /encapsulated,  /color, bits_per_pixel=16, xsize=wsize*2, ysize=wsize
      arrhs = 150*1.1
   ENDELSE 
   
   tmparr = vz

   nls = 29

   levels=(findgen(nls)/(nls-1)-0.5)*(radmax)*2
   coll=(1+(levels/radmax))*127
   map_set,0,180, /noborder, /mollweide
   contour, tmparr, x, y, xstyle=4, ystyle=4, c_color=coll, /fill,/overplot, /data, levels=levels
  

   ;;xyouts, 60,  100, 'vectors = horizontal flow at '+string(format='(f5.0)',r(l1))+' km', charsize=1.5
   ;;xyouts, 10, -120, 'shading = radial flow at '+string(format='(f5.0)',r(l2))+' km', charsize=1.5
   

   f1 = (m-1)/yrange
   f2 = (n-1)/xrange
   
   pf =  0.0175
   fac = 360/hormax*0.005
  
   every0 = 7
   steps0 = 30
   

   FOR i=1, m-2, every0 DO BEGIN 
      steps = 1+fix(steps0/(0.5+cos(y(i, 0)*pf)))
      every = fix(every0/(0.1+cos(y(i, 0)*pf)))
      FOR j=0, n-1, every DO BEGIN 
         x0 = x(i, j) &  y0= y(i, j)
         plots, x0, y0, /data, color=arrowcol

         FOR k=1, steps DO BEGIN 

            ii = (y0-ymin)*f1
            ij = (x0-xmin)*f2

            vxp =  interpolate(vx, ii, ij) * fac / cos(y0*pf)
            vyp =  interpolate(vy, ii, ij) * fac 

            x1 = x0 + vxp 
            y1 = y0 + vyp
            
            IF(x1 GT 360 OR x1 LT 0 OR y1 GT 90 OR y1 LT -90)THEN BEGIN 
               k = steps 
            ENDIF ELSE BEGIN 
               IF(k EQ steps)THEN BEGIN 
                  arrow, x0, y0, x1, y1, /data, /solid, hsize=arrhs, color=arrowcol, thick=arrowthick
               ENDIF ELSE BEGIN 
                  plots, x1, y1, /continue, /data, color=arrowcol, thick=arrowthick
               ENDELSE 
            ENDELSE 
            x0 = x1 & y0=y1
            
         ENDFOR
      ENDFOR 
   ENDFOR  
   map_continents
   pnuvel, col=20, 2
   IF(printing)THEN device, /close
   set_plot, 'X'

END 
