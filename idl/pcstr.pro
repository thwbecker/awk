pro pcstr,start,stop,range,pr,retarray
print,'pc2tiff startindex [stopindex stress-value-range printing retarr'
if(n_params() lt 4)then pr=0
if(n_params() lt 3)then range=10000.0
if(n_params() lt 2)then stop=start
if(n_params() lt 1)then exit
print,'Executing with ',start,stop,range,pr


;strf="/datdyn/becker/finel/coulomb."
strf="/datdyn/becker/finel/tau."
plarrow=0 & sur=2
tmp=' '
nr=1&time=0.0	
dev='X'
j=200
nqt=1.1
border=0.0
close, 1	
left=0 & right=1000
if(range lt 0)then begin
	print,"Checking for maximal data points..."
	for nr=start,stop do begin
		openr,1,strf+strtrim(nr,1)+".raw"
		print,'Reading ',strf+strtrim(nr,1)+".raw"
		readf,1,m,time
		n=sqrt(m)
		clb=dblarr(3,m)
		readf,1,clb
		if(abs(max(clb(2,*)))gt range)then range= abs(max(clb(2,*)))*nqt
		if(abs(min(clb(2,*)))gt range)then range= abs(min(clb(2,*)))*nqt
		close,1
	end
	print,'ranging symmetrically',-range,range
end
lev=28
deltac = (double(range) - double( -range)) / (double(lev)-1.0)
levvec=fltarr(lev+2)
levvec(1:lev)= -range + dindgen(lev) * deltac 


set_plot,dev
window,0,xsize=700,ysize=700

for nr=start,stop do begin
	openr,1, strf+strtrim(nr,1)+".raw"
	print,'Reading ',strf+strtrim(nr,1)+".raw"
	readf,1,m,time 
	
	clb=dblarr(3,m)
	clbx=dblarr(m)
	clby=dblarr(m)	
	retarray=fltarr(m)
	readf, 1, clb
	close,1
	clbs=clb(2,*) 
	clbx=clb(0,*)
	clby=clb(1,*)

	triangulate,clb(0,*),clb(1,*),tr,b
	cl=trigrid(clb(0,*),clb(1,*),clb(2,*),tr,$
		[(max(clbx)-min(clbx))/float(j),(max(clby)-min(clby))/float(j)],$
		;[min(clbx)+border,min(clby)+border,max(clbx)-border,max(clby)-border],$
		missing=min(clbs))
;	cl=trigrid(clb(0,*),clb(1,*),clb(2,*),tr,$
;		[(max(clbx)-min(clbx))/float(j),(max(clby)-min(clby))/float(j)],$
;		/quintic)
;	cl=trigrid(clb(0,*),clb(1,*),clb(2,*),tr,$
;		[(max(clbx)-min(clbx))/float(j),(max(clby)-min(clby))/float(j)],$
;		extrapolate=b)
;	cl=tri_surf(clbs,clbx,clby,nx=j,ny=j)
	retarray=cl
	
	clmax=max(cl) & clmin=min(cl)
	if(clmin lt -range)then levvec(0)=clmin-100.0 $
		else levvec(0)= -range-deltac
	if(clmax gt range)then levvec(lev+1)= clmax+100.0 $
		else levvec(lev+1)= -range+deltac*lev

	;print,levvec
	if sur eq 1 then begin
		
		contour,cl,levels=levvec,/fill
		;contour,cl,levels=levvec,/follow,/overplot
	end

	if sur eq 2 then begin
		;scaledcl= (abs(cl-levvec(0))/abs(levvec(lev+1)-levvec(0)))*255
		;if(abs(clmin) gt abs(clmax))then region=2*abs(clmin) else $
			region=2* abs(clmax)
		region=range*2.0
		scaledcl= (cl/region)*255 + 128
		print,'Max :',clmax,' MIN:',clmin,'Color Skaling:',min(scaledcl),max(scaledcl)
		shade_surf,cl,shade=scaledcl,$
			ax=90,az=0,zstyle=4
		if(clmin eq clmax)then begin
			xxx=[0,m,m,0] & yyy=[0,0,m,m]
			polyfill,xxx,yyy,color=scaledcl(0)
		end
	end
	;show3,cl
	;shade_surf,cl,shade=bytscl(cl)
	;tvscl,cl
	
if(pr)then begin
	common colors,r_orig,g_orig,b_orig,$
		r_con,g_con,b_con
	image=tvrd()
	tiff_write,"coulomb."+strtrim(nr,1)+".tiff",image,red=r_orig,$
		green=g_orig,blue=b_orig
	print,"Printing to ","coulomb."+strtrim(nr,1)+".tiff"

	close,1
end
	
	if((not pr)and(tmp ne 'a'))then begin
		print,"S to stop, K to kill, A for all"
		tmp=get_kbrd(1)
		if tmp eq 'k' then begin
			wdelete
			stop
		end
		if tmp eq 's' then stop
		
	end
	
end
end









