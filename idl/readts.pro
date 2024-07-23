;;PRO readts
   close,1, 2, 3

   PI = 3.1415926535
   ;; SOLLEN EPS FILES ERZEUGT WERDEN ?
   pr = 1
   IF(NOT pr)THEN dev='X' ELSE dev='PS'
   set_plot,dev
   
   compare=0 & seis = 1 & pure_stresses=1 &  slip=1

   starttest = 9 & stoptest=10

  
   newstyle=1 &  oldstressdatastyle=0

   ypmadapt = 0
   ypmval = 3.0



   tcsa = 1                     ; Timescale adapt

   nosred = 1

   spacescale = 1000.0          ; Eine FE Einheit entspricht 1000 m

   uprintlimit = 0.01           ; Limit fuer die Ausgabe in der Liste in m, 0.01 = 1cm

   ;;xxmax = max(fltcoord)*2.0
   xxmax = 1000.0               ; Ausdehnung des FE-Gebietes in FE-Einheiten


   FOR  test = starttest, stoptest do begin

      timescale = 1.0           ; Eine FE Zeitschritt entspricht einem Jahr

     

      
      ;;modeldir="/lobe_crack_wo/"
      ;;modeldir="/chain/"+strtrim(test,1) + "/"
      ;;modeldir = "/random/" + strtrim(test,1) + "/"
      ;;modeldir="/arc_faults_again/"+strtrim(test,1)+"/"
      ;;modeldir = "/en_echelon/"+strtrim(test,1)+"/"
      ;;modeldir = "/one_rot/"+strtrim(test, 1)+"/"
      modeldir = "/randarc/"+strtrim(test, 1)+"/"
      ;;modeldir = modeldir+"ondul/"
      ;;modeldir = "/eff_modul/"+strtrim(test, 1)+"/"
      ;;modeldir = "/one_crack/hp1e8/"
      ;;modeldir = "/en_echelon/complicated/"+strtrim(test,1)+"/"
      ;;modeldir = "/anatolian/"+strtrim(test,1)+"/"
      ;;modeldir="random/"+strtrim(test,1)+"/"
      ;;modeldir = "/en_echelon/complicated/"+strtrim(test,1)+"/"
      ;;modeldir = "/"
      filedir = "/home/datdyn2/becker/finel"+modeldir
      ;;filedir="/home/fb12/thbecker/data"+modeldir
      ;;filedir="/home/geodyn1/becker/finel/results/"+modeldir
      ;;filedir="/home/datdyn3/becker/model_data"+modeldir
      
      ptimestart=0
      ;;checkend = 1
      checkend=0 &  ptimeend=994 ; ptimeend muss eins kleiner als fixedtimerange sein
      fixedtimestart = 0 

      if(checkend)then ptimeend= -1

      IF(1)THEN BEGIN 
   

         IF (test  EQ 54)THEN BEGIN 
            ptimeend = 1000
            timescale = 2.0
         ENDIF 
         IF(test EQ 9)THEN ptimeend = 220
         IF(test EQ 10)THEN ptimeend = 200

         IF (test  EQ 55)THEN ptimeend = 550 
         IF (test EQ 57)THEN BEGIN 
            ptimeend = 1000
            timescale = 2.0
         ENDIF 
         ptimeend = ptimeend - 1 
      ENDIF 
      fixedtimerange = ptimeend+1



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
      endif else BEGIN
         spawn,  "gunzip "+filedir+"mesh_constants.gz"
         openr,1,filedir+"mesh_constants"
         readf,1,emodul,nyu
         readf,1,alpha1,deltat,alpha2
         readf,1,nmyu,fmyu,sdmyu
         readf,1,foff,loff,hp
         close,1			
      endelse
      
      modulmyu = emodul/(2.0+2.0*nyu)
      print, "mumodul: ", modulmyu
      openr,1,filedir+"faultcoord"
      readf,1,nrflt
      halflength = dblarr(nrflt)
      fltcoord=dblarr(4,nrflt)
      angle = dblarr(nrflt)
      readf,1,fltcoord
      close,1
      FOR i=0, nrflt-1 DO BEGIN 
         tmp = dblarr(2)
         tmp(0) = fltcoord(2, i)-fltcoord(0, i)
         tmp(1) = fltcoord(3, i)-fltcoord(1, i)
         halflength(i) = betrag(tmp)/2.0
         IF(tmp(0) NE 0.0)THEN angle(0) = (atan(tmp(1), tmp(0))/PI)*180.0 $
         ELSE angle(0) = 90.0
      ENDFOR 

      geofac = xxmax/spacescale
      if(seis)then begin
         openr,1,filedir+"seis"
         readf,1,gnrflt,i,j
         mo=dblarr(gnrflt,j-i+1) & sd=dblarr(gnrflt,j-i+1)
         rupl = dblarr(gnrflt,j-i+1)
         WHILE  not eof(1) do begin
            readf,1,it,flt & readf,1,x1,y1 & readf,1,x2,y2 
            readf,1,rupture_length
            ds=1.0
            if(newstyle)then readf,1,du,ds else readf,1,du
            time= it - i
            ddmm = (rupture_length*spacescale)*15000*(abs(du)*spacescale)*modulmyu
            mo(flt-1,time) = mo(flt-1,time) + ddmm
            sd(flt-1, time) = ds
            rupl(flt-1, time) = rupture_length
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
         spawn, "gunzip "+filedir+"stress_timeseries*"
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
         duend(*,fault-startfault)=tmpv
         close,1
         openr,1,filedir+"stress_timeseries.flt"+strtrim(fault,1)+".dumid"
         readf,1,n
         readf,1,tmpv
         dumid(*,fault-startfault)=tmpv
         close,1
         openr,1,filedir+"stress_timeseries.flt"+strtrim(fault,1)+".dumean"
         readf,1,n
         readf,1,tmpv
         dumean(*,fault-startfault)=tmpv
         close,1

      end
                                ;!p.multi=[0,3,nrflt,0]
                                ;!p.multi=[0,2,nrflt,0]
      if dev eq 'PS' then begin
         device,filename=filedir+'coulomb_series.eps',bits_per_pixel=8,$
          xsize=16,ysize=5.5,scale_factor=1.0,/encapsulated
         print,"Printing to",filedir+'coulomb_series.eps'
      end
      

      ymin=0.0 & ymax=0.0
      dufac=50 & dushift= -100

      ;; COULOMBSPANNUNGEN

      if(0) then begin		; Darstellung in vier untereinanderliegenden Plots
         !p.multi=[0,3,nrflt,0]
         for i=0,nrflt-1 do begin
            if dev eq 'X' then begin
               if (i eq 0)then window,0,xsize=1200,ysize=600
               wset,0
            end
            IF(i EQ 0)THEN BEGIN 
               plot,timeplot*timescale,csmax(ptimestart:ptimeend,i)/1e6,$
                title="!6Max. !7l!6!i1!n-C.-Sp. Flt." + $
                strtrim(i+1,1) + "(" + strtrim(fmyu, 1) + ", " + strtrim(sdmyu, 1) + ")", $
                xtitle="!6time ["+string(format='(g5.3)',timescale)+" yr]",charsize=1.5,xstyle=1, $
                ytitle="!6Spannung [MPa]",yrange=[1.1*ymin,1.1*ymax],ystyle=1, $
                range=[fixedtimestart, fixedtimestart+fixedtimerange]
               oplot,timeplot*timescale,csmax(ptimestart:ptimeend,i)/1e6,psym=7,symsize=0.25
               oplot,timeplot*timescale,abs(dumean(ptimestart:ptimeend,i))*dufac+dushift
               plot,timeplot*timescale,csend(ptimestart:ptimeend,i)/1e6,title="!7l!6!i1!n-C.-Sp. fault"+$
                strtrim(i+1,1)+" Ende",charsize=1.5, xstyle=1, $
                range=[fixedtimestart, fixedtimestart+fixedtimerange]
               oplot,timeplot*timescale,abs(duend(ptimestart:ptimeend,i))*dufac+dushift
               plot,timeplot*timescale,csmid(ptimestart:ptimeend,i)/1e6,title="!7l!6!i1!n-C.-Sp. fault"+$
                 strtrim(i+1,1)+" Mitte",charsize=1.5,$
                 psym=7,symsize=0.25,ytitle="!6Spannung [MPa]",$
                 xtitle="!6time ["+string(format='(g5.3)',timescale)+" yr]", xstyle=1, $
                range=[fixedtimestart, fixedtimestart+fixedtimerange]
               oplot,timeplot*timescale,csmid(ptimestart:ptimeend,i)/1e6
               oplot,timeplot*timescale,abs(dumid(ptimestart:ptimeend,i))*dufac+dushift
            ENDIF ELSE BEGIN 
               plot,timeplot*timescale,csmax(ptimestart:ptimeend,i)/1e6,$
                title="Flt." + $
                strtrim(i+1,1) + "(" + strtrim(fmyu, 1) + ", " + strtrim(sdmyu, 1) + ")", $
                xtitle="!6time ["+string(format='(g5.3)',timescale)+" yr]",charsize=1.5,xstyle=1, $
                ytitle="!6Spannung [MPa]",yrange=[1.1*ymin,1.1*ymax],ystyle=1, $
                range=[fixedtimestart, fixedtimestart+fixedtimerange]
               oplot,timeplot*timescale,csmax(ptimestart:ptimeend,i)/1e6,psym=7,symsize=0.25
               oplot,timeplot*timescale,abs(dumean(ptimestart:ptimeend,i))*dufac+dushift
               plot,timeplot*timescale,csend(ptimestart:ptimeend,i)/1e6,title="Fault"+$
                strtrim(i+1,1)+" Ende",charsize=1.5, xstyle=1, $
                range=[fixedtimestart, fixedtimestart+fixedtimerange]
               oplot,timeplot*timescale,abs(duend(ptimestart:ptimeend,i))*dufac+dushift
               plot,timeplot*timescale,csmid(ptimestart:ptimeend,i)/1e6,title="fault"+$
                strtrim(i+1,1)+" Mitte",charsize=1.5,$
                psym=7,symsize=0.25,ytitle="!6Spannung [MPa]",xtitle="!6time ["+string(format='(g5.3)',timescale)+" yr]", xstyle=1, $
                range=[fixedtimestart, fixedtimestart+fixedtimerange]
               oplot,timeplot*timescale,csmid(ptimestart:ptimeend,i)/1e6
               oplot,timeplot*timescale,abs(dumid(ptimestart:ptimeend,i))*dufac+dushift
            ENDELSE 

         end
      endif else begin          ; Darstellung in einem Plot
         if dev eq 'X' then begin
            window,0
            wset,0
         end
         !p.multi=0
         symbolsize = 0.25
         yminimum=min(csmid(ptimestart:ptimeend,0)/1e6)
         if (nrflt gt 1) then begin
            for k=1,nrflt-1 do begin
               if((min(csmid(ptimestart:ptimeend,k))/1e6) lt yminimum) then $
                yminimum = min(csmid(ptimestart:ptimeend,k))/1e6
            end
         end
         plot,timeplot*timescale, csmedian(ptimestart:ptimeend,0)/1e6,psym=4,$
          ;;title="Mittlere !7l!6!i1!n-Coulomb-Spannung (!7l!6!i1!n: "+string(format='(g4.2)',fmyu)+$
          ;;", !7l!6!i2!n: "+string(format='(g4.2)',sdmyu)+")", $
          xtitle="!6time [yr]",ytitle="Spannung [MPa]",yrange=[yminimum,0], xstyle=1, $
          xrange=[fixedtimestart, fixedtimestart+fixedtimerange], symsize=symbolsize, ycharsize=1.25
         oplot,timeplot*timescale,csmedian(ptimestart:ptimeend,0)/1e6,linestyle=0
         if (nrflt gt 1) then begin
            oplot,timeplot*timescale,csmid(ptimestart:ptimeend,1)/1e6,psym=5, symsize=symbolsize ;,color=200
            oplot,timeplot*timescale,csmid(ptimestart:ptimeend,1)/1e6,linestyle=1 ;,color=200
         end
         if(nrflt gt 2)then begin
            oplot,timeplot*timescale,csmid(ptimestart:ptimeend,2)/1e6,psym=6, symsize=symbolsize
            oplot,timeplot*timescale,csmid(ptimestart:ptimeend,2)/1e6,linestyle=2
         end
         if(nrflt gt 3)then begin
            oplot,timeplot*timescale,csmid(ptimestart:ptimeend,3)/1e6,psym=1, symsize=symbolsize
            oplot,timeplot*timescale,csmid(ptimestart:ptimeend,3)/1e6,linestyle=3
         end
         if(nrflt gt 4)then begin
            oplot,timeplot*timescale,csmid(ptimestart:ptimeend,4)/1e6,psym=2, symsize=symbolsize
            oplot,timeplot*timescale,csmid(ptimestart:ptimeend,4)/1e6,linestyle=4
         end
         if(nrflt gt 5)then begin
            oplot,timeplot*timescale,csmid(ptimestart:ptimeend,4)/1e6,psym=3, symsize=symbolsize
            oplot,timeplot*timescale,csmid(ptimestart:ptimeend,4)/1e6,linestyle=5
         end
         if(nrflt gt 6)then begin
            oplot,timeplot*timescale,csmid(ptimestart:ptimeend,4)/1e6,psym=4, symsize=symbolsize
            oplot,timeplot*timescale,csmid(ptimestart:ptimeend,4)/1e6,linestyle=6
         end
         for j=0,nrflt-1 do BEGIN
            tmps = size(csmid)
                                ;IF(tmps(1) GT 10)THEN $
                                ;xyouts,10+j*5,csmid(10+j*2,j)/1e6,strtrim(j+1,1),charsize=2.0 ELSE $
                                ;xyouts,j*5,csmid(j*2,j)/1e6,strtrim(j+1,1)
         end

      end


      if dev eq 'PS' then device,/close

      ;; AUSDRUCK DER GEOMETRIE DER VERWERFUNGEN

      !p.multi=0

      
      if dev eq 'X' then begin
         if (test eq starttest)then window,1,xsize=400,ysize=400
         ;;if (test eq starttest)then window,1,xsize=900,ysize=900
         wset,1
      endif else begin
         device,filename=filedir+'geometry.eps', bits_per_pixel=8,$
          /encapsulated,xsize=10,ysize=10,scale_factor=1.0
         print,'Printing to'+filedir+'geometry.eps'
      end
      if(compare)then begin
         plot,fltcoord(0,*)/geofac,xrange=[-0.1*xxmax/geofac,1.1*xxmax/geofac],$
          yrange=[-0.1*xxmax/geofac,1.1*xxmax/geofac],$
          xstyle=1,ystyle=1,/nodata,title="!7Dr!i!6C!n(Hauptriss)",$
          xtitle="x["+string(format='(g4.2)',(spacescale*geofac)/xxmax)+" km]",$
          ytitle="y["+string(format='(g4.2)',(spacescale*geofac)/xxmax)+" km]",$
          xcharsize=0.75,ycharsize=0.75
      endif else begin
         plot,fltcoord(0,*)/geofac,xrange=[-0.1*xxmax/geofac,1.1*xxmax/geofac],$
          yrange=[-0.1*xxmax/geofac,1.1*xxmax/geofac],$
          xstyle=1,ystyle=1,/nodata,$
          xtitle="x["+string(format='(g4.2)',(spacescale*geofac)/xxmax)+" km]",$
          ytitle="y["+string(format='(g4.2)',(spacescale*geofac)/xxmax)+" km]",$
          xcharsize=0.75,ycharsize=0.75
      endelse
      polyfill,[0,xxmax/geofac,xxmax/geofac,0],[0,0,xxmax/geofac,xxmax/geofac],color=254
      ;xyouts,50/geofac,50/geofac,modeldir,charsize=0.5,color=1
      for i=0,nrflt-1 do begin
         print,i+1,':'
         print,fltcoord(*,i)/geofac
         plots,fltcoord(0,i)/geofac,fltcoord(1,i)/geofac
         plots,fltcoord(2,i)/geofac,fltcoord(3,i)/geofac,/continue,color=1,thick=4.0
         IF(nrflt LE 5)THEN xyouts,((fltcoord(0,i) + fltcoord(2,i))/2.0+20)/geofac,$
           ((fltcoord(1,i) + fltcoord(3,i))/2.0+20)/geofac,strtrim(i+1,1),color=1
         
         IF(nrflt LE 3)THEN xyouts,0/geofac,(900-80*i)/geofac,"a("+strtrim(i+1,2)+"): "+$
           string(format='(g4.2)',halflength(i)/geofac)+" km",color=1,$
           charsize=0.75
         if (compare)then begin
            contour,smooth(cs,2),clbx,clby,levels=[0],/follow,/overplot,color=1
         end
      end
      if dev eq 'PS' then device,/close

      ;;
      ;; AUSDRUCK DER NORMAL UND SCHERSPANNUNGEN 
      ;;
      
      if(pure_stresses)then begin

         ;; normalspannung

         if dev eq 'X' then begin	
            if (test eq starttest)then window,3
            wset,3
         endif else begin
            device,filename=filedir+'nos.eps', bits_per_pixel=8,$
             /encapsulated,xsize=16,ysize=5.5*nrflt,scale_factor=1.0
            print,'Printing to '+filedir+'nos.eps'
         end
         !p.multi=[0,1,nrflt,0]
         IF(nrflt LT 5)THEN BEGIN 
            for i=startfault,stopfault do begin
               IF(tcsa)THEN BEGIN 
                  IF(i EQ startfault)THEN BEGIN 
                     IF(nosred)THEN BEGIN 
                        meann = fix(mittelwert((nosmedian(ptimestart:ptimeend,i-1)+hp)/1e6)) 
                        plot,timeplot*timescale,(nosmedian(ptimestart:ptimeend,i-1)+hp)/1e6-meann,$
                          title="Mittlere Normalspannung Fault "+strtrim(i,1)+" red. um"+strtrim(meann, 1)+"MPa", xstyle=1,  $
                          ytitle="!6Spannung [MPa]",xtitle="!6time [yr]", $
                          xrange=[fixedtimestart*timescale, (fixedtimestart+fixedtimerange)*timescale]
                     ENDIF ELSE BEGIN 
                        plot,timeplot*timescale,(nosmedian(ptimestart:ptimeend,i-1)+hp)/1e6,$
                          title="Mittlere Normalspannung Fault"+strtrim(i,1), xstyle=1,  $
                          ytitle="!6Spannung [MPa]",xtitle="!6time [yr]", $
                          xrange=[fixedtimestart*timescale, (fixedtimestart+fixedtimerange)*timescale]
                     ENDELSE 
                  ENDIF ELSE BEGIN   
                     plot,timeplot*timescale,(nosmedian(ptimestart:ptimeend,i-1)+hp)/1e6,$
                       title="fault "+strtrim(i,1), xstyle=1,  $
                       ytitle="!6Spannung [MPa]",xtitle="!6time [yr]", $
                       xrange=[fixedtimestart*timescale, (fixedtimestart+fixedtimerange)*timescale]
                  ENDELSE   
               ENDIF ELSE BEGIN 
                  IF(i EQ startfault)THEN BEGIN 
                     IF(nosred)THEN BEGIN 
                        meann = fix(mittelwert((nosmedian(ptimestart:ptimeend,i-1)+hp)/1e6)) 
                        plot,timeplot,(nosmedian(ptimestart:ptimeend,i-1)+hp)/1e6-meann,$
                          title="Mittlere Normalspannung Fault "+strtrim(i,1)+" red. um"+strtrim(meann, 1)+"MPa", xstyle=1,  $
                          ytitle="!6Spannung [MPa]",xtitle="!6time ["+string(format='(g5.3)',timescale)+" yr]", $
                          xrange=[fixedtimestart, fixedtimestart+fixedtimerange]
                     ENDIF ELSE BEGIN 
                        plot,timeplot,(nosmedian(ptimestart:ptimeend,i-1)+hp)/1e6,$
                          title="Mittlere Normalspannung Fault"+strtrim(i,1), xstyle=1,  $
                          ytitle="!6Spannung [MPa]",xtitle="!6time ["+string(format='(g5.3)',timescale)+" yr]", $
                          xrange=[fixedtimestart, fixedtimestart+fixedtimerange]
                     ENDELSE 
                  ENDIF ELSE BEGIN   
                     plot,timeplot,(nosmedian(ptimestart:ptimeend,i-1)+hp)/1e6,$
                       title="fault "+strtrim(i,1), xstyle=1,  $
                       ytitle="!6Spannung [MPa]",xtitle="!6time ["+string(format='(g5.3)',timescale)+" yr]", $
                       xrange=[fixedtimestart, fixedtimestart+fixedtimerange]
                  ENDELSE   
               ENDELSE 
            END
            if dev eq 'PS' then device,/close
            ;; scherspannung

            if dev eq 'X' then begin	
               if (test eq starttest)then window,4
               wset,4
            endif else begin
               device,filename=filedir+'tau.eps', bits_per_pixel=8,$
                 /encapsulated,xsize=16,ysize=5.5*nrflt,scale_factor=1.0
               print,'Printing to '+filedir+'tau.eps'
            END
            !p.multi=[0,1,nrflt,0]
            IF(nrflt LT 5)THEN BEGIN 
               for i=startfault,stopfault do begin
                  IF(i EQ startfault)THEN BEGIN 
                     deltatau=(max(taumedian(1:n-2,i-1)) - min(taumedian(1:n-2,i-1)))/1e6
                     IF(tcsa)THEN $
                       plot,timeplot*timescale,(taumedian(ptimestart:ptimeend,i-1))/1e6,$
                       ytitle="!6Spannung [MPa]",xtitle="!6time [yr]", xstyle=1, $
                       title="mean shear Spannung fault "+strtrim(i,1), $
                       xrange=[fixedtimestart*timescale, (fixedtimestart+fixedtimerange)*timescale] $
                     ELSE $
                       plot,timeplot,(taumedian(ptimestart:ptimeend,i-1))/1e6,$
                       title="mean shear Spannung fault "+strtrim(i,1), $
                       ytitle="!6Spannung [MPa]",xtitle="!6time ["+string(format='(g5.3)',timescale)+" yr]", xstyle=1, $
                       xrange=[fixedtimestart, fixedtimestart+fixedtimerange]
                  ENDIF ELSE BEGIN 
                     deltatau=(max(taumedian(1:n-2,i-1)) - min(taumedian(1:n-2,i-1)))/1e6
                     IF(tcsa) THEN $
                       plot,timeplot*timescale,(taumedian(ptimestart:ptimeend,i-1))/1e6,$
                       title="fault "+strtrim(i,1), $
                       ytitle="!6Spannung [MPa]",xtitle="!6time [yr]", xstyle=1, $
                       xrange=[fixedtimestart*timescale, (fixedtimestart+fixedtimerange)*timescale] $
                     ELSE $
                       plot,timeplot,(taumedian(ptimestart:ptimeend,i-1))/1e6,$
                       title="fault "+strtrim(i,1), $
                       ytitle="!6Spannung [MPa]",xtitle="!6time ["+string(format='(g5.3)',timescale)+" yr]", xstyle=1, $
                       xrange=[fixedtimestart, fixedtimestart+fixedtimerange]
                  ENDELSE 
               ENDFOR  
            END 
            if dev eq 'PS' then device,/close
         ENDIF ELSE BEGIN  
            if dev eq 'X' then begin	
               if (test eq starttest)then window,3
               wset,3
            endif else BEGIN
               yss = 5.0*nrflt
               IF(yss GT 29)THEN yss=29
               device,filename=filedir+'nos.eps', bits_per_pixel=8,$
                 /encapsulated,xsize=16,ysize=yss,scale_factor=1.0
               print,'Printing to '+filedir+'nos.eps'
            end
            !p.multi=[0,1,1,0]
            mnmin = min(nosmedian(ptimestart:ptimeend,*)+hp)/1e6
            mnmax = max(nosmedian(ptimestart:ptimeend,*)+hp)/1e6
            msmin = min(taumedian(ptimestart:ptimeend,*))/1e6
            msmax = max(taumedian(ptimestart:ptimeend,*))/1e6
            
            for i=startfault,stopfault do begin
               IF(i EQ startfault)THEN BEGIN 
                  plot,timeplot,(nosmedian(ptimestart:ptimeend,i-1)+hp)/1e6,$
                   title="<N-Sp.> ", xstyle=1,  $
                   ytitle="!6Spannung [MPa]",xtitle="!6time ["+string(format='(g5.3)',timescale)+" yr]", $
                   xrange=[fixedtimestart, fixedtimestart+fixedtimerange], $
                   yrange=[mnmin, mnmax]
                  xyouts, timeplot(ptimeend-5), (nosmedian(ptimeend-5,i-1)+hp)/1e6,strtrim(i, 1)
               ENDIF ELSE BEGIN 
                  oplot,timeplot,(nosmedian(ptimestart:ptimeend,i-1)+hp)/1e6
                                ;xyouts, timeplot(ptimeend-5-i*5), (nosmedian(ptimeend-5-i*5,i-1)+hp)/1e6,strtrim(i, 1)
               ENDELSE 
               
            ENDFOR
 
            if dev eq 'PS' then device,/close

            if dev eq 'X' then begin	
               if (test eq starttest)then window,4
               wset,4
            endif else BEGIN
               yss = 5.0*nrflt
               IF(yss GT 29)THEN yss=29
               device,filename=filedir+'tau.eps', bits_per_pixel=8,$
                 /encapsulated,xsize=16,ysize=yss,scale_factor=1.0
               print,'Printing to '+filedir+'tau.eps'
            end
            !p.multi=[0,1,1,0]
            mnmin = min(nosmedian(ptimestart:ptimeend,*)+hp)/1e6
            mnmax = max(nosmedian(ptimestart:ptimeend,*)+hp)/1e6
            msmin = min(taumedian(ptimestart:ptimeend,*))/1e6
            msmax = max(taumedian(ptimestart:ptimeend,*))/1e6
            
            for i=startfault,stopfault do begin
               plot,timeplot,(taumedian(ptimestart:ptimeend,i-1)+hp)/1e6,$
                 title="Scherspannung ", xstyle=1,  $
                 ytitle="!6Spannung [MPa]",$
                 xtitle="!6time ["+string(format='(g5.3)',timescale)+" yr]", $
                 xrange=[fixedtimestart, fixedtimestart+fixedtimerange], $
                 yrange=[mnmin, mnmax]
            ENDFOR 
            if dev eq 'PS' then device,/close
            
         ENDELSE 
      END   

      ;;
      ;;    AUSDRUCK DER SEISMISCHEN MOMENTE 
      ;;
      

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
         mfac = 1e20
         IF(gnrflt LE 4)THEN BEGIN 
            !p.multi=[0,1,gnrflt,0]
            if dev eq 'X' then begin
               window,5 &  wset,5
            endif else begin
               device,filename=filedir+'seis.eps', bits_per_pixel=8,$
                /encapsulated,xsize=22,ysize=nrflt*7.0;;, xoffset=10
               print,'Printing to '+filedir+'seis.eps'
            ENDELSE
            IF(ypmadapt)THEN $
              yplotmax = max(mo)/Mfac $
            ELSE $
              yplotmax = ypmval
            !x.charsize = 2.0
            !y.charsize = 2.0
            charsize = 2.0
            FOR  i=0,gnrflt-1 DO  BEGIN 
               IF(i EQ 0)THEN BEGIN 
                  IF(tcsa)THEN BEGIN 
                     plot,timeplot*timescale,mo(i,*)/Mfac, $
                       psym=10,ytitle="M!i0!n [10!e20!nNm]",$
                       title="fault "+strtrim(i+1,1), $
                       xstyle=1, ystyle=1, yrange=[0, yplotmax], $
                       xrange=[fixedtimestart*timescale, (fixedtimestart+fixedtimerange)*timescale] 
                  ENDIF ELSE BEGIN 
                     plot,timeplot,mo(i,*)/Mfac, title="seismic moment fault "+strtrim(i+1,1), $
                       psym=10,ytitle="M!i0!n [10!e20!nNm]",$
                       ;;xtitle="!6time ["+string(format='(g4.2)',timescale)+" yr]", $
                     xtitle="", $
                       xstyle=1, ystyle=1, yrange=[0, yplotmax], $
                       xrange=[fixedtimestart, fixedtimestart+fixedtimerange] 
                  ENDELSE   
               ENDIF ELSE BEGIN 
                  IF(i EQ gnrflt-1) THEN BEGIN 
                     IF(tcsa)THEN BEGIN 
                        ;;plot,timeplot*timescale,mo(i,*)/Mfac,
                        ;;title="seismic moment fault "+strtrim(i+1,1), $
                        plot,timeplot*timescale,mo(i,*)/Mfac, $
                          psym=10,ytitle="M!i0!n [10!e20!nNm]",title="fault "+strtrim(i+1,1), $
                          xtitle="!6time [yr]", $
                          xstyle=1, ystyle=1, yrange=[0, yplotmax], $
                          xrange=[fixedtimestart*timescale, (fixedtimestart+fixedtimerange)*timescale] 
                     ENDIF  ELSE BEGIN 
                        plot,timeplot,mo(i,*)/Mfac, title="seismic moment fault "+strtrim(i+1,1), $
                          psym=10,ytitle="M!i0!n [10!e20!nNm]", $
                          xtitle="!6time ["+string(format='(g4.2)',timescale)+" yr]", $
                          xstyle=1, ystyle=1, yrange=[0, yplotmax], $
                          xrange=[fixedtimestart, fixedtimestart+fixedtimerange] 
                     ENDELSE 
                  ENDIF ELSE BEGIN 
                  
                     IF(tcsa)THEN $
                       plot,timeplot*timescale,mo(i,*)/Mfac, title="fault "+strtrim(i+1,1), $
                       psym=10,ytitle="M!i0!n [10!e20!nNm]", $
                       ;;xtitle="!6time [yr]", $
                     xtitle = "", $
                       xstyle=1, ystyle=1, yrange=[0, yplotmax], $
                       xrange=[fixedtimestart*timescale, (fixedtimestart+fixedtimerange)*timescale] $
                     ELSE $
                       plot,timeplot,mo(i,*)/Mfac, title="fault "+strtrim(i+1,1), $
                       psym=10,ytitle="M!i0!n [10!e20!nNm]", $
                       xtitle="!6time ["+string(format='(g5.3)',timescale)+" yr]", $
                       xstyle=1, ystyle=1, yrange=[0, yplotmax], $
                       xrange=[fixedtimestart, fixedtimestart+fixedtimerange]
                  ENDELSE  
               ENDELSE 
            ENDFOR 
            !p.multi=0
            if (dev eq 'PS')then device,/close
            
         ENDIF ELSE BEGIN 
            
            !p.multi=[0,1,0,0]
            IF dev eq 'X' THEN BEGIN 
               window,4 & wset,4
            ENDIF ELSE BEGIN 
               ;IF(5.5*gnrflt GT 29)THEN yss = 29 ELSE yss = gnrflt*5.5
               yss = 12.5
               device,filename=filedir+'seis.eps', bits_per_pixel=8,$
                /encapsulated,xsize=16,ysize=yss, xoffset=10
               print,'Printing to '+filedir+'seis.eps'
            ENDELSE 
            IF(tcsa)THEN $
              plot,timeplot*timescale,msum(0:ptimeend)/Mfac, title="total seismic moment", $
              psym=10,ytitle="M!i0!n [10!e20!nNm]",xtitle="!6time ["+string(format='(g5.3)',timescale)+" yr]", $
              xstyle=1, ystyle=1, yrange=[0, max(msum)/Mfac], ycharsize=1.0, $
              xrange=[fixedtimestart, fixedtimestart+fixedtimerange] $
            ELSE $
              plot,timeplot,msum(0:ptimeend)/Mfac, title="total seismic moment", $
              psym=10,ytitle="M!i0!n [10!e20!nNm]",xtitle="!6time [yr]", $
              xstyle=1, ystyle=1, yrange=[0, max(msum)/Mfac], $
              xrange=[fixedtimestart*timescale, (fixedtimestart+fixedtimerange)*timescale] 
            !p.multi=0
            if (dev eq 'PS')then device,/close
         END   
      end
      

      ;;
      ;;    AUSDRUCK DES KUMULATIVEN VERSATZES UND DER DATENLISTE
      ;;

      
      IF(slip)THEN BEGIN 
         slipfactor = 1000
         IF(gnrflt LT 5)THEN $
          !p.multi = [0,1,gnrflt,0] ELSE $
          !p.multi = [0, 1, 1, 0]
         gss = 5.5*gnrflt
         if gss GT 29 THEN gss = 25 
         if dev eq 'X' then begin
            window,5 &  wset,5
         endif else begin
            device,filename=filedir+'slip.eps', bits_per_pixel=8,$
             /encapsulated,xsize=19,ysize=gss, xoffset=10
            print,'Printing to '+filedir+'slip.eps'
         endelse
         openw, 3, filedir+"dudata.tex"
         openw, 5, filedir+"dudata.txt"
         lenn = size(dumean)
         lenn = lenn(1)
         for i=0,gnrflt-1 do BEGIN
            IF(i EQ 0)THEN BEGIN 
               ;; DATENAUSGABE FUER EINEN EINZELNEN FAULT
               IF(gnrflt LT 5)THEN BEGIN 
                  IF(tcsa)THEN $
                    plot,timeplot*timescale,abs(dumean(ptimestart:ptimeend, i))*slipfactor, $
                    title="cumulative slip fault "+strtrim(i+1,1), $
                    psym=10,ytitle="Mittlerer Versatz ["+$
                    string(format='(g4.2)', (spacescale/slipfactor))+" m]",$
                    xtitle="!6time [yr]", $
                    xstyle=1, ystyle=1, yrange=[0, max(abs(dumean)*slipfactor)], $
                    xrange=[fixedtimestart*timescale, (fixedtimestart+fixedtimerange)*timescale]  $
                  ELSE $
                    plot,timeplot,abs(dumean(ptimestart:ptimeend, i))*slipfactor, $
                    title="cumulative slip fault "+strtrim(i+1,1), $
                    psym=10,ytitle="Mittlerer Versatz ["+$
                    string(format='(g4.2)', (spacescale/slipfactor))+" m]",$
                    xtitle="!6time ["+string(format='(g5.3)',timescale)+" yr]", $
                    xstyle=1, ystyle=1, yrange=[0, max(abs(dumean)*slipfactor)], $
                    xrange=[fixedtimestart, fixedtimestart+fixedtimerange]
               ENDIF ELSE BEGIN 
                  IF(pr)THEN cl = 0 ELSE cl = 10*i+10
                  IF(tcsa)THEN $
                    plot,timeplot*timescale,abs(dumean(ptimestart:ptimeend, i))*slipfactor, $
                    title="cumulative slip", $
                    psym=10,ytitle="Mittlerer Versatz ["+string(format='(g4.2)',$
                                                                (spacescale/slipfactor))+" m]",$
                    xtitle="!6time [yr]", $
                    xstyle=1, ystyle=1, yrange=[0, max(abs(dumean)*slipfactor)], $
                    xrange=[fixedtimestart*timescale, (fixedtimestart+fixedtimerange)*timescale] , color=cl $
                  ELSE $
                     plot,timeplot,abs(dumean(ptimestart:ptimeend, i))*slipfactor, $
                    title="cumulative slip", $
                    psym=10,ytitle="Mittlerer Versatz ["+string(format='(g4.2)',$
                                                                (spacescale/slipfactor))+" m]",$
                    xtitle="!6time ["+string(format='(g5.3)',timescale)+" yr]", $
                    xstyle=1, ystyle=1, yrange=[0, max(abs(dumean)*slipfactor)], $
                    xrange=[fixedtimestart, fixedtimestart+fixedtimerange] , color=cl

               ENDELSE 
               
               dmu = 0.0 & count=0 &  midmag=0.0 &  dt=0
               
               print, "fault "+strtrim(i+1, 1)+$
                " time $\Delta u$ $M_0$ $\Delta \sigma$ $L/2a$ $\bar \sigma_{n}$ $E_S$ $M_S^{4.28}$ $M_S^{4.26}$ \\" 
               printf, 3, "Fault angle: ", angle(i)
               printf, 5, "Fault angle: ", angle(i)

               printf, 3, "\begin{tabular}{ccccccccc}"
               printf, 3, "fault "+strtrim(i+1, 1)+ $
                 "$t[yr]$ & $\Delta u[m]$ & $M_0[10^19Nm]$ & $\Delta \sigma [MPa]$ & $\frac{L}{2a}$ &"+ $
                 "$\bar \sigma_{n}[MPa]$ & $E_s[10^{15}J]$ & $M_S^{\gref{4.28}}$ & $M_S^{\gref{4.26}}$ \\"
               esum = 0.0
               FOR j=1, ptimeend DO BEGIN 
                  IF(abs(abs(dumean(j, i))-abs(dumean(j-1, i)))*spacescale GE uprintlimit)THEN BEGIN 
                     uslip = (abs(dumean(j, i)) - abs(dumean(j-1, i)))*spacescale
                     tmpmag = (alog10(mo(i, j))-9.1)/1.5
                     energy = (abs(sd(i, j))/(2.0*modulmyu))*mo(i, j)
                     esum =  esum + energy
                     IF(uslip GE 0.01)THEN BEGIN 
                        dmu =    dmu + uslip
                        midmag = midmag + tmpmag
                        count = count + 1
                     ENDIF 
                     print, string(format='(f7.2)', timeplot(j)*timescale)," ", $
                       string(format='(f9.6)',uslip), $
                       string(format='(e10.3)', mo(i, j)), $
                       string(format='(e10.3)',abs(sd(i, j))),$
                       string(format='(f7.4)',abs(rupl(i, j))/(2.0*halflength(i))),$
                       string(format='(f10.2)', nosmedian(j, i)),$
                       string(format='(e10.3)',energy),$
                       string(format='(g6.3)',(alog10(energy)-4.8)/1.5),$
                       string(format='(g6.3)',tmpmag)
                     printf,5, string(format='(f7.2)', timeplot(j)*timescale)," ", $
                       string(format='(f9.6)',uslip), $
                       string(format='(e10.3)', mo(i, j)), $
                       string(format='(e10.3)',abs(sd(i, j))),$
                       string(format='(f7.4)',abs(rupl(i, j))/(2.0*halflength(i))),$
                       string(format='(f10.2)', nosmedian(j, i)),$
                       string(format='(e10.3)',energy),$
                       string(format='(g6.3)',(alog10(energy)-4.8)/1.5),$
                       string(format='(g6.3)',tmpmag)

                     printf,3, string(format='(i4)', timeplot(j)*timescale)," &", $
                       string(format='(f8.2)',uslip),  " &",$
                       string(format='(f8.2)', mo(i, j)/1.0e19)," & ", $
                       string(format='(f8.2)',abs(sd(i, j))/1.0e6)," &", $
                       string(format='(f8.2)',abs(rupl(i, j))/(2.0*halflength(i)))," &",$
                       string(format='(f8.2)', nosmedian(j, i)/1.0e6)," &",$
                       string(format='(f8.2)',energy/1.0e15 )," &",$
                       string(format='(g6.3)',(alog10(energy)-4.8)/1.5), " &",$
                       string(format='(g6.3)',tmpmag), "\\"
                  ENDIF 
               ENDFOR 
               printf, 3, "\end{tabular}"
               IF(count NE 0)THEN BEGIN 
                  print, "im Mittel :", dmu/double(count)
                  print, "mittlere Magnitude nach (4.26):", midmag/double(count), "\\"
                  print, "gesamte Energie: ", esum
                  print, "kumulativer Slip bei"

                  printf,3, "im Mittel :", dmu/double(count), "\\"
                  printf, 3, "mittlere Magnitude (4.26):", midmag/double(count), "\\"
                  printf, 3, "gesamte Energie: ", esum
                  printf,3, "kumulativer Slip bei\\"

               ENDIF 
               
               FOR j=0, ptimeend DO BEGIN 
                  IF((double(timeplot(j))/(50/timescale))EQ(fix(timeplot(j)/(50/timescale))))THEN BEGIN 
                     print, "time: "+strtrim(timeplot(j)*timescale)+$
                       " Gesamtes u:"+string(abs(dumean(j, i))*spacescale)+$
                       "  Ges.\ Mo:"+string(mmsum(i, j))+"\\"
                     printf,3, "time: "+strtrim(timeplot(j)*timescale)+$
                       " Gesamtes u:"+string(abs(dumean(j, i))*spacescale)+$
                       "  Ges.\ Mo:"+string(mmsum(i, j))+"\\"
                  ENDIF 
               ENDFOR 
            ENDIF ELSE BEGIN

               ;; DATENAUSGABE BEI MEHREREN FAULTS

               print
               printf, 3
               IF(gnrflt LT 5)THEN BEGIN 
                  plot,timeplot,abs(dumean(ptimestart:ptimeend, i))*slipfactor, $
                    title="fault "+strtrim(i+1,1), $
                    psym=10,ytitle="Mittlerer Versatz ["+strtrim(spacescale/slipfactor, 1)+" m]",$
                    xtitle="time ["+string(format='(g5.3)',timescale)+" yr]", $
                    xstyle=1, ystyle=1, yrange=[0, max(abs(dumean*slipfactor))], $
                    xrange=[fixedtimestart, fixedtimestart+fixedtimerange] 
               ENDIF ELSE BEGIN 
                  IF(pr)THEN cl = 0 ELSE cl = 10*i+10
                  oplot,timeplot,abs(dumean(ptimestart:ptimeend, i))*slipfactor, psym=10, color=cl
                  
                  ;xyouts, timeplot(lenn-10-i*5), abs(dumean(lenn-10-i*5, i))*slipfactor, i+1,$
                    color=cl
               ENDELSE  
               
               dmu = 0.0 & count=0 & midmag=0.0
               printf, 3, "\begin{tabular}{ccccccccc}"
               print, "fault "+strtrim(i+1, 1)+$
                " time $\Delta u$ $M_0$ $\Delta \sigma$ $E_S$ $M_S^{4.28}$ $M_S^{4.26}$\\"
               printf, 3, "fault "+strtrim(i+1, 1)+ $
                "$t[yr]$ & $\Delta u[m]$ & $M_0[10^19Nm]$ & $\Delta \sigma [MPa]$ & $\frac{L}{2a}$ &"+ $
                 "$\bar \sigma_{n}[MPa]$ & $E_s[10^{15}J]$ & $M_S^{\gref{4.28}}$ & $M_S^{\gref{4.26}}$ \\"
               esum = 0.0
               FOR j=1, ptimeend DO BEGIN 
                  IF(abs(abs(dumean(j, i)) - abs(dumean(j-1, i)))*spacescale GE uprintlimit) THEN BEGIN 
                     uslip = (abs(dumean(j, i)) - abs(dumean(j-1, i)))*spacescale
                     tmpmag = (alog10(mo(i, j))-9.1)/1.5
                     energy = (abs(sd(i, j))/(2.0*modulmyu))*mo(i, j)
                     esum = esum+energy
                     IF(uslip GE 0.01)THEN BEGIN 
                        dmu = dmu + uslip
                        count = count + 1
                        midmag = midmag + tmpmag
                     ENDIF 
                     
                     print, string(format='(f7.2)', timeplot(j)*timescale)," ", $
                       string(format='(f9.6)',uslip), $
                       string(format='(e10.3)', mo(i, j)), $
                       string(format='(e10.3)',abs(sd(i, j))),$
                       string(format='(e10.3)',energy ),$
                       string(format='(g6.3)',(alog10(energy)-4.8)/1.5),$
                       string(format='(g6.3)',tmpmag), string(format='(g6.3)',tmpmag)
         
                     printf, 5, string(format='(f7.2)', timeplot(j)*timescale)," ", $
                       string(format='(f9.6)',uslip), $
                       string(format='(e10.3)', mo(i, j)), $
                       string(format='(e10.3)',abs(sd(i, j))),$
                       string(format='(e10.3)',energy ),$
                       string(format='(g6.3)',(alog10(energy)-4.8)/1.5),$
                       string(format='(g6.3)',tmpmag), string(format='(g6.3)',tmpmag)

                     printf,3, string(format='(i4)', timeplot(j)*timescale)," &", $
                       string(format='(f8.2)',uslip),  " &",$
                       string(format='(f8.2)', mo(i, j)/1.0e19)," & ", $
                       string(format='(f8.2)',abs(sd(i, j))/1.0e6)," &",$
                       string(format='(f8.2)',abs(rupl(i, j))/(2.0*halflength(i)))," &",$
                       string(format='(f8.2)', (nosmedian(j, i)/1.0e6))," &",$
                       string(format='(f8.2)',energy/1.0e15 )," &",$
                       string(format='(g6.3)',(alog10(energy)-4.8)/1.5), " &",$
                       string(format='(g6.3)',tmpmag), "\\"
                  ENDIF 
               ENDFOR
               printf, 3, "\end{tabular}"
               IF(count NE 0) THEN BEGIN 
                  print, "im Mittel :", dmu/double(count)
                  print, "mittlere Mag (4.26):", midmag/double(count)
                  print, "gesamte Energie:", esum
                  print, "kumulativer Slip bei"
                  printf,3, "im Mittel :", dmu/double(count), "\\"
                  printf,3, "mittlere Mag (4.26):", midmag/double(count), "\\"
                  printf, 3, "gesamte Energie:", esum
                  printf,3, "kumulativer Slip bei"+"\\"
               ENDIF 
               FOR j=0, ptimeend DO BEGIN 
                  IF((double(timeplot(j))/(50.0/timescale))EQ(fix(timeplot(j)/(50/timescale))))THEN BEGIN 
                     print, "time: "+strtrim(timeplot(j)*timescale)+$
                       " Gesamtes u:"+string(abs(dumean(j, i))*spacescale)+$
                       "  Ges.\ Mo:"+string(mmsum(i, j))+"\\"
                     printf,3, "time: "+strtrim(timeplot(j)*timescale)+$
                       " Gesamtes u:"+string(abs(dumean(j, i))*spacescale)+$
                       "  Ges.\ Mo:"+string(mmsum(i, j))+"\\"
                  ENDIF 
               ENDFOR 
            ENDELSE 
         ENDFOR 
         printf, 3
         close, 3, 5
         !p.multi=0
         if (dev eq 'PS')then device,/close
      ENDIF 
      

      if (dev eq 'X') then begin
         tmp=get_kbrd(1)
         if tmp eq 's' then begin
            wset,0
            stop
         end
      end

      spawn, "gzip "+filedir+"stress_timeseries* &" 
   END
   

END


