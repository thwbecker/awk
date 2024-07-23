
;Routine zum Plotten des Spannungsfeldes eines Gebietes 
;pro pgstr,start,stop,range,pr,clb1,clb2,clb3,fms,sms,deg,clbx,clby

;print,'pgstr startindex [stopindex stress-value-range printing][clb1 clb2 clb3]'
;if(n_params() lt 4)then pr=0
;if(n_params() lt 3)then range=2e8
;if(n_params() lt 2)then stop=start
;if(n_params() lt 1)then exit
;print,'Executing with ',start,stop,range,pr

PI = 3.14159265358979


;; Postscript ?
pr=0

;; Daten neu einlesen ?
readdata=1 

;; Vorspannung Simple Shear
tau0 = 2.0e6

;; Winkel der Bruchflaechenorinetirung fuer Coulomb-Spannung
cazi = ((45-15.48)/180.0)*PI

;; Elastische Parameter
nyu = 0.25 &  emodul= 5.0e10

;; Was soll geplottet werden ?
duplot = 0 &  stressplot=1 &  csfieldwrite=0
contourplots = 1 &  profiles=0


fixdushift=1.0
duh0= -0.0 & mode2=0

plarrow=0 & sur=1 & windowsize=500
xwindowsize=1.5 * windowsize & ywindowsize = 2.0 * windowsize


readflt=1 

 
midat = 500.0 &  normlength=50.0
xmag=1 & ymag =1 & xoff=0 & yoff=0
xmin=10 & xmax=990 & ymin = 10 & ymax = 990
spacescale = 100
textcolor=50

IF(pr)THEN dev = 'PS' ELSE dev = 'X'

start=1 & stop = 1

range =1.5e8 
close,1,2,3
;modeldir="arc_faults_again/55/"
;modeldir="static_sngl_cracks/sngl_crack.1.5.0.200/"
;modeldir="one_crack/stressexample/"
;modeldir = "iteration_interpolation/fixed_stress.2/"
;modeldir = "en_echelon/5/"
;modeldir = "eff_modul/12/"
;modeldir = "stress_examples/negoldmeshcreated_data/outerstress/"
;modeldir = "tapering_functions/cossquare/"
;modeldir = "rotation/relaxed_du/"
modeldir = "nosplit/"
;modeldir = ""
endofname = ".xyz"
filedir="/home/datdyn2/becker/finel/"+modeldir
;filedir="/home/geodyn1/becker/finel/results/"+modeldir




normv=dblarr(2) & tangv = dblarr(2)
print, "Caculating normal and tangential stresses along plane", (cazi/PI)*180
tangv=[sin(cazi),cos(cazi)]
normv(0) = tangv(1) & normv(1)= -tangv(0)

cmin= -range & cmax= range
region=range*2.0
print, "TAU0 IS SET TO:", tau0


if(readflt)then BEGIN ;; EINLESEN DER FAULTCOORDINATEN

   openr,1,filedir+"faultcoord"
   ;openr, 1, "/home/bigusr/becker/model_data/arc_faults_again/50/faultcoord"
   readf,1,nrflt
   IF(nrflt)THEN BEGIN 
      fc=dblarr(4,nrflt)
      readf,1,fc
      fc=(fc-midat)/normlength
   ENDIF 
   close,1
endif else begin
   print,"Faultcoordinaten !"
endelse
	

