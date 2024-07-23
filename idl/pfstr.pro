; Routine zum Plotten von gemittelten Spannungen am Fault als Funktion der Zeit
;pro pfstr,fault,start,stop

close,1,2

faultstart= 1 & faultstop= -1   ; Einzulesende profil.flt[fault].[it] Daten, -1 = alle
faultstop = 2
evercheck = 1
teststart =10 & teststop=10 & check_length=0 ; Verschiedene Test-Directories

verbose=1                       ; Schreibt die Namen der Files auf stdout
start=1 & stop = 400 & stepping=1 & limit=1400 ; Anzahl der Iterationen
newstyle=1
nowgo = 0 & printonly=0
diffdu = 0

plotframe=0 &  printeps=0 &  propspeed=0 &  slowdown=900

oldstressstyle=0        ; =1 bedeutet Lesen von stre??.#.# fuer Konstanten, 0 von mesh_const

readdata=1 &  printdata=1 &  stoptimeplotit=1500

IF(plotframe EQ 1)THEN printdata = 0
static=0                        ; Suche nach erster Aktivierung
if(newstyle)then print,'Benutze neue profil-Files'


tau_unend=1.0e7


if(printeps)THEN dev = 'PS' ELSE dev='X'

set_plot,dev
IF(dev EQ 'X')THEN    window, ysize=900

