close,1, 2, 3

   ;; SOLLEN EPS FILES ERZEUGT WERDEN ?
   pr = 0
   IF(NOT pr)THEN dev='X' ELSE dev='PS'
   set_plot,dev
   
   compare=0 & seis = 1 & pure_stresses=1 &  slip=1
   starttest=6 & stoptest=6
   ptimestart=0
   newstyle=1 &  oldstressdatastyle=0

   timescale = 10.0
   spacescale = 100.0

   FOR  test = starttest, stoptest do begin
      fixedtimerange = 0
      fixedtimestart = 125
      checkend=1
      if(checkend)then ptimeend= -1
      
      ;;modeldir="/lobe_crack_wo/"
      ;;modeldir="/arc_faults/"+strtrim(test,1) + "/"
      ;;modeldir = "/random/" + strtrim(test,1) + "/"
      ;;modeldir="/arc_faults_run3/"+strtrim(test,1)+"/"
      modeldir = "/en_echelon/fresh/"+strtrim(test,1)+"/"
      ;;modeldir = "/tmp/2/"
      ;;modeldir = "/en_echelon/complicated/"+strtrim(test,1)+"/"
      ;;modeldir = "/anatolian/"+strtrim(test,1)+"/"
      ;;modeldir="random/"+strtrim(test,1)+"/"
      ;;modeldir = "/en_echelon/complicated/"+strtrim(test,1)+"/"
      ;;filedir="/home/datdyn/becker/finel"+modeldir
      filedir="/home/geodyn/becker/finel/results/"+modeldir

      if(compare)then begin
         openr,1,"/datdyn/becker/finel/lobe_crack/only_main/csfield.dat"
         readf,1,n
         cs=dblarr(n,n) & clbx =dblarr(n,n) & clby=dblarr(n,n)
         readf,1,cs
         close,1
         openr,1,"/datdyn/becker/finel/lobe_crack/only_main/clbx.dat"
         readf,1,clbx
         close,1
         openr,1,"/datdyn/becker/finel/lobe_crack/only_main/clby.dat"
         readf,1,clby
         close,1
      end
      
      if(oldstressdatastyle)then begin
         openr,1,filedir+"stre11.1.xyz"
         readf,1,time,fmyu,sdmyu,nmyu,hp,off
         close,1
      endif else begin
         openr,1,filedir+"mesh_constants"
         readf,1,emodul,nyu
         readf,1,alpha1,deltat,alpha2
         readf,1,nmyu,fmyu,sdmyu
         readf,1,foff,loff,hp
         close,1			
      endelse
      
      modulmyu = emodul/(2.0+2.0*nyu)
      openr,1,filedir+"faultcoord"
      readf,1,nrflt
      fltcoord=dblarr(4,nrflt)
      readf,1,fltcoord
      close,1
      ;;xxmax = max(fltcoord)*2.0
      xxmax = 1000.0
      if(seis)then begin
         openr,1,filedir+"seis"
         readf,1,gnrflt,i,j
         mo=dblarr(gnrflt,j-i+1) & sd=dblarr(gnrflt,j-i+1)
         WHILE  not eof(1) do begin
            readf,1,it,flt & readf,1,x1,y1 & readf,1,x2,y2 
            readf,1,a 
            ds=1.0
            if(newstyle)then readf,1,du,ds else readf,1,du
            time= it - i
            mo(flt-1,time) = mo(flt-1,time) + a^2 * abs(du) * modulmyu * (spacescale^3) 
            sd(flt-1, time) = ds
         ENDWHILE 
         close,1
      ENDIF 
      IF(fixedtimerange EQ 0)THEN fixedtimerange = j-i+1
      fixedtimestart =  fixedtimestart + i
      timeplot = indgen(fixedtimerange)+fixedtimestart

      startfault=1 & stopfault=nrflt	

      for fault = startfault,stopfault do begin
         print,"Reading "+filedir+"stress_timeseries.flt"+$
          strtrim(fault,1)+".csmedian"
         openr,1,filedir+"stress_timeseries.flt"+$
          strtrim(fault,1)+".csmedian"
         readf,1,n
         IF(n NE fixedtimerange)THEN BEGIN 
            print, "fixedtimerange: ", fixedtimerange
            print, "n: ", n
          ;;  stop 
         ENDIF 
         if(ptimeend eq -1)then ptimeend=n-1
         print,"Last it:",ptimeend
         if (fault eq startfault) then begin
            csmedian = dblarr(n,1+stopfault-startfault)
            csmax = dblarr(n,1+stopfault-startfault)
            csmin = dblarr(n,1+stopfault-startfault)
            csmid = dblarr(n,1+stopfault-startfault)
            csend = dblarr(n,1+stopfault-startfault)
            dumid = dblarr(n,1+stopfault-startfault)
            duend = dblarr(n,1+stopfault-startfault)
            dumean = dblarr(n,1+stopfault-startfault)
            taumedian = dblarr(n,1+stopfault-startfault)
            nosmedian = dblarr(n,1+stopfault-startfault)
            tmpv=dblarr(n)
         end
         readf,1,tmpv
         csmedian(*,fault-startfault)=tmpv
         close,1
         
         openr,1,filedir+"stress_timeseries.flt"+strtrim(fault,1)+".csmax"
         readf,1,n
         readf,1,tmpv
         csmax(*,fault-startfault)=tmpv
         close,1
         openr,1,filedir+"stress_timeseries.flt"+strtrim(fault,1)+".csmin"
         readf,1,n
         readf,1,tmpv
         csmin(*,fault-startfault)=tmpv
         close,1
         openr,1,filedir+"stress_timeseries.flt"+strtrim(fault,1)+".taumedian"
         readf,1,n
         readf,1,tmpv	
         taumedian(*,fault-startfault)=tmpv
         close,1
         openr,1,filedir+"stress_timeseries.flt"+strtrim(fault,1)+".nosmedian"
         readf,1,n
         readf,1,tmpv	
         nosmedian(*,fault-startfault)=tmpv
         close,1
         openr,1,filedir+"stress_timeseries.flt"+strtrim(fault,1)+".csmid"
         readf,1,n
         readf,1,tmpv
         csmid(*,fault-startfault)=tmpv
         close,1
         openr,1,filedir+"stress_timeseries.flt"+strtrim(fault,1)+".csend"
         readf,1,n
         readf,1,tmpv
         csend(*,fault-startfault)=tmpv
         close,1
         openr,1,filedir+"stress_timeseries.flt"+strtrim(fault,1)+".duend"
         readf,1,n
         readf,1,tmpv
         duend(*,fault-startfault)=tmpv/2.0
         close,1
         openr,1,filedir+"stress_timeseries.flt"+strtrim(fault,1)+".dumid"
         readf,1,n
         readf,1,tmpv
         dumid(*,fault-startfault)=tmpv/2.0
         close,1
         openr,1,filedir+"stress_timeseries.flt"+strtrim(fault,1)+".dumean"
         readf,1,n
         readf,1,tmpv
         dumean(*,fault-startfault)=tmpv/2.0
         close,1
      end
                                ;!p.multi=[0,3,nrflt,0]
                                ;!p.multi=[0,2,nrflt,0]
      if dev eq 'PS' then begin
         device,filename=filedir+'coulomb_series.eps',bits_per_pixel=8,$
          xsize=19.5,ysize=10,scale_factor=1.0,/encapsulated
         print,"Printing to",filedir+'coulomb_series.eps'
      end
      

      ymin=0.0 & ymax=0.0
      dufac=50 & dushift= -100

      if(seis)then BEGIN
         msum=dblarr(n)
         mmsum = dblarr(gnrflt, n)
         FOR i=0, n-1 DO BEGIN 
            FOR  j=0,gnrflt-1 DO  BEGIN 
               msum(i) = msum(i)+mo(j, i)
            ENDFOR 
         ENDFOR 
         FOR i=0, gnrflt-1 DO BEGIN 
            mmsum(i, 0) = mo(i, 0)
            FOR j=1, n-1 DO BEGIN 
               mmsum(i, j) = mmsum(i, j-1)+mo(i, j)
            ENDFOR 
         ENDFOR 
         IF(gnrflt LE 4)THEN BEGIN 
            !p.multi=[0,1,gnrflt,0]
            if dev eq 'X' then begin
               window,4 &  wset,4
            endif else begin
               device,filename=filedir+'seis.eps', bits_per_pixel=8,$
                /encapsulated,xsize=19,ysize=5.5*gnrflt, xoffset=10
               print,'Printing to '+filedir+'seis.eps'
            endelse
            
            for i=0,gnrflt-1 do begin
               plot,timeplot,mo(i,*), title="Moment Fault "+strtrim(i+1,1), $
                psym=10,ytitle="Seismisches Moment [A.U.]",xtitle="Zeit ["+string(format='(g5.3)',timescale)+" yr]", $
                xstyle=1, ystyle=1, yrange=[0, max(mo)], $
                xrange=[fixedtimestart, fixedtimestart+fixedtimerange]
            ENDFOR 
            !p.multi=0
            if (dev eq 'PS')then device,/close
            
         ENDIF ELSE BEGIN 
            
            !p.multi=[0,1,0,0]
            IF dev eq 'X' THEN BEGIN 
                  window,4 & wset,4
               ENDIF ELSE BEGIN 
                  IF(5.5*gnrflt GT 29)THEN yss = 29 ELSE yss = gnrflt*5.5
                  device,filename=filedir+'seis.eps', bits_per_pixel=8,$
                   /encapsulated,xsize=19,ysize=yss, xoffset=10
                  print,'Printing to '+filedir+'seis.eps'
               ENDELSE 
               
               plot,timeplot,msum(*), title="Gesamtes seismisches Moment "+strtrim(i+1,1), $
                psym=10,ytitle="Seismisches Moment [Nm]",xtitle="Zeit ["+string(format='(g5.3)',timescale)+" yr]", $
                xstyle=1, ystyle=1, yrange=[0, max(msum)], $
                xrange=[fixedtimestart, fixedtimestart+fixedtimerange]
               !p.multi=0
               if (dev eq 'PS')then device,/close
            END   
         end


         magmin = 10.0 & magmax=1.0
         for i=0,gnrflt-1 do BEGIN
            FOR j=1, n-1 DO BEGIN 
               IF(abs(abs(dumean(j, i))-abs(dumean(j-1, i))) GT 1.0e-08)THEN BEGIN 
                  energy = (abs(sd(i, j))/(2.0*modulmyu))*mo(i, j)
                  
                  print, string(format='(f7.2)', timeplot(j))," ", $
                   string(format='(f9.5)',(alog10(energy)-11.8)/1.5)
                  IF((alog10(energy)-11.8)/1.5 LT magmin)THEN magmin =  (alog10(energy)-11.8)/1.5
                  IF((alog10(energy)-11.8)/1.5 GT magmax)THEN magmax =  (alog10(energy)-11.8)/1.5
               ENDIF  
            ENDFOR   
         ENDFOR 
         print, magmin, magmax
         boxes = 20
         dmag = (magmax-magmin)/double(boxes)
         cnt = intarr(boxes)
         for i=0,gnrflt-1 do BEGIN
            FOR j=1, n-1 DO BEGIN 
               IF(abs(abs(dumean(j, i))-abs(dumean(j-1, i))) GT 1.0e-08)THEN BEGIN 
                  energy = (abs(sd(i, j))/(2.0*modulmyu))*mo(i, j)
                  mag = (alog10(energy)-11.8)/1.5
                  FOR k=1, boxes DO BEGIN
                     IF((mag LT  magmin+double(k)*dmag) AND  (mag GE  magmin+double(k-1)*dmag))$
                      THEN cnt(k-1) = cnt(k-1)+1
                  ENDFOR 
               ENDIF  
            ENDFOR   
         ENDFOR 
         
      ENDFOR 
END 




