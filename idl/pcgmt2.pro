pro pcgmt2,start,stop,range,pr,clbs,clbx,clby,scaledclbs
print,'pcgmt startindex [stopindex stress-value-range printing][clbs clbx clby]'
if(n_params() lt 4)then pr=0
if(n_params() lt 3)then range=40000
if(n_params() lt 2)then stop=start
if(n_params() lt 1)then exit

print,'Executing with ',start,stop,range,pr
sur=1 & windowsize=600
nr=1 
dev='X'
left=0 & right=1000
xoff= -200 & yoff= -190 & mag=1.2
;xoff= -100 & yoff= 10 & mag = 0.9
;xoff= -1100 & yoff = -900 & mag=3.0
textcolor=127

cmin= -range & cmax= range
region=range*2.0
deltafac=1e6
lev=28
deltac = (double(cmax)-double(cmin)) / (double(lev)-1)

filedir="/datdyn/becker/finel/"
close, 1
time=dblarr(1)
set_plot,dev
xwindowsize= windowsize*2.5
ywindowsize= windowsize

window,0,xsize=xwindowsize,ysize=ywindowsize

;loadct,13
;loadct,22	
;loadct,0
!p.multi=[0,2,0,0,0]

for nr=start,stop do begin

	filename="tau"
	openr,1, filedir+filename+"."+strtrim(nr,1)+".raw.xyz"
	print,'Reading ',filedir+filename+"."+strtrim(nr,1)+".raw.xyz"
	readf,1,m 
	n=sqrt(m)
	if nr eq start then begin
		tlbszero=dblarr(n,n)
		tlbszero=0.0
	end
	k=10 & l =40
	tlb=dblarr(3,n*n)	
	tlbs=dblarr(n,n)
	tlbx=dblarr(n,n)
	tlby=dblarr(n,n)
	readf, 1, tlb
	close,1
	
	openr,1,filedir+"du."+strtrim(nr,1)+".dat"
	print,'Reading ',filedir+"du."+strtrim(nr,1)+".dat for timing."
	readu,1,time
	close,1
	levvec=dblarr(lev+2)
	
	tlbs(*,*)= tlb(2,*)-tlbszero
	tlbszero=tlb(2,*)
	tlbx(*,*)=tlb(0,*)*mag+xoff
	tlby(*,*)=tlb(1,*)*mag+yoff
	mintlbs=min(tlbs) & maxtlbs=max(tlbs)
	print,'MAX:',maxtlbs,'MIN:',mintlbs 
	
	scaledtlbs= (tlbs/range)*127 + 128
	c1=0
	
	if(mintlbs lt -range)then levvec(0)=mintlbs-100.0 $
		else levvec(0)= -range-deltac	
	if(maxtlbs gt range)then levvec(lev+1)=maxtlbs+100.0 $
		else levvec(lev+1)= -range+deltac*lev
	levvec(1:lev)= cmin + findgen(lev) * deltac 
	help,levvec
	print,levvec

if(sur)then begin 

	shade_surf,tlbs,tlbx,tlby,shade=bytscl(scaledtlbs),$
		ax=90,az=0,xrange=[left,right],ystyle=4,xstyle=4,zstyle=4,$
		yrange=[left,right],/device


upper=500 & lower = 50
if(mintlbs eq maxtlbs)then begin
	x=[lower,upper,upper,lower] & y = [lower,lower,upper,upper]
	polyfill,x,y,color=scaledtlbs,/device
end
	xyouts,120,970,"!5Scher-Spannung",$
		charsize=2.0,color=textcolor
	xyouts,850,930,"zur Zeit ",color=textcolor+10,charsize=2.0
	xyouts,1100,930,strtrim(fix(time(0)),1),charsize=2.0,color=textcolor+20

end


