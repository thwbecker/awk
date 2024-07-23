;pro pgcoulomb,start,stop,range,pr
;print,'pgcoulomb startindex[stopindex stress-value-range printing]'
;if(n_params() lt 4)then pr=0
;if(n_params() lt 3)then range=2e8

;if(n_params() lt 2)then stop=start
;if(n_params() lt 1)then exit
;print,'Executing with ',start,stop,range,pr
start= 19 & stop = 22
range =2e8 & pr=0

close,1,2,3

modeldir="moving_sngl_crack.2/"
;modeldir="static_sngl_cracks/sngl_crack.1.5.0.200/"
;modeldir="moving_sngl_crack/"
filedir="/datdyn/becker/finel/"+modeldir

plarrow=0 & sur=1 & windowsize=500
xwindowsize=1.5 * windowsize & ywindowsize = 2.0 * windowsize


nr=1 
;dev='X'
dev='PS'
set_plot,dev

if dev eq 'PS' then begin
	device,filename='stre.eps',bits_per_pixel=16,/color,$
;		fuer fast quadratische Plots
;		/encapsulated,xsize=8,ysize=7,scale_factor=1.0,xoffset=1
;		fuer rechteckige Plots
		/encapsulated,xsize=19,ysize=9,scale_factor=1.0,xoffset=1
;		/landscape
	print,'Output in stre.eps'
	;a(where (a eq 0B))=255B
end

!p.multi=[0,4,2,0]
xmag=1 & ymag =1 & xoff=0 & yoff=0

normv=dblarr(2) & tangv = dblarr(2)

normv=[0,1.0]
tangv=[1.0,0]

xmin=10 & xmax=990 & ymin = 10 & ymax = 990

textcolor=200

cmin= -range & cmax= range
region=range*2.0



readdata=1

set_plot,dev


for nr=start,stop do begin
if readdata eq 1 then begin
	tau0=(7+double(nr)*0.2)*2e7

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
	clbx=dblarr(n,n) &	clby=dblarr(n,n) & pf=dblarr(n,n)
	cs=dblarr(n,n) & tcs=dblarr(n,n)
	fms=dblarr(n,n) & sms=dblarr(n,n) & deg=dblarr(n,n)
	readf, 1, clb & close,1
	clbx(*,*)= clb(0,*,*)*xmag+xoff & clby(*,*)=clb(1,*,*)*ymag+yoff 
	clb1(*,*)= clb(2,*,*)
	readf,2,clb & clb2(*,*)= clb(2,*,*) & close,2
	readf,3,clb & clb3(*,*)= clb(2,*,*) & close,3

	clbn= -sigma_n(clb1,clb2,clb3,normv,tangv)
	clbt= -sigma_t(clb1,clb2,clb3,normv,tangv)

	minclb1=min(clb1) & maxclb1=max(clb1) & medclb1=mittelwert(clb1)
	print,'MAX s11:',maxclb1,'MIN s11',minclb1,' Mittelwert',medclb1
	minclb2=min(clb2) & maxclb2=max(clb2) & medclb2=mittelwert(clb2)
	print,'MAX s12:',maxclb2,'MIN s12',minclb2,' Mittelwert',medclb2
	minclb3=min(clb3) & maxclb3=max(clb3) & medclb3=mittelwert(clb3)
	print,'MAX s22:',maxclb3,'MIN s22',minclb3,' Mittelwert',medclb3
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
	cs= -sms & sms= -fms & fms= cs
	


;	cs = cstress(fms,sms,a,hp,b)        - cstress(tau0,-tau0,a,hp,b)
	cs = cstress(fms,sms,a,hp,b)        - cstress(2e8,-2e8,a,hp,b)
	tcs= cstress(clbt,clbn,fmyu,hp,off) - cstress(tau0,0.0,fmyu,hp,off) 
	if(off ne 0.0)then begin
		pf= ((fms-sms) * fmyu * sqrt(((off^2)*(1+fmyu^2))/(fmyu^2))) / $
			(off*(2*off+fmyu*(fms+hp)+fmyu*(sms+hp) ))
	end
	if(off eq 0.0)then begin
		pf= (fmyu*(fms+sms+2*hp)) / ( sqrt(1+fmyu^2)*(fms-sms))
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

end

	

if(0) then begin 
	shade_surf,clb2-2.0e8,clbx,clby,shade=bytscl(clb2),$
		ax=90,az=0,zstyle=4,xrange=[xmin,xmax],yrange=[ymin,ymax],$
		xtitle="!6Scherspannung !7r!6!ixy!n!6",background= bgcolor,$
		ytitle="!6y/m",color=50
	
	for i=0,255,5 do begin
		xvec=[ -200,-180,-180,-200] & yvec =[i*4, i*4,i*4+5,i*4+5]
		polyfill,xvec,yvec,color=i
	end
	plots,450,500 & plots,550,500,/continue,thick=4
