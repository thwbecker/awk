pro pom,prnd,prel,predge,printing
if n_params() lt 4 then printing=0
if n_params() lt 3 then predge=0
if n_params() lt 2 then prel=0
if n_params() lt 1 then prnd=0
if prel eq 1 then useedge=0 else useedge=1

print,'POM [prnd prel predge printing]'
print,"           entweder prel oder predge !"
if printing eq 0 then dev='X' else dev ='PS'
tmp=''
filedir="/home/datdyn2/becker/finel/"
BOXSIZE=800
prx=0
charfac=(BOXSIZE/1200)*1.2

close, 1
openr, 1, filedir+"meshn"
readf, 1, nrnd,time
coord=fltarr(3,nrnd)
readf,1,coord
close,1

spnd=fltarr(nrnd)
openr,1,filedir+'spnd'
readf,1,spnd
close,1

openr,1,filedir+"meshe"
readf,1,nrel,nrcon,time
con=intarr(2+nrcon,nrel)
readf,1,con
close,1

openr,1,filedir+"edge"
readf,1,nredge,nrbmrk
edge=intarr(3+nrbmrk,nredge)
readf,1,edge
close,1

if dev eq 'X' then loadct,13
if dev eq 'PS' then loadct,0
set_plot,dev

if dev eq 'X' then WINDOW, xsize=BOXSIZE,ysize=BOXSIZE
if dev eq 'PS' then device,filename='meshonly.ps'

fac=BOXSIZE/((max(coord(1,*))- min(coord(1,*)))*1.1)
xoff=min(coord(1,*))+20
yoff=xoff
if dev eq 'PS' then begin
	fac=fac*16
	xoff=0
	yoff=0
end
c1=250&c2=200
if dev eq 'PS' then c1=0

if(useedge ne 1)then begin

for i=0,nrel-1 do begin
	startindex=con(1,i)-1 & mat=con(1+nrcon,i)
	x0=coord(1,startindex)*fac+xoff		
	y0=coord(2,startindex)*fac+yoff
	xm=x0&ym=y0
	c1=mat*50+100

	plots,x0,y0,/device,linestyle=1,color=c1
	if (prel) then x2=x0&y2=y0
	if nrcon ne 8 then begin
		for j=2,nrcon do begin
			index=con(j,i)-1	
			x1=coord(1,index)*fac+xoff
			y1=coord(2,index)*fac+yoff
			plots,x1,y1, /continue,/device,color=c1
			if(prel) then xm=xm+x1&ym=ym+y1
		end
		plots,x0,y0,/continue,/device,color=c1
		xm=xm/nrcon&ym=ym/nrcon
	end
	if nrcon eq 8 then begin
			index=con(5,i)-1
			x1=coord(1,index)*fac+xoff
			y1=coord(2,index)*fac+yoff
			plots,x1,y1, /continue,/device,color=c1
			index=con(2,i)-1
			x1=coord(1,index)*fac+xoff
			y1=coord(2,index)*fac+yoff
			plots,x1,y1, /continue,/device,color=c1
			xm=xm+x1&ym=ym+y1
			index=con(6,i)-1
			x1=coord(1,index)*fac+xoff
			y1=coord(2,index)*fac+yoff
			plots,x1,y1, /continue,/device,color=c1
			index=con(3,i)-1
			x1=coord(1,index)*fac+xoff
			y1=coord(2,index)*fac+yoff
			plots,x1,y1, /continue,/device,color=c1
			xm=xm+x1&ym=ym+y1
			index=con(8,i)-1
			x1=coord(1,index)*fac+xoff
			y1=coord(2,index)*fac+yoff
			plots,x1,y1, /continue,/device,color=c1
			plots,x0,y0,/continue,/device,color=c1
			if (con(3,i) ne con(4,i))or(con(7,i) ne con(3,i))$
				then print,'Fehler im Serendipity El.'
			xm=xm/3&ym=ym/3
	end
	;if dev eq 'PS' then c1=0

	if (prel) then xyouts,xm,ym,strtrim(i+1,1),$
		color=c2,/device,charsize=0.1*charfac
	;if (prel) and dev eq 'X' then xyouts,xm,ym-10,$
		;strtrim(mat,1),color=c1,/device,charsize=0.3*charfac
	
end
c1=150
change=0
;if dev eq 'PS' then c1=0
;if dev eq 'X' then change=1
altoff=3
c2=130
for i=0,nrnd-1 do begin
		;if(change) then begin
		;	if(c1 eq 150)then  c1 = 170 else c1 =150
		;end
		x0=coord(1,i)*fac+xoff		
		y0=coord(2,i)*fac+yoff
		if(prx)then plots,x0,y0,psym=7,/device
		if (prnd)then begin
			xyouts,x0+altoff,y0+altoff,strtrim(i+1,1)$
				,color=c2,/device,charsize=0.5*charfac
			if altoff eq 3 then altoff= -3 $
				else altoff=3
		end
		if(spnd(i) eq 1)then begin
			c1=spnd(i)*10+60
			c1=200
			plots,x0,y0,psym=7,/device
		end
end
end
if(useedge eq 1)then begin

c3=120
for i=0,nredge-1 do begin
	j=edge(1,i)-1
	x0=coord(1,j)*fac+xoff		
	y0=coord(2,j)*fac+yoff
	x1=x0&y1=y0
	if(edge(3,i)eq 0)then c1=50
	if(edge(3,i)eq 1)then c1=150
	if(edge(3,i)gt 100)then c1=100+25*(edge(3,i)-100)	
	plots,x0,y0,/device,color= c1
	j=edge(2,i)-1
	x0=coord(1,j)*fac+xoff		
	y0=coord(2,j)*fac+yoff
	plots,x0,y0,/device,/continue,color= c1
	y1=(y1+y0)/2 & x1=(x1+x0)/2
	if(predge)then begin
		xyouts,x1,y1,strtrim(i+1,1),$
			color=c3,/device,charsize=0.5*charfac
	end
	
end
altoff=3
for i=0,nrnd-1 do begin
	x0=coord(1,i)*fac+xoff		
	y0=coord(2,i)*fac+yoff
	if(prx)then plots,x0,y0,psym=7,/device
	if (prnd)then begin
		xyouts,x0+altoff,y0+altoff,strtrim(i+1,1)$
			,color=c2,/device,charsize=0.5*charfac
		if altoff eq 3 then altoff= -3 $
			else altoff=3
		end
	if(spnd(i) eq 1)then begin
			c1=spnd(i)*10+60
			c1=100
			plots,x0,y0,psym=7,/device
	end
end
end
if dev eq 'PS' then begin
	print,'Output in meshonly.ps'
	device,/close
end
if dev eq 'X' then begin
	tmp=get_kbrd(1)
	if tmp eq 'k' then wdelete
end
end





