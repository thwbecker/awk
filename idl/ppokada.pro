close, 1
   
   average=1
   dep = 100
   n = 201L & o=11L
   ;n = 101L
   ;o = 101L
   ;;lpl = 50 & rpl=150
   lpl = 15 &  rpl=50
   ;;llpl = 150 & rrpl=200
   llpl = 75 &  rrpl=n-1
   FOR nr=5, 5 DO BEGIN 
      m = n*o
      clb1 = dblarr(m)
      clb2 = dblarr(m)
      clb3 = dblarr(m)
      ux = dblarr(m)
      uy = dblarr(m)
      uz = dblarr(m)
      xc = dblarr(m)
      yc = dblarr(m)
      mid = (o-1)/2
      modeldir = "/home/geodyn/becker/okada/profiles/"+strtrim(nr, 1)+"/"

      IF((nr EQ 4)OR (nr EQ 0))THEN dep=50
      IF(nr EQ 5)THEN dep=100
      
      FOR z=dep, dep  DO BEGIN 
         IF(fix(z)-z NE  0)THEN BEGIN 
            IF(z GE 10)THEN nrdigit = 4 ELSE nrdigit = 3
            formatstring = '(f'+string(format='(i1)', nrdigit)+'.1)'
            endname = string(format=formatstring, z)+'.bin' 
         ENDIF ELSE BEGIN 
            IF(z GE 10)THEN nrdigit = 2 ELSE nrdigit = 1
            formatstring = '(i'+string(format='(i1)', nrdigit)+')'
            endname = string(format=formatstring, z)+'.bin'
         ENDELSE 
         IF(z EQ 0)THEN endname = '-0.bin'
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
            clb1 = rotate(reform(clb1, o, n), 4)
            clb2 = rotate(reform(clb2, o, n), 4)
            clb3 = rotate(reform(clb3, o, n), 4)
            ux = rotate(reform(ux, o, n), 4)
            uy = rotate(reform(uy, o, n), 4)
            uz = rotate(reform(uz, o, n), 4)
            xc = rotate(reform(xc, o, n), 4)
            yc = rotate(reform(yc, o, n), 4)
            IF(average EQ 1 )THEN BEGIN 
               leftaverage = 0 & rightaverage=0
               FOR i=0L, n-1  DO BEGIN 
                  IF((xc(i, mid) GT -1.0)AND(leftaverage EQ 0))THEN leftaverage = i
                  IF(xc(i, mid) LT  1.0)THEN rightaverage = i
               ENDFOR 
               print, "Setting values (", leftaverage, ":", rightaverage, ",", mid, ")"
               print, "  to their neighbours average."
               FOR i=leftaverage, rightaverage DO BEGIN 
                  clb1(i, mid) = (clb1(i, mid-1)+clb1(i, mid+1))/2.0
                  clb2(i, mid) = (clb2(i, mid-1)+clb2(i, mid+1))/2.0
                  clb3(i, mid) = (clb3(i, mid-1)+clb3(i, mid+1))/2.0
                  ux(i, mid) = (ux(i, mid-1)+ux(i, mid+1))/2.0
                  uy(i, mid) = (uy(i, mid-1)+uy(i, mid+1))/2.0
                  uz(i, mid) = (uz(i, mid-1)+uz(i, mid+1))/2.0
               ENDFOR 
            ENDIF 
            print, modeldir
            print, "z: "+strtrim(z, 1)+" Min s_xy: "+ strtrim(min(clb2), 1)+" Max: "+strtrim(max(clb2), 1)
            
            !p.multi = [0, 1, 2, 0]
            plot, xc(*, mid), clb2(*, mid)/1e6, title="!7r!6!ixy!n bei y=0", xtitle="x/a",$
             ytitle="!7r!6!ixy!n [MPa]"
            print, "<sxy>:", mittelwert(clb2(lpl:rpl, *)), " min(sxy):", min(clb2)
            strfac = 0.2666666667
            x = xc(llpl:rrpl, mid)
            y = (abs(x)/sqrt(x^2-1.0)-1)*strfac
            oplot, x, y, thick=2
            x = xc(0:lpl-1, mid)
            y = (abs(x)/sqrt(x^2-1.0)-1)*strfac
            oplot, x, y, thick=2
            strfac = 0.266666667
            tmp = 0.0d
            FOR i=0, lpl-1 DO BEGIN 
               tmp =  tmp + abs(y(i)-clb2(i, mid)/1e6)/abs(y(i))
               print, xc(i, mid), y(i), clb2(i, mid)/1e6, abs(y(i)-clb2(i, mid)/1e6)/abs(y(i))
            ENDFOR 
            print, " Prozentualer Fehler normiert auf 2D:", (tmp*100.0)/lpl

            ;;plot, yc(mid, *),ux(mid, *), title="u!ix!n bei x=0", xtitle="y/a", ytitle="u!ix!n [m]"
            plot, xc(*, mid),uy(*, mid), title="u!iy!n bei y=0",xtitle="x/a", ytitle="u!iy!n [m]"
            print, "Max u_y:", max(uy(*, mid))
            strfac = 0.166666667
            x = xc(llpl:rrpl, mid)
            y = strfac*(abs(x)-sqrt(x^2-1.0))
            oplot, x, y, thick=2
            x = xc(0:lpl-1, mid)
            y = -strfac*(abs(x)-sqrt(x^2-1.0))
            oplot, x, y, thick=2
            tmp = 0.0d
            FOR i=0, lpl-1 DO BEGIN 
               tmp =  tmp + abs(y(i)-uy(i, mid))/(abs(y(i)))
            ENDFOR 
            print, " Prozentualer Fehler normiert auf 2D:", (tmp*100.0)/lpl
            openw, 1, modeldir+"duy.dat"
            FOR i=0, rrpl DO BEGIN
               printf, 1, xc(i, mid), uy(i, mid)/0.1666666666666
            ENDFOR 
            close, 1
            openw, 1, modeldir+"sxy.dat"
            FOR i=0, rrpl DO BEGIN
               printf, 1, xc(i, mid), clb2(i, mid)/1e6
            ENDFOR 
            close, 1

            
            !p.multi = 0
            print, "S to stop, other key to continue..."
            tmp = get_kbrd(1)
            IF(tmp EQ 's')THEN stop 
         ENDIF 
      END  
   END


END  







