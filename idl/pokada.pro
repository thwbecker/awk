close, 1
   modeldir = "/home/becker/okada"

   average=0
   read3d = 0
   nrlayer = 21
   printing = 0
   multiplot = 0
   ;; discrete_test_0 besitzt als maximalen u_x Wert 0.5 bei maximalem
   ;; disl0 von 1 !


   u0 = 2.5 ;; haelfte vom oknew wert
   print, "RESCALING ALL DISPLACEMENTS by a  factor of ", u0
   
   IF((modeldir EQ "/home/geodyn/becker/okada/discrete_test_3/")OR $
      (modeldir EQ "/home/geodyn/becker/okada/discrete_test_4/"))THEN BEGIN 
      n = 201L
   ENDIF ELSE BEGIN 
      n = 101L
   ENDELSE  

   mid = (n-1)/2 
   l = fix(0.297*double(n)) & r=fix(0.693*double(n))
   d3dn = (r-l)+1
   m = n*n 
   clb1 = dblarr(m)
   clb2 = dblarr(m)
   clb3 = dblarr(m)
   ux = dblarr(m)
   uy = dblarr(m)
   uz = dblarr(m)
   xc = dblarr(m)
   yc = dblarr(m)
   

   clb13d = dblarr(d3dn, d3dn, nrlayer)
   clb23d = dblarr(d3dn, d3dn, nrlayer)
   clb33d = dblarr(d3dn, d3dn, nrlayer)
   ux3d =  dblarr(d3dn, d3dn, nrlayer)
   uy3d =  dblarr(d3dn, d3dn, nrlayer)
   uz3d =  dblarr(d3dn, d3dn, nrlayer)
   
   
   hc = 0
   ;;FOR z=0.0,20.0, 1.0 DO BEGIN 
   FOR z=8.5, 8.5, 0.5 DO BEGIN 
      IF(fix(z)-z NE  0)THEN BEGIN 
         IF(z GE 10)THEN nrdigit = 4 ELSE nrdigit = 3
         formatstring = '(f'+string(format='(i1)', nrdigit)+'.1)'
         endname = string(format=formatstring, z)+'.bin' 
      ENDIF ELSE BEGIN 
         IF(z GE 10)THEN nrdigit = 2 ELSE nrdigit = 1
         formatstring = '(i'+string(format='(i1)', nrdigit)+')'
         endname = string(format=formatstring, z)+'.bin'
      ENDELSE 

      IF(z EQ 0.0)THEN endname = '-0.bin'
      print, modeldir+"stre11."+endname
      OPENR, 1, modeldir+"stre11."+endname, ERROR = err
      IF (err EQ  0) then BEGIN 
         close, 1
         openr, 1, modeldir+"stre11."+endname
         readu, 1, clb1 &  close, 1
         openr, 1, modeldir+"stre12."+endname
         readu, 1, clb2 &  close, 1
         openr, 1, modeldir+"stre22."+endname
         readu, 1, clb3 & close, 1
         openr, 1, modeldir+"xc."+endname
         readu, 1, xc & close, 1
         openr, 1, modeldir+"yc."+endname
         readu, 1, yc &  close, 1
         openr, 1, modeldir+"ux."+endname
         readu, 1, ux &  close, 1
         openr, 1, modeldir+"uy."+endname
         readu, 1, uy &  close, 1
         openr, 1, modeldir+"uz."+endname
         readu, 1, uz &  close, 1
         clb1 = rotate(reform(clb1, n, n), 4)
         clb2 = rotate(reform(clb2, n, n), 4)
         clb3 = rotate(reform(clb3, n, n), 4)
         ux = (rotate(reform(ux, n, n), 4))/u0
         uy = (rotate(reform(uy, n, n), 4))/u0
         uz = (rotate(reform(uz, n, n), 4))/u0
         xc = rotate(reform(xc, n, n), 4)
         yc = rotate(reform(yc, n, n), 4)
         fms = dblarr(n, n)
         sms = dblarr(n, n)
         deg = dblarr(n, n)
         IF(average EQ 1 )THEN BEGIN 
            print, "AVERAGING ALL MID VALUES ALONG THE FAULT !"

            IF (hc EQ 0)THEN BEGIN 
               leftaverage = 0 & rightaverage=0
               FOR i=0L, n-1  DO BEGIN 
                  IF((xc(i, mid) GT -1.0)AND(leftaverage EQ 0))THEN leftaverage = i
                  IF(xc(i, mid) LT  1.0)THEN rightaverage = i
               ENDFOR 
            ENDIF 
            print, "Setting values (", leftaverage, ":", rightaverage, ",", mid, ")"
            print, "  to their neighbours average."
            FOR i=leftaverage, rightaverage DO BEGIN 
               clb1(i, mid) = (clb1(i, mid-1)+clb1(i, mid+1))/2.0
               clb2(i, mid) = (clb2(i, mid-1)+clb2(i, mid+1))/2.0
               clb3(i, mid) = (clb3(i, mid-1)+clb3(i, mid+1))/2.0
               ux(i, mid) = ((ux(i, mid-1)+ux(i, mid+1))/2.0)
               uy(i, mid) = ((uy(i, mid-1)+uy(i, mid+1))/2.0)
               uz(i, mid) = ((uz(i, mid-1)+uz(i, mid+1))/2.0)
            ENDFOR 
         ENDIF 
         
         clb13d(*, *, hc) = clb1(l:r,l:r) 
         clb23d(*, *, hc) = clb2(l:r,l:r)
         clb33d(*, *, hc) = clb3(l:r,l:r)
         ux3d(*, *, hc) = ux(l:r,l:r)
         uy3d(*, *, hc) = uy(l:r,l:r)
         uz3d(*, *, hc) = uz(l:r,l:r)

         hc = hc+1
         
         print, "z: "+strtrim(z, 1)+" Min s_xy: "+ strtrim(min(clb2), 1)+$
          " Max: "+strtrim(max(clb2), 1)
         IF(NOT read3d)THEN BEGIN 
            
            IF(multiplot)THEN BEGIN
               set_plot, 'X'
               window, 0 & wset, 0
               !p.multi = [0, 3, 3, 0]
               contour, (clb1+clb3)/2.0, xc, yc, nlevels=29, /fill, $
                 title="Mittl.Norm.-Sp.",  xtitle="x/a", ytitle="y/a"
               contour, (clb1+clb3)/2.0, xc, yc, level=0, /overplot, /follow
               contour, clb2, xc, yc, nlevels=28, title="Sigma!ixy!n", /fill, xtitle="x/a", ytitle="y/a"
               contour, clb2, xc, yc, level=0, /overplot, /follow
               contour, ux, xc, yc, nlevels=29, /fill, title="u!ix!n", xtitle="x/a", ytitle="y/a"
               contour, ux, xc, yc, level=0, /overplot, /follow
               contour, uy, xc, yc, nlevels=29, /fill, title="u!iy!n"  , xtitle="x/a", ytitle="y/a"
               contour, uy, xc, yc, level=0, /overplot, /follow
               
               plot, xc(*, mid), clb2(*, mid), title="Scherspannung bei y=0", xtitle="x/a",$
                 ytitle="Spannung"
               plot, yc(mid, *),ux(mid, *), title="u_x bei x=0"
               plot, xc(*, mid),uy(*, mid), title="u_y bei y=0"
                                ;plot, yc(mid, *),uz(mid, *), title="u_z bei x=0"
                                ;velovect, ux(l:r,l:r),uy(l:r,l:r),title="Verschiebungsfeld", xstyle=4, ystyle=4
               contour,clb2-0.3*(clb1+clb3)
               surface, uz, xc, yc, title="u_z"
            ENDIF 
            
            rebinning = 3
            !p.multi = 0
            IF(printing)THEN BEGIN 
               set_plot, 'PS'
               device, filename=modeldir+"ux.eps", /encapsulated, /color, xsize=10, ysize=10, $
                 bits_per_pixel=16
               print, "printing to"+modeldir+"ux.eps"
            ENDIF ELSE BEGIN 
               set_plot, 'X'
               window, 1, xsize=500, ysize=500, title="ux" &  wset, 1
            ENDELSE 
            myshow3, ux, xc, yc, sscale=rebinning,/interp, "!6u!ix!n"
            plots, -1, 0, /t3d & plots, 1, 0, /continue,  thick=5, /t3d, color = 30
            IF(printing)THEN device, /close

            !p.multi = 0
            IF(printing)THEN BEGIN 
               set_plot, 'PS'
               device, filename=modeldir+"uy.eps", /encapsulated, /color, xsize=10, ysize=10, $
                 bits_per_pixel=16
               print, "printing to"+modeldir+"uy.eps"
            ENDIF ELSE BEGIN 
               set_plot, 'X'
               window, 2, xsize=500, ysize=500, title="uy" &  wset, 2
            ENDELSE 
            myshow3, uy, xc, yc, sscale=rebinning,/interp, "u!iy!n"
            plots, -1, 0, /t3d & plots, 1, 0, /continue,  thick=5, /t3d, color = 30

            IF(printing)THEN device, /close

            !p.multi = 0
            IF(printing)THEN BEGIN 
               set_plot, 'PS'
               device, filename=modeldir+"uz.eps", /encapsulated, /color, xsize=10, ysize=10, $
                 bits_per_pixel=16
               print, "printing to"+modeldir+"uz.eps"
            ENDIF ELSE BEGIN 
               set_plot, 'X'
               window, 3, xsize=500, ysize=500, title="uz" &  wset, 3
            ENDELSE 
            myshow3, uz, xc, yc, sscale=rebinning,/interp, "!6u!iz!n"
            plots, -1, 0, /t3d & plots, 1, 0, /continue,  thick=5, /t3d, color = 30
            IF(printing)THEN device, /close

            
            print, "S to stop, other key to continue..."
            tmp = get_kbrd(1)
            IF(tmp EQ 's')THEN stop 
            !p.multi = 0 & set_plot, 'X'
         ENDIF 
      ENDIF 
   END 
END 






