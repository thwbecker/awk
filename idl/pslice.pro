PRO pslice, profilenr, vyextreme, vxzextreme, dir
   close, 1, 2, 3, 4, 5, 6, 8
   ;;   profilenr = 1
  
   printing = 1

   plotmap = 0
   
   ;;dir = '/home/becker/plates/flow_field/experiments/indonesia/'
   openr, 6, dir + 'pro.hdr'
   readf, 6, n, m, lon0, lat0, azi, hlen
   close, 6
   print, n, m
   print, 'lon ', lon0, ' lat ', lat0, ' azi ', azi
   grtcrc = fltarr(3, m)
   openr, 6, dir + 'tmp.xy'
   readf, 6, grtcrc
   close, 6
   
   vx = dblarr(m, n)
   vy = dblarr(m, n)
   vz = dblarr(m, n)
   x = dblarr(m, n)
   z = dblarr(m, n)
   
   rad = grtcrc(2, *)/180*3.1416
   depth = dblarr(n)
   
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
   readu, 7, depth
   close, 7
   r = 6371-depth   
   
   rmin = min(r)
   rmax = max(r)
   rrange = rmax-rmin
   phimin = min(rad)
   phimax = max(rad)
   phirange = phimax-phimin
     
   pzlim = 5000


   
   loadct, 13
   depthl = 2900
   ;;yf = fix(max(abs(x))/depthl)
   yf = 5
   FOR i=0, m-1 DO BEGIN 
      FOR j=0, n-1 DO BEGIN 
         z(i, j) = r(j)*cos(rad(i))
         x(i, j) = r(j)*sin(rad(i))
      ENDFOR 
   ENDFOR 
   xmax = max(x)
   xmin = min(x)
   zmin = min(z)
   zmax = max(z)
   cmbz = (6371-2900)*cos(rad)
   cmbx = (6371-2900)*sin(rad)
   ombz = 6371*cos(rad)
   ombx = 6371*sin(rad)
   ulmbz = (6371-670)*cos(rad)
   ulmbx = (6371-670)*sin(rad)


   IF(NOT printing)THEN BEGIN 
      set_plot, 'X'
      wsize = 700
      window, ysize=wsize, xsize=1.1*(xmax-xmin)/(zmax-pzlim)*wsize*0.82
      arrhs = 6
      thickness = 1
   ENDIF ELSE BEGIN 
      wsize = 20
      set_plot, 'PS'
      device, filename = strcompress(dir + "profile" + string(format='(i2)', profilenr) + ".eps",/remove_all), $
        /encapsulated,  xsize=(xmax-xmin)/(zmax-pzlim)*wsize*0.82, $
        ysize=wsize, /color, bits_per_pixel=16
      arrhs = 120*2.5
      thickness = 4

   ENDELSE 
   
   tmpmapset = lat0-90
   IF(tmpmapset LT -90)THEN tmpmapset = 180+tmpmapset
   IF(tmpmapset GT 90)THEN tmpmapset = -180+tmpmapset


   nls = 29
   ctmp = -vy
   levels=(findgen(nls)/(nls-1)-0.5)*vyextreme*2
   coll=127+levels/vyextreme*127 
   
   IF(plotmap)THEN BEGIN 
      map_set,tmpmapset,lon0, /orthographic,/continents,$
        /grid,/isotropic,/noborder, $
        POS=[.33, 0.35, 0.75, 0.7], /horizon
      contour, ctmp, x, z,  xrange=[xmin*1.1, xmax*1.1], levels=levels, $
        yrange=[zmin *0.9, zmax*1.1], xstyle=1, ystyle=1, c_color=coll, $
        /fill, /noerase
   ENDIF ELSE BEGIN 
      plot, x, z, /nodata, xrange=[xmin*1.1, xmax*1.1], $
        yrange=[pzlim*0.95, zmax*1.02], xstyle=1, ystyle=1,  $
        title='center at (' + string(format='(f5.1)', lon0) + 'W, ' + $
        string(format='(f5.1)', lat0)+'N); azimuth '+string(format='(f4.0)', azi)+'deg'

      ;;contour, ctmp, x, z,  xrange=[xmin*1.1, xmax*1.1], levels=levels, $
      ;;  yrange=[pzlim*0.95, zmax*1.02], xstyle=1, ystyle=1, c_color=coll, $
      ;;  /fill, title='center at (' + string(format='(f5.1)', lon0) + 'W, ' + $
      ;;  string(format='(f5.1)', lat0)+'N); azimuth '+string(format='(f4.0)', azi)+'deg'
   ENDELSE  
   IF(pzlim LE 3471)THEN BEGIN 
      plots, cmbx(0), cmbz(0), /data
      plots, cmbx(1:m-1), cmbz(1:m-1), /data, /continue, thick=2
   ENDIF 
   plots, ombx(0), ombz(0), /data
   plots, ombx(1:m-1), ombz(1:m-1), /data, /continue, thick=2

   plots, ulmbx(0), ulmbz(0), /data
   plots, ulmbx(1:m-1), ulmbz(1:m-1), /data, /continue, thick=2, linestyle=2
  
  
   f1 = (m-1)/phirange
   f2 = (n-1)/rrange
   fac = rrange/max(vxzextreme)*0.007
   steps = 20
   every = 3


   FOR i=0, m-1, every DO BEGIN 
      FOR j=0, n-1, every/1.5 DO BEGIN 
         x0 = x(i, j) &  z0= z(i, j)
         plots, x0, z0, /data      
         FOR k=1, steps DO BEGIN 
            phi = atan(x0, z0)
            f3 = cos(phi)
            f4 = sin(phi)
            r0 = sqrt(x0^2+z0^2)
            
            im = (phi-phimin)*f1
            in = (n-1)-(r0-rmin)*f2
            vxp = interpolate(vx, im, in) * fac
            vzp = interpolate(vz, im, in) * fac

            ;;IF(k EQ 1)THEN $
            ;;  print, vx(i, j)*fac,  vxp, vz(i, j)*fac, vzp

            ;;vxp = 0
            ;;vzp = fac*0.1
            
            vxt = f3 * vxp + f4 * vzp
            vzt = f3 * vzp - f4 * vxp
            
            x1 = x0 + vxt
            z1 = z0 + vzt
            
            IF(r0 GT 6371 OR r0 LT pzlim*0.95 OR phi GT phimax OR phi LT phimin)THEN BEGIN 
               k = steps 
            ENDIF ELSE BEGIN 
               IF(k EQ steps)THEN BEGIN 
                  arrow, x0, z0, x1, z1, /data, /solid, hsize=arrhs, thick=thickness
               ENDIF ELSE BEGIN 
                  plots, x1, z1, /continue, /data, thick=thickness
               ENDELSE 
            ENDELSE 
            
            x0 = x1 & z0=z1
            
         ENDFOR
      ENDFOR 
   ENDFOR  
   width = 1
   symbol = 8
   size = 3000/rrange
   ;;file = '/home/becker/quakes/vdhilst/hypocenters.mo'
   ;;   n = 77106
   ;;file = '/home/becker/quakes/schoeffel/harvard.xyzm'
   ;;n = 363
   USERSYM, [-.75,0,.75,0],[0,.75,0,-.75], /FILL



   hypo_project, '/home/becker/quakes/vdhilst/hypocenters.mo', 77106, $
     lon0, lat0, azi, width, symbol, 255, size


   hypo_project, '/home/becker/quakes/schoeffel/harvard.xyzm', 363, $
     lon0, lat0, azi, width, symbol,  55, size
   
   
   
   IF(printing)THEN device, /close
   set_plot, 'X'

END 