end
if(0) then begin
	plot,clbx(*,50),clb2(*,50)-tau0,$
		title="!7D!6Scherspannung bei y = 500",$
		xtitle="x/m",ytitle="!6Spannung/Pa"

end
if(1) then begin
	shade_surf,clb2,clbx,clby,shade=fix(((clb2-1.2e8)/1.3e8)*255.),$
		az=0,ax=90,zstyle=4,color=textcolor
	;contour,smooth(cs,2),clbx,clby,/fill,levels=levvec
	;shade_surf,cs,clbx,clby,shade=fix(((cs+5.0e8)/10.0e8)*255.),$
	;	az=0,ax=90,zstyle=4,color=textcolor

	plot,clbx(*,50),clb2(*,50)/1e6,yrange=[0,300],color=textcolor
	plots,0,158 & plots,1000,158,/continue,linestyle=5,color=textcolor
	plots,0,123 & plots,1000,123,/continue,linestyle=5,color=textcolor
	print,'MIN / MAX s12(*,50)',min(clb2(*,50)),max(clb2(*,50))
	
end

if(0) then begin
	contour,smooth(clb2-tau0,2),clbx,clby,/follow,/fill,$
		title="!7D!6Scherspannung !7r!6!ixy!n!6",xtitle="x/m",$
		ytitle="y/m",color=textcolor
	contour,smooth(clb2-tau0,2),clbx,clby,levels=[-2e8,-1e8,0,1e8,2e8],$
		/follow,/overplot,C_labels=[1,1,1,1,1]
	
end

if(0) then begin
	contour,smooth(clb1+clb3,2),clbx,clby,levels=levvec,/fill,/follow,$
		title="!7D!6(tr(!7r!6!iij!n)!6)",$
		ytitle="y/m",color=textcolor,xtitle="x/m"
	contour,smooth(clb1+clb3,2),clbx,clby,levels=[-2e8,0,2e8],/follow,$
		c_labels=[1,1,1],/overplot
	plots,450,500 & plots,550,500,/continue,thick=4
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





	
if (0) then begin
	contour,smooth(tcs,2),clbx,clby,levels=levvec,/fill,$
	title="!7D!6Coulombspannung: !10#!7r!6!it!n!10#!7 - l * r!i!6n!n!6",$
	xtitle="x/m",ytitle="y/m",color=textcolor
	contour,smooth(tcs,2),clbx,clby,levels=[-2e8,0,2e8],/follow,$
		c_labels=[1,1,1],/overplot
	plots,450,500 & plots,550,500,/continue,thick=4
end
if (0) then begin
	contour,smooth(cs,2),clbx,clby,levels=levvec,/fill,$
	title="!7D!6Coulombspannung: !10#!7r!6!i1!n!10#!7 - !6a!7 * r!i!62!n!6",$
	xtitle="x/m",ytitle="y/m",color=textcolor
	contour,smooth(cs,2),clbx,clby,levels=[-2e8,-1e8,0,1e8,2e8],/follow,$
		c_labels=[1,1,1],/overplot
	plots,450,500 & plots,550,500,/continue,thick=4
end




if(0) then begin
	contour,smooth(pf,2),clbx,clby,levels=levvec2,/fill,$
	title="!6Mohr-Bruchwahrscheinlichkeit",$
	xtitle="x/m",ytitle="y/m",color=textcolor
	contour,smooth(pf,2),clbx,clby,levels=[-1,-0.75,-0.5,-0.25,0],/follow,$
		c_labels=1,/overplot
	plots,450,500 & plots,550,500,/continue,thick=4
end




	
end
	if(pr)then begin
		common colors,r_orig,g_orig,b_orig,$
			r_con,g_con,b_con
		image=tvrd(0,0,windowsize,windowsize)
		tiff_write,filedir+"stresses."+strtrim(nr,1)+".tiff",$
			image,red=r_orig,green=g_orig,blue=b_orig
		print,"Printing to ",filedir+"stresses."+strtrim(nr,1)+".tiff"
		close,1
	end
	;if dev eq 'X' then tmp=get_kbrd(1)

if (dev eq 'PS') then $
		colorscl,120,250,"!6Scherspannung / MPa",textcolor,1
!p.multi=0
if dev eq 'PS' then device,/close
end









