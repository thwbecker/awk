pro plotmesh,autoscale,prnd,printing,dpv
print,'plotmesh [autoscale prnd printing dpv]'
if(n_params() lt 4)then dpv=0
if(n_params() lt 3)then printing=0
if(n_params() lt 2)then prnd=0
if(n_params() lt 1)then autoscale=1
if (printing)then dev='PS' else dev='X'

BOXSIZE=600

DOTTED=1
REFERENCE=0
dmag=10
filedir="/home/datdyn2/becker/finel/"
close, 1

openr,1,filedir+'meshe'
readf,1,nrel,nrcon,time
con=intarr(2+nrcon,nrel)
readf,1,con
close,1

set_plot,dev
if dev eq 'X' then WINDOW,0, xsize=BOXSIZE,ysize=BOXSIZE
loadct,13
if dev eq 'PS' then begin
	device,filename='mesh.ps',/color, bits_per_pixel=8
	print,'Output in mesh.ps'
end
openr, 1, filedir+'disp'
count=1
while not eof(1) do begin
readf, 1, nrnd
coord=fltarr(5,nrnd)
readf,1,coord
if count gt 2 then autoscale=0
if autoscale eq 1  then begin	
	if( max(coord(3,*)) ne 0 ) then $
		dmag = round(max(coord(1,*))/max(coord(3,*))/50)$
		else dmag=1
	if (dmag eq 0) then dmag=1
end
if(autoscale ne 0)and(autoscale ne 1)then dmag = autoscale
fac=BOXSIZE/(max(coord(1,*))*1.5)
xoff=50
yoff=xoff
if dev eq 'PS' then begin
	fac = fac *20
end
if (REFERENCE)then begin
	for i=0,nrel-1 do begin
	startindex=con(1,i)-1
	x0=coord(1,startindex)*fac+xoff		
	y0=coord(2,startindex)*fac+yoff
	plots,x0,y0,/device,linestyle=DOTTED,color=155
	cl = 150
	if nrcon ne 8 then begin
		for j=2,nrcon do begin
			index=con(j,i)-1	
			x1=coord(1,index)*fac+xoff
			y1=coord(2,index)*fac+yoff
			
			;if dev eq 'PS' then cl = 0
			plots,x1,y1, /continue,/device,$
				linestyle=DOTTED,color=cl
		end
	end
	if nrcon eq 8 then begin
		index=con(5,i)-1
		x1=coord(1,index)*fac+xoff
		y1=coord(2,index)*fac+yoff
		plots,x1,y1, /continue,/device,color=cl,linestyle=0
		index=con(2,i)-1
		x1=coord(1,index)*fac+xoff
		y1=coord(2,index)*fac+yoff
		plots,x1,y1, /continue,/device,color=cl,linestyle=0
		index=con(6,i)-1
		x1=coord(1,index)*fac+xoff
		y1=coord(2,index)*fac+yoff
		plots,x1,y1, /continue,/device,color=cl,linestyle=0
		index=con(3,i)-1
		x1=coord(1,index)*fac+xoff
		y1=coord(2,index)*fac+yoff
		plots,x1,y1, /continue,/device,color=cl,linestyle=0
		index=con(8,i)-1
		x1=coord(1,index)*fac+xoff
		y1=coord(2,index)*fac+yoff
		plots,x1,y1, /continue,/device,color=cl,linestyle=0
		plots,x0,y0,/continue,/device,color=cl,linestyle=0
		if (con(3,i) ne con(4,i))or(con(7,i) ne con(3,i))$
			then print,'Fehler im Serendipity El.'		
	end
	cl=155
;	if dev eq 'PS' then cl=0
	plots,x0,y0,/continue,/device,linestyle=DOTTED,color=cl
	
end
end
cl=150
if dev eq 'PS' then cl = 0
if (prnd eq 1) then begin
	for i=0,nrnd-1 do begin
		x0=coord(1,i)*fac+xoff		
		y0=coord(2,i)*fac+yoff
		xyouts,x0+5,y0+5,strtrim(i+1,1)$
			,color=cl,/device,charsize=0.8
	end
end



