;pro plotmsa, ppel,printing
;PLOTTEN DER HAUPTSPANNUNGSACHSEN
print,'PLOT MAIN STRESS AXIS [stresspoint/element printing]'
if n_params() lt 2 then printing=0
if n_params() lt 1 then ppel=1
if (printing) then dev='PS' else dev='X'

;ppel meint Punkte pro Element, normalerweise ein Spannungspunkt 

windowsize=600 &  headsize=.4
spannungsfaktor=50.0
xoff=30
yoff=xoff
pi=3.141
filedir="/home/datdyn2/becker/finel/"

step=2

;Einlesen der Anzahl der Elemente fuer den Schleifenindex
close, 1
openr, 1, filedir+'disp'
readf, 1, nrnd
coord=fltarr(5,nrnd)
readf,1,coord
close,1

;Einlesen der Spannungsdaten
openr, 1, filedir+'stre'
readf, 1, nrel		     	;nrel is number of elements (element mids)
stre=fltarr(6,nrel*ppel)	;stress array to read from
xstre=fltarr(nrel*ppel)		;x-position of stress matrix-elements
ystre=fltarr(nrel*ppel)		;y-position 
first_stre=fltarr(nrel*ppel)	;first main stress
second_stre=fltarr(nrel*ppel)	;second main stress
alpha=fltarr(nrel*ppel)		;arc between first main stress and x-axis


readf, 1,stre
close, 1
help,stre

;(x,y)-Position der Spannungswertausgabe
xstre(*)=stre(1,*)
ystre(*)=stre(2,*)

;Spannungswerte (Beide Hauptachsenbetraege, Winkel)
first_stre(*)=stre(3,*)
second_stre(*)=stre(4,*)
alpha(*)=(stre(5,*)/180.0)*3.14159265358979

set_plot,dev
if (dev eq 'PS') then loadct,0 else loadct,13		
if dev eq 'X' then WINDOW, xsize=windowsize,ysize=windowsize, $
		title='Hauptspannungsachsen'
if dev eq 'PS' then device,filename='msa.ps', bits_per_pixel=8


plstfac1=windowsize*0.9/max(xstre)
if (max(abs(first_stre)) eq 0) and (max(abs(second_stre)) eq 0) then factor=1
if (max(abs(first_stre)) gt max(abs(second_stre))) then factor=max(abs(first_stre))$
	else factor=max(abs(second_stre))
plstfac2=(plstfac1/factor)*spannungsfaktor

if dev eq 'PS' then begin
	plstfac1 = plstfac1 *20
	plstfac2=plstfac2*25
end

c1=0 & c2=0
if (dev eq 'X') then BEGIN
   c1=105 & c2=230
ENDIF 
;step = 3

print, "degmittelwert=", mittelwert(stre(5, *))
for i=0,nrel*ppel-1,step do begin
	x0=xstre(i)*plstfac1 + xoff
	y0=ystre(i)*plstfac1 + yoff
	x1=xstre(i)*plstfac1 + (first_stre(i)*cos(alpha(i))) *plstfac2+xoff
	y1=ystre(i)*plstfac1 + (first_stre(i)*sin(alpha(i))) *plstfac2+yoff
	x2=xstre(i)*plstfac1 - (second_stre(i)*sin(alpha(i)))*plstfac2+xoff
	y2=ystre(i)*plstfac1 + (second_stre(i)*cos(alpha(i)))*plstfac2+yoff
	x3=xstre(i)*plstfac1 - (first_stre(i)*cos(alpha(i))) *plstfac2+xoff
	y3=ystre(i)*plstfac1 - (first_stre(i)*sin(alpha(i))) *plstfac2+yoff
	x4=xstre(i)*plstfac1 + (second_stre(i)*sin(alpha(i)))*plstfac2+xoff
	y4=ystre(i)*plstfac1 - (second_stre(i)*cos(alpha(i)))*plstfac2+yoff
	;if((i mod step) eq 0)then begin
		arrow,x0,y0,x1,y1,/solid,/device,hsize=-headsize,color=c1
		arrow,x2,y2,x0,y0,/solid,/device,hsize=-headsize,color=c2
		arrow,x0,y0,x3,y3,/solid,/device,hsize=-headsize,color=c1
		arrow,x4,y4,x0,y0,/solid,/device,hsize=-headsize,color=c2
	;end
end

plots,xoff,0+yoff,/device
plots,max(coord(1,*))*plstfac1+ xoff,yoff,/device,/continue
plots,max(coord(1,*))*plstfac1+ xoff,max(coord(2,*))*plstfac1+yoff,/device,/continue
plots,xoff,yoff+max(coord(2,*))*plstfac1,/device,/continue
plots,xoff,yoff,/device,/continue


if dev eq 'PS' then device,/close
if dev eq 'X' then begin
	tmp=get_kbrd(1)
	if tmp eq 'k' then wdelete,0
end

end









