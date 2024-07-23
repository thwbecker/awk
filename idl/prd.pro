pro prd,start,stop,mag1,mag2,u,du

   print,"PRD start stop magu magdu u du"
   if n_params()lt 3 then mag1=10
   if n_params()lt 4 then mag2=10
   if n_params()lt 1 then start=1
   if n_params()lt 2 then stop= start
   
   writegmtfile = 0
   plotdu = 1
   vectors = 0


   set_plot,'X'
   BOXSIZE=700
   WINDOW,0, xsize=BOXSIZE,ysize=BOXSIZE
   loadct,13
   
   filedir="/home/datdyn2/becker/finel/"
   ;;filedir="/home/bigusr/becker/model_data/eff_modul/runs_after_1712/force_bc/c_1.606/"

   dispfile=filedir+"realdisp."
   gmtfilex = filedir+"dugmtx.dat"
   gmtfiley = filedir+"dugmty.dat"

   time=dblarr(1)

   close,1, 2
   off=50 
   
   print, "Reading "+filedir+"meshe ..."
   openr,1,filedir+"meshe"
   readf,1,numel,nen,time
   ix=intarr(2+nen,numel)
   readf,1,ix
   close,1
   print, "Reading "+filedir+"meshn ..."
   openr,1,filedir+"meshn"
   readf,1,numnp,time
   x=dblarr(3,numnp)
   readf,1,x
   close,1
   
   dim=2
   u= dblarr(dim*nen*numel)
   du=dblarr(dim*nen*numel)
   ;;u_node=dblarr(2,numnp)
   fac=0.9*BOXSIZE/max(x(2,*))
   ;;print,numel,'Elemente mit ',nen,'Knoten, insg:',numnp


   for nr=start,stop do begin
      openr,1,dispfile+strtrim(nr,1)+".dat"
      print,'Reading ',dispfile+strtrim(nr,1)+".dat"
      readu,1,time
      print, "Normal displacements..."
      readu,1,u
      print, "Split displacements..."
      readu,1,du
      close,1
      

      print
      print,'Using magnification ',mag1,' for normal    displacement,'
      print,'      magnification ',mag2,' for splitnode displacement,'
      print
      print,'U  min: ',min(u),' U  max:',max(u)
      print,'DU min: ',min(du),'DU max:',max(du)
      IF(nen NE 3)THEN BEGIN 
         print, "nur o1 elemente !"
         stop
      ENDIF 

      IF(plotdu)THEN BEGIN 
         for i=0,numel-1 do begin
            
            nd=ix(1+0,i)-1
            x1=(x(1,nd) + u(0+0*dim+i*dim*nen)*mag1 + du(0+0*dim+i*dim*nen)*mag2)*fac+off 
            x2=(x(2,nd) + u(1+0*dim+i*dim*nen)*mag1 + du(1+0*dim+i*dim*nen)*mag2)*fac+off 
            plots,x1,x2,/device	,color=255
            ;;u_node(0,nd)=u(0+0*dim+i*dim*nen) & u_node(1,nd)=u(1+0*dim+i*dim*nen)
            for j=1,nen-1 do begin
               nd=ix(1+j,i)-1 
               ;;u_node(0,nd)=u(0+j*dim+i*dim*nen) & u_node(1,nd)=u(1+j*dim+i*dim*nen)
               x1=(x(1,nd) + u(0+j*dim+i*dim*nen)*mag1 + du(0+j*dim+i*dim*nen)*mag2)*fac+off 
               x2=(x(2,nd) + u(1+j*dim+i*dim*nen)*mag1 + du(1+j*dim+i*dim*nen)*mag2)*fac+off 
               plots,x1,x2,/device,/continue,color=255
               
            END 	
            nd=ix(1+0,i)-1
            x1=(x(1,nd) + u(0+0*dim+i*dim*nen)*mag1 + du(0+0*dim+i*dim*nen)*mag2)*fac+off 
            x2=(x(2,nd) + u(1+0*dim+i*dim*nen)*mag1 + du(1+0*dim+i*dim*nen)*mag2)*fac+off 
            plots,x1,x2,/device,/continue	,color=255
            
         ENDFOR
      ENDIF 

      IF(vectors)THEN BEGIN 
         for i=0l,numel-1 do begin
            for j=0l,nen-1 do begin
               nd=ix(1+j,i)-1 
               shiftx = u(0+j*dim+i*dim*nen)*mag1 + du(0+j*dim+i*dim*nen)*mag2
               shifty = u(1+j*dim+i*dim*nen)*mag1 + du(1+j*dim+i*dim*nen)*mag2
               arrow, x(1,nd)*fac+off, x(2,nd)*fac+off, (x(1,nd)+shiftx)*fac+off, (x(2,nd)+shifty)*fac+off, color=155
            ENDFOR  	
         ENDFOR  
      ENDIF 


      IF(writegmtfile) THEN BEGIN 
         openw, 1, gmtfilex
         openw, 2, gmtfiley
         print, "Now print to", gmtfilex
         print, "    and ", gmtfiley 
         for i=0l,numel-1 do begin
            for j=0l,nen-1 do begin
               nd=ix(1+j,i)-1 
               printf, 1, x(1,nd), x(2,nd), string(format='(g30.15)', u(0+j*dim+i*dim*nen)+du(0+j*dim+i*dim*nen))
               printf, 2, x(1,nd), x(2,nd), string(format='(g30.15)',u(1+j*dim+i*dim*nen)+du(1+j*dim+i*dim*nen))
            ENDFOR  	
              
         ENDFOR  
         close, 1, 2
         print, "Done."
         print
      ENDIF   


		
      xyouts,200,10,time(0),/device

      
   END 
   

   tmp=get_kbrd(1)
   if(tmp eq 'k') then begin
      wdelete,0
      stop
   end
   if tmp eq 's' then stop
   erase



end
