filename="coulomb"

	openr,1, filedir+filename+"."+strtrim(nr,1)+".raw.xyz"
	print,'Reading ',filedir+filename+"."+strtrim(nr,1)+".raw.xyz"
	readf,1,m 
	n=sqrt(m)
	k=10 & l =40
	if nr eq start then begin
		clbszero=dblarr(n,n)
		clbszero=0.0
	end
	clb=dblarr(3,n*n)	
	clbs=dblarr(n,n)
	name=dblarr(n*n)
	clbx=dblarr(n,n)
	clby=dblarr(n,n)
	readf, 1, clb
	close,1
	openr,1,filedir+"du."+strtrim(nr,1)+".dat"
	print,'Reading ',filedir+"du."+strtrim(nr,1)+".dat for timing."
	readu,1,time
	close,1
	levvec=dblarr(lev+2)
	
	clbs(*,*)=clb(2,*)-clbszero
	clbszero=clb(2,*)
	clbx(*,*)=clb(0,*)*mag+xoff
	clby(*,*)=clb(1,*)*mag+yoff
	minclbs=min(clbs) & maxclbs=max(clbs)
	print,'MAX:',maxclbs,'MIN:',minclbs 
	
	scaledclbs= (clbs/range)*127 + 128
	name=clbs
	c1=0
	
	if(minclbs lt -range)then levvec(0)=minclbs-100.0 $
		else levvec(0)= -range-deltac	
	if(maxclbs gt range)then levvec(lev+1)=maxclbs+100.0 $
		else levvec(lev+1)= -range+deltac*lev
	levvec(1:lev)= cmin + findgen(lev) * deltac 
	help,levvec
	print,levvec

if(sur)then begin 
	shade_surf,clbs,clbx,clby,shade=bytscl(scaledclbs),$
		ax=90,az=0,xrange=[left,right],ystyle=4,xstyle=4,zstyle=4,$
		yrange=[left,right],/device






upper=700 & lower = 100
	xyouts,100,970,"!5Coulomb-Spannung!9: !4s!5-!4l!i!51!n!9.!4r!i!5n!n",$
		charsize=2.0,color=textcolor

	step=1 & xu=550 & yu = 30 & len = 450

	for i=0,254,step do begin
		dx=35.0 & dy=len/(255.0/step) 
		polyfill,[xu,xu+dx,xu+dx,xu],$
		[yu-dy/2.0+i*dy,yu-dy/2.0+i*dy,yu-dy/2.0+(i+1.0)*dy,$
			yu-dy/2.0+(i+1.0)*dy],color=i,/device
		if(fix(i/10.0) eq (i/10.0))then $
			xyouts,xu+dx*5.0-100,yu+(i-1)*dy-dy/2.0,$
				strtrim((((i-127.0)/255.0)*range)*1e-06,1),$
				color=textcolor,/device
	end
	xyouts,xu+dx*5.0-100,yu+100*dy+290,"MPa",charsize=1.5,$
		color=textcolor,/device
	yb=350 & xb= 900 & bsize=80 & dx0 = 7 & ddx = 0.2
	magfac=1
	xbv=[xb+(dx0+time*ddx)*magfac,xb+bsize+(dx0+time*ddx)*magfac,$
		xb-(dx0+time*ddx)*magfac+bsize,xb-(dx0+time*ddx)*magfac]
	ybv=[yb,yb,yb+bsize,yb+bsize]
	polyfill,xbv,ybv,color=textcolor+20
end

if(not sur)then begin
	contour,(clbs),clbx,clby,nlevels=10,xrange=[left,right],$
		yrange=[left,right],/follow

end

if(pr)then begin
	common colors,r_orig,g_orig,b_orig,$
		r_con,g_con,b_con
	image=tvrd()
	tiff_write,filedir+"coulomb."+strtrim(nr,1)+".tiff",image,red=r_orig,$
		green=g_orig,blue=b_orig
	print,"Printing to ",filedir+"coulomb."+strtrim(nr,1)+".tiff"

	close,1

end
end
end