for i=0,nrel-1 do begin
	startindex=con(1,i)-1&mat=con(1+nrcon,i)-1
	x0=(coord(1,startindex)+$
		coord(3,startindex)*dmag)*fac+xoff		
	y0=(coord(2,startindex)+coord(4,startindex)*dmag)*fac+yoff
	cl=50*(mat+1)
;	if dev eq 'PS' then cl =0
	plots,x0,y0,/device,linestyle=0,color=cl
	if(prnd eq 2) then begin
		if((i mod 2) eq 0)then cnd =100 else cnd=250
		if((i mod 2) eq 0)then setoff = 5 else setoff=-5
;		if dev eq 'PS' then cnd=150
		xyouts,x0,y0,strtrim(i+1,1)$
			,color=cnd,/device,charsize=0.8
	end
	if nrcon ne 8 then begin
		for j=2,nrcon do begin
			index=con(j,i)-1	
			x1=(coord(1,index)+coord(3,index)*dmag)*fac+xoff
			y1=(coord(2,index)+coord(4,index)*dmag)*fac+yoff
			plots,x1,y1, /continue,/device,linestyle=0,$
				color=cl
			if(prnd eq 2)then begin
				xyouts,x1,y1,strtrim(i+1,1)$
					,color=cnd,/device,charsize=0.8
			end
		end
		plots,x0,y0,/continue,/device,linestyle=0,color=cl
	
	end
	if nrcon eq 8 then begin
		index=con(5,i)-1
		x1=(coord(1,index)+coord(3,index)*dmag)*fac+xoff
		y1=(coord(2,index)+coord(4,index)*dmag)*fac+yoff
		plots,x1,y1, /continue,/device,color=cl,linestyle=0
		index=con(2,i)-1
		x1=(coord(1,index)+coord(3,index)*dmag)*fac+xoff
		y1=(coord(2,index)+coord(4,index)*dmag)*fac+yoff
		plots,x1,y1, /continue,/device,color=cl,linestyle=0
		index=con(6,i)-1
		x1=(coord(1,index)+coord(3,index)*dmag)*fac+xoff
		y1=(coord(2,index)+coord(4,index)*dmag)*fac+yoff
		plots,x1,y1, /continue,/device,color=cl,linestyle=0
		index=con(3,i)-1
		x1=(coord(1,index)+coord(3,index)*dmag)*fac+xoff
		y1=(coord(2,index)+coord(4,index)*dmag)*fac+yoff
		plots,x1,y1, /continue,/device,color=cl,linestyle=0
		index=con(8,i)-1
		x1=(coord(1,index)+coord(3,index)*dmag)*fac+xoff
		y1=(coord(2,index)+coord(4,index)*dmag)*fac+yoff
		plots,x1,y1, /continue,/device,color=cl,linestyle=0
		plots,x0,y0,/continue,/device,color=cl,linestyle=0
		if (con(3,i) ne con(4,i))or(con(7,i) ne con(3,i))$
			then print,'Fehler im Serendipity El.'
	end
end

if dev eq 'X' then begin
	xyouts,BOXSIZE/2-200,BOXSIZE-50,'Verschiebungen, mit Faktor '+$
	strtrim(dmag,1)+' vergroessert',/device
	xyouts,BOXSIZE/2-200,BOXSIZE-30,'Zeitschritt '+strtrim(count,1),/device
	xyouts,BOXSIZE/2-200,10,'Taste drücken für nächstes Bild...',/device
end
cl=100
;if dev eq 'PS' then cl =0
if (dpv) then begin
	if (nrnd gt 100)then inc= (nrnd/100)
	if (nrnd le 100)then inc= 1
	for i=0,nrnd-1,inc do begin
		arrow,coord(1,i)*fac+xoff,coord(2,i)*fac+yoff,$
			(coord(1,i)+coord(3,i)*dmag)*fac+xoff,$
			(coord(2,i)+coord(4,i)*dmag)*fac+yoff,$
			/device,color=cl
	end
end



if dev eq 'X' then begin
	tmp=get_kbrd(1)
	if(count gt 1)then begin
		erase
		if(tmp eq 'k') then begin
			wdelete,0
			stop
		end
	end
	if tmp eq 'k' then erase
end
count=count+1
end
if (dev eq 'X')then begin
	if(tmp eq 'k') then wdelete,0
end
if dev eq 'PS' then device,/close
end




