;; spannungen des landers bebens
;kompressive spannung in richtung azi

prdat = 1
;!p.multi = [0, 2, 2, 0]
!p.multi = 0
PI = 3.141592653589
comp=1e7
FOR azi=8.0, 8.0 DO BEGIN 


                                        ; Winkel von der y-Achse aus im Uhrzeigersinn in deg
phi = ((90.0-azi)/180)*PI ; Winkel von der x-Achse aus geg. Uhrzeigersinn in  Rad

start=  1 & stop = 2
close,1,2,3

;;filedir="/home/geodyn/becker/quake/landers/"
filedir = "/home/geodyn/becker/finel/results/landers/"
;;filedir = "/home/datdyn/becker/finel/"

dev='X'
;dev='PS'
;set_plot,dev


openr,1,filedir+"faultcoord"
readf,1,nrflt
IF(nrflt GT 0)THEN BEGIN 
   fltcoord=dblarr(4,nrflt)
   readf,1,fltcoord
   fltcoord=(fltcoord-500.0)/50.0
ENDIF 
close,1


for nr=start,stop do begin
   
   openr,1, filedir+"stre11."+strtrim(nr,1)+".xyz"
   print,'Reading ',filedir+"stre??."+strtrim(nr,1)+".xyz"
   openr,2, filedir+"stre12."+strtrim(nr,1)+".xyz"
   openr,3, filedir+"stre22."+strtrim(nr,1)+".xyz"
   for i=1,3 do begin
      readf,i,time,fmyu,sdmyu,nomyu,hp,off
      readf,i,m 
   end
   n=sqrt(m)
   b = ( 2.0 * off ) / (sqrt(1.0 + fmyu^2) - fmyu)
   a=( sqrt(1+fmyu^2) + fmyu ) / ( sqrt(1+fmyu^2) - fmyu )
   
   
   clb=dblarr(3,n,n)& 	clb1=dblarr(n,n)	
   clb2=dblarr(n,n) & 	clb3=dblarr(n,n)
   clbn=dblarr(n,n) & 	clbt=dblarr(n,n)
   clbx=dblarr(n,n) &	clby=dblarr(n,n) 
   half=n/2
   fms=dblarr(n,n) & sms=dblarr(n,n) & deg=dblarr(n,n)

   readf, 1, clb & close,1
   clbx(*,*)= clb(0,*,*) & clby(*,*)=clb(1,*,*)
   clbx=(clbx-500.0)/50.0 & clby=(clby-500.0)/50.0
   
   clb1(*,*)= clb(2,*,*)
   readf,2,clb & clb2(*,*)= clb(2,*,*) & close,2
   readf,3,clb & clb3(*,*)= clb(2,*,*) & close,3
	
   if(comp ne 0.0)then $
    print,"Achtung, addiere zusaetzliche kompressive Spannung zu clb1 und clb2 !",comp,azi
   
   clb1 = clb1 - comp*0.5*(1.0+cos(2*phi))
   clb3 = clb3 - comp*0.5*(1.0-cos(2*phi))
   clb2 = clb2 - comp*0.5*cos(2*phi)*tan(2*phi)
  

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
   cs= -sms & sms= -fms & fms= cs & deg=deg+90.0



   
   
   minclb1=min(clb1) & maxclb1=max(clb1) & medclb1=mittelwert(clb1)
   minclb2=min(clb2) & maxclb2=max(clb2) & medclb2=mittelwert(clb2)
   minclb3=min(clb3) & maxclb3=max(clb3) & medclb3=mittelwert(clb3)
   minfms=min(fms) & maxfms=max(fms) & medfms=mittelwert(fms)
   minsms=min(sms) & maxsms=max(sms) & medsms=mittelwert(sms)
   mindeg=min(deg) & maxdeg=max(deg) & meddeg=mittelwert(deg)
   print, "Spannungen in MPa:"
   print,'MAX s11:',maxclb1/1e6,'MIN s11',minclb1/1e6,' Mittelwert',medclb1/1e6
   print,'MAX s12:',maxclb2/1e6, 'MIN s12',minclb2/1e6,' Mittelwert',medclb2/1e6
   print,'MAX s22:',maxclb3/1e6,'MIN s22',minclb3/1e6,' Mittelwert',medclb3/1e6
   print,'MAX fms:',maxfms/1e6 ,'MIN fms', minfms /1e6,' Mittelwert',medfms /1e6
   print,'MAX sms:',maxsms/1e6 ,'MIN sms',minsms /1e6,' Mittelwert',medsms /1e6
   print,'MAX deg:',maxdeg/1e6 ,'MIN deg',mindeg /1e6,' Mittelwert',meddeg /1e6

   
   
   dcs =  cstress(fms,sms,a,0.0,b)  - cstress(comp, 0.0, a, 0.0, b)
   

   c1=250 & c2 =100

   left = 0 &  right=n-1
   contour,smooth(dcs/1e6, 2),clbx,clby,$
    levels=[-2.0, -1.75, -1.5, -1.25, -1.0, -0.75, -0.5, -0.25, 0.0, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0], $
     /fill, title="p="+string(format='(e8.6)', comp/1e6)+" MPa", xtitle="x/a" , ytitle="y/a"
   contour,smooth(dcs/1e6, 2),clbx,clby,levels=0.0, /follow,/overplot
   
   for flt=0,nrflt-1 do begin
      plots,fltcoord(0,flt),fltcoord(1,flt) 
      plots,fltcoord(2,flt),fltcoord(3,flt),/continue,thick=4
      print, "Fault ", flt+1, "wurde durch "
      print, 243.5645+(fltcoord(0, flt)*50.0*0.0108),34.201167+(fltcoord(1, flt)*50.0*0.00899)
      print, 243.5645+(fltcoord(2, flt)*50.0*0.0108),34.201167+(fltcoord(3, flt)*50.0*0.00899)
      print, "angenaehert"
   endfor


   IF prdat EQ 1 THEN BEGIN 
      openw,1,filedir+"cs."+strtrim(nr,1)+".xyz"
      print,"Printing to cs."+strtrim(nr,1)+".xyz"
      printf,1,n*n
      for i=0,n-1 do begin
         for j=0,n-1 do begin
            printf,1,243.5645+(clbx(i,j)*50.0*0.0108),$
             34.201167+(clby(i,j)*50.0*0.00899),dcs(i,j)/1e6
         end
      end
      close,1

      smdcs = smooth(dcs, 2)
      openw,1,filedir+"cs.smooth."+strtrim(nr,1)+".xyz"
      print,"Printing to cs.smooth."+strtrim(nr,1)+".xyz"
      printf,1,n*n
      for i=0,n-1 do begin
         for j=0,n-1 do begin
            printf,1,243.5645+(clbx(i,j)*50.0*0.0108),$
             34.201167+(clby(i,j)*50.0*0.00899),smdcs(i,j)/1e6
         end
      end
      close,1
      


   ENDIF 
      
				


   if(dev eq 'PS')then device,/close
ENDFOR  
ENDFOR 

END 









