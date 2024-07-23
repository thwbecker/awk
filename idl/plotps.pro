;Plots stresses and displacements from files "stre" and "disp"

dpmag=10			;magnify displacements


close, 1
;dev='X'
dev='PS'


			;opens "stre" for data
openr, 1, 'stre'
readf, 1, nrel		;nrel is number of elements (element mids)
stre=fltarr(9,nrel)	;stress array to read from
xstre=fltarr(nrel)	;x-position of stress matrix-elements
ystre=fltarr(nrel)	;y-position 
sig11=fltarr(nrel)	;sigma 11 matrix element
sig22=fltarr(nrel)
sig12=fltarr(nrel)
first_stre=fltarr(nrel)	;first main stress
second_stre=fltarr(nrel);second main stress
alpha=fltarr(nrel)	;arc between first main stress and x-axis
pi=3.141
readf, 1, stre
close, 1


 	

for i=0, nrel-1 do begin
	xstre(i)=stre(1,i)
	ystre(i)=stre(2,i)
	sig11(i)=stre(3,i)
	sig22(i)=stre(4,i)
	sig12(i)=stre(5,i)
	first_stre(i)=stre(6,i)
	second_stre(i)=stre(7,i)
	alpha(i)=(stre(8,i)/360)*2*pi
end
ww=sqrt(nrel)

;weird extrapolation starts here!!!
;if ww ne fix(ww) then begin
;	ww=ceil(ww)
;	newnrel=(ww*ww)
;	xstre=congrid(xstre,newnrel)
;	ystre=congrid(ystre,newnrel)
;	sig11=congrid(sig11,newnrel)
;	sig22=congrid(sig22,newnrel)
;	sig12=congrid(sig12,newnrel)
;	first_stre=congrid(first_stre,newnrel)
;	second_stre=congrid(second_stre,newnrel)
;	alpha=congrid(alpha,newnrel)
;endif

if ww eq fix(ww) then begin
	stressnet=fltarr(ww,ww)
	xstressnet=fltarr(ww,ww)
	ystressnet=fltarr(ww,ww)
	for i=0,ww-1 do begin
		for j=0,ww-1 do begin
			xstressnet(i,j)=xstre(j*ww+i)
			ystressnet(i,j)=ystre(j*ww+i)
		end
	end
endif

;opens 'disp' for data
openr, 1, 'disp'
readf, 1, nrnd		;nrnd is the number of nodes for the displacements

disp=fltarr(5,nrnd)	;displacement array to read from

readf, 1, disp
close, 1
we=sqrt(nrnd)

net=fltarr(we,we)
xnet=fltarr(we,we)
ynet=fltarr(we,we)
dxnet=fltarr(we,we)
dynet=fltarr(we,we)

for i=0,we-1 do begin
	for j=0,we-1 do begin
		xnet(i,j)=disp(1,j*we+i)
		ynet(i,j)=disp(2,j*we+i)
		dxnet(i,j)=xnet(i,j)+disp(3,j*we+i)*dpmag
		dynet(i,j)=ynet(i,j)+disp(4,j*we+i)*dpmag
	end
end

;	PLOTTING
set_plot,dev
;mesh and stuff

if dev eq 'X' then WINDOW,0, xsize=500,ysize=500,title='Displacements'
if dev eq 'PS' then device,filename='displacements.ps'

;undeformed mesh

surface,net,xnet,ynet,zstyle=4,ax=90,az=0,xrange=[min(dxnet),$
	max(dxnet)],yrange=[min(dxnet),max(dxnet)],$
	/save,linestyle=2

;deformed mesh
surface,net,dxnet,dynet,zstyle=4,ax=90,az=0,xrange=[min(dxnet),$
	max(dxnet)],yrange=[min(dxnet),max(dxnet)],/noerase,$
		linestyle=0

;knode numbers and displacement vectors
xyouts,0.2,max(dynet)*1.3,"Displacements (magnified with factor "$
	+strtrim((dpmag),1)+")"
	

