print,"READSEIS"
   close,1, 2, 3
   pi = 3.1415926535897
   teststart =10 & teststop=10 ;teststart
   ;;plotstop = -1


   plotstop = 198 & tseisplotstop=198
   pcs = dblarr(4, 10000)

   ssfs = 1 &  stresscompare=1 &  stats=1
   tiffprint=0 & psprint=0 & printepsstats=0
   everworth = 0 & xan=0 &  gifconvert=1
   showaniplots =0              ; show the animation of the seismicity

   IF((xan EQ 1)OR(tiffprint EQ 1)OR(psprint EQ 1))THEN showaniplots = 1


   FOR test=teststart, teststop do BEGIN

      spacescale = 1000.0

      ;filedir="/home/geodyn/becker/finel/results/"
      filedir="/home/datdyn2/becker/finel/"
      ;filedir = ""
      ;modeldir = filedir+"en_echelon/"+strtrim(test, 1)+"/"
      ;;modeldir = filedir+"random/"+strtrim(test, 1)+"/"
      modeldir = filedir+"randarc/"+strtrim(test, 1)+"/"
      ;;modeldir=filedir+"eff_modul/"+strtrim(test, 1)+"/"
      ;modeldir=filedir+"/home/bigusr/becker/model_data/arc_faults_again/"+strtrim(test, 1)+"/"



                                ; stresscompare und simpleshearfs vergleichen die 
                                ; tatsaechliche aktivierungsanzahl mit
                                ; der nach der coulombspannung
                                ; erwarteten. stats erstellt
                                ; momentstatistiken 
                                ; psprint erstellt PS images der
                                ; raeumlichen seismizitaet 


      print,"Working on "+modeldir
      spawn, "gunzip -f "+modeldir+"faultcoord.gz"
      openr,1,modeldir+"faultcoord"
      readf,1,gnrflt
      fc=dblarr(4,gnrflt)
      readf,1,fc
      close,1
      maxx = 1000

      spatiobox = 10
      spatioseis = dblarr(spatiobox, spatiobox)

      openr,1,modeldir+"mesh_constants"
      readf,1,emodul,nyu
      readf,1,alpha1,deltat,alpha2
      readf,1,nmyu,fmyu,sdmyu
      modulmyu = emodul/(2.0+2.0*nyu)
      readf,1,foff,loff,hp
      close,1
      off = foff



      IF((stats) AND (stresscompare))THEN BEGIN 
         print, "Loading reference stress state"
         IF(ssfs)THEN BEGIN 
            print, "for simple shear with free sides..."
            smdir = "/home/geodyn1/becker/finel/results/ssfsreference/"
         ENDIF 
         openr, 1, smdir+"stre11.1.xyz"
         openr, 2, smdir+"stre12.1.xyz"
         openr, 3, smdir+"stre22.1.xyz"
         readf, 1, t1, t2, t3, t4, t5, t6 &  readf, 1, nstrb
         readf, 2, t1, t2, t3, t4, t5, t6 &  readf, 2, nstrb
         readf, 3, t1, t2, t3, t4, t5, t6 &  readf, 3, nstrb
         mstrb = sqrt(nstrb)
         rclb1 = dblarr(3, mstrb, mstrb) &  rclb2 = dblarr(3, mstrb, mstrb) 
         rclb3 = dblarr(3, mstrb, mstrb)
         readf, 1, rclb1 &  rclb1= -reform(rclb1(2, *, *)) &  close, 1
         readf, 2, rclb2 &  rclb2= -reform(rclb2(2, *, *)) &  close, 2
         readf, 3, rclb3 &  rclb3= -reform(rclb3(2, *, *)) &  close, 3
         rfms = dblarr(mstrb, mstrb) & rsms=dblarr(mstrb, mstrb) & rdeg=dblarr(mstrb, mstrb)
         tmp = 0.0
         FOR i=0, mstrb-1 DO BEGIN 
            FOR j=0, mstrb-1 DO BEGIN 
               rfms(i, j) = pstressfms( rclb1(i, j), rclb2(i, j), rclb3(i, j))
               rsms(i, j) = pstresssms(rclb1(i, j), rclb2(i, j), rclb3(i, j))
               rdeg(i, j) = pstressdeg(rclb1(i, j), rclb2(i, j), rclb3(i, j))
            ENDFOR 
         ENDFOR 
         b = ( 2.0 * off ) / (sqrt(1.0 + fmyu^2) - fmyu)
         a=( sqrt(1+fmyu^2) + fmyu )/ ( sqrt(1+fmyu^2) - fmyu )
         rcsmax = max(cstress(rfms,rsms,a,hp,b))
         rcsmin = min(cstress(rfms,rsms,a,hp,b))
         IF((rcsmin LT 0.0)AND(rcsmax LT 0.0))THEN $
           rcsrange = rcsmax-rcsmin
      ENDIF  

      
      print,"Reading  "+modeldir+"seis"
      openr,1,modeldir+"seis"
      readf,1,nrflt,start,stop
      m=dblarr(nrflt,stop-start+1)
      nract=intarr(stop-start+1)
      n=0 &  tmpfc=dblarr(2) &  ittimemax=0
      while not eof(1) do begin
         readf,1,it,flt & readf,1,x1,y1 & readf,1,x2,y2 & readf,1,rupture_length
         readf,1,du,ds 
         time= it - start
         tmpmoment = rupture_length*spacescale*15000*abs(du)*spacescale*modulmyu
         m(flt-1,time)=m(flt-1,time)+tmpmoment
         nract(time)=nract(time)+1
         energy = (abs(ds)/(2.0*modulmyu))*tmpmoment
         disc = (rupture_length/maxx)*spatiobox*50
         tmpfc(0) = x2-x1 & tmpfc(1)=y2-y1
         FOR sc1=0.0d, 1.0d, (1.0/disc) DO BEGIN 
            tmpx = x1+sc1*tmpfc(0)
            tmpy = y1+sc1*tmpfc(1)
            spi = fix((tmpx/maxx)*double(spatiobox))
            spj = fix((tmpy/maxx)*double(spatiobox))
            spatioseis(spi, spj) = spatioseis(spi, spj) + (energy/double(disc+1))
         ENDFOR 
         ittimemax = it
         n=n+1
      endwhile
      close,1
      spatioseis = spatioseis/double(ittimemax)
      IF(n NE 0)THEN BEGIN 
         se=fltarr(9,n) 
         openr,1,modeldir+"seis"
         readf,1,nrflt,start,stop
         readf,1,se
         close,1
      ENDIF ELSE BEGIN 
         print, "Keine Beben in "+modeldir+"seis"
      ENDELSE 
      
      IF(n NE 0) THEN BEGIN 
         tseis = intarr(nrflt)
         seis_intervals = dblarr(stop-start+1)
         naflt = 0 &  wasact=intarr(nrflt)
         summo=dblarr(stop-start+1)
         for i=0,nrflt-1 do begin
            hit = 0
            for j=0,stop-start do begin
               IF(abs(m(i, j)) NE 0.0)THEN BEGIN 
                  seis_intervals(j-tseis(i)) = seis_intervals(j-tseis(i))+abs(m(i,j))
                  tseis(i) = j
                  summo(j)=summo(j)+abs(m(i,j))
                  IF(hit EQ 0)THEN BEGIN 
                     hit = 1
                     wasact(naflt) = i
                     naflt = naflt+1
                  ENDIF 
               ENDIF  
            ENDFOR  
         ENDFOR  
         print, "activated: ", naflt, " of ", nrflt

         set_plot, 'X'
         window,0 & wset,0 
         
         IF  (nrflt lt 5)THEN  BEGIN 
            !p.multi=[0,1,nrflt,0]	
            for i=0,nrflt-1 do begin
               plot,m(i,*),yrange=[0,max(m)],title="!6Fault "+strtrim(i+1,1),psym=10,$
                 xtitle="Zeit [100a]",ytitle="Seism. Moment [A.U.]"
            ENDFOR  
         ENDIF ELSE  BEGIN 
            !p.multi=0
            plot,summo,title="!6Gesamtes seismisches Moment",xtitle="Zeit [100a]",$
              ytitle="Seism. Moment [A.U.]",psym=10
         ENDELSE 
         
         IF(printepsstats)THEN dev = 'PS' ELSE dev = 'X'
         IF(stats)THEN BEGIN 
            ;; TOTAL MOMENT STATISTICS
            set_plot, dev
            IF (dev EQ 'X')THEN BEGIN 
               window, 1 &  wset, 1
            ENDIF ELSE BEGIN 
               device,filename=modeldir+"stats.eps", xsize=19, $
                 ysize=18, /encapsulated
               print, "Printing to "+modeldir+"stats.eps"
            ENDELSE 

            
            !p.multi = [0, 2, 2, 0]
            maxmag=alog10(max(summo)) & 
            ssummo = summo(sort(summo)) & minmag=9e99 &  i=0
            WHILE ((minmag EQ 9e99)AND(i LE stop-start))DO BEGIN 
               IF(ssummo(i) NE 0.0)THEN minmag=alog10(ssummo(i))
               i = i+1
            ENDWHILE 
            maglvl = 50
            magstep = (maxmag-minmag)/double(maglvl)
            magcnt = intarr(maglvl)
            magbox = dindgen(maglvl)*magstep+minmag
            FOR i=0, stop-start DO BEGIN 
               IF(summo(i) NE 0)THEN BEGIN 
                  IF(alog10(summo(i)) EQ maxmag)THEN BEGIN 
                     magcnt(maglvl-1) = magcnt(maglvl-1)+1 
                  endif ELSE BEGIN 
                     updt = fix((alog10(summo(i))-minmag)/magstep)
                     magcnt(updt) = magcnt(updt)+1
                  ENDELSE 
               ENDIF  
            ENDFOR    
            plot, magbox, magcnt,psym=10, xtitle="log(M!ig!n)",  ytitle="Nr. of events",xstyle=1, $
              title="Total seismic moment"
         
            ;; SINGLE FAULT STATISTICS
            
            nactivation = intarr(nrflt)
            moments = abs(m) & maxmag=alog10(max(moments)) &  minmag=9e9
            FOR i=0, nrflt-1 DO BEGIN 
               FOR j=0,  stop-start DO BEGIN 
                  IF(moments(i, j) NE 0.0)THEN $
                    IF(alog10(moments(i, j)) LT minmag)THEN minmag=alog10(moments(i, j))
               ENDFOR 
            ENDFOR 
            maglvl = 50
            magstep = (maxmag-minmag)/double(maglvl)
            magcnt = intarr(maglvl)
            magbox = dindgen(maglvl)*magstep+minmag
            FOR i=0, nrflt-1 DO BEGIN 
               FOR j=0, stop-start DO BEGIN 
                  IF(moments(i, j) NE 0.0)THEN BEGIN 
                     tmpmag = alog10(moments(i, j))
                     IF(tmpmag EQ maxmag)THEN BEGIN 
                        magcnt(maglvl-1) = magcnt(maglvl-1)+1
                     ENDIF ELSE BEGIN 
                        updt = fix((tmpmag-minmag)/magstep)
                        magcnt(updt) = magcnt(updt)+1
                     ENDELSE 
                     nactivation(i) = nactivation(i)+1
                  ENDIF    
               ENDFOR  
            ENDFOR 
            tnumber = total(nactivation) & maxna=max(nactivation)
            plot, magbox, magcnt,psym=10, xtitle="log(M)",  ytitle="Nr. of events", $
              title="seismic moment"
            print, "total activations: ", tnumber,  " maximum individual activation",  maxna
            


            ;; PROBABILITY PLOTS
            
            narcbox = 40
            arcs= dblarr(nrflt) &  tmp=dblarr(2) & narcs=intarr(narcbox)
            arcboxes = -(pi/2.0)+(dindgen(narcbox)/double(narcbox-1))*pi
            nexpected = dblarr(nrflt) 
            FOR i=0, nrflt-1 DO BEGIN 
               arc =  atan((fc(2,i)-fc(0, i)), (fc(3, i)-fc(1, i)))
               IF(arc GT  0.5*pi)THEN arc = arc - pi
               IF(arc LT -0.5*pi)THEN arc = arc + pi
               arcs(i) = arc
               into = fix(((arcs(i)+pi/2.0)/pi)*double(narcbox))
               IF(into EQ narcbox)THEN into=narcbox-1
               narcs(into) = narcs(into)+1
               tmp(0) = (fc(2, i)+fc(0, i))/2.0
               tmp(1) = (fc(3, i)+fc(1, i))/2.0
               s1 = interpolate(rfms, (tmp(0)/maxx)*double((mstrb-1)), $
                                (tmp(1)/maxx)*double((mstrb-1)))
               s2 = interpolate(rsms, (tmp(0)/maxx)*double((mstrb-1)), $
                                (tmp(1)/maxx)*double((mstrb-1)))
               tm = (s1-s2)/2.0 & mn=(s1+s2)/2.0
               beta = arcs(i) - $
                 interpolate(rdeg, (tmp(0)/maxx)*double((mstrb-1)), $
                             (tmp(1)/maxx)*double((mstrb-1)))
               normal = (mn+hp)-tm*cos(2*(beta/180.0)*pi)
               tangential = tm*sin(2*(beta/180.0)*pi)
               nexpected(i) = cstress(tangential, normal, fmyu, hp, off)
            ENDFOR  
            csmin = min(nexpected) &  csmax=max(nexpected)
            nexpected = fix(((nexpected-csmin)/(csmax-csmin))*double(maxna)*0.5)

            plot, arcboxes, narcs, /nodata, title="orientation", xtitle="Nr. of faults", $
              ystyle=1, xst=1, xrange=[0, max( narcs)], yrange=[-max( narcs), max( narcs)],$
              xmargin=[6,16],ymargin=[2,2],xticks=1, yticks=1
            openw, 1, modeldir+"odis.dat"
            print, "Printing to "+modeldir+"odis.dat"
            FOR i=0, narcbox-1 DO BEGIN 
               plots, 0, 0
               plots, cos(arcboxes(i))*narcs(i), sin(arcboxes(i))*narcs(i), thick=5,$
                 /data, /continue
               printf, 1, double(narcs(i))/double(max(narcs)), (arcboxes(i)/pi)*180.0
            ENDFOR 
            close, 1
            plot, smooth(nactivation, 2), psym=10, xtitle="Nr. of fault", ytitle="Times of activation"
            oplot, smooth(nexpected, 2), psym=10, thick=5
            if(dev EQ 'PS')THEN device, /close


            IF(dev EQ 'X')THEN BEGIN 
               window, 2 & wset, 2
            ENDIF ELSE BEGIN 
               device,filename=modeldir+"timestats.eps", xsize=14, $
                 ysize=10, /encapsulated
               print, "Printing to "+modeldir+"timestats.eps"
            ENDELSE 
            !p.multi = 0
            plot, seis_intervals(0:tseisplotstop)/1e21, xtitle="!6T!iseis!n [yr]", $
              ytitle="!6M!i0!n [10!e21!nNm]", psym=10, title="periodicity"
            IF(dev EQ 'PS')THEN device, /close

            spasmax = max(spatioseis)
            IF(spasmax NE 0)THEN BEGIN 
               IF(dev EQ 'X')THEN BEGIN 
                  window, 5 & wset, 5
               ENDIF ELSE BEGIN 
                  device,filename=modeldir+"spatioseis.eps", xsize=10, $
                    ysize=10.5, /encapsulated, bits_per_pixel=16
                  print, "Printing to "+modeldir+"spatioseis.eps"
               ENDELSE 
               !p.multi = 0
               plot, spatioseis, /nodata, xtitle="x", ytitle="y", $
                 title="released energy", xst=1, yst=1, $
                 xrange=[0, maxx], yrange=[0, maxx]
               FOR i=0d, spatiobox-1 DO BEGIN 
                  FOR j=0d, spatiobox-1 DO BEGIN 
                     IF(spatioseis(i, j) NE 0)THEN BEGIN 
                        IF(dev EQ 'X')THEN cl = (spatioseis(i, j)/spasmax)*255 ELSE $
                          cl = 253-(spatioseis(i, j)/spasmax)*253 
                        
                     ENDIF ELSE BEGIN 
                        IF (dev EQ 'PS')THEN cl = 253 ELSE cl = 1
                     ENDELSE 
                     xvec = [3+(i/spatiobox)*maxx, ((i+1)/spatiobox)*maxx-3, $
                             ((i+1)/spatiobox)*maxx-3, (i/spatiobox)*maxx+3]
                     yvec = [3+(j/spatiobox)*maxx, 3+(j/spatiobox)*maxx, $
                             ((j+1)/spatiobox)*maxx-3, ((j+1)/spatiobox)*maxx-3]
                     polyfill, xvec, yvec, color=cl
                  ENDFOR 
               ENDFOR 
               IF(dev EQ 'PS')THEN device, /close
               set_plot, 'PS'
               device,filename=modeldir+"spatioseisscl.eps", xsize=4, $
                    ysize=10, /encapsulated, bits_per_pixel=16
               print, "Printing to "+modeldir+"spatioseisscl.eps"

               f=findgen(256) * (spasmax/1e13)/256.0 &  ff=fltarr(50, 256)
               f = reverse(f)
               for i=0,49 do begin
                  ff(i, *)=f
               end
               mk_image,ff
               axis,yaxis=0,yticklen=-0.04,yrange=[0,spasmax/1e13],ythick=2.,$
                 yticks=2,ytitle="energy [10 TJ/yr]",ystyle=1
               ;axis,yaxis=1,yticks=2,yticklen=1,ystyle=1, yrange=[0,spasmax/1e13]

               device, /close
               set_plot, 'X'
            ENDIF 
         ENDIF   
         
         




         
         IF(showaniplots)THEN BEGIN 
            
            ;; SEISMICITY PLOTS
            
            
            IF(dev EQ 'X')THEN BEGIN
               window,3,xsize=500,ysize=500 & wset=3
            ENDIF 
            !p.multi=0
            if(xan)then xinteranimate,set=[500,500,stop-start+1]

            OPENR, 1, modeldir+"seis.tst", ERROR = err
            IF (err EQ  1) then openw,1,modeldir+"seis.tst"
            
            c1 = 0 &  c2=255 &  c3=255
            IF(plotstop NE -1)THEN stop =  plotstop
            

            for time=start,stop do BEGIN
               wset, 3
               worth = 0
               plot,fc,/nodata,xstyle=1,ystyle=1,xrange=[0,maxx],yrange=[0,maxx],$
                 title="Zeit: "+string(format='(i3)',time)
               polyfill,[2,maxx-2,maxx-2,2],[2,2,maxx-2,maxx-2],color=c1
               for i=0,gnrflt-1 do begin
                  plots,fc(0,i),fc(1,i)
                  plots,fc(2,i),fc(3,i),/continue,color=c2
               END
               
               IF (err EQ  1) then printf,1,time,nract(time-start)
               m=0 & i=0 & plotcount=0
               while((i lt n) and (m lt nract(time-start)))do begin
                  if(se(0,i) eq time)then begin
                     IF (err EQ  1) then printf,1,se(2:5,i)
                     plots,se(2,i),se(3,i) 
                     plots,se(4,i),se(5,i),/continue,thick=5.0
                     pcs(0, plotcount) = se(2, i) & pcs(1, plotcount) = se(3, i)
                     pcs(2, plotcount) = se(4, i) & pcs(3, plotcount) = se(5, i)
                     plotcount = plotcount+1
                     color = c3
                     worth = 1
                     m=m+1
                  END 
                  i=i+1
               ENDWHILE 
               
               plot,fc,/nodata,xstyle=1,ystyle=1,xrange=[0,maxx],yrange=[0,maxx],$
                 title="Zeit: "+string(format='(i3)',time), /noerase
               if(xan)then xinteranimate,frame=time-start,window=[1,0,0,500,500]
               if((tiffprint)AND((worth)OR(everworth)))then begin
                  common colors,r_orig,g_orig,b_orig,r_con,g_con,b_con
                  image=tvrd()
                  tiff_write,modeldir+"seismo."+strtrim(fix(time-start+1),2)+".tiff",$
                  image,red=r_orig,$
                    green=g_orig,blue=b_orig
                  print,"Printing to ",modeldir+"seismo."+strtrim(fix(time-start+1),2)+".tiff"
               END 
               
               IF(psprint AND ((worth)OR(everworth)))THEN BEGIN 
                  set_plot, 'PS'
                  IF(gifconvert EQ 0)THEN BEGIN 
                     device,filename=modeldir+"seismo."+strtrim(fix(time-start+1),2)+".eps", $
                       xsize=7.15, ysize=7, /encapsulated
                  ENDIF ELSE BEGIN 
                     device,filename=modeldir+"seismo."+strtrim(fix(time-start+1),2)+".eps",$
                       xsize=14.3, ysize=14, /encapsulated
                  ENDELSE 
                  print,"Printing to ",modeldir+"seismo."+strtrim(fix(time-start+1),2)+".eps"
                  plot,fc,/nodata,xrange=[0,maxx],yrange=[0,maxx],/noerase, $
                    title="!6Zeit: "+string(format='(i3)',time),  $
                    xstyle=1, ystyle=1,xticks=4, yticks=4
                  
                  polyfill,[15,maxx-13,maxx-13,15],[15,15,maxx-14,maxx-14],color=240,/data
                  
                  for i=0,gnrflt-1 do begin
                     plots,fc(0,i),fc(1,i)
                     plots,fc(2,i),fc(3,i),/continue, thick=3.0
                  END
                  FOR i=0, plotcount-1 DO BEGIN 
                     plots,pcs(0,i),pcs(1,i) 
                     plots,pcs(2,i),pcs(3,i),/continue,thick=12.0
                  ENDFOR 
                  device, /close
                  set_plot, 'X'
               ENDIF 
            ENDFOR   
            IF (err EQ  1) THEN close,1
            
            if(xan) then xinteranimate,10
         ENDIF   
      ENDIF      


      IF(NOT printepsstats)THEN BEGIN 
         set_plot, 'X'
         window,4 & wset, 4
      ENDIF ELSE BEGIN 
         set_plot, 'PS'
         print, "Printing to txplot.eps"
         device,filename=modeldir+"txplot.eps", xsize=15, $
           ysize=10*(plotstop/200), /encapsulated
      ENDELSE 
      plot, m, xrange=[0, 1000], yrange=[0, plotstop], /nodata, xtitle="x!iproj!n [km]", $
        ytitle="t[yr]", xstyle=1,  xticks=1, ystyle=1
      IF(nrflt LE 5)THEN BEGIN 
         FOR i=0, nrflt-1  DO BEGIN 
            plots, fc(0, i)+4, -4 & plots, fc(0, i), 0, /continue
            plots, fc(0, i)+4, 4 & plots, fc(0, i), 0, /continue
            xyouts, (fc(2, i)+ fc(0, i))/2.0, 3,$
              strtrim(i+1, 1), /data, alignment=0.5, charsize=1.3
            plots, fc(2, i)-4, -4 & plots, fc(2, i), 0, /continue
            plots, fc(2, i)-4, 4 & plots, fc(2, i), 0, /continue
         ENDFOR
      ENDIF 
      ;;print, minmag, maxmag
      for time=start,plotstop do BEGIN
         worth = 0
         m=0 & i=0 

         WHILE ((i LT  n) AND (m LT  nract(time-start)))do begin
            if(se(0,i) eq time)then begin
               tmpmoment = se(6, i)*spacescale*15000*abs(se(7, i))*spacescale*modulmyu
               thickness_toplot = ((alog10(tmpmoment)-9.1)/1.5)-2.5

               plots, se(2, i), time
               plots, se(4, i), time, /continue, thick=thickness_toplot
               m=m+1
            END 
            i=i+1
         ENDWHILE 
      ENDFOR 
      IF(printepsstats)THEN device, /close

      IF(NOT printepsstats)THEN tmpchar =get_kbrd(1)



      print, "The sum of seismic intervals is: ", total(seis_intervals)
      statssummcount = 0.0
      FOR i=0, maglvl-1 DO BEGIN 
         statssummcount =  statssummcount + (10^magbox(i))*magcnt(i)
      ENDFOR 
      print, "The sum of the single fault stats is: ",  statssummcount

   ENDFOR     
END 




