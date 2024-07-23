;pro prstr,start,stop,range,pr,clb1,clb2,clb3,fms,sms,deg,clbx,clby

;print,'pgstr startindex [stopindex stress-value-range printing][clb1 clb2 clb3]'
;if(n_params() lt 4)then pr=0
;if(n_params() lt 3)then range=2e8
;if(n_params() lt 2)then stop=start
;if(n_params() lt 1)then exit
;print,'Executing with ',start,stop,range,pr
start=1 & stop =1 & range =2e8 & pr = 0

close,1,2,3

modeldir="sngl_crack.0.5.0.6000/"
filedir="/datdyn/becker/finel/static_sngl_cracks/"+modeldir

plarrow=0 & sur=1 & windowsize=500
xwindowsize=1.5*windowsize & ywindowsize = 2.0*windowsize

hauptspannungen=0

nr=1 
dev='X'

xmag=1 & ymag =1 & xoff=0 & yoff=0

xmin=10 & xmax=990 & ymin = 10 & ymax = 990

textcolor=127

cmin= -range & cmax= range
region=range*2.0

set_plot,dev

;window,0,xsize=xwindowsize,ysize=ywindowsize
for nr=start,stop do begin

	openr,1, filedir+"stre11."+strtrim(nr,1)+".raw"
	print,'Reading ',filedir+"stre??."+strtrim(nr,1)+".raw"
	openr,2, filedir+"stre12."+strtrim(nr,1)+".raw"
	openr,3, filedir+"stre22."+strtrim(nr,1)+".raw"
	for i=1,3 do begin
		readf,i,time,fmyu,sdmyu,nomyu,hp,off
	end
	n=0
	while not eof(1) do begin
		readf,1,xx,yy,zz
		n=n+1
	end
	close,1
	clb=dblarr(3,n)
	openr,1, filedir+"stre11."+strtrim(nr,1)+".raw"
	readf,1,time,fmyu,sdmyu,nomyu,hp,off,clb
	close,1
	m=50

	clb1=dblarr(m,m)	
	clb2=dblarr(m,m)
	clb3=dblarr(m,m)

	
	fms=dblarr(m,m) & sms=dblarr(m,m) & deg=dblarr(m,m)
	triangulate,clb(0,*),clb(1,*),tr,b
	
	clb1=trigrid(clb(0,*),clb(1,*),clb(2,*),tr,$
		[(max(clb(0,*))-min(clb(0,*)))/ float(m),$
		(max(clb(1,*))-min(clb(1,*)))/float(m)])
	readf,2,clb 
	clb2=trigrid(clb(0,*),clb(1,*),clb(2,*),tr,$
		[(max(clb(0,*))-min(clb(0,*)))/ float(m),$
		(max(clb(1,*))-min(clb(1,*)))/float(m)])
	close,2
	readf,3,clb 
	clb3=trigrid(clb(0,*),clb(1,*),clb(2,*),tr,$
		[(max(clb(0,*))-min(clb(0,*)))/ float(m),$
		(max(clb(1,*))-min(clb(1,*)))/float(m)])
	close,3
	

	minclb1=min(clb1) & maxclb1=max(clb1) & medclb1=mittelwert(clb1)
	print,'MAX s11:',maxclb1,'MIN s11',minclb1,' Mittelwert',medclb1
	minclb2=min(clb2) & maxclb2=max(clb2) & medclb2=mittelwert(clb2)
	print,'MAX s12:',maxclb2,'MIN s12',minclb2,' Mittelwert',medclb2
	minclb3=min(clb3) & maxclb3=max(clb3) & medclb3=mittelwert(clb3)
	print,'MAX s22:',maxclb3,'MIN s22',minclb3,' Mittelwert',medclb3
	
	if (hauptspannungen eq 1)then begin
		x1=0.0 & x2= 0.0 & r = 0.0
		for i=0,n-1 do begin
			for j=0,n-1 do begin
				x1=(clb1(i,j) + clb3(i,j))/2.0
				x2=(clb1(i,j) - clb3(i,j))/2.0
				r = sqrt(x2*x2 + clb2(i,j) * clb2(i,j) )
				fms(i,j)=x1+r & sms(i,j) = x1-r
				deg(i,j)=45.0
				if(x2 ne 0.0)then $
				deg(i,j)= 22.5 * (atan(clb2(i,j),x2) / atan(1.0))
			end
		end
	end
;	!p.multi=[0,2,3,0]
	lev=30
	levvec=dblarr(lev)
	for i=0,lev-1 do begin
		 levvec(i)= -range + double(i)*((2.0*range)/double(lev-1))
	end
	print,lev
	;contour,clb1+clb2,clbx,clby,/smooth


	
	if(pr)then begin
		common colors,r_orig,g_orig,b_orig,$
			r_con,g_con,b_con
		image=tvrd(0,0,windowsize,windowsize)
		tiff_write,filedir+"stresses."+strtrim(nr,1)+".tiff",$
			image,red=r_orig,green=g_orig,blue=b_orig
		print,"Printing to ",filedir+"stresses."+strtrim(nr,1)+".tiff"
		close,1
	end
end

end