for nr=start,stop do BEGIN ;; HAUPTSCHLEIFE	
   
   if (stressplot) then BEGIN ;; EINLESEN DER SPANNUNGSFELDER

      openr,1, filedir+"stre11."+strtrim(nr,1)+endofname
      print,'Reading ',filedir+"stre??."+strtrim(nr,1)+endofname
      openr,2, filedir+"stre12."+strtrim(nr,1)+endofname
      openr,3, filedir+"stre22."+strtrim(nr,1)+endofname
      for i=1,3 do begin
         readf,i,time,fmyu,sdmyu,nomyu,hp,off
         readf,i,m 
      end
      n=sqrt(m)
   
      b = ( 2.0 * off ) / (sqrt(1.0 + fmyu^2) - fmyu)
      a=( sqrt(1+fmyu^2) + fmyu )/ ( sqrt(1+fmyu^2) - fmyu )
   
      if (nr eq start)then spstre=dblarr(5,stop-start+1)
      clb=dblarr(3,n,n) & 	clb1=dblarr(n,n)	
      clb2=dblarr(n,n) & 	clb3=dblarr(n,n)
      clbn=dblarr(n,n) & 	clbt=dblarr(n,n)
      clbx=dblarr(n,n) &	clby=dblarr(n,n) & pf=dblarr(n,n)
      beta=dblarr(n,n)
      half=n/2
      cs=dblarr(n,n) & tcs=dblarr(n,n)
      fms=dblarr(n,n) & sms=dblarr(n,n) & deg=dblarr(n,n)
      fstrex=dblarr(n,n) & fstrey=dblarr(n,n)
      sstrex=dblarr(n,n) & sstrey=dblarr(n,n)
   
      
      readf, 1, clb & close,1
      clbx(*,*)= clb(0,*,*)*xmag+xoff & clby(*,*)=clb(1,*,*)*ymag+yoff 
      maxclbx = max(clbx)
      clbx=(clbx-midat)/normlength & clby=(clby-midat)/normlength
      clb1(*,*)= clb(2,*,*)
      readf,2,clb & clb2(*,*)= clb(2,*,*) & close,2
      readf,3,clb & clb3(*,*)= clb(2,*,*) & close,3
      clbn= -sigma_n(clb1,clb2,clb3,normv,tangv)
      clbt= -sigma_t(clb1,clb2,clb3,normv,tangv)

      ;; BERECHNUNG DER HAUPTSPANNUNGEN
 
      x1=double(0.0) & x2=double( 0.0) & r =double( 0.0)
      for i=0,n-1 do begin
         for j=0,n-1 do begin
            x1=(clb1(i,j) + clb3(i,j))/2.0
            x2=(clb1(i,j) - clb3(i,j))/2.0
            r = sqrt(x2*x2 + clb2(i,j) * clb2(i,j) )
            fms(i,j)=x1 + r & sms(i,j) = x1 - r
            deg(i,j)=45.0
            if(x2 ne 0.0)then $
              deg(i,j)= 22.5*(atan(clb2(i,j),x2)/atan(1.0))
         end
      end
      
      clb1= -clb1 & clb2 = -clb2 & clb3 = -clb3
      cs= -sms & sms= -fms & fms= cs &  deg=deg+90.0
      
      minclb1=min(clb1) & maxclb1=max(clb1) & medclb1=mittelwert(clb1)
      print,'MAX s11:',maxclb1,'MIN s11',minclb1,' Mittelwert',medclb1
      minclb2=min(clb2) & maxclb2=max(clb2) & medclb2=mittelwert(clb2)
      print,'MAX s12:',maxclb2,'MIN s12',minclb2,' Mittelwert',medclb2
      minclb3=min(clb3) & maxclb3=max(clb3) & medclb3=mittelwert(clb3)
      print,'MAX s22:',maxclb3,'MIN s22',minclb3,' Mittelwert',medclb3
      
      cs = cstress(fms,sms,a,hp,b)        - cstress(tau0,-tau0,a,hp,b)
      tcs= cstress(clbt,clbn,fmyu,hp,off) - $
        cstress(tau0*sin(2*(PI/4-cazi)),-tau0*cos(2*(PI/4-cazi)),fmyu,hp,off) 
      
      if(off ne 0.0)then begin
         pf= ((fms-sms) * fmyu * sqrt(((off^2)*(1+fmyu^2))/(fmyu^2))) / $
           (off*(2*off+fmyu*(fms+hp)+fmyu*(sms+hp) ))
      end
      if(off eq 0.0)then begin
         pf= (fmyu*(fms+sms+2*hp)) / ( sqrt(1+fmyu^2)*(fms-sms))
      end
      
      np=0.0
      sstrex=  - (sms+np) * cos((deg*3.1415927)/180.0) 
      sstrey=  - (sms+np) * sin((deg*3.1415927)/180.0)
      fstrex=  - (fms+np) * sin((deg*3.1415927)/180.0) 
      fstrey=    (fms+np) * cos((deg*3.1415927)/180.0)
      
      for i=0,n-1 do begin
         for j=0,n-1 do begin
            if ((fms(i,j)+sms(i,j)+2.0*hp) ne 0.0)then $
              beta(i,j)=(3.1415927-asin(((fms(i,j)-sms(i,j))/2.0) / $
                                        ((2.0*hp+fms(i,j)+sms(i,j))/2.0)))/2.0
         end
      end
      lev=30
      levvec=dblarr(lev-1)
      levvec(lev/2)=0.0
      for i=1,(lev-2)/2 do begin
         levvec((lev/2)+i-1)= 0.0 + double(i)*(range/double(lev/2-1))
         levvec((lev/2)-i-1)= 0.0 - double(i)*(range/double(lev/2-1))
      end
      print,levvec
      bgcolor=0
      clab=intarr(29)
      clab(*)=0 & clab(14)=1
      levvec2=dblarr(lev-1)
      for i=1,(lev-2)/2 do begin
         levvec2((lev/2)+i-1)= 0.0 + double(i)*(0.5/double(lev/2-1))
         levvec2((lev/2)-i-1)= 0.0 - double(i)*(0.5/double(lev/2-1))
      end
      levvec2=levvec2 + 0.5
      print,levvec2
   END 

   IF(duplot)THEN BEGIN ;; EINLESEN DER VERSCHIEBUNGSFELDER
 
      openr, 1, filedir+"dugmtx.dat.xyz"
      readf, 1, ndu
      openr, 2, filedir+"dugmty.dat.xyz"
      readf, 2, ndu
      m = fix(sqrt(ndu))
      du1 = dblarr(3, m,m) &  du2 = dblarr(3, m,m)
      dux = dblarr(m) &  duy = dblarr(m)
      duxc = dblarr(m, m) & duyc=dblarr(m, m)
      print, "Reading "+filedir+"dugmtx.dat.xyz"
      readf, 1, du1 &  close, 1
      print, "Reading "+filedir+"dugmty.dat.xyz"
      readf, 2, du2 &  close, 2
      dux= reform(du1(2, *, *))
      duy= reform(du2(2, *, *))
      duxc = reform(du1(0,*,*))
      duyc = reform(du1(1,*,*))
      duxc = (duxc-midat)/normlength
      duyc = (duyc-midat)/normlength
   ENDIF 


   if(csfieldwrite)then BEGIN ;; AUSGABE DER COULOMBSPANNUNG
      openw,1,filedir+"csfield.dat"
      printf,1,n
      printf,1,cs
      close,1
      openw,1,filedir+"clbx.dat"
      printf,1,clbx
      close,1
      openw,1,filedir+"clby.dat"
      printf,1,clby
      close,1
   end	
     
   IF(contourplots) THEN BEGIN ;; CONTOURPLOTS ********************

      ;; SCHERSPANNUNG

      IF(pr)THEN BEGIN 
         dev = 'PS'
         set_plot, dev
         device, file=filedir+"s12cont.eps", /encapsulated, xsize=15, ysize=15, bits_per_pixel=16
         print, 'Printing to "+filedir+"s12cont.eps"
      ENDIF ELSE BEGIN 
         dev = 'X'
         set_plot,dev
         window, 0, xsize=300, ysize=900
         wset, 0
         !p.multi = [0, 1, 3, 0]
      ENDELSE 
      ntau = abs(tau0)
      nmin = min(clb2/ntau) &  nmax=max(clb2/ntau)
      IF nmin NE 0.0 THEN nmin = 0.0
      levvec = nmin+dindgen(29)*((nmax-nmin)/30)
      print, levvec
      smoothfactor = 3 &  cssize=2.5


      IF(mittelwert(clb2) <  0)THEN f1 = -1.0 ELSE f1 = 1.0

      shade_surf,smooth(clb2/ntau,smoothfactor),clbx,clby,shade=bytscl(smooth(clb2/ntau,smoothfactor)),ax=90,az=0,$
        xstyle=4, ystyle=4, zstyle=4
      contour, smooth(clb2/ntau, smoothfactor), clbx, clby,  level=[f1*0.2], xtitle="!6x/a", ytitle="!6y/a", $
        title="!7r!6!ixy!n!6/!7r!6!i!7Y!6!n", /noerase, xstyle=1, ystyle=1
      contour, smooth(clb2/ntau, smoothfactor), clbx, clby,  level=[f1*0.4], /overplot
      contour, smooth(clb2/ntau, smoothfactor), clbx, clby,  level=[f1*0.6], /overplot
      contour, smooth(clb2/ntau, smoothfactor), clbx, clby,  level=[f1*0.8], /overplot
      contour, smooth(clb2/ntau, smoothfactor), clbx, clby,  level=[f1*0.9], /overplot,  /follow
      contour, smooth(clb2/ntau, smoothfactor), clbx, clby,  level=[f1*0.95], /overplot,  /follow
      contour, smooth(clb2/ntau, smoothfactor), clbx, clby,  level=[f1*1.0], /overplot, /downhill, /follow
      contour, smooth(clb2/ntau, smoothfactor), clbx, clby,  level=[f1*1.05], /overplot,  /follow
      contour, smooth(clb2/ntau, smoothfactor), clbx, clby,  level=[f1*1.1], /overplot,  /follow
      contour, smooth(clb2/ntau, smoothfactor), clbx, clby,  level=[f1*1.2], /overplot
      contour, smooth(clb2/ntau, smoothfactor), clbx, clby,  level=[f1*1.4], /overplot
      contour, smooth(clb2/ntau, smoothfactor), clbx, clby,  level=[f1*1.6], /overplot
      plots,-1,0 & plots,1,0,/continue,thick=5
      xyouts, 0, 3, "!5+!6", charsize=cssize & xyouts, 0, -3, "!5+!6", charsize=cssize
      xyouts, -3.5, 0, "!5+!6", charsize=cssize & xyouts, 3.5, 0, "!5+!6", charsize=cssize
      xyouts, -3, -3, "!5-!6", charsize=cssize & xyouts, 3, -3, "!5-!6", charsize=cssize
      xyouts, -3, 3, "!5-!6", charsize=cssize & xyouts, 3, 3, "!5-!6", charsize=cssize
      IF(pr)THEN device, /close

      ;;  MITTLERE NORMALSPANNUNG

      IF(pr)THEN BEGIN 
         device , file=filedir+"mnscont.eps", /encapsulated, xsize=15, ysize=15, bits_per_pixel=16
         print, "ptinting to mnscont.eps"
      ENDIF 
      l = n*0.0 &  r=1.0*(n-1)
      ntau = abs(tau0)
      shade_surf,smooth((clb1(l:r, l:r)+clb3(l:r, l:r))/(2.0*ntau),smoothfactor ),clbx,clby,$
        shade=bytscl(smooth((clb1(l:r, l:r)+clb3(l:r, l:r))/(2.0*ntau),smoothfactor )),ax=90,az=0,$
        xstyle=4, ystyle=4, zstyle=4
      contour, smooth((clb1(l:r, l:r)+clb3(l:r, l:r))/(2.0*ntau),smoothfactor ), clbx(l:r, l:r), clby(l:r, l:r),/noerase, $
        /follow, levels=0.0,  title="!6(!7r!i!6xx!n+!7r!6!iyy!n)/(2!7r!iY!6!n)", xtitle="!6x/a", ytitle="!6y/a", $
        xstyle=1, ystyle=1
      contour, smooth((clb1(l:r, l:r)+clb3(l:r, l:r))/(2.0*ntau),smoothfactor ), clbx(l:r, l:r), clby(l:r, l:r), $
         levels=[0.25], /overplot
      contour, smooth((clb1(l:r, l:r)+clb3(l:r, l:r))/(2.0*ntau),smoothfactor ), clbx(l:r, l:r), clby(l:r, l:r), $
         levels=[-0.25], /overplot
      contour, smooth((clb1(l:r, l:r)+clb3(l:r, l:r))/(2.0*ntau),smoothfactor ), clbx(l:r, l:r), clby(l:r, l:r), $
        /follow, levels=[0.5], /overplot
      contour, smooth((clb1(l:r, l:r)+clb3(l:r, l:r))/(2.0*ntau),smoothfactor ), clbx(l:r, l:r), clby(l:r, l:r), $
        /follow, levels=[-0.5], /overplot
      contour, smooth((clb1(l:r, l:r)+clb3(l:r, l:r))/(2.0*ntau),smoothfactor ), clbx(l:r, l:r), clby(l:r, l:r), $
         levels=[0.75], /overplot
      contour, smooth((clb1(l:r, l:r)+clb3(l:r, l:r))/(2.0*ntau),smoothfactor ), clbx(l:r, l:r), clby(l:r, l:r), $
         levels=[-0.75], /overplot
      ;;contour, smooth((clb1(l:r, l:r)+clb3(l:r, l:r))/(2.0*ntau),smoothfactor ), clbx(l:r, l:r), clby(l:r, l:r), $
      ;;  /follow, levels=[0.05], /overplot
      ;;contour, smooth((clb1(l:r, l:r)+clb3(l:r, l:r))/(2.0*ntau),smoothfactor ), clbx(l:r, l:r), clby(l:r, l:r), $
      ;;  /follow, levels=[-0.05], /overplot
      contour, smooth((clb1(l:r, l:r)+clb3(l:r, l:r))/(2.0*ntau),smoothfactor ), clbx(l:r, l:r), clby(l:r, l:r), $
        /follow, levels=[1.0], /overplot
      contour, smooth((clb1(l:r, l:r)+clb3(l:r, l:r))/(2.0*ntau),smoothfactor ), clbx(l:r, l:r), clby(l:r, l:r), $
        /follow, levels=[-1.0], /overplot
      plots,-1,0 & plots,1,0,/continue,thick=4
      xyouts, -3, 3, "!5-!6", charsize=cssize
      xyouts, -3, -3, "!5+!6", charsize=cssize
      xyouts, 3, 3, "!5+!6", charsize=cssize
      xyouts, 3, -3, "!5-!6", charsize=cssize
      IF(pr)THEN device, /close
   ENDIF       



   if(profiles) then BEGIN  ;; profil der scherspannung
      dev = 'X'
      set_plot, dev
      plot,(clbx(*,half)-midat)/normlength,clb2(*,half)/emodul,$
        title="!6Scherspannung (y="+string(format='(g5.4)',clby(0,half))+") !7D!6u!imax!n=1m",$
        yrange=[-0.03,0.03],xtitle="(x-500m)/a",ytitle="!6Spannung/E-Modul",ystyle=1
      xwerte = (dindgen(100)/100)*2.0-1.0
      oplot, xwerte, sqrt(1.0-xwerte*xwerte)*max(clb2(*,half)/emodul)
      
      dev = 'PS'
      set_plot, dev 
      device,filename='stre.eps',bits_per_pixel=16,$
        /encapsulated,xsize=16,ysize=14,scale_factor=1.0,xoffset=1
      plot,(clbx(*,half)-midat)/normlength,clb2(*,half)/emodul,$
        title="!6Scherspannung (y="+string(format='(g5.4)',clby(0,half))+") !7D!6u!imax!n=1m",$
        yrange=[-0.03,0.03],xtitle="(x-500m)/a",ytitle="!6Spannung/E-Modul",ystyle=1
      print,'Plotting to stre.eps'
      device,/close
      dev = 'X'
      set_plot, dev
      spstre(0,nr-start)=clb2(40,50)/1e9	
      spstre(1,nr-start)=clb2(44,50)/1e9	
      spstre(2,nr-start)=clb2(50,50)/1e9	
      spstre(3,nr-start)=clb2(56,50)/1e9	
      spstre(4,nr-start)=clb2(60,50)/1e9	
   END 
   
   if(0) then BEGIN ;; PROFIL DER SCHERSPANNUNG UND AUSGABE EINES GNUPLOT FILES
      sfac = (fixdushift*emodul)/((1-nyu)*(1+nyu)*4*normlength)
      print, "Stressfactor is", sfac
      
      x=dindgen(100)/100.0+1.00001
      plot,clbx(*,half),-clb2(*,50)/sfac,$
        title="!6Scherspannung bei y = "+string(format='(g3.1)',clby(0,half)),charsize=1.0,$
        xtitle="x/a",ytitle="!6Spannung/S-Fac",psym=7
      print, "Printing to strepro"
      openw, 1, "strepro.dat"
      FOR i=0, n-1 DO BEGIN 
         printf, 1, clbx(i,half),-clb2(i,50)/emodul
      ENDFOR 
      close, 1
      print, "Stressfactor is", sfac, "
      print, "fixdushift", fixdushift
   END 

   if(0) then BEGIN ;; Scherspannung
      contour,smooth(clb2-2.0e8,2),clbx,clby,levels=levvec,/follow,/fill,$
        title="!7D!6Scherspannung !7r!6!ixy!n!6",xtitle="x/m",$
        ytitle="y/m",color=textcolor
      contour,smooth(clb2-2.0e8,2),clbx,clby,levels=[-2e8,-1e8,0,1e8,2e8],$
        /follow,/overplot,C_labels=[1,1,1,1,1]
      plots,450,500 & plots,550,500,/continue,thick=4
   end

   if(0) then begin
      contour,smooth(clb1+clb3,2),clbx,clby,levels=levvec,/fill,/follow,$
        title="!7D!6(tr(!7r!6!iij!n)!6)",$
        ytitle="y/m",color=textcolor,xtitle="x/m"
      contour,smooth(clb1+clb3,2),clbx,clby,levels=[-2e8,0,2e8],/follow,$
        c_labels=[1,1,1],/overplot
      ;;plots,450,500 & plots,550,500,/continue,thick=4
   end

   if(0) then begin
      contour,smooth(clb3,2),clbx,clby,levels=levvec,/fill,/follow,$
        title="!7Dr!6!iyy!n!6",$
        ytitle="y/m",xtitle="x/m",color=textcolor
      contour,smooth(clb3,2),clbx,clby,levels=[-2e8,0,2e8],/follow,$
        c_labels=[1,1,1],/overplot
      plots,450,500 & plots,550,500,/continue,thick=4
   end

   if(0) then begin
      step=1 & xu=0 & yu = 0 & len = 700
      for i=0,254,step do begin
         dx=35.0 & dy=len/(255.0/step) 
         polyfill,[xu,xu+dx,xu+dx,xu],$
           [yu-dy/2.0+i*dy,yu-dy/2.0+i*dy,yu-dy/2.0+(i+1.0)*dy,$
            yu-dy/2.0+(i+1.0)*dy],color=i,/device
         if(fix(i/10.0) eq (i/10.0))then $
           xyouts,xu+dx*5.0,yu+(i-1)*dy-dy/2.0,$
           strtrim((((i-127.0)/255.0)*range)*1e-06,1),$
           color=textcolor,/device
      end
      xyouts,xu+dx*5.0,yu+300*dy,"MPa",charsize=2.0,color=textcolor,/device
   end


   if(0) then begin
      contour,smooth( (abs(fms-sms)/2.0) - 0.6*((fms+sms)/2.0),2),$
        clbx,clby,/fill,levels=levvec,$
        xrange=[200,800],yrange=[200,800]
   end
   
   if(0)then begin

      lx=20 & rx=80 
      ly=lx & ry=rx
      stremax=max(abs(fms)) & if (max(abs(sms)) gt stremax)then $
        stremax=max(abs(sms))
      strefac=((rx-lx)*0.1)/stremax
      c1=200 & c2 =100
      plot,clbx,clby,xrange=[clbx(lx,ly),clbx(rx,ly)],$
        yrange=[clby(lx,ry),clby(lx,ly)],/nodata,xstyl=1,ystyle=1
      for i=lx,rx,fix((rx-lx) / 30) do begin
         for j=ly,ry,fix((ry-ly) / 30) do begin
            x0=clbx(i,j) & y0=clby(i,j)
            x1=clbx(i,j)  + fstrex(i,j) * strefac
            y1=clby(i,j)  + fstrey(i,j) * strefac
            x2=clbx(i,j)  + sstrex(i,j) * strefac	
            y2=clby(i,j)  + sstrey(i,j) * strefac
            x3=clbx(i,j)  - fstrex(i,j) * strefac
            y3=clby(i,j)  - fstrey(i,j) * strefac
            x4=clbx(i,j)  - sstrex(i,j) * strefac
            y4=clby(i,j)  - sstrey(i,j) * strefac
            arrow,x1,y1,x0,y0,/data,hsize= -0.3,color=c1,/solid
            arrow,x0,y0,x2,y2,/data,hsize= -0.3,color=c2,/solid
            arrow,x3,y3,x0,y0,/data,hsize= -0.3,color=c1,/solid
            arrow,x0,y0,x4,y4,/data,hsize= -0.3,color=c2,/solid
            
         end
      end
	
      ;;velovect,fstrex(left:right,left:right),fstrey(left:right,left:right),$
      ;;	/noerase,color=100
      ;;velovect,sstrex(left:right,left:right),sstrey(left:right,left:right),$
      ;;	/noerase,color=50
      
   END 
	

   if(contourplots) then BEGIN ;; contourplot der optimalen coulombspannnung

      IF(pr)THEN BEGIN 
         dev = 'PS'
         set_plot, dev
         device, file=filedir+"cscont.eps", /encapsulated, xsize=15, ysize=15, bits_per_pixel=16
         print, "printing to cscont.eps"
      ENDIF ELSE BEGIN 
         dev = 'X'
         set_plot, dev
         wset, 0
      ENDELSE  
      ni = 1 
      !p.multi = [0, sqrt(ni), sqrt(ni), 0]
      lvmyu = 0.0 & rvmyu= 0.8
      mustep = (rvmyu-lvmyu)/double(ni)
      IF (mustep EQ 0.0) THEN mustep = 1.0
      ;;   FOR varmyu=lvmyu, rvmyu, mustep DO BEGIN 

      FOR varmyu=0.6, 0.6  DO BEGIN 
         bvar = ( 2.0 * off ) / (sqrt(1.0 + varmyu^2) - varmyu)
         avar=( sqrt(1+varmyu^2) + varmyu )/ ( sqrt(1+varmyu^2) - varmyu )
         ntau = abs(tau0)
         shade_surf, smooth(cstress(fms,sms,avar,hp,bvar)- cstress(ntau,-ntau,avar,hp,bvar),smoothfactor)/ntau,$
           clbx,clby, xstyle=4, ystyle=4, zstyle=4, $
           shade=bytscl(smooth(cstress(fms,sms,avar,hp,bvar)- cstress(ntau,-ntau,avar,hp,bvar),smoothfactor)/ntau ), $
           ax=90, az=0
         contourcolor = 255
         contour,smooth(cstress(fms,sms,avar,hp,bvar)- cstress(ntau,-ntau,avar,hp,bvar),smoothfactor)/ntau,$
           clbx,clby,levels=0.0,/nodata,xstyle=1, ystyle=1, $
           title="!7Dr!6!iC!e1!n/!7r!iy!n!6 mit !7l!i!6s!n="+string(format='(f4.2)',varmyu),$
           xtitle="!6x/a",ytitle="!6y/a", /noerase, color=0
         contour,smooth(cstress(fms,sms,avar,hp,bvar)- cstress(ntau,-ntau,avar,hp,bvar),smoothfactor)/ntau,$
           clbx,clby,levels=[0.0],/follow,/overplot, /downhill, color=contourcolor
         contour,smooth(cstress(fms,sms,avar,hp,bvar)- cstress(ntau,-ntau,avar,hp,bvar),smoothfactor)/ntau,$
           clbx,clby,levels=[0.5],/follow,/overplot, color=contourcolor
         contour,smooth(cstress(fms,sms,avar,hp,bvar)- cstress(ntau,-ntau,avar,hp,bvar),smoothfactor)/ntau,$
           clbx,clby,levels=[-0.5],/follow,/overplot, color=contourcolor
         contour,smooth(cstress(fms,sms,avar,hp,bvar)- cstress(ntau,-ntau,avar,hp,bvar),smoothfactor)/ntau,$
           clbx,clby,levels=[0.25],/overplot, color=contourcolor
         contour,smooth(cstress(fms,sms,avar,hp,bvar)- cstress(ntau,-ntau,avar,hp,bvar),smoothfactor)/ntau,$
           clbx,clby,levels=[1.0],/follow,/overplot, color=contourcolor
         contour,smooth(cstress(fms,sms,avar,hp,bvar)- cstress(ntau,-ntau,avar,hp,bvar),smoothfactor)/ntau,$
           clbx,clby,levels=[1.5],/follow,/overplot, color=contourcolor
         contour,smooth(cstress(fms,sms,avar,hp,bvar)- cstress(ntau,-ntau,avar,hp,bvar),smoothfactor)/ntau,$
           clbx,clby,levels=[-0.25],/overplot, color=contourcolor
         contour,smooth(cstress(fms,sms,avar,hp,bvar)- cstress(ntau,-ntau,avar,hp,bvar),smoothfactor)/ntau,$
           clbx,clby,levels=[-1.0],/follow,/overplot, color=contourcolor
         contour,smooth(cstress(fms,sms,avar,hp,bvar)- cstress(ntau,-ntau,avar,hp,bvar),smoothfactor)/ntau,$
           clbx,clby,levels=[-1.5],/follow,/overplot, color=contourcolor
         contour,smooth(cstress(fms,sms,avar,hp,bvar)- cstress(ntau,-ntau,avar,hp,bvar),smoothfactor)/ntau,$
           clbx,clby,levels=[0.75],/overplot, color=contourcolor
         contour,smooth(cstress(fms,sms,avar,hp,bvar)- cstress(ntau,-ntau,avar,hp,bvar),smoothfactor)/ntau,$
           clbx,clby,levels=[-0.75],/overplot, color=contourcolor

         plots,-1,0 & plots,1,0,/continue,thick=5, color=contourcolor
         
      ENDFOR  

      xyouts, -3.25, -3, "!5-!6", charsize=cssize
      xyouts, 3.25, -3, "!5-!6", charsize=cssize
      xyouts, -3.25, 3, "!5-!6", charsize=cssize
      xyouts, 3.25, 3, "!5-!6", charsize=cssize
      xyouts, .5, -3, "!5+!6", charsize=cssize
      xyouts, -.5, 3, "!5+!6", charsize=cssize
      xyouts, -3.25, 0, "!5+!6", charsize=cssize
      xyouts, 3.25, 0, "!5+!6", charsize=cssize
      
      IF(pr)THEN device, /close
   END 

   if(0) then BEGIN ;; contourplot der horizontalen bruchflaechen
      IF(pr)THEN BEGIN 
         set_plot, 'PS'
         device, file=filedir+"tcscont.eps", /encapsulated, xsize=15, ysize=15
         print, "printing to tcscont.eps"
      ENDIF 
      ni = 1 & delmyu=0.0
      !p.multi = [0, sqrt(ni), sqrt(ni), 0]
      lvmyu = fmyu-delmyu & rvmyu=fmyu+delmyu
      mustep = (rvmyu-lvmyu)/double(ni)
      IF (mustep EQ 0.0) THEN mustep = 1.0
      FOR varmyu=lvmyu, rvmyu, mustep DO BEGIN 
         
         ntau = abs(tau0)
         contour,smooth(cstress(clbt,clbn,varmyu,hp,off)- cstress(ntau,0.0,varmyu,hp,off),2)/ntau,$
           clbx,clby,levels=0.0,/nodata,$
           title="!7Dr!6!iC!n mit !7l=!6"+string(format='(g3.1)',varmyu),$
           xtitle="x/a",ytitle="y/a"
         contour,smooth(cstress(clbt,clbn,varmyu,hp,off)- cstress(ntau,0.0,varmyu,hp,off),2)/ntau,$
           clbx,clby,levels=[0.0],/follow,/overplot, /downhill
         contour,smooth(cstress(clbt,clbn,varmyu,hp,off)- cstress(ntau,0.0,varmyu,hp,off),2)/ntau,$
           clbx,clby,levels=[0.25],/follow,/overplot
         contour,smooth(cstress(clbt,clbn,varmyu,hp,off)- cstress(ntau,0.0,varmyu,hp,off),2)/ntau,$
           clbx,clby,levels=[0.5],/follow,/overplot
         contour,smooth(cstress(clbt,clbn,varmyu,hp,off)- cstress(ntau,0.0,varmyu,hp,off),2)/ntau,$
           clbx,clby,levels=[1.0],/follow,/overplot
         contour,smooth(cstress(clbt,clbn,varmyu,hp,off)- cstress(ntau,0.0,varmyu,hp,off),2)/ntau,$
           clbx,clby,levels=[1.5],/follow,/overplot
         contour,smooth(cstress(clbt,clbn,varmyu,hp,off)- cstress(ntau,0.0,varmyu,hp,off),2)/ntau,$
           clbx,clby,levels=[-0.25],/follow,/overplot
         contour,smooth(cstress(clbt,clbn,varmyu,hp,off)- cstress(ntau,0.0,varmyu,hp,off),2)/ntau,$
           clbx,clby,levels=[-0.5],/follow,/overplot
         contour,smooth(cstress(clbt,clbn,varmyu,hp,off)- cstress(ntau,0.0,varmyu,hp,off),2)/ntau,$
           clbx,clby,levels=[-1.0],/follow,/overplot
         contour,smooth(cstress(clbt,clbn,varmyu,hp,off)- cstress(ntau,0.0,varmyu,hp,off),2)/ntau,$
           clbx,clby,levels=[-1.5],/follow,/overplot
         plots,-1,0 & plots,1,0,/continue,thick=4
         
         
      ENDFOR 
      
      IF(pr)THEN device, /close
   end



   if(0) then begin
      contour,smooth(tcs,2),clbx,clby,levels=levvec,/fill,$
        title="!7D!6Coulombspannung: !10#!7r!6!it!n!10#!7 - l * r!i!6n!n!6",$
        xtitle="x/m",ytitle="y/m",color=textcolor
      contour,smooth(tcs,2),clbx,clby,levels=[-2e8,0,2e8],/follow,$
        c_labels=[1,1,1],/overplot
      plots,450,500 & plots,550,500,/continue,thick=4
   end
   
   if(0) then BEGIN
      ;;          AUGABE VON SPANNUNGSFELDERN
      c1=250 & c2 =100
      !p.multi=[0,1,1,0]
      
      ;;loadct,26
      left=0 & right=n-1
      if(pr)then begin
         set_plot, 'PS'
         device,filename=filedir+'stresses.'+strtrim(nr, 1)+'.eps',bits_per_pixel=16,/color,$
           /encapsulated,xsize=20,ysize=10,scale_factor=1.0
         print,"Printing to"+filedir+"stresses."+strtrim(nr, 1)+"eps"
      endif else BEGIN
         set_plot, 'X'
         window,xsize=800,ysize=800
      ;;if(nr eq start)then window,xsize=1000,ysize=450
      endelse
      
      ;;csmax=max(abs(cs(left:right,left:right)))
      ;;cs =cs/csmax
	
      IF(0)THEN BEGIN 
         if(0)then begin	
            
            shade_surf,cs(left:right,left:right),clbx(left:right,left:right),clby(left:right,left:right),$
                                ;shade=128+cs*128,ax=90,az=0,xstyle=1,ystyle=1,zstyle=4,xtitle="x/a",ytitle="y/a"
            shade=bytscl(cs),ax=90,az=0,xstyle=1,ystyle=1,zstyle=4,xtitle="x/a",ytitle="y/a",color=c1
            contour,cs(left:right,left:right),clbx(left:right,left:right),clby(left:right,left:right),$
              levels=[0.0],/follow,/overplot
            
         endif else begin
            shade_surf,clb2(left:right,left:right)/1e9,clbx(left:right,left:right),clby(left:right,left:right),$
              shade=bytscl(clb2),ax=90,az=0,xstyle=1,ystyle=1,zstyle=4,xtitle="x/a",ytitle="y/a"
            contour,smooth(clb2(left:right,left:right),3)/1e9,clbx(left:right,left:right),clby(left:right,left:right),$
              levels=[-0.2,-0.1,0.0,0.1,0.2],/follow,/overplot
         ENDELSE
      ENDIF 
      for flt=0,nrflt-1 do begin
         plots,fc(0,flt),fc(1,flt) 
         plots,fc(2,flt),fc(3,flt),/continue,thick=4,color=c1
      endfor
      

      if(fmyu eq 0.1)then xyouts,-4.75,4.0,"!6Coulombspannung",charsize=1.5
      ;;xyouts,-1.0,-4,"!7l!6="+string(format='(g3.1)',fmyu)
      if(0)then begin
         openw,1,filedir+"cs.xyz"
         print,"Printing to cs.xyz"
         printf,1,n*n
         for i=0,n-1 do begin
            for j=0,n-1 do begin
               printf,1,243.56+(clbx(i,j)*0.00899),34.2+(clby(i,j)*0.00899),cs(i,j)
            end
         end
      END 
      
      if(0)then begin
         c1 = 250
         ld = 0.1
         rd = 0.9
         nrar = 20 & g0geofac=0.1
         lx=ld*double(n-1) & rx=rd*double(n-1)
         ly=ld*double(n-1) & ry=rd*double(n-1)
         plot,clbx(lx:rx,ly:ry),clby(lx:rx,ly:ry),/nodata,xstyle=1,ystyle=1,xtitle="x/a",ytitle="y/a",$
           color=c1
         contour,smooth(clb1+clb3+2.0*hp,2),clbx,clby,/follow,level=[0],/overplot,color=c1
         stremax=max(abs(fms(lx:rx,ly:ry)))
         if (max(abs(sms(lx:rx,ly:ry))) gt stremax)then stremax=max(abs(sms(lx:rx,ly:ry)))
         strefac=(1.0/stremax)*(max(clbx(lx:rx,ly:ry))/20.0)
         
         for flt=0,nrflt-1 do begin
            plots,fc(0,flt),fc(1,flt) 
            plots,fc(2,flt),fc(3,flt),/continue,thick=4,color=c1
         endfor
         for xx=lx,rx,((rx-lx) / nrar) do begin
            for yy=ly,ry,((ry-ly) / nrar) do begin
               geofac = g0geofac ;*(((interpolate(fms,xx,yy)-interpolate(sms,xx,yy))/2.0)/(max((fms-sms)/2.0)))
               x0=interpolate(clbx,xx,yy) & y0=interpolate(clby,xx,yy)
               if((((interpolate(clb1,xx,yy)+interpolate(clb3, xx, yy))/2.0)) LT 0.0)then begin
                  degfac= -45.0
                  c2=128
               endif else begin
                  degfac= -(45.0-((atan(fmyu)/2.0)/3.1415927)*180.0)
                  c2= c1
               endelse
               x1= x0 + geofac * cos(((interpolate(deg,xx,yy)+degfac)/180.0)*3.1415927)
               y1= y0 + geofac * sin(((interpolate(deg,xx,yy)+degfac)/180.0)*3.1415927)
               x2= x0 - geofac * cos(((interpolate(deg,xx,yy)+degfac)/180.0)*3.1415927)
               y2= y0 - geofac * sin(((interpolate(deg,xx,yy)+degfac)/180.0)*3.1415927)
               plots,x0,y0,color=c2 & plots,x1,y1,/continue,color=c2 
               plots,x2,y2,/continue,color=c2
            endfor
         endfor
         contour, (clb1+clb3)/2.0, clbx, clby, /overplot, level=0, /downhill, /follow
      endif
      if(dev eq 'PS')then device,/close
   end
   
   if(0) then begin
      contour,smooth(pf,2),clbx,clby,levels=levvec2,/fill,$
        title="!6Mohr-Bruchwahrscheinlichkeit",$
        xtitle="x/m",ytitle="y/m",color=textcolor
      contour,smooth(pf,2),clbx,clby,levels=[-1,-0.75,-0.5,-0.25,0],/follow,$
        c_labels=1,/overplot
      plots,-1,0 & plots,1,0,/continue,thick=4
   end
   
   IF(0)THEN BEGIN 
      window, xsize=1100, ysize=500
      !p.multi = [0, 2, 0, 2]
   
      contour, smooth(cs/tau0, 2), clbx, clby, xrange=[-5, 5], yrange=[-5, 5], $
        levels=[-2, -1.5, -1, -0.5, 0,0.5, 1,1.5, 2], $
        title="!7r!i!6c!n!e1!n/!7r!i!6xy!n!eh!n, !7b!6=optimal", xtitle="x/a", ytitle="y/a", /follow, xstyle=1, ystyle=1
      FOR i=0, nrflt-1 DO BEGIN 
         plots, fc(0, i), fc(1, i) & plots, fc(2, i), fc(3, i), /continue
      ENDFOR 
      contour, smooth(tcs/tau0, 2), clbx, clby, xrange=[-5, 5], yrange=[-5, 5], $
        levels=[-2,-1.5, -1, -0.5, 0,0.5, 1,1.5, 2], $
        title="!7r!i!6c!n!e1!n/!7r!i!6xy!n!eh!n, !7b!6="+string(format='(g5.3)', ((PI/4-cazi)/PI)*180.0), $
        xtitle="x/a", ytitle="y/a", /follow, xstyle=1, ystyle=1
      FOR i=0, nrflt-1 DO BEGIN 
         plots, fc(0, i), fc(1, i) & plots, fc(2, i), fc(3, i), /continue
      ENDFOR 
   ENDIF   

   IF(duplot)THEN BEGIN  ;; AUSGABE VON VERSCHIEBUNGSFELDERN
      
      dumax = max(abs(dux))
      IF(max(abs(duy))GT dumax)THEN dumax=max(abs(duy))
      step = m/50
      IF(dumax NE 0.0)THEN $
        fac = 2.5*(interpolate(duxc, step, 0)-duxc(0, 0))/dumax ELSE $
        fac = 1.0
      hi = m/2 -3 & lo=m/2+3 &  mi=m/2
      !p.multi = 0
      IF(dev EQ 'PS')THEN BEGIN 
         device,filename=filedir+'dufield.eps',bits_per_pixel=16,/color,$
           /encapsulated,xsize=15,ysize=14,scale_factor=1.0
         print,"Printing to "+filedir+"dufield.eps"
      ENDIF ELSE BEGIN 
         window,0 
         wset, 0
      ENDELSE 
      
      IF(duh0 NE 0)THEN BEGIN 
         plot, duxc, duyc, /nodata, title="!6Verschiebungsfeld, reduziert um homogene Verschiebungen",$
           xtitle="x/a", ytitle="y/a" 
      ENDIF ELSE BEGIN 
         plot, duxc, duyc, /nodata, title="!6Verschiebungsfeld", $
           xtitle="x/a", ytitle="y/a"
      ENDELSE 
      sty = 0 & stty=m-1 
      nhmax = 0
      FOR j=0, m-1, step DO BEGIN 
         FOR i=sty, stty, step DO BEGIN 
            xx = interpolate(duxc, i, j) &  yy= interpolate(duyc, i, j)
            ddx = interpolate(dux, i, j)-(duh0*yy)
            ddy = interpolate(duy, i, j)
            IF(abs(ddx) GT nhmax)THEN nhmax = abs(ddx)
            IF(abs(ddy) GT nhmax)THEN nhmax = abs(ddy)
            xxx = xx + ddx * fac 
            yyy = yy + ddy * fac
            arrow, xx, yy, xxx, yyy, /data, $
              /solid, hsize= -0.3
         ENDFOR 
         IF(sty eq 0)THEN BEGIN 
            sty = 0.5
            stty = m-0.5
         ENDIF ELSE BEGIN  
            sty = 0
            stty = m-1
         ENDELSE 
      ENDFOR 
      
      xx = reform(duxc(*, 0))
      yy = dblarr(m)
      midpoints = 0
      FOR i=0, m-1 DO BEGIN 
         IF(abs(xx(i)) GE 1.0)THEN BEGIN 
            IF(mode2)THEN yy(i) = u2disp(xx(i)) ELSE yy(i) = -u2disp(xx(i))
         ENDIF ELSE BEGIN 
            yy(i) = 0
         ENDELSE 
         IF(abs(xx(i)) LE  1.0)THEN BEGIN 
            IF(midpoints EQ 0)THEN rstart = i
            midpoints = midpoints + 1
         ENDIF 
      ENDFOR
      xr = dblarr(midpoints) &  yr=dblarr(midpoints) & yf=dblarr(midpoints) & v=0
      FOR i=0, midpoints-1 DO BEGIN 
         xr(i) = xx(rstart+i)
         IF(mode2)THEN $
           yr(i) = duy(rstart+i, mi) $
         ELSE $
           yr(i) = dux(rstart+i, mi)
      ENDFOR 

      a = SVDFIT(xr,yr,2, YFIT = yf, VARIANCE=v)
      neigung = ((atan(a(1)/normlength))/3.141592653)*180.0
      stauchung = (max(dux(*, mi))/normlength)*100.0
      plots, xx(rstart), duy(rstart, mi)*fac
      plots, xx(rstart+midpoints-1), duy(rstart+midpoints-1, mi)*fac,   /continue ;
      IF(dev EQ 'PS')THEN device, /close 
      IF(dev EQ 'PS')THEN BEGIN 
         device,filename=filedir+'duy.eps',bits_per_pixel=16,/color,$finel/results/rotation
           /encapsulated,xsize=18,ysize=10,scale_factor=1.0
         print,"Printing to "+filedir+"duy.eps"
      ENDIF ELSE BEGIN 
         window, 1 &  wset, 1
      ENDELSE 
      !p.multi = [0, 1, 1, 0]
      IF(mode2)THEN $
        plot, duxc(*,0), duy(*, mi)/nhmax, title="!6u!iy!n bei y="+string(format='(g4.2)', duyc(1,mi)), $
        xtitle="x/a", ytitle="u!iy!n/MAX(u!iinhomogen!n)",psym=4 $
      ELSE $
        plot, duxc(*,0), dux(*, mi)/nhmax, title="!6u!ix!n bei y="+string(format='(g4.2)', duyc(1,mi)), $
        xtitle="x/a", ytitle="u!ix!n/MAX(u!iinhomogen!n)",psym=4 
      
      IF(mode2)THEN oplot, xx, yy*max(duy(*, mi)/nhmax), linestyle=2 ELSE $
        oplot, xx, yy*max(dux(*, mi)/nhmax), linestyle=2
      oplot, xr, yf/nhmax
      tmp = nhmax*spacescale
      IF(mode2)THEN $
        xyouts, 0.25, -0.3, "Neigung: "+string(format='(g5.2)', neigung)+" deg"$
      ELSE $
        xyouts, 0.25, 0.3, "Stauchung: "+string(format='(g5.2)', stauchung)+" %"
      ;;xyouts, 0.25, 0.2, "Max. inhomogen Verschiebung: "+string(format='(g5.2)', tmp)+" [m]"
      IF(dev EQ 'PS')THEN device, /close 
      IF(dev EQ 'PS')THEN BEGIN 
         device,filename=filedir+'dux.eps',bits_per_pixel=16,/color,$
           /encapsulated,xsize=15,ysize=14,scale_factor=1.0
         print,"Printing to "+filedir+" dux.eps"
      ENDIF ELSE BEGIN  
         window,2 &  wset, 2
      ENDELSE  
      
      IF(mode2)THEN BEGIN 
         !p.multi = [0, 1, 3, 0]
         plot, duxc, dux(*, hi)/nhmax, title="!6u!ix!n bei y="+string(format='(g5.2)', duyc(1,hi)),psym=4, $
           xtitle="x/a", ytitle="u!ix!n/MAX(u!iinhomogen!n)"
         plot, duxc, dux(*, mi)/nhmax, title="!6u!ix!n bei y="+string(format='(g5.2)', duyc(1,mi)),psym=4, $
           xtitle="x/a", ytitle="u!ix!n/MAX(u!iinhomgen!n)"
         plot, duxc, dux(*, lo)/nhmax, title="!6u!ix!n bei y="+string(format='(g5.2)', duyc(1,lo)),psym=4, $
           xtitle="x/a", ytitle="u!ix!n/MAX(u!iinhomogen!n)"
      ENDIF ELSE BEGIN 
         !p.multi = [0, 1, 2, 0]
         plot, duxc, duy(*, hi)/nhmax, title="!6u!iy!n bei y="+string(format='(g5.2)', duyc(1,hi)),psym=4, $
           xtitle="x/a", ytitle="u!iy!n/MAX(u!iinhomogen!n)"
         plot, duxc, duy(*, lo)/nhmax, title="!6u!iy!n bei y="+string(format='(g5.2)', duyc(1,lo)),psym=4, $
           xtitle="x/a", ytitle="u!iy!n/MAX(u!iinhomogen!n)"
         plots,-1,0 & plots,1,0,/continue,thick=4
      ENDELSE 
      IF(dev EQ 'PS')THEN device, /close 
      
   ENDIF 

   tmp = get_kbrd(1)
ENDFOR 


END











