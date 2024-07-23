;; ptemp - plot data from conman finite element code 

PRO ptemp, startmodel, stopmodel, printing, printsingle, important_temperature
   on_error,2                   ;Return to caller if an error occurs
   ;; enter defgault model here
   if n_elements(startmodel) le 0 THEN startmodel = 96
   if n_elements(stopmodel) le 0 then stopmodel = startmodel
   if n_elements(printing) le 0 then printing = 0
   if (n_elements(printsingle) eq 0) then printsingle = 0
   IF n_elements(important_temperature) LE 0 THEN important_temperature = 0.79
   contourlevels = [important_temperature-0.09,  important_temperature-0.04, $
                    important_temperature,important_temperature+0.06,  $
                    important_temperature+0.11,important_temperature+0.16, $
                    important_temperature+0.21]
   contourlabels = [0, 0, 1, 0, 0, 1, 0]
   contourcolors = [100, 130, 150, 170, 190, 210, 230]
   clcont = 0
   contourthickness = [1, 1, 2, 1, 1, 1, 1]
   visccontourlevels = [0.01, 0.5, 1, 1.5, 2, 2.5, 3, 3.5]
   visccontourlabels = [0, 1, 0, 1, 0, 1, 0, 1]
   tracecontourvalue = important_temperature
   timescale = 1.0

   annotate_contours = 0
   ;; use double diffusive?
   dd = 0

   ;; print viscous dissiptation

   vid = 1

   flowlinetracing = 0
   velbc_arrows = 0
   fixed_vel_scaling = 1.0/9.0 &  nr_arrows=500

   conmanking = 0
   max_nr_times = 100
   FOR model=startmodel, stopmodel DO begin 
      maxstress = 30.0
      
      IF(dd)THEN $
        dir = "$workdir/../subduct_dd/"+strcompress(string(model),/remove_all)+"/" $
      ELSE $
        dir = "$workdir/"+strcompress(string(model),/remove_all)+"/"
      ;;dir = "$workdir/"+strcompress(string(model),/remove_all)+"a/"
      
      print, "# working directory is ", dir
      OPENR, 1, dir+'rayleigh.out', ERROR = err
      IF (err NE 0) then BEGIN 
         rayleighno = 3.51e03
         print, "# Using default rayleigh no of ", rayleighno
      ENDIF ELSE BEGIN 
         readf, 1, rayleighno
         close, 1
         rayleighno = mittelwert(rayleighno)
         print, "# Using rayleigh no of ", rayleighno
      ENDELSE 
      trenchtemp = important_temperature
      stopattime = 100.0
      reducestressyu = 3 & reducestressyl = 3
      reducestressr = 3 &  reducestressleft=3
      onlycontours=1 & onlylower = 0
      contours = 0 & animate = 0 & plotnr = 0
      IF (conmanking)THEN stress = 0
      velblowup = 1
      nointerrupt = 0 & printatten = 1
      frames = 10 & stress = 1
      IF(printing EQ 1)THEN nointerrupt = 1
      s = strarr(1)
      init = 0
      printnr = 0
      framecount = 0
      counttoten = 0
      plotnow = 0
      veldat = dblarr(max_nr_times, 15) & time=0.0
      flowsum = dblarr(max_nr_times)
      meantzz = dblarr(max_nr_times)
      a = double(1) &  b = double(1)
      n =  long(1) &  m=long(1) &  nrnd=long(1) & i=long(1)
      filestat = fstat(1) & IF(filestat.open EQ 1)THEN close, 1
      openr, 1, dir + "field.new"
      filestat = fstat(2) & IF(filestat.open EQ 1)THEN close, 2
      tmp_flt_s = 1.0
      IF(stress)THEN openr, 2, dir+"str.new" ELSE openr, 2, dir+"in.new"
      IF(animate)THEN BEGIN 
         xinteranimate,set=[1200,800,frames]
         print, 'Animating temperature field', frames, ' frames'
      ENDIF 
      WHILE(NOT  eof(1) AND NOT eof(2) AND (time LE stopattime))  DO  BEGIN 
         IF(conmanking)THEN BEGIN 
            readf, 1, dims, m, n, nrnd, timestep, time 
         ENDIF ELSE BEGIN 
            readf, 1, dims, m, n, nrnd, timestep, time, tmp_flt_s
         ENDELSE 
         readf, 1, s
         IF(NOT printing) THEN print,  dims, n, m, nrnd, timestep, time, tmp_flt_s
         IF(init EQ 0)THEN BEGIN 
            x = dblarr(nrnd)
            y = dblarr(nrnd)
            u = dblarr(nrnd)
            v = dblarr(nrnd)
            t = dblarr(nrnd)
            b = dblarr(nrnd)
            IF(stress)THEN BEGIN 
               tzz = dblarr(nrnd)
               txz = dblarr(nrnd)
               pressure = dblarr(nrnd)
               txx = dblarr(nrnd)
               viscosity = dblarr(nrnd)
            ENDIF 
            IF(NOT printing)THEN BEGIN
               loadct, 0 
               set_plot, "X"
               window, 0, xsize=1200,ysize=600
            ENDIF ELSE BEGIN 
               set_plot, "PS"
               loadct, 0
            ENDELSE 
            init = 1
         ENDIF 
         FOR i=0L, nrnd-1 DO BEGIN 
            IF(NOT dd)THEN BEGIN 
               readf, 1, j, x1, x2, v1, v2, temperature 
               x(i) = x1 &  y(i) = x2
               u(i) = v1 &  v(i)=v2 & t(i)=temperature
            ENDIF ELSE BEGIN 
               readf, 1, j, x1, x2, v1, v2, temperature,  comp
               x(i) = x1 &  y(i) = x2
               u(i) = v1 &  v(i)=v2 & t(i)=temperature
               b(i) = comp
            ENDELSE 
         ENDFOR 
         rotfac = 4
         t = rotate(reform(t, n+1, m+1), rotfac)
         x = rotate(reform(x, n+1, m+1), rotfac)
         y = rotate(reform(y, n+1, m+1), rotfac)
         u = rotate(reform(u, n+1, m+1), rotfac)
         v = rotate(reform(v, n+1, m+1), rotfac)
         IF(dd)THEN b=rotate(reform(b, n+1, m+1), rotfac)
         xmin = min(x)
         xmax = max(x)
         ymax = max(y)
         xspan = xmax - min(x) & yspan=max(y)-min(y)
         oldtopo = replicate(0.0d, n+1)
         IF(stress)THEN BEGIN 
            readf, 2,  dims, nrnd, m, n,  c, d, e
            readf, 2, s
            stmp = strcompress(s, /remove_all)
            stmp = strmid(stmp,14,1)
            FOR i=0L, nrnd-1 DO BEGIN 
               readf, 2, j, x1, x2, s22, s12, pre, visc
               tzz(i) = s22 &  txz(i)= s12 & pressure(i)=pre & viscosity(i)=visc
            ENDFOR 
            IF(stmp[0] EQ 'P')THEN BEGIN 
               IF(NOT printing)THEN print, 'using pressure from str.new'
               txx = -tzz
            ENDIF ELSE BEGIN 
               ;;               txx = pressure
               txx = -tzz
            ENDELSE  
            txx = rotate(reform(txx, n+1, m+1), rotfac)
            tzz = rotate(reform(tzz, n+1, m+1), rotfac)
            txz = rotate(reform(txz, n+1, m+1), rotfac)
            pressure =  rotate(reform(pressure, n+1, m+1), rotfac)
            viscosity =  rotate(reform(viscosity, n+1, m+1), rotfac)
            IF(rotfac EQ 4)THEN BEGIN 
               i = n & n=m & m=i
            ENDIF 
            cms2, n+1, m+1, txx, txz, tzz, fms, sms, deg
         ENDIF ELSE BEGIN 
            IF(rotfac EQ 4)THEN BEGIN 
               i = n & n=m & m=i
            ENDIF 
         ENDELSE 
         IF(NOT  printing)THEN BEGIN 
            plotnow = 1
         ENDIF ELSE BEGIN 
            IF(counttoten EQ printatten-1)THEN BEGIN 
               plotnow = 1  
               counttoten=0 
            ENDIF ELSE counttoten = counttoten+1
         ENDELSE 
         ;;   IF(fix(time)-time NE 0)THEN plotnow = 0
        
         IF(plotnow)THEN BEGIN 

            trench = 1.0 
            IF(NOT printing)THEN wset, 0 ELSE BEGIN 
               IF(NOT printsingle)THEN BEGIN 
                  device, filename=dir+strcompress("p"+string(format='(f10.2)', 100.0*time)+".ps", /remove_all), $
                    bits_per_pixel=16, /landscape, xsize=2+10*xspan/yspan, ysize=2.39+10,/TIMES, /BOLD
               ENDIF  
            ENDELSE  
            IF(NOT printsingle)THEN BEGIN 
               IF(xspan/yspan GT 3.0)THEN !p.multi = [0, 1, 4, 0] ELSE !p.multi = [0, 2, 2, 0]
            ENDIF ELSE BEGIN 
               !p.multi = 0
            ENDELSE 
          
            IF(yspan GT  1.0)THEN BEGIN  
               xtitlestring="(|u!ix!n|(z<"+string(format='(i1)', fix(yspan/2.0))+"))!imax!n: "+$
                 string(format='(f5.2)',max(abs(u(*, 0:m/2))))+ $
                 " (|u!ix!n|(z>"+string(format='(i1)', fix(yspan/2.0))+"))!imax!n: "+$
                 string(format='(f5.3)',max(abs(u(*, m/2+1:m))))+ $
                 " (u!ix,y!n(z<"+string(format='(i1)', fix(yspan/2.0))+"))!iavg!n: "+$
                 string(format='(f5.3)',mittelwert(sqrt(u(*, 0:m/2)^2+v(*, 0:m/2)^2)))+ $
                 " (u!ix,y!n(z>"+string(format='(i1)', fix(yspan/2.0))+"))!iavg!n: "+$
                 string(format='(f5.3)',mittelwert(sqrt(u(*, m/2+1:m)^2+v(*, m/2+1:m)^2)))
               ytitlestring="(|u!iy!n|(z<1))!imax!n: "+string(format='(f5.3)',max(abs(v(*, 0:m/2))))+ $
                 " (|u!iy!n|(z<"+string(format='(i1)', fix(yspan/2.0))+"))!imax!n: "+$
                 string(format='(f5.3)',max(abs(v(*, m/2+1:m))))
            ENDIF  ELSE  BEGIN  
               xtitlestring="max(|u!ix!n|): "+string(format='(f4.2)',max(abs(u(*, 0:m))))
               ytitlestring="max(|u!iy!n|): "+string(format='(f4.2)',max(abs(v(*, 0:m))))
            ENDELSE 
            ;;!x.charsize = 0.5 & !y.charsize=0.5
            IF(printsingle)THEN BEGIN 
               device, filename=dir+strcompress("vel"+string(format='(f10.3)', time)+".eps", /remove_all), $
                 /encapsulated, xsize=8.528625*xspan, ysize=9.025, /TIMES, /BOLD, bits_per_pixel=16, xoffset=1.75
               IF(NOT dd)THEN $
                 contour, t, x, y, levels=contourlevels, /fill,  c_color=contourcolors, $
                 title="u!ix,y!n at t="+string(format='(f10.2)', time*timescale), $
                 xtitle=xtitlestring, ytitle=ytitlestring, xticklen=01.0e-10, yticklen=01.0e-10, C_THICK=contourthickness $
               ELSE $
                 contour, b, x, y, levels=contourlevels, /fill,  c_color=contourcolors, $
                 xtitle="x", ytitle="z", xticklen=01.0e-10, yticklen=01.0e-10, C_THICK=contourthickness 
               myvel2, u(*, 0:m), v(*, 0:m), x, y, n, m, cl=clcont, nvecs=nr_arrows, fac=fixed_vel_scaling, $
                 overplot=1
            ENDIF ELSE BEGIN 
               IF(NOT dd)THEN $
                 contour, t, x, y, levels=contourlevels, /fill, c_color=contourcolors, $
                 title="u!ix,y!n at t="+string(format='(f10.2)', time*timescale), xtitle=xtitlestring, ytitle=ytitlestring $
               ELSE $
                 contour, b, x, y, levels=contourlevels, /fill, c_color=contourcolors, $
                 title="u!ix,y!n at t="+string(format='(f10.2)', time*timescale), xtitle=xtitlestring, ytitle=ytitlestring 
               myvel2, u(*, 0:m), v(*, 0:m), x, y, n, m,  overplot=1, cl=clcont, nvec=nr_arrows, fac=fixed_vel_scaling
            ENDELSE 
            !x.charsize = 1.0 & !y.charsize=1.0
            IF(annotate_contours)THEN $
              contour, t, x, y, levels=contourlevels, c_labels=contourlabels, /overplot, /follow, C_THICK=contourthickness, $
               color=clcont $
            ELSE $ 
              contour, t, x, y, levels=contourlevels, /overplot, C_THICK=contourthickness, $
               color=clcont 
            IF(velbc_arrows)THEN BEGIN 
               FOR i=0, m, 3 DO BEGIN 
                  arrow, xmin-0.30, y(0, i), xmin-0.30+u(0, i)*fixed_vel_scaling, y(0, i), /data, hsize=-.1
                  arrow, xmax+0.15, y(n, i), xmax+0.15+u(n, i)*fixed_vel_scaling, y(n, i), /data, hsize=-.1
               ENDFOR 
            ENDIF 
          
            FOR i=0, n-1 DO BEGIN 
               IF(t(i, m) GT trenchtemp)THEN trench = double(i)/double(n)
            ENDFOR
            IF(trench LT 0.2)THEN trench = 0.2
            IF(trench GT 0.8)THEN trench = 0.8
            trenchat = trench*xspan
            IF(NOT printing)THEN print, "trench at", trenchat


            IF(flowlinetracing)THEN BEGIN 
               IF(0)THEN BEGIN 
                  i = trench*n*1
                  j = 0.5*m
                  WHILE t(i, j) GT 0.8 DO BEGIN 
                     j = j+1
                  ENDWHILE 
                  i = trench*n*1
                  WHILE ((i LT n) AND (u(i, j) GT 0.0)) DO BEGIN 
                     i = i+1
                  ENDWHILE 
                  fac = -0.02
               ENDIF ELSE BEGIN 
                  fac = 0.02
                  ;; for the 96,97,98 models
                  ;;j = 0.93/yspan*m
                  ;; for the 1033 model
                  j = 0.89/yspan*m
                  i = 1.5/xspan*n
               ENDELSE 
               

               trace = dblarr(2, 3000) 
               k = 0
               trace(0, k)=x(i, j) &  trace(1, k)=y(i, j)
               radius = replicate(1.0e20, 3000)
               plots, trace(0, 0), trace(1, 0),  thick=3.0, /data
               tmp2 = 1.0
               WHILE ((trace(0, k) LE 1.75) AND (k LT 2998) AND (trace(1, k) GT 0.5)) DO BEGIN 
                  tmp1 = interpolate(u,trace(0, k)/xspan*n, trace(1, k)/yspan*m)*fac
                  tmp2 = interpolate(v,trace(0, k)/xspan*n, trace(1, k)/yspan*m)*fac
                  trace(0, k+1) = trace(0, k)+tmp1
                  trace(1, k+1) = trace(1, k)+tmp2
                  k =  k + 1
               ENDWHILE 
               
               FOR i=1, k-1 DO BEGIN 
                  plots, trace( 0, i), trace(1, i),  /continue, thick=3.0, /data
                  scnd = (trace(1, i+1)-2.0*trace(1, i)+trace(1, i-1))/(trace(0, i)-trace(0, i-1))^2
                  fst = (trace(1, i+1)-trace(1, i-1))/(2.0*(trace(0, i)-trace(0, i-1)))
                  radius(i)= abs(((1.0+fst^2)^(3/2))/scnd)
               ENDFOR 
               veldat(plotnr, 12) = min(radius, minele);; minimum radius of curvature

               orth_dir = dblarr(2)
               orth_curve = dblarr(2, 2000)
               IF(minele EQ 0)THEN minele = 1
               orth_dir(0) = -(interpolate(v, trace(0, minele+1)/xspan*n, trace(1, minele+1)/yspan*m) + $
                               interpolate(v, trace(0, minele-1)/xspan*n, trace(1, minele-1)/yspan*m))/100.0
               orth_dir(1) =  (interpolate(u, trace(0, minele+1)/xspan*n, trace(1, minele+1)/yspan*m) + $
                               interpolate(u, trace(0, minele-1)/xspan*n, trace(1, minele-1)/yspan*m))/100.0
               k = 0
               orth_curve(0, k) = trace(0, minele) & orth_curve(1, k) = trace(1, minele) 
               plots,  orth_curve(0, k),  orth_curve(1, k), thick=3.0
               WHILE ((interpolate(t, orth_curve(0, k)/xspan*n,orth_curve(1, k)/yspan*m) LT 0.79)AND(k LT 1999))DO BEGIN 
                  orth_curve(0, k+1) = orth_curve(0, k)+ orth_dir(0)
                  orth_curve(1, k+1) = orth_curve(1, k)+ orth_dir(1)
                  k = k+1
                  plots,  orth_curve(0, k),  orth_curve(1, k), thick=3.0, /continue
               ENDWHILE 
               ;; distance to the continent or upper box limit upwards
               veldat(plotnr, 13) = sqrt((orth_curve(0, k)-orth_curve(0, 0))^2+(orth_curve(1, k)-orth_curve(1, 0))^2)

               l = k
               orth_curve(0, l) =  orth_curve(0, 0) &   orth_curve(1, l) =  orth_curve(1, 0) 
               plots,  orth_curve(0, l),  orth_curve(1, l), thick=3.0
            
               WHILE ((interpolate(t, orth_curve(0, l)/xspan*n,orth_curve(1, l)/yspan*m) LT 0.79)AND(l LT 1999)$
                      AND (orth_curve(1, l) LT ymax) )DO BEGIN 
                  orth_curve(0, l+1) = orth_curve(0, l)- orth_dir(0)
                  orth_curve(1, l+1) = orth_curve(1, l)- orth_dir(1)
                  l = l+1
                  plots,  orth_curve(0, l),  orth_curve(1, l), thick=3.0, /continue
               ENDWHILE 
               IF(k GE 1)THEN $
                 ;; distance to the mantle
                 veldat(plotnr, 14) = sqrt((orth_curve(0, k-1)-orth_curve(0, l))^2+(orth_curve(1, k-1)-orth_curve(1, l))^2)
            ENDIF 


            IF(printsingle)THEN device, /close
            
            IF(0)THEN BEGIN 
               IF(velblowup)THEN BEGIN 
                  velovect, u(n*(trench-0.2):n*(trench+0.2),m*0.6:m), v(n*(trench-0.2):n*(trench+0.2),m*0.6:m),$
                    x(n*(trench-0.2):n*(trench+0.2),0),$
                    y(0,m*0.6:m), title="magnified u!ix,y!n at trench", $
                    xtitle="x, abs(u!ix!emax!n): "+strtrim(max(abs(u(n*(trench-0.2):n*(trench+0.2),m*0.6:m))), 0), $
                    ytitle="y, abs(u!iy!emax!n): "+strtrim(max(abs(v(n*(trench-0.2):n*(trench+0.2),m*0.6:m))), 0)
               ENDIF ELSE BEGIN 
                  plot,t(n/2, *),y(n/2, *),title="T at x=0.5",xtitle="T",ytitle="y (depth)", xrange=[0, 1.0]
                  plots, 0, 1 & plots, 1, 0,/continue,linestyle=3
               ENDELSE 
            ENDIF 
            contour, t,x, y, PATH_XY=xy, PATH_INFO=info, levels=contourlevels, /Path_Data_Coords
            k = 0 & contourlow=replicate(9999.0, 2) & trenchdist=9999.0 & trenchcontour=dblarr(2)
            FOR i=0, (N_ELEMENTS(info) - 1 ) DO BEGIN
               FOR j=0,  info(i).n-1 DO BEGIN 
                  IF((info(i).value EQ tracecontourvalue)AND(xy(0, k+j) GT 0.25)AND(xy(0, k+j) LT xspan*0.75))THEN BEGIN 
                     IF((abs(trenchat-xy(0, k+j)) LT trenchdist)AND(xy(1, k+j) LT 0.94))THEN BEGIN 
                        trenchcontour(0)= xy(0, k+j) &  trenchcontour(1) = xy(1, k+j)  
                        trenchdist=abs(trenchat-xy(0, k+j))
                     ENDIF 
                     IF(contourlow(1) GT xy(1, k+j))THEN BEGIN 
                        contourlow(0) = xy(0, k+j) 
                        contourlow(1) = xy(1, k+j)
                     ENDIF 
                  ENDIF 
               ENDFOR 
               k = j
            ENDFOR 
            contourlowspeed = dblarr(2) & halfheightspeed=dblarr(2)
            trenchcontourspeed = dblarr(2)
            contourlowspeed(0) = interpolate(u, contourlow(0)/xspan*n, contourlow(1)/yspan*m) 
            contourlowspeed(1) = interpolate(v, contourlow(0)/xspan*n, contourlow(1)/yspan*m)
            trenchcontourspeed(0) = interpolate(u,trenchcontour(0)/xspan*n, trenchcontour(1)/yspan*m)
            trenchcontourspeed(1) = interpolate(v,trenchcontour(0)/xspan*n, trenchcontour(1)/yspan*m)
            halfheightspeed(0) = interpolate(u,trenchcontour(0)/xspan*n, 0.5*m)
            halfheightspeed(1) = interpolate(v,trenchcontour(0)/xspan*n, 0.5*m)

            IF(plotnr GT max_nr_times)THEN BEGIN 
               print, "Increase the number of allowed plotted timesteps (max_nr_times)", max_nr_times
               stop
            ENDIF 
            veldat(plotnr, 0) = time & veldat(plotnr, 1:2)=contourlow & veldat(plotnr, 3:4)=contourlowspeed
            veldat(plotnr, 5:6) = trenchcontour & veldat(plotnr, 7:8)= trenchcontourspeed
            veldat(plotnr, 9:10) = halfheightspeed
            flowsum(plotnr) =                   total(v(*, 0))*(xspan/yspan)
            flowsum(plotnr) = flowsum(plotnr) - total(u(n, *))
            flowsum(plotnr) = flowsum(plotnr) - total(v(*, m))*(xspan/yspan)
            flowsum(plotnr) = flowsum(plotnr) + total(u(0, *))
            IF(NOT printing)THEN print, "assuming contant spacing: left_in: ", total(u(0, *)), " right_in: ", -total(u(n, *))
            IF(NOT printing)THEN print, "low_in: ", total(v(*, 0))*(xspan/yspan), " dM/dt=", flowsum(plotnr)
            IF(NOT onlycontours)THEN BEGIN 
               IF(stress)THEN BEGIN 

                  IF(printsingle)THEN device, $
                    filename=dir+strcompress("visc"+string(format='(f10.3)', time)+".eps", /remove_all), $
                    /encapsulated, xsize=(1+12.0*xspan), ysize=12, /TIMES, /BOLD, bits_per_pixel=16
                  shade_surf, alog10(viscosity), x, y,AX = 045, AZ = 015, $
                    xtitle="x", ytitle="z", ztitle="log!i10!n(!4l!3)", yticks=3,$
                    ytickv=[0.25*yspan, 0.5*yspan, 0.75*yspan], zcharsize=2.0
                  IF(printsingle)THEN device, /close
                  IF(stmp[0] EQ 'P')THEN BEGIN 
                     shade_surf,pressure, x, y,shade=bytscl(pressure),az=0,ax=90,zstyle=4, xtitle="pressure"
                     contour, pressure, x, y, title="p",  nlevels=10, /overplot, /follow
                  ENDIF ELSE BEGIN 
                     shade_surf, tzz(*,reducestressyl:m-reducestressyu),  $
                       x(*,reducestressyl:m-reducestressyu), y(*,reducestressyl:m-reducestressyu),$
                       shade=bytscl((txx(*,reducestressyl:m-reducestressyu))), az=0,ax=90,zstyle=4, xtitle="Tzz"
                     contour, ((txx(*,reducestressyl:m-reducestressyu))),  $
                       x(*,reducestressyl:m-reducestressyu), y(*,reducestressyl:m-reducestressyu), $
                       title="Tzz",  nlevels=10, /overplot, /follow
                  ENDELSE 
                  shade_surf, txz, x, y, shade=bytscl(txz), az=0,ax=90,zstyle=4, xtitle="shear stress"
                  contour, txz, x, y, title="txz",  nlevels=10, /overplot, /follow
                  xyouts, 0.25, 0.25, dir, charsize=0.75
               ENDIF ELSE BEGIN 
                  plot,t(n/2,*),y(n/2,*), xtitle="temperature at x="+string(x(n/2, 0)), $
                    ytitle="z"
               ENDELSE 
            ENDIF ELSE  BEGIN 
               IF(stress)THEN BEGIN 
                  IF(NOT vid)THEN BEGIN 
                     IF(printsingle)THEN device, filename=dir+strcompress("visc"+string(format='(f10.3)', time)+".eps", /remove_all), $
                       /encapsulated, xsize=(1+8.0*xspan), ysize=11, /TIMES, /BOLD, bits_per_pixel=16
                     shade_surf, alog10(viscosity), x, y,AX = 065, AZ = 015, $
                       xtitle="x", ytitle="z", ztitle="log!i10!n(!4l!3)", ytickv=[0.25*yspan, 0.5*yspan, 0.75*yspan],$
                       yticks=3, zcharsize=2.0
                     IF(printsingle)THEN device, /close
                  ENDIF ELSE BEGIN
                     reducestressleft = 1
                     reducestressr = 1 & reducestressyl=2
                     reducestressyu =  1
                     vd =alog10((txx(reducestressleft:n+1-reducestressr,reducestressyl:m-reducestressyu)^2+$
                                 txz(reducestressleft:n+1-reducestressr,reducestressyl:m-reducestressyu)^2)/$
                                (viscosity(reducestressleft:n+1-reducestressr,reducestressyl:m-reducestressyu)))

                     print, " time ", time, "max visc diss", max(vd)

                     print, "max shear strain rates", max(abs(txz/(2.*viscosity)))
                     IF(printsingle)THEN device, $
                       filename=dir+strcompress("exz"+string(format='(f10.3)', time)+".eps", /remove_all), $
                       /encapsulated, xsize=8.528625*xspan, ysize=9.025, /TIMES, /BOLD, bits_per_pixel=16
                     contour,(abs(txz(n*0.25:n*0.75, *))+abs(txx(n*0.25:n*0.75, *)))/(2.*viscosity(n*0.25:n*0.75, *)),$
                       x(n*0.25:n*0.75, *), y(n*0.25:n*0.75, *),$
                       levels=[0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 5], $
                       /follow
                     contour,abs(t(n*0.25:n*0.75, *)/(2.*viscosity(n*0.25:n*0.75, *))),$
                       x(n*0.25:n*0.75, *), y(n*0.25:n*0.75, *), thick=2.0, $
                       levels=contourlevels, /overplot
                     IF(printsingle)THEN device, /close
                     
                     IF(printsingle)THEN device, $
                       filename=dir+strcompress("vd"+string(format='(f10.3)', time)+".eps", /remove_all), $
                       /encapsulated, xsize=8.528625*xspan, ysize=9.025, /TIMES, /BOLD, bits_per_pixel=16
                     ;;shade_surf, vd, x(reducestressleft:n+1-reducestressr,reducestressyl:m-reducestressyu),$
                     ;;  y(reducestressleft:n+1-reducestressr,reducestressyl:m-reducestressyu), $
                     ;;  shade=bytscl(vd), az=0,ax=90,zstyle=4
                     contour,vd,x(reducestressleft:n+1-reducestressr,reducestressyl:m-reducestressyu),$
                       y(reducestressleft:n+1-reducestressr,reducestressyl:m-reducestressyu), $
                       levels=[-0.5, 0 , 0.5, 1 ,1.5, 2.0], xtitle="x",  /fill,  $
                       c_color=[245, 200, 150, 100, 50, 25]
                     contour,vd,x(reducestressleft:n+1-reducestressr,reducestressyl:m-reducestressyu),$
                       y(reducestressleft:n+1-reducestressr,reducestressyl:m-reducestressyu), /follow, $
                       levels=[-0.5, 0 , 0.5, 1 ,1.5, 2.0], /overplot
                     IF(printsingle)THEN device, /close
                  ENDELSE 


                  IF(stmp[0] EQ 'P')THEN BEGIN 
                     contour, pressure, x, y, title="pressure",  nlevels=10, /follow, xtitle="x", ytitle="z" 
                  ENDIF ELSE BEGIN 
                     IF(printsingle)THEN device, $
                       filename=dir+strcompress("msa"+string(format='(f10.3)', time)+".eps", /remove_all), $
                       /encapsulated,  xsize=8.528625*xspan, ysize=9.025, /TIMES, /BOLD, bits_per_pixel=16
                     pmsa3, n+1-reducestressr-reducestressleft,m-reducestressyu-reducestressyl, $
                       (n+1-reducestressleft-reducestressr)/20, $
                       (m-reducestressyu-reducestressyl)/20, $
                       x(reducestressleft:n+1-reducestressr,reducestressyl:m-reducestressyu), $
                       y(reducestressleft:n+1-reducestressr,reducestressyl:m-reducestressyu),$
                       fms(reducestressleft:n+1-reducestressr,reducestressyl:m-reducestressyu),$
                       sms(reducestressleft:n+1-reducestressr,reducestressyl:m-reducestressyu), $
                       deg(reducestressleft:n+1-reducestressr,reducestressyl:m-reducestressyu), maxstress
                     IF(printsingle)THEN device, /close
                  ENDELSE 
                  tmp_flt = fltarr(n)
                  FOR i=0, n-1 DO BEGIN 
                     IF(x(i, m-1) LT trenchat)THEN tmp_flt(i) = 0.75e06/2800.0/9.81 ELSE $
                       tmp_flt(i) = 0.75e06/3300.0/9.81
                  ENDFOR 
                  IF(printsingle)THEN BEGIN 
                     device, $
                       filename=dir+strcompress("topo"+string(format='(f10.3)', time)+".eps", /remove_all), $
                       /encapsulated, xsize=(1+6.45*xspan), ysize=7.9, /TIMES, /BOLD, bits_per_pixel=16
                     plot,x(*,m-1),tzz(*,m-1)*tmp_flt(*)/1.0e03, xtitle="x", ytitle="h [km]", $
                       charsize=0.75, yrange=[-1, 1]
                  ENDIF ELSE BEGIN 
                     plot,x(*,m-1),tzz(*,m-1)*tmp_flt(*)/1.0e03, xtitle="x", ytitle="h [km]", $
                       title=dir, charsize=0.75, yrange=[-1, 1]
                  ENDELSE 
                  plots, trenchat, min(tzz(*,m-1)*tmp_flt(*)/1.0e03) & plots, trenchat,max(tzz(*,m-1)*tmp_flt(*)/1.0e03) ,$
                    /continue, linestyle=1
                  ;;plots, 0, 0 &  plots, max(x(*, m-1)), 0, /continue, linestyle=2
                  veldat(plotnr, 11) = total(abs(oldtopo - tzz(*,m-1)*tmp_flt(*)/1.0e03))*xmax*670.0/double(n+1)
                  oldtopo = tzz(*,m-1)*tmp_flt(*)/1.0e03
                  meantzz(plotnr) = mittelwert(tzz(trenchat/xmax*0.25*n:trenchat/xmax*0.75*n, m-1)*tmp_flt(*)/1.0e03)
                  plots, x(trenchat/xmax*0.25*n, 0), meantzz(plotnr)*1.2
                  plots, x(trenchat/xmax*0.25*n, 0), meantzz(plotnr)*0.8, /continue
                  plots, x(trenchat/xmax*0.25*n, 0), meantzz(plotnr)
                  plots, x(trenchat/xmax*0.75*n, 0), meantzz(plotnr), /continue
                  plots, x(trenchat/xmax*0.75*n, 0), meantzz(plotnr)*1.2, /continue
                  plots, x(trenchat/xmax*0.75*n, 0), meantzz(plotnr)*0.8, /continue
                  IF(printsingle)THEN device, /close
               ENDIF ELSE BEGIN 
                  plot,t(n/2,*),y(n/2,*), xtitle="temperature at x="+string(x(n/2, 0)), $
                    ytitle="z"
               ENDELSE 
            ENDELSE 
            

            IF(printing)THEN device, /close
            IF(animate)THEN BEGIN 
               IF(framecount GT frames)THEN BEGIN 
                  print, 'No more frames left!'
               ENDIF ELSE BEGIN 
                  xinteranimate,frame=framecount,window=[0, 0, 0, 1200,800]
                  framecount = framecount+1
               ENDELSE 
            ENDIF ELSE BEGIN 
               IF(NOT nointerrupt)THEN BEGIN 
                  tmpstring = get_kbrd(1)
                  IF(tmpstring EQ 'q')THEN BEGIN 
                     close, 1, 2
                     stop 
                  ENDIF 
                  IF (tmpstring EQ 'p')THEN BEGIN 
                     set_plot, 'PS'
                     !p.multi = [0, 3, 1, 0]
                     device, file=dir+"temp."+string(format='(i1)', printnr)+".eps", /encapsulated, $
                       xsize=22, ysize=8, bits_per_pixel=16, /color
                     velovect, u, v, x(0, *), y(*, 0), title="u!ix,y!n at t="+strtrim(time, 0), $
                       xtitle="abs(u!ix!emax!n): "+strtrim(max(abs(u)), 0), ytitle="abs(u!iy!emax!n): "+strtrim(max(abs(v)), 0)
                     plot,t(n/2, *),y(n/2, *),title="T at x=0.5",xtitle="T",ytitle="y (depth)"
                     plots, 0, 1 & plots, 1, 0,/continue,linestyle=3
                     shade_surf,t,x,y,shade=bytscl(t),az=0,ax=90,zstyle=4, $
                       xtitle="!3x", ytitle="z"
                     IF(contours)THEN $
                       contour, t, x, y, levels=contourlevels, c_labels=contourlabels, $
                       /follow, /overplot, C_THICK=contourthickness
                     device,  /close
                     printnr = printnr+1
                     set_plot, 'X'
                  ENDIF 
               ENDIF 
            ENDELSE 
            plotnow = 0
         ENDIF   
         plotnr = plotnr+1
      ENDWHILE 
      IF(animate)THEN xinteranimate, 10
      set_plot, 'PS'
      !p.multi = 0
      device, file=dir+"subveldat.eps"
      plot, x, y, /nodata, xstyle=4, ystyle=4
      i = 0
      xyouts, -0.2, 1.1, dir
      xyouts, -0.2, 1.0, "time <> contourlow (x,y) (u,v) <> trenchcontourlow (x,y) (u,v) <> y=0.5 at trench (u,v) <> mass change <> mean_h <> abs(dh)*z "
      print, "# time <> contourlow (x,y) (u,v) <> trenchcontourlow (x,y) (u,v) <> y=0.5 at trench (u,v) <> mass change <> mean_h <> abs(dh)*z <> min(radius) <> lower R <> total length"
      WHILE((veldat(i, 0) NE 0.0)OR (i EQ 0))DO BEGIN 
         xyouts, -0.2, 0.9-i*0.05, string(format='(17g10.4)', veldat(i, 0),  veldat(i, 1),  veldat(i, 2),$
                                          veldat(i, 3),  veldat(i, 4),  veldat(i, 5),  veldat(i, 6), $ 
                                          veldat(i, 7),  veldat(i, 8),  veldat(i, 9),  veldat(i, 10), $
                                          flowsum(i), meantzz(i), veldat(i, 11),  veldat(i, 12), veldat(i, 13), veldat(i, 14)), $
           charsize=0.5
         IF(i LT  1)THEN $
           print, "# ", string(format='(17g15.4)', veldat(i, 0),  veldat(i, 1),  veldat(i, 2),$
                               veldat(i, 3),  veldat(i, 4),  veldat(i, 5),  veldat(i, 6), $ 
                               veldat(i, 7),  veldat(i, 8),  veldat(i, 9),  veldat(i, 10), flowsum(i), meantzz(i), $
                               veldat(i, 11), veldat(i, 12), veldat(i, 13), veldat(i, 14)) $
         ELSE $
           print, string(format='(17g15.4)', veldat(i, 0),  veldat(i, 1),  veldat(i, 2),$
                         veldat(i, 3),  veldat(i, 4),  veldat(i, 5),  veldat(i, 6), $ 
                         veldat(i, 7),  veldat(i, 8),  veldat(i, 9),  veldat(i, 10), flowsum(i), meantzz(i), veldat(i, 11), $
                         veldat(i, 12), veldat(i, 13), veldat(i, 14))
         i = i+1
      ENDWHILE 
      device, /close
      close, 1, 2
      set_plot, 'X'
   ENDFOR 
END 




