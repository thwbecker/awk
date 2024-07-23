pro plotm1,autoscale,prnd,printing

if(n_params() eq 0)then begin
	printing=0
	autoscale=0
	prnd=0
end
if(n_params() eq 1)then begin
	printing=0
	prnd=0
end
if(n_params() eq 2)then printing=0
if (printing)then dev='PS' else dev='X'
BOXSIZE=1000
DOTTED=1
dmag=10
DPV=0
loadct,13
close, 1
openr,1,'meshe'
readf,1,nrel,nrcon,time
con=intarr(2+nrcon,nrel)
readf,1,con
close,1


set_plot,dev
if dev eq 'X' then WINDOW,4, xsize=BOXSIZE,ysize=BOXSIZE
if dev eq 'PS' then device,filename='mesh.ps'

openr, 1, 'disp'
count=1

while not eof(1) do begin

readf, 1, nrnd
coord=fltarr(5,nrnd)
readf,1,coord
if count gt 2 then autoscale=0
if(autoscale) then begin
	
	if( max(coord(3,*)) ne 0 ) then $
		dmag = round(max(coord(1,*))/max(coord(3,*))/50)
	if (dmag eq 0) then dmag=1
end
fac=BOXSIZE/(max(coord(1,*))*1.5)
xoff=50
yoff=xoff
if dev eq 'PS' then begin
	fac = fac *20
end
k=1
waittime=.3
for i=0,nrel-1 do begin
	if (k*40)gt 200 then k=1
	cl=k*40+10
	startindex=con(1,i)-1
	x0=coord(1,startindex)*fac+xoff		
	y0=coord(2,startindex)*fac+yoff
	plots,x0,y0,/device,color=cl+5
	for j=2,nrcon do begin
		index=con(j,i)-1	
		x1=coord(1,index)*fac+xoff
		y1=coord(2,index)*fac+yoff
		cl =cl+j*10
		
		plots,x1,y1, /continue,/device,color=cl
		wait,waittime
	end
	
	if dev eq 'PS' then cl=0
	plots,x0,y0,/continue,/device,color=cl+3*10
	wait,waittime
	k=k+1
	
end
cl=150
if dev eq 'PS' then cl = 0
if (prnd) then begin
	for i=0,nrnd-1 do begin
		x0=coord(1,i)*fac+xoff		
		y0=coord(2,i)*fac+yoff
		xyouts,x0+5,y0+5,strtrim(i+1,1)$
			,color=cl,/device,charsize=0.8
	end
end




if dev eq 'X' then begin
	xyouts,BOXSIZE/2-200,BOXSIZE-50,'Verschiebungen, mit Faktor '+$
	strtrim(dmag,1)+' vergroessert',/device
	xyouts,BOXSIZE/2-200,BOXSIZE-30,'Zeitschritt '+strtrim(count,1),/device
	xyouts,BOXSIZE/2-200,10,'Taste drücken für nächstes Bild...',/device
end
cl=100
if dev eq 'PS' then cl =0
if (DPV) then begin
	for i=0,nrnd-1 do begin
		arrow,coord(1,i)*fac+xoff,coord(2,i)*fac+yoff,$
			(coord(1,i)+coord(3,i)*dmag)*fac+xoff,$
			(coord(2,i)+coord(4,i)*dmag)*fac+yoff,$
			/device,color=cl
	end
end



if dev eq 'X' then tmp=get_kbrd(1)
erase
count=count+1
end
if dev eq 'X' then wdelete,4,0
if dev eq 'PS' then device,/close
end



