pro pmove,start,stop,indufac,ret_array
print,'PMOVE [start ][stop][dufac][ret_array]'

if(n_params() lt 3)then indufac=0
if(n_params() lt 1)then start=1
if(n_params() lt 2)then stop=start

filedir="/datdyn/becker/finel/"
dim=2
BOXSIZE=800
charfac=(BOXSIZE/1200)*1.2
time=double(1)

close, 1
openr, 1, filedir+'meshn'
readf, 1, numnp,time
coord=fltarr(3,numnp)
readf,1,coord
close,1

openr,1,filedir+'meshe'
readf,1,numel,nen,time
con=intarr(2+nen,numel)
readf,1,con
close,1

openr,1,filedir+'edge'
readf,1,nredge,nrbmrk
edge=intarr(3+nrbmrk,nredge)
readf,1,edge
close,1

du=dblarr(nen*dim*numel)
alt_du=dblarr(nen*dim*numel)
ret_array=dblarr(nen*dim*numel)
;plotted=intarr(numnp)

set_plot,'X'
WINDOW, xsize=BOXSIZE,ysize=BOXSIZE
fac=BOXSIZE/((max(coord(1,*))- min(coord(1,*)))*1.1)
xoff=min(coord(1,*))+20
yoff=xoff

for nr=start,stop do begin

	openr,1, filedir+"du."+strtrim(nr,1)+".dat"
	print,'Reading ',filedir+"du."+strtrim(nr,1)+".dat"
	readu,1,time,du
	close,1
	du=du-alt_du
	ret_array=du
	alt_du=du
	if indufac eq 0 then begin
		if(max(abs(du))ne 0.0)then dufac= 1.0e01/max(abs(du))
		if(max(abs(du))eq 0.0)then  dufac=1.0
		
	end
	if indufac ne 0 then dufac = indufac
	;for i=0,numnp-1 do begin
	;	plotted(i)=0
	;end
	for i=0,numel-1 do begin
		c1= 50+((i+1)/2*numel)*125
		for j=0,nen-1 do begin
			node=con(1+j,i)-1
			dux=dufac * du(i*nen*dim + j*dim)
			duy=dufac * du(i*nen*dim + j*dim+1)
			if(dux ne 0.0 or duy ne 0.0)then begin
				;plotted(node)=1
				x0=coord(1,node)*fac+xoff		
				y0=coord(2,node)*fac+yoff
				for k=0,nen-1 do begin
					node=con(1+k,i)-1
					x0=x0+coord(1,node)*fac+xoff		
					y0=y0+coord(2,node)*fac+yoff
				end
				x0=x0/(nen+1)&y0=y0/(nen+1)
				x1=x0+ dux
				y1=y0+ duy	
				arrow,x0,y0,x1,y1,hsize= -0.5,color=c1
			end
		end
	end
	xyouts,200,10,'DU(t n+1)-DU(t n) at '+strtrim(time,1),/device
	tmp=get_kbrd(1)
	erase
	if(tmp eq 's')then stop
	if(tmp eq 'k')then begin
		wdelete
		stop
	end
end
close,1

end





