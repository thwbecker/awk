PRO colorscl,min,max,title,col,psout, flip
if n_params() lt 4 then begin
	print,'COLORSCL, Minimum, Maximum, Titel, Schriftfarbe [ PS-Ausgabe]'
	stop
end
if n_params() lt 5 then psout = 0
if psout eq 1 then dev ='PS' else dev = 'X'
set_plot,dev
!p.multi=0
if dev eq 'PS' then begin
	device,filename='colorscl.eps',bits_per_pixel=8,/color,$
		/encapsulated,xsize=8,ysize=3,scale_factor=1.0,xoffset=1
	print,'Output in colorscl.eps'
	
end

f=findgen(256) * (max-min)/256.0 + min
ff=fltarr(256,50)
for i=0,49 do begin
   IF(flip)THEN $
     ff(*,i)=255-f $
   ELSE $
   ff(*, i) = f
end
if dev eq 'X' then window,5,title='FARBCODE',xsize=370,ysize=160
mk_image,ff

axis,xaxis=0,xticklen=-0.04,xrange=[min,max],color=col,xthick=2.,$
	xticks=2,xtitle=title,xstyle=1
axis,xaxis=1,xtickname=['MIN','MAX'],xticks=1,xticklen=1,color=col,$
	xstyle=1

if dev eq 'PS' then begin
	device,/close
	set_plot,'X'
end
wset,0

end
