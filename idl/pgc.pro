pro pgc,start,stop,range,pr,clbs,clbx,clby,scaledclbs
print,'pcgmt startindex [stopindex stress-value-range printing][clbs clbx clby]'
if(n_params() lt 4)then pr=0
if(n_params() lt 3)then range=40000
if(n_params() lt 2)then stop=start
if(n_params() lt 1)then exit
print,'Executing with ',start,stop,range,pr
plarrow=0 & sur=1 & windowsize=900
nr=1 
dev='X'
left=0 & right=1000
;xoff= -200 & yoff= -190 & mag=1.2
xoff= -100 & yoff= 10 & mag = 0.9
;xoff= -1100 & yoff = -900 & mag=3.0
textcolor=127
cmin= -range & cmax= range
region=range*2.0
lev=28
deltac = (double(cmax)-double(cmin)) / (double(lev)-1)
;filedir="/datdyn/becker/finel/model_c/"
filedir="/datdyn/becker/finel/model_e/"


close, 1
time=dblarr(1)
set_plot,dev

window,0,xsize=windowsize,ysize=windowsize

;loadct,13
;loadct,22	
;loadct,0
for nr=start,stop do begin
	openr,1, filedir+"coulomb."+strtrim(nr,1)+".raw.xyz"
	print,'Reading ',filedir+"coulomb."+strtrim(nr,1)+".raw.xyz"
	readf,1,m 
	n=sqrt(m)
	k=10 & l =40
	clb=fltarr(3,n*n)	
	clbs=fltarr(n,n)
	name=fltarr(n*n)
	clbx=fltarr(n,n)
	clby=fltarr(n,n)
	readf, 1, clb
	close,1
	openr,1,filedir+"du."+strtrim(nr,1)+".dat"
	print,'Reading ',filedir+"du."+strtrim(nr,1)+".dat for timing."
	readu,1,time
	close,1
	levvec=fltarr(lev+2)
	
	clbs(*,*)=clb(2,*)
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
;	shade_surf,clbs,clbx,clby,shade=bytscl(scaledclbs),$
;	ax=90,az=0,zstyle=4,xtitle='x',xrange=[left,right],$
;		yrange=[left,right],/device



	shade_surf,clbs,clbx,clby,shade=bytscl(scaledclbs),$
		ax=90,az=0,xrange=[left,right],ystyle=4,xstyle=4,zstyle=4,$
		yrange=[left,right],/device
upper=700 & lower = 100
if(minclbs eq maxclbs)then begin
	x=[200,800,800,200] & y = [ 200,200,800,800]
	polyfill,x,y,color=scaledclbs,/device
end
	xyouts,100,970,"!5Coulomb-Spannung!9: !4s!5-!4l!i!51!n!9.!4r!i!5n!n",$
		charsize=2.0,color=textcolor
;	xyouts,100,970,$
;		"!5Coulomb-Spannung!9: !4r!i1!n!5-!4l!5'!9.!4r!i!53!n nach Byerlee",$
;			charsize=2.0

	xyouts,300,930,"zur Zeit ",color=textcolor
	xyouts,400,925,strtrim(fix(time(0)),1),charsize=2.0,color=textcolor+20
	step=1 & xu=720 & yu = 30 & len = 700
	for i=0,254,step do begin
		dx=35.0 & dy=len/(255.0/step) 
		polyfill,[xu,xu+dx,xu+dx,xu],$
		[yu-dy/2.0+i*dy,yu-dy/2.0+i*dy,yu-dy/2.0+(i+1.0)*dy,$
			yu-dy/2.0+(i+1.0)*dy],color=i,/device
		if(fix(i/10.0) eq (i/10.0))then $
			xyouts,xu+dx*5.0,yu+(i-1)*dy-dy/2.0,$
				strtrim((((i-127.0)/255.0)*range)*1e-06,1),$
				color=textcolor
	end
	xyouts,xu+dx*5.0,yu+300*dy,"MPa",charsize=2.0,color=textcolor
;	contour,clbs,clbx,clby,/fill,$
;		levels=levvec,xtitle='Coulomb stress'
;	contour,clbs,clbx,clby,levels=levvec,/follow,/overplot
;	surface,clbs,clbx,clby,zrange=[cmin,cmax],zstyle=1
;	show3,clbs



	;surface,clbs
end

if(not sur)then begin
	contour,(clbs),clbx,clby,nlevels=10,xrange=[left,right],$
		yrange=[left,right],/follow

end
if(pr)then begin
	common colors,r_orig,g_orig,b_orig,$
		r_con,g_con,b_con
	image=tvrd(0,0,windowsize,windowsize)
	tiff_write,filedir+"coulomb."+strtrim(nr,1)+".tiff",image,red=r_orig,$
		green=g_orig,blue=b_orig
	print,"Printing to ",filedir+"coulomb."+strtrim(nr,1)+".tiff"

	close,1

end
end
end









