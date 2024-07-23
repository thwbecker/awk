nr= -1

delta= 0
stress= 0
disp= 1

close,1

dev='X'
;dev='PS'

filedir="/datdyn/becker/finel/"
if (nr eq 0) then file=filedir+"du_profil" 

step=1 & stop=nr & start=nr
if(nr eq -1)then begin
	start=0 & step=10 &  stop = 150

end

x= 550-findgen(100)
xx=450+indgen(100)

set_plot,dev
if dev eq 'X' then window,0


if dev eq 'PS' then begin
	device,filename='figure.ps', bits_per_pixel=8;,/color
	print,'Output in figure.ps'
end
k=0
for i=start+step,stop,step do begin
	if (i gt 0) then file=filedir+"du_profil."+strtrim(i,1)
	print,'Reading ',file
		if(i eq start+step)then begin
			openr,1,file
			n=0
				while not eof(1)do begin
				readf,1,xxx,d1,d2,d3,d4,d5,d6,d7
				n=n+1
			end	
			ddu=dblarr(n,(stop-start+step)/step)
			close,1
		end
		
		du=dblarr(8,n)
		openr,1,file
		readf,1,du
		close,1
		if stress eq 1 then begin
			plot,du(0,*),du(7,*),psym=1,xrange=[440,560],$
				title="Spannungen Iteration"+strtrim(i,1)
		end
		if disp eq 1 then begin
			plot,du(0,*),du(3,*),psym=1,xrange=[440,560],$
				title="Displacement Iteration"+strtrim(i,1)
			oplot,du(0,*),du(1,*),psym=5
			oplot,xx,(sqrt(50^2 - (500-x)^2)/50.0)* max(du(3,*)),$
				psym=0
		end	
		if delta ne 1 then begin		
			tmp=get_kbrd(1)
	
			if tmp eq 'k' then stop

				
			erase
		end
		ddu(*,k)=du(5,sort(du(0,*)))
		k=k+1
end
if delta eq 1 then begin
	x=fltarr(n,k+1)
	y=fltarr(n,k+1)
	for i=0,k do begin
		y(*,i)=i+1
	end
	for i=0,n-1 do begin
		x(i,*)=450.0+(100.0/n)*i
	end
	
	left=0 & right=14
	south=0 & north = n-1
;	!p.font=8
	c1=1.5
	shade_surf,ddu(south:north,left:right),x(south:north,left:right),$
		y(south:north,left:right),$
		/noerase,yrange=[right+1,left],charsize=c1

	surface,ddu(south:north,left:right),x(south:north,left:right),$
		y(south:north,left:right),yrange=[right+1,left],$
		title="Inkrementeller Versatz",$
		xtitle="x/m",ztitle="du/m",/noerase,$
		ytitle="Iterationen / "+strtrim(step,1),charsize=c1
	
end
if dev eq 'PS' then device,/close
end