for i=0,we-1 do begin
	for j=0,we-1 do begin
		xyouts,xnet(i,j)*1.02,ynet(i,j)*1.02,$
			strtrim(fix(j*we+i+1),1)
		arrow,xnet(i,j),ynet(i,j),dxnet(i,j),dynet(i,j),$
			/data
	end
end	

;Hauptspannungsachsen
plstfac=1
if (max(first_stre) or max(second_stre)) ne 0 then begin
	if (max(first_stre) gt max(second_stre)) then $
	factor=max(first_stre)else factor=max(second_stre)
	plstfac=0.1/factor
endif

for i=0,nrel-1 do begin
	x0=xstre(i)
	y0=ystre(i)
	x1=xstre(i) + (first_stre(i)*cos(alpha(i))) *plstfac
	y1=ystre(i) + (first_stre(i)*sin(alpha(i))) *plstfac
	x2=xstre(i) - (second_stre(i)*sin(alpha(i)))*plstfac
	y2=ystre(i) + (second_stre(i)*cos(alpha(i)))*plstfac
	x3=xstre(i) - (first_stre(i)*cos(alpha(i))) *plstfac
	y3=ystre(i) - (first_stre(i)*sin(alpha(i))) *plstfac
	x4=xstre(i) + (second_stre(i)*sin(alpha(i)))*plstfac
	y4=ystre(i) - (second_stre(i)*cos(alpha(i)))*plstfac
	arrow,x0,y0,x1,y1,/data,/solid
	arrow,x2,y2,x0,y0,/data,/solid
	arrow,x0,y0,x3,y3,/data,/solid
	arrow,x4,y4,x0,y0,/data,/solid
end
if dev eq 'PS' then device, /close

;SIGMAS
;Sigma 11
if ww eq fix(ww) then begin
	if dev eq 'X' then WINDOW,1, xsize=300,ysize=300,$
		title='Sigma 11',xpos=0,ypos=800
	if dev eq 'PS' then device,filename='sigma11.ps'
	for i=0,ww-1 do begin
		for j=0,ww-1 do begin
			stressnet(i,j)=-sig11(j*ww+i)
		end
	end
	shade_surf,stressnet,xstressnet,ystressnet,ax=90,az=0,$
		shade=bytscl(stressnet)
	if dev eq 'PS' then device,/close
endif

;Sigma 22
if ww eq fix(ww) then begin
	if dev eq 'X' then WINDOW,2, xsize=300,ysize=300,$
		title='Sigma 22',xpos=312,ypos=390
	if dev eq 'PS' then device,filename='sigma22.ps'
	for i=0,ww-1 do begin
		for j=0,ww-1 do begin
			stressnet(i,j)=-sig22(j*ww+i)
		end
	end
	shade_surf,stressnet,xstressnet,ystressnet,ax=90,az=0,$
		shade=bytscl(stressnet)
	if dev eq 'PS' then device,/close
endif

;Sigma 12
if ww eq fix(ww) then begin
	if dev eq 'X' then WINDOW,3, xsize=300,ysize=300,$
		title='Sigma 12',xpos=312,ypos=800
	if dev eq 'PS' then device,filename='sigma11.ps'
	for i=0,ww-1 do begin
		for j=0,ww-1 do begin
			stressnet(i,j)=-sig12(j*ww+i)
		end
	end
	shade_surf,stressnet,xstressnet,ystressnet,ax=90,az=0,$
		shade=bytscl(stressnet)
	;contour,stressnet,xstressnet,ystressnet,nlevels=10
	if dev eq 'PS' then device,/close
endif

;if dev eq 'X' then WINDOW,4, xsize=300,ysize=300,$
;	title='Hauptspannungsachsen',xpos=0,ypos=390
;if dev eq 'PS' then device,filename='mainstreaxes.ps'
;if dev eq 'PS' then device,/close



end