for test=teststart,teststop do begin
   evercheck = 1
   IF(1)THEN BEGIN 
      IF (test  EQ 9)THEN stop = 220
      IF (test  EQ 10)THEN stop = 200

      IF (test  EQ 31)THEN stop = 365

      IF (test  EQ 32)THEN stop = 291
      IF (test  EQ 33)THEN stop = 211
      IF (test  EQ 34)THEN stop = 127
      IF (test  EQ 35)THEN stop = 171
      IF (test  EQ 36)THEN stop = 145
      IF (test  EQ 37)THEN stop = 222
      IF (test  EQ 38)THEN stop = 128
      IF (test  EQ 20)THEN stop = 995
      IF (test  EQ 23)THEN stop = 452
      IF (test  EQ 24)THEN stop = 570
      IF (test  EQ 25)THEN stop = 423
      IF (test  EQ 54)THEN stop = 1000
      IF (test  EQ 55)THEN stop = 550
      IF (test  EQ 57)THEN stop = 1000


   ENDIF 
   
   ;;modeldir="moving_sngl_crack.2/"
   ;;modeldir = "one_rot/"+strtrim(test,1)+"/"
   modeldir = "randarc/"+strtrim(test,1)+"/"
   ;;modeldir="arc_faults_again/"+strtrim(test,1)+"/"
   ;;modeldir="en_echelon/"+strtrim(test,1)+"/"
   ;;modeldir="random/"+strtrim(test,1)+"/"
   ;;modeldir = "/one_crack/hp1e8/"
   ;;modeldir="random/"+strtrim(test,1)+"/"
   ;;modeldir = "eff_modul/"+strtrim(test,1)+"/"
   ;;modeldir = "one_crack/stress_free/"+strtrim(test,1)+"/"
   ;;modeldir = ""
   ;;filedir = "/home/geodyn/becker/finel/results/arc_faults_run3/"+strtrim(test,1)+"/"
   ;;filedir = "/home/geodyn/becker/finel/results/"+modeldir
   filedir="/home/datdyn2/becker/finel/"+modeldir
   ;;filedir = "/home/bigusr/becker/model_data/"+modeldir

   spawn,  "gunzip "+filedir+"faultcoord.gz"
   spawn,  "gunzip "+filedir+"mesh_constants.gz"

   openr,1,filedir+"faultcoord"
   readf,1,nrallflt
   fltcoord=dblarr(4,nrallflt)
   readf,1,fltcoord
   close,1
   spawn, "gunzip "+filedir+"profil.flt* "
   
   if(evercheck)then faultstop=nrallflt
   nrflt=faultstop-faultstart+1
   if (verbose)then begin		
      print,"Nr. der Faults: ",nrallflt
      print,"Koordinaten: "
      print,fltcoord
   endif
   
   if ((dev eq 'PS') AND (plotframe NE 1))then begin
      device,filename='du.eps', bits_per_pixel=8,$
       /encapsulated,xsize=22,ysize=18,scale_factor=1.0
      ;;		/color,/landscape
      print,'Output in du.eps'
   endif
   
   csmax=dblarr(nrflt,stop-start+1) &  taumedian=dblarr(nrflt,stop-start+1)
   nosmedian=dblarr(nrflt,stop-start+1) & csmedian=dblarr(nrflt,stop-start+1)
   csmin=dblarr(nrflt,stop-start+1) & csend=dblarr(nrflt,stop-start+1)
   csmid=dblarr(nrflt,stop-start+1) & dumean=dblarr(nrflt,stop-start+1)
   dumid=dblarr(nrflt,stop-start+1) & duend=dblarr(nrflt,stop-start+1)
   
   if(printdata)then begin
      openw,2,filedir+"seis"
      printf,2,nrflt,start,stop
   endif
   if (oldstressstyle)then begin
      openr,1,filedir+"stre12."+strtrim(1,1)+".xyz"
      readf,1,time,fmyu,sdmyu,nmyu,hp,foff
      close,1		
   endif else begin
      openr,1,filedir+"mesh_constants"
      readf,1,emodul,nyu
      readf,1,alpha1,deltat,alpha2
      readf,1,nmyu,fmyu,sdmyu
      readf,1,foff,loff,hp
      close,1
   endelse	
   dtref=((1.0 - nyu^2)/emodul)*tau_unend*4.0
   
   for fault=faultstart,faultstop do begin

      if (check_length)then begin
         if(newstyle)then begin
            file=filedir+"profil.flt" + strtrim(fault,1)
            openr,1,file & readf,1,start,n & du=dblarr(8,n)
            readf,1,du
            while not eof(1) do begin
               readf,1,stop,n
               readf,1,du
            endwhile
            close,1
         endif else begin
            it=0 & errorvar=0
            while (errorvar eq 0) do  begin
               it=it+1
               file=filedir+"profil.flt" + strtrim(fault,1) + "." + strtrim(it,1)
               openr,1,file,error=errorvar
               close,1
            endwhile
            it=it-1	
            stop=it & start=1
         endelse
         if(verbose)then print,'Using checked',stop,'Iterations'
      endif else begin
         if(verbose)then print,'Using fixed iterations from ',start,' to ',stop
      endelse
      
      fvec=dblarr(2) & nfvec=dblarr(2)
      fvec(0)=fltcoord(2,fault-1)-fltcoord(0,fault-1)
      fvec(1)=fltcoord(3,fault-1)-fltcoord(1,fault-1)
      length=betrag(fvec)
      fvec = fvec / length
      nfvec(0)= -fvec(1) & nfvec(1)=fvec(0) 
      a=length / 2.0 & duref=dtref*a
      if(verbose) then print,'Fault ',fault,'(',fvec,')',a
      
      print,"Iterationen von ", start,"bis ", stop," mit Plot-Schritten von ", stepping

      FOR it=start, stop DO BEGIN 
         IF(it EQ slowdown)THEN stepping = 1
         tmp=""
         if(newstyle)then begin
            if (it eq start)then begin
               file=filedir+"profil.flt"+strtrim(fault,1)
               if(verbose)then print,"Reading file ",file
               openr,1,file
            end
            readf,1,it,n
            if(it eq start)then begin
               du=dblarr(8,n)
               useis=dblarr(n)
               ustress=dblarr(n)
               tau=dblarr(stop-start+1,n)
               nos=dblarr(stop-start+1,n)
               dist=dblarr(n)
            end
         endif else begin
            file=filedir+"profil.flt"+strtrim(fault,1)+"."+strtrim(it,1)
            if (verbose eq 1)then print,'Reading ',file
            if(it eq start)then begin
               openr,1,file
               n=0
               while not eof(1) do begin
                  readf,1,xx,yy,dutgesamt,dutmesh,dungesamt,dunmesh,stau,snos
                  n=n+1
               endwhile
               close,1
               du=dblarr(8,n)
               useis=dblarr(n)
               ustress=dblarr(n)
               tau=dblarr(stop-start+1,n)
               nos=dblarr(stop-start+1,n)
               dist=dblarr(n)
            end
            openr,1,file
         endelse
         
         readf,1,du
         
         if(newstyle ne 1)then close,1
         
         dist(*)=(sqrt((du(0,*)-fltcoord(0,fault-1))^2 + (du(1,*)-fltcoord(1,fault-1))^2)-a)/a
         du=du(*,sort(dist))
         dist=dist(sort(dist))
         
         if ((plotframe eq 1) AND ((double(it) / double(stepping))EQ(fix(it/stepping))) AND $
             ((nowgo EQ 0)OR(nowgo EQ it))AND((printonly EQ 0)OR(printonly EQ it)))THEN  BEGIN 
            if(0)then begin
               set_plot,'PS'
               !p.multi=0
               device,filename=filedir+'versatz.ps', bits_per_pixel=16,$
                /portrait,xsize=16,ysize=5.5,scale_factor=1.0, xoffset=0.5
               print,"Printing to "+filedir+"versatz.ps"
               um = max(abs(du(2,*)-du(3,*)))
               an =  um/(1.0e4*7.5e-11)
               print, "Using an:", an
               xx = -an+dindgen(400)*((an*2.0)/400.0)
               xxx = -50.0+dindgen(400)*((100.0)/400.0)
               plot, xx/50.0,( sqrt((an+1.0e-10)^2-xx^2)*(um/an+1.0e-10))/1e-04, $
                title="!6Analytische Loesungen fuer a!i0!n=50 und a!in!n:"+strtrim(an, 1), $
                xrange=[-an/50.0-0.1,an/50.0+0.1],xstyle=1,xtitle="Abtand von der Faultmitte / a!i0!n",$
                ytitle="Relativer Tangentialversatz [10e-4 AU]" 
               oplot,dist(*),(abs(du(2,*)-du(3,*)))/1e-04, psym=7
               oplot,xxx/50.0,(sqrt(50.00000001^2-xxx^2)*(um/50.00000001))/1e-04
               device,/close
               set_plot,'X'
               stop
            endif

            IF(dev EQ 'PS')THEN BEGIN 
               device,filename=filedir+'versatz.a.'+strtrim(it, 1)+'.ps', /portrait, $
                xsize=16,ysize=5.5,scale_factor=1.0,bits_per_pixel=8, yoffset= 0.0
               print, 'Printing to '+filedir+'versatz.'+strtrim(it, 1)+'.ps'
            ENDIF 
            if(max(du(4,*)-du(5,*))ne 0.0)then normplot = 1 else normplot=0
            if(normplot)then !p.multi=[0,0,6,0] else !p.multi=[0,0,5,0]
            IF(dev EQ 'PS')THEN !p.multi = 0
            maxabsdu = max(abs(du(2,*)-du(3,*)))
            IF((it EQ start)OR(it EQ stepping)OR(printonly NE 0)OR(nowgo NE 0))THEN BEGIN 
               alttdu = dblarr(n)
               alttdu = abs(du(2,*)-du(3,*))
               plot,dist(*),(abs(du(2,*)-du(3,*))) , $
                title="!6 Verschiebung Fault "+strtrim(fault,1)+", Iteration "+$
                strtrim(it,1),xrange=[-1.1,1.1],xtitle="Abtand von der Faultmitte / a ",xstyle=1,$
                ytitle="(Relativer Tangentialversatz - analyt. Loesung auf Max. skaliert)/ m",psym=4
               oplot,dist(*),abs(du(2,*)-du(3,*))- sqrt(1-dist(*)^2)*maxabsdu
               oplot,dist(*),sqrt(1-dist(*)^2)*maxabsdu,linestyle=1
            ENDIF ELSE BEGIN 
               IF(diffdu)THEN BEGIN 
                  plot,dist(*),(abs(du(2,*)-du(3,*)))-alttdu , $
                   title="!7D!6 Verschiebung Fault "+strtrim(fault,1)+", Iteration "+$
                   strtrim(it,1),xrange=[-1.1,1.1],xtitle="Abtand von der Faultmitte / a ",xstyle=1,$
                   ytitle="Differenz im tangential Versatz/ m",psym=4
                  oplot,dist(*),abs(du(2,*)-du(3,*))-alttdu  
                  alttdu = abs(du(2,*)-du(3,*))
               ENDIF ELSE BEGIN 
                  plot,dist(*),(abs(du(2,*)-du(3,*))) , $
                   title="!6 Verschiebung Fault "+strtrim(fault,1)+", Iteration "+$
                   strtrim(it,1),xrange=[-1.1,1.1],xtitle="Abtand von der Faultmitte / a ",xstyle=1,$
                   ytitle="Tangentialer Versatz/ m",psym=4
                  oplot,dist(*),abs(du(2,*)-du(3,*))- sqrt(1-dist(*)^2)*maxabsdu
                  oplot,dist(*),sqrt(1-dist(*)^2)*maxabsdu,linestyle=1
               ENDELSE 


            ENDELSE 
            IF(dev EQ 'PS')THEN device, /close

            IF(dev EQ 'PS')THEN BEGIN 
               device,filename=filedir+'versatz.b.'+strtrim(it, 1)+'.ps', /portrait, $
                xsize=16,ysize=5.5,scale_factor=1.0,bits_per_pixel=8, yoffset= 0.0
               print, 'Printing to '+filedir+"versatz.c"+strtrim(it, 1)+".ps"
            ENDIF 

            plot,dist(1:n-2),(abs(du(6,1:n-2))-abs(mittelwert(du(6,1:n-2))))/1.0e6,$
              xtitle=" x / a",$
              ytitle="!7r!6!ixy!n - <!7r!6!ixy!n>[MPa]",psym=4, xstyle=1, xrange=[-1.1, 1.1]
            oplot,dist(1:n-2),(du(6,1:n-2)-mittelwert(du(6,1:n-2)))/1.0e6
            xyouts, dist(n-40), (du(6, n-2)-mittelwert(du(6,1:n-2)))/1.0e6, $
              "<!7r!6!ixy!n>="+string(format='(f6.3)', (mittelwert(du(6, *)))/1.0e6)+" MPa"
            print, 'Delta ScherSp.[Mpa] Min: ', max( du(6,1:n-2)-mittelwert(du(6,1:n-2))),$
             'Max: ', min( du(6,1:n-2)-mittelwert(du(6,1:n-2)))
            IF(dev EQ 'PS')THEN device, /close

            IF(dev EQ 'PS')THEN BEGIN 
               device,filename=filedir+'versatz.c'+strtrim(it, 1)+'.ps', /portrait, $
                xsize=16,ysize=5.5,scale_factor=1.0,bits_per_pixel=8, yoffset= 0.0
               print, 'Printing to '+filedir+"versatz.c."+strtrim(it, 1)+'.ps'
            ENDIF 

            plot,dist(1:n-2), (du(7,1:n-2)-mittelwert(du(7,1:n-2)))/1.0e6, xtitle="x/a",$
             ytitle="Normalspannung [MPa]",psym=4, xstyle=1, xrange=[-1.1, 1.1]
            oplot,dist(1:n-2),du(7,1:n-2)-mittelwert(du(7,1:n-2))
            xyouts, dist(n-30), (du(7, n-2)-mittelwert(du(7,1:n-2)))/1.0e6, strtrim(mittelwert(du(7, *))/1.0e6)
            print, 'Delta NormalSp. [MPa] Min: ', min( du(7,1:n-2)-mittelwert(du(7,1:n-2))),$
             'Max: ', max( du(7,1:n-2)-mittelwert(du(7,1:n-2)))
            print
            IF(dev EQ 'PS')THEN device, /close

            IF(dev EQ 'PS')THEN BEGIN 
               device,filename=filedir+'versatz.d.'+strtrim(it, 1)+'.ps', /portrait, $
                xsize=16,ysize=5.5,scale_factor=1.0,bits_per_pixel=8, yoffset= 0.0
               print, 'Printing to '+filedir+"versatz.d."+strtrim(it, 1)+'.ps'
            ENDIF 

            plot,dist(1:n-2), cstress(du(6,1:n-2), du(7,1:n-2),sdmyu, hp, foff) $
             -mittelwert(cstress(du(6,1:n-2), du(7,1:n-2),sdmyu, hp, foff)),$
             xtitle="x/a",$
             ytitle="!7r!6!iC!n-<!7r!6!iC!n> [Pa]",psym=4, xstyle=1, xrange=[-1.1, 1.1]
            
            xyouts, dist(n-50), cstress(du(6,n-3), du(7,n-3),sdmyu, hp, foff) $
             -mittelwert(cstress(du(6,1:n-2), du(7,1:n-2),sdmyu, hp, foff)),$
             "<!7r!6!iC!n>="+string(format='(f5.1)', mittelwert(cstress(du(6,1:n-2), du(7,1:n-2),sdmyu, hp, foff)))+$
              " Pa"
            IF(dev EQ 'PS')THEN device, /close


            if(it-start eq 0)then begin
               plot,dumean(fault-faultstart,0:it-start),xrange=[0,200] 
               xyouts,it-start+1,dumean(fault-faultstart,it-start),"Mittl. Disl." 
            endif else begin
               IF(propspeed)THEN BEGIN 
                  vmax = 0.0
                  FOR i= 1, it-start-1 DO BEGIN 
                     IF( abs(dumean(fault-faultstart,i)-dumean(fault-faultstart,i-1)) GT vmax)THEN $
                      vmax=abs(dumean(fault-faultstart,i)-dumean(fault-faultstart,i-1))
                  ENDFOR 
                  plot,dumean(fault-faultstart,0:it-start-1),xrange=[0,stoptimeplotit],$
                   yrange=[-vmax, vmax],xtitle="Iterationsschritt",$
                   ytitle="!7d!6/!7d!6t", /nodata
                  FOR i= 1, it-start-1 DO BEGIN 
                     plots, i, dumean(fault-faultstart,i)-dumean(fault-faultstart,i-1), /continue
                  ENDFOR 
               ENDIF ELSE BEGIN 
                  plot,dumean(fault-faultstart,0:it-start-1),xrange=[0,stoptimeplotit],$
                   yrange=[min(dumean),max(dumid)],xtitle="Iterationsschritt",$
                   ytitle="Tangentialer Relativversatz"
                  xyouts,it-start+1,dumean(fault-faultstart,it-start-1),"Mittl. Disl." 
                  oplot,dumid(fault-faultstart,0:it-start-1)
                  xyouts,it-start+1,dumid(fault-faultstart,it-start-1),"Disl. Mitte" 
                  oplot,duend(fault-faultstart,0:it-start-1)
                  xyouts,it-start+1,duend(fault-faultstart,it-start-1),"Disl. Ende" 
               ENDELSE 
            ENDELSE 
            if(normplot)then begin
               plot,dist(*),du(4,*)-du(5,*),title="Fault "+strtrim(fault,1)+", Iteration "+$
                strtrim(it,1),xstyl=1,xrange=[-1.1,1.1],$
                xtitle="Abtand von der Faultmitte / a ",$
                ytitle="Relativer Normalversatz [m]",psym=7
               oplot,dist(*),du(4,*)-du(5,*)
            end		
            
            IF(dev EQ 'X')THEN BEGIN 
               tmp=get_kbrd(1) 
            ENDIF ELSE BEGIN 
               device, /close
            ENDELSE 

            if((tmp eq 'k')or(tmp eq 's'))then stop
            IF(tmp EQ 'g')THEN BEGIN 
               print, "Springe zur Iteration:"
               read, nowgo
            ENDIF 
            
            ;;oplot,dist(*),du(4,*)-du(5,*)
            if(it eq stop)then begin
               set_plot,'PS'
               device,filename='iterationen.eps', bits_per_pixel=8,$
                /encapsulated,xsize=21,ysize=29,scale_factor=1.0
               print,"Printing to iterationen.eps"
               if(max(du(4,*)-du(5,*))ne 0.0)then normplot = 1 else normplot=0
               if(normplot)then !p.multi=[0,0,4,0] else !p.multi=[0,0,3,0]
               maxabsdu = max(abs(du(2,*)-du(3,*)))
               plot,dist(*),(abs(du(2,*)-du(3,*))) - sqrt(1-dist(*)^2)*maxabsdu, $
                title="!6 Verschiebung Fault "+strtrim(fault,1)+", Iteration "+$
                strtrim(it,1),xrange=[-1.1,1.1],xtitle="Abtand von der Faultmitte / a ",$
                ytitle="(Relativer Tangentialversatz - analyt. Loesung auf Max. skaliert)/ m",psym=4
               oplot,dist(*),abs(du(2,*)-du(3,*))
               oplot,dist(*),sqrt(1-dist(*)^2)*maxabsdu,linestyle=1
               plot,dist(1:n-2),du(6,1:n-2)-mittelwert(du(6,1:n-2)),xtitle="Abtand von der Faultmitte / a",$
                title="Scherspannung am Riss - mittl. Scherspannung",$
                ytitle="Spannung / Pa",psym=4
               oplot,dist(1:n-2),du(6,1:n-2)-mittelwert(du(6,1:n-2))
               if(it-start eq 0)then begin
                  plot,dumean(fault-faultstart,0:it-start),xrange=[0,stoptimeplotit] 
                  xyouts,it-start+1,dumean(fault-faultstart,it-start),"Mittl. Disl." 
               endif else begin
                  plot,dumean(fault-faultstart,0:it-start-1),xrange=[0,stoptimeplotit],$
                   yrange=[min(dumean),max(dumean)],xtitle="Iterationsschritt",$
                   ytitle="Tangentialer Relativversatz / m"
                  xyouts,it-start+1,dumean(fault-faultstart,it-start-1),"Mittl. Disl." 
                  oplot,dumid(fault-faultstart,0:it-start-1)
                  xyouts,it-start+1,dumid(fault-faultstart,it-start-1),"Disl. Mitte" 
                  oplot,duend(fault-faultstart,0:it-start-1)
                  xyouts,it-start+1,duend(fault-faultstart,it-start-1),"Disl. Ende" 
               endelse
               if(normplot)then begin
                  plot,dist(*),du(4,*)-du(5,*),title="Fault "+strtrim(fault,1)+", Iteration "+$
                   strtrim(it,1),xrange=[-1.1,1.1],$
                   xtitle="Abtand von der Faultmitte / a ",$
                   ytitle="Relativer Normalversatz / m",psym=7
                  oplot,dist(*),du(4,*)-du(5,*)
               end		
               
               
               
               device,/close
               set_plot,'X'
            end
         endif
         if(static)then begin
            for lp=0,n-1 do begin
               if (du(2,lp) ne du(3,lp)) then tmp='s'
            endfor
         endif
         
         ;; Suche nach - tangentialen - seismischen Events
         
         if(printdata)then begin
            if(it eq start)then begin
               for k=0,n-1 do begin
                  useis(k)=du(2,k)-du(3,k)
                  ustress(k)=du(6,k)
               endfor
            endif else begin
               k=0
               while (k lt n) do begin
                  IF(abs((du(4,k)-du(5,k))) gt 1.0e-09)then begin
                     print, "Normal activity !"
                  ENDIF 
                  if( abs((du(2,k)-du(3,k)) - useis(k) ) gt 1.0e-09)then begin
                     locdtaumean = du(6,k) - ustress(k)
                     locutmean=( (du(2,k)-du(3,k) ) - useis(k))
                     div=1 & hit=0
                     printf,2,it,fault
                     xtmp=dblarr(2)
                     xtmp(0)=du(0,k)+du(2,k)*fvec(0)
                     xtmp(1)=du(1,k)+du(2,k)*fvec(1)
                     while((k lt n-1)and(hit eq 0))do begin
                        if(( (du(2,k+1)-du(3,k+1)) ne useis(k+1) ) and $
                           ((signum((du(2,k+1)-du(3,k+1))-useis(k+1)) eq $
                             signum((du(2,k)-du(3,k))-useis(k))))) then begin
                           k=k+1 & div=div+1
                           locutmean   = locutmean  + ((du(2,k)-du(3,k))-useis(k))
                           locdtaumean = locdtaumean+ (du(6,k)-ustress(k))
                        endif else begin
                           hit=1
                        endelse 
                     endwhile
                     if(div ne 1)then begin
                        printf,2,xtmp(0),xtmp(1)
                        printf,2,du(0,k)+du(2,k)*fvec(0),du(1,k)+du(2,k)*fvec(1)
                        rupl = sqrt((du(0,k)+du(2,k)*fvec(0)-xtmp(0))^2+$
                                      (du(1,k)+du(2,k)*fvec(1)-xtmp(1))^2)
                        printf,2,rupl
                        locutmean = locutmean / double(div)
                        locdtaumean = locdtaumean / double(div)
                     endif else begin
                        if(k ne n-1)then begin
                           rupl=sqrt((du(0,k+1)+du(2,k+1)*fvec(0)-xtmp(0))^2+$
                                    (du(1,k+1)+du(2,k+1)*fvec(1)-xtmp(1))^2)
                        endif else begin
                           rupl=sqrt((du(0,k-1)+du(2,k-1)*fvec(0)-xtmp(0))^2+$
                                    (du(1,k-1)+du(2,k-1)*fvec(1)-xtmp(1))^2)
                        endelse
                        printf,2,xtmp(0)-(rupl/2.0)*fvec(0),xtmp(1)-(rupl/2.0)*fvec(1)
                        printf,2,xtmp(0)+(rupl/2.0)*fvec(0),xtmp(1)+(rupl/2.0)*fvec(1)
                        printf,2,rupl
                     endelse
                     print,locutmean," u_x(AU)", locdtaumean, " Ds(AU)", rupl, " L(AU)"
                     printf,2,locutmean,locdtaumean
                  endif
                  k=k+1
               endwhile
            endelse
         endif
         
         tau(it-start,*) = du(6,*)
         nos(it-start,*) = du(7,*)
         
         csmax(fault-faultstart,it-start)   =max(cstress(du(6,1:n-2),du(7,1:n-2),fmyu,hp,foff))
         csmedian(fault-faultstart,it-start)=$
          mittelwert(cstress(du(6,1:n-2),du(7,1:n-2),fmyu,hp,foff))
         taumedian(fault-faultstart,it-start)=mittelwert(tau(it-start,1:n-2))
         nosmedian(fault-faultstart,it-start)=mittelwert(nos(it-start,1:n-2))
         csmin(fault-faultstart,it-start)= min(cstress(du(6,1:n-2),du(7,1:n-2),fmyu,hp,foff))
         csend(fault-faultstart,it-start) = cstress(du(6,n-2),du(7,n-2),fmyu,hp,foff)
         csmid(fault-faultstart,it-start) = cstress(du(6,n/2),du(7,n/2),fmyu,hp,foff)
         duend(fault-faultstart,it-start)=(du(2,n-2)-du(3,n-2))
         dumid(fault-faultstart,it-start)=(du(2,fix(n/2))-du(3,fix(n/2)))
         dumean(fault-faultstart,it-start)= mittelwert(du(2,*)-du(3,*))
         
         if(static)then begin
            if ((tmp eq 's')or(it eq stop)) then begin
               if(it ne limit)then begin
                  if(verbose)then print,"Aufklaffung tangential bei Iterationsnummer",it
                                ;print,"Winkel: ",((atan(fvec(0),fvec(1))/(2.0*3.1415926535))*360.0)+90.0
                  print,((atan(fvec(0),fvec(1))/(2.0*3.1415926535))*360.0)+90.0,it
                  if((it eq stop)and(verbose))then print,"Am Ende der Zeitteihe !"
                  it=stop
               end
            end
         end
         
         if(0)then begin
            !p.multi=[0,1,2,0]
            plot,du(0,*),(du(6,*)-0.8*(du(7,*)+hp))/1e6,$
             title="Coulomb-Spannung Fault"+strtrim(fix(fault),1)+$
             "Iteration"+strtrim(it)
            plot,du(0,*),du(2,*)
         end
         if(printdata)then begin
            for k=0,n-1 do begin
               useis(k)=(du(2,k)-du(3,k))
               ustress(k)=du(6,k)
            endfor
         endif

      end
      if(newstyle)then close,1
      

   end
   if(printdata)then close,2

   ;;!p.multi=[0,0,2,0]
   for i=0,nrflt-1 do begin
      
      !p.multi=[0,0,nrflt,0]
      plot,csmedian(i,*)/1e6,title="Mittl. C-Spannung, Fault "+strtrim(i+1,1),$
       ytitle="Spannung/Mpa",xtitle="Zeit [Jahre]"
      if ((printdata ne 1)and(plotframe eq 1)) then tmpchar=get_kbrd(1)
   end
   
   if printdata eq 1 then begin
      for i=faultstart,faultstop do begin
         sizev=size(csmedian)
         n=sizev(2)
         openw,1,filedir+"stress_timeseries.flt"+strtrim(i,1)
         printf,1,'# Mittlere Coulombspannung tau-fault_myu*(nos+hp)'
         for j=0,n-1 do begin
            printf,1,j,csmedian(i-1,j)
         end	
         printf,1
         
         printf,1,'# Maximale Coulombspannung'
         for j=0,n-1 do begin
            printf,1,j,csmax(i-1,j)
         end	
         printf,1
         
         printf,1,'# Minimale Coulombspannung'
         for j=0,n-1 do begin
            printf,1,j,csmin(i-1,j)
         end	
         printf,1
         
         printf,1,'# Mittlere Scherspannung'
         for j=0,n-1 do begin
            printf,1,j,taumedian(i-1,j)
         end	
         printf,1
         
         printf,1,'# Mittlere Normalspannung'
         for j=0,n-1 do begin
            printf,1,j,nosmedian(i-1,j)
         end	
         printf,1
         printf,1,'# Coulombspannung am Rissende'
         for j=0,n-1 do begin
            printf,1,j,csend(i-1,j)
         end	
         printf,1
         printf,1,'# Coulombspannung an der Rissmitte'
         for j=0,n-1 do begin
            printf,1,j,csmid(i-1,j)
         end	
         printf,1
         printf,1,'# Delta du_t am Rissende'
         for j=0,n-1 do begin
            printf,1,j,duend(i-1,j)
         end	
         printf,1
         printf,1,'# Delta du_t aa der Rissmitte'
         for j=0,n-1 do begin
            printf,1,j,dumid(i-1,j)
         end	
         printf,1
         printf,1,'# mittleres Delta du_t'
         for j=0,n-1 do begin
            printf,1,j,dumean(i-1,j)
         end	
         printf,1
         
         close,1
         
         openw,1,filedir+"stress_timeseries.flt"+strtrim(i,1)+".csmedian"
         printf,1,n
         printf,1,csmedian(i-1,*)
         close,1
         openw,1,filedir+"stress_timeseries.flt"+strtrim(i,1)+".csmax"
         printf,1,n
         printf,1,csmax(i-1,*)
         close,1
         openw,1,filedir+"stress_timeseries.flt"+strtrim(i,1)+".taumedian"
         printf,1,n
         printf,1,taumedian(i-1,*)
         close,1
         openw,1,filedir+"stress_timeseries.flt"+strtrim(i,1)+".nosmedian"
         printf,1,n
         printf,1,nosmedian(i-1,*)
         close,1
         openw,1,filedir+"stress_timeseries.flt"+strtrim(i,1)+".csmin"
         printf,1,n
         printf,1,csmin(i-1,*)
         close,1
         openw,1,filedir+"stress_timeseries.flt"+strtrim(i,1)+".csend"
         printf,1,n
         printf,1,csend(i-1,*)
         close,1
         openw,1,filedir+"stress_timeseries.flt"+strtrim(i,1)+".csmid"
         printf,1,n
         printf,1,csmid(i-1,*)
         close,1
         openw,1,filedir+"stress_timeseries.flt"+strtrim(i,1)+".duend"
         printf,1,n
         printf,1,duend(i-1,*)
         close,1
         openw,1,filedir+"stress_timeseries.flt"+strtrim(i,1)+".dumid"
         printf,1,n
         printf,1,dumid(i-1,*)
         close,1
         openw,1,filedir+"stress_timeseries.flt"+strtrim(i,1)+".dumean"
         printf,1,n
         printf,1,dumean(i-1,*)
         close,1
         
      end
   end
   spawn, "gzip -f "+filedir+"profil*"
   spawn, "gzip -f "+filedir+"stress_timeseries*"

END
if (dev eq 'PS' AND plotframe NE 1) then device,/close
end












