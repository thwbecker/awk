; Routine zum Plotten von gemiitelten Spannungen am Fault als Funktion der Zeit
;pro pfstr,fault,start,stop

close,1

faultstart= 2 & faultstop= 2
teststart=1 & teststop=50 & check_length=1
start=1 & stop = 100

plotframe=0 & oldstressstyle=0
readdata=0 & printdata = 0
static=1

nrflt=faultstop-faultstart+1

ny=0.25
e=5.0e10
tau_unend=2.0e8

dtref=((1.0 - ny^2)/e)*tau_unend*4.0
dev='X'
;dev='PS'



for test=teststart,teststop do begin

;modeldir="moving_sngl_crack.2/"
;modeldir="wing_crack_newer/"
;modeldir="lobe_crack/testrun2/"+strtrim(test,1)+"/"
;modeldir="orient_series/reference/"
modeldir="orient_series/testrun3/"+strtrim(test,1)+"/"
;modeldir=""
filedir="/datdyn/becker/finel/"+modeldir

openr,1,filedir+"faultcoord"
	readf,1,nrallflt
	fltcoord=dblarr(4,nrallflt)
	readf,1,fltcoord
close,1
		
print,nrallflt
print,fltcoord

set_plot,dev
if dev eq 'PS' then begin
	device,filename='du.eps', bits_per_pixel=8,$
		/encapsulated,xsize=22,ysize=18,scale_factor=1.0
;		/color,/landscape
	print,'Output in du.eps'
end
for fault=faultstart,faultstop do begin

if (oldstressstyle)then begin
	
		openr,1,filedir+"stre12."+strtrim(1,1)+".xyz"
		readf,1,time,fmyu,sdmyu,nmyu,hp,foff
		close,1
	
endif else begin
	openr,1,filedir+"mesh_constants"
		readf,1,emodul,nyu
		readf,1,alpha1,deltat,alpha2
		readf,1,nmyu,fmyu,sdmyu
		readf,1,foff,loff,hp
	close,1
endelse



if (check_length)then begin
	it=1
	errorvar=0
	while (errorvar eq 0) do  begin
		file=filedir+"profil.flt"+strtrim(fault,1)+"."+strtrim(it,1)
		openr,1,file,error=errorvar
		close,1
		it=it+1
	end
	stop=it & start=1
	print,'Using checke',stop,'Iterations'
endif else begin
	print,'Using fixed iterations from ',start,' to ',stop
endelse


for it=start,stop do begin
tmp=""
file=filedir+"profil.flt"+strtrim(fault,1)+"."+strtrim(it,1)
if (plotframe eq 1)then print,'Reading ',file

if (it eq start)then begin
	openr,1,file
	n=0
	while not eof(1) do begin
		readf,1,xx,yy,dutgesamt,dutmesh,dungesamt,dunmesh,stau,snos
		n=n+1
	end
	close,1
end

du=dblarr(8,n)
openr,1,file
readf,1,du
close,1

if((it eq start)and(fault eq faultstart))then begin
	csmax=dblarr(nrflt,stop-start+1)
	taumedian=dblarr(nrflt,stop-start+1)
	nosmedian=dblarr(nrflt,stop-start+1)
	csmedian=dblarr(nrflt,stop-start+1)
	fieldstress=dblarr(10,stop-start+1)
	csmin=dblarr(nrflt,stop-start+1)
	csend=dblarr(nrflt,stop-start+1)
	csmid=dblarr(nrflt,stop-start+1)
	dumean=dblarr(nrflt,stop-start+1)
	dumid=dblarr(nrflt,stop-start+1)
	duend=dblarr(nrflt,stop-start+1)
end
if(it eq start)then begin
	tau=dblarr(stop-start+1,n)
	nos=dblarr(stop-start+1,n)
end

fvec=dblarr(2) & nfvec=dblarr(2)
fvec(0)=fltcoord(2,fault-1)-fltcoord(0,fault-1)
fvec(1)=fltcoord(3,fault-1)-fltcoord(1,fault-1)
length=betrag(fvec)
fvec = fvec / length
nfvec(0)= -fvec(1) & nfvec(1)=fvec(0) 
a=length / 2.0

if (it eq start)then print,'Fault ',fault,'(',fvec,')',a

duref=dtref*a

dist=dblarr(n)
dist(*)=(sqrt( (du(0,*)-fltcoord(0,fault-1))^2 + $
	       (du(1,*)-fltcoord(1,fault-1))^2)-a)/a

du=du(*,sort(dist))
dist=dist(sort(dist))

if ((dev eq 'X')and(plotframe eq 1)) then begin

	plot,dist(*),du(2,*)-du(3,*)
	oplot,dist(*),du(4,*)-du(5,*)
end
for lp=0,n-1 do begin
	if (du(2,lp) ne du(3,lp)) then tmp='s'
end
;if(fault eq faultstart)then begin
;	for i=0,100,10 do begin
;		fieldstress(0,it-start)=max(xystre(2,*,i))
;	end
;end	

tau(it-start,*) = du(6,*)
nos(it-start,*) = du(7,*)

csmax(fault-faultstart,it-start)   =max(cstress(du(6,1:n-2),du(7,1:n-2),fmyu,hp,foff))
csmedian(fault-faultstart,it-start)=mittelwert(cstress(du(6,1:n-2),du(7,1:n-2),fmyu,hp,foff))
taumedian(fault-faultstart,it-start)=mittelwert(tau(it-start,1:n-2))
nosmedian(fault-faultstart,it-start)=mittelwert(nos(it-start,1:n-2))
csmin(fault-faultstart,it-start)= min(cstress(du(6,1:n-2),du(7,1:n-2),fmyu,hp,foff))
csend(fault-faultstart,it-start) = cstress(du(6,n-2),du(7,n-2),fmyu,hp,foff)
csmid(fault-faultstart,it-start) = cstress(du(6,n/2),du(7,n/2),fmyu,hp,foff)
if (it eq start)then begin
	duend(fault-faultstart,0) = du(2,n-2)-du(3,n-2)
	dumid(fault-faultstart,0) = du(2,fix(n/2))-du(3,fix(n/2))
	dumean(fault-faultstart,0)= mittelwert(du(2,*)-du(3,*))
endif else begin
	duend(fault-faultstart,it-start)=(du(2,n-2)-du(3,n-2)); - duend(fault-faultstart,it-start-1)
	dumid(fault-faultstart,it-start)=(du(2,fix(n/2))-du(3,fix(n/2))); - dumid(fault-faultstart,it-start-1)
	dumean(fault-faultstart,it-start)= mittelwert(du(2,*)-du(3,*)); - dumean(fault-faultstart,it-start-1)


if tmp eq 's' then begin
	print,"Aufklaffung tangential bei Iterationsnummer",it
	print,"Winkel: ",(atan(fvec(0),fvec(1))/(2.0*3.1415926535))*360.0
	it=stop
end
end

if(0)then begin
	!p.multi=[0,1,2,0]
	plot,du(0,*),(du(6,*)-0.8*(du(7,*)+hp))/1e6,$
		title="Coulomb-Spannung Fault"+strtrim(fix(fault),1)+$
		"Iteration"+strtrim(it)
	plot,du(0,*),du(2,*)
end

end

end

;!p.multi=[0,0,2,0]
for i=0,nrflt-1 do begin

;	plot,(tau(i,*,n/2)-sdmyu*(nos(i,*,n/2)+hp))/1.0e6,$
;	title="!6!10#!7r!6!it!n!10#!7-l!6!i2!n!7*r!i!6n!n!6 bei (500,500)",$
;	xtitle="Zeit / 10a",ytitle="Spannung / MPa",charsize=2.0,$
;	xcharsize=1.0,ycharsize=1.0

;	oplot,(tau(i,*,n/2)-sdmyu*(nos(i,*,n/2)+hp))/1.0e6,psym=5
;	plot,abs(fieldstress(3,*))/1e6,$
;		title="!10#!6max(!7s!6!ixy!n(y=480))!10#!6",charsize=2,$
;		xtitle="Zeit / 10a",ytitle="Spannung / MPa"

	!p.multi=[0,0,nrflt,0]
	plot,csmedian(i,*)
	if ((printdata ne 1)and(plotframe ne 1)) then tmpchar=get_kbrd(1)
end

if printdata eq 1 then begin
for i=faultstart,faultstop do begin
	sizev=size(csmedian)
	n=sizev(2)
	openw,1,filedir+"stress_timeseries.flt"+strtrim(i,1)
		printf,1,'# Mittlere Coulombspannung tau-fault_myu*(nos+hp)'
		for j=0,n-1 do begin
			printf,1,j,csmedian(i-1,j)
		end	
		printf,1

		printf,1,'# Maximale Coulombspannung'
		for j=0,n-1 do begin
			printf,1,j,csmax(i-1,j)
		end	
		printf,1

		printf,1,'# Minimale Coulombspannung'
		for j=0,n-1 do begin
			printf,1,j,csmin(i-1,j)
		end	
		printf,1

		printf,1,'# Mittlere Scherspannung'
		for j=0,n-1 do begin
			printf,1,j,taumedian(i-1,j)
		end	
		printf,1

		printf,1,'# Mittlere Normalspannung'
		for j=0,n-1 do begin
			printf,1,j,nosmedian(i-1,j)
		end	
		printf,1
		printf,1,'# Coulombspannung am Rissende'
		for j=0,n-1 do begin
			printf,1,j,csend(i-1,j)
		end	
		printf,1
		printf,1,'# Coulombspannung an der Rissmitte'
		for j=0,n-1 do begin
			printf,1,j,csmid(i-1,j)
		end	
		printf,1
		printf,1,'# Delta du_t am Rissende'
		for j=0,n-1 do begin
			printf,1,j,duend(i-1,j)
		end	
		printf,1
		printf,1,'# Delta du_t aa der Rissmitte'
		for j=0,n-1 do begin
			printf,1,j,dumid(i-1,j)
		end	
		printf,1
		printf,1,'# mittleres Delta du_t'
		for j=0,n-1 do begin
			printf,1,j,dumean(i-1,j)
		end	
		printf,1

	close,1

	openw,1,filedir+"stress_timeseries.flt"+strtrim(i,1)+".csmedian"
		printf,1,n
		printf,1,csmedian(i-1,*)
	close,1
	openw,1,filedir+"stress_timeseries.flt"+strtrim(i,1)+".csmax"
		printf,1,n
		printf,1,csmax(i-1,*)
	close,1
	openw,1,filedir+"stress_timeseries.flt"+strtrim(i,1)+".taumedian"
		printf,1,n
		printf,1,taumedian(i-1,*)
	close,1
	openw,1,filedir+"stress_timeseries.flt"+strtrim(i,1)+".nosmedian"
		printf,1,n
		printf,1,nosmedian(i-1,*)
	close,1
	openw,1,filedir+"stress_timeseries.flt"+strtrim(i,1)+".csmin"
		printf,1,n
		printf,1,csmin(i-1,*)
	close,1
	openw,1,filedir+"stress_timeseries.flt"+strtrim(i,1)+".csend"
		printf,1,n
		printf,1,csend(i-1,*)
	close,1
	openw,1,filedir+"stress_timeseries.flt"+strtrim(i,1)+".csmid"
		printf,1,n
		printf,1,csmid(i-1,*)
	close,1
	openw,1,filedir+"stress_timeseries.flt"+strtrim(i,1)+".duend"
		printf,1,n
		printf,1,duend(i-1,*)
	close,1
	openw,1,filedir+"stress_timeseries.flt"+strtrim(i,1)+".dumid"
		printf,1,n
		printf,1,dumid(i-1,*)
	close,1
	openw,1,filedir+"stress_timeseries.flt"+strtrim(i,1)+".dumean"
		printf,1,n
		printf,1,dumean(i-1,*)
	close,1

end
end

end
if dev eq 'PS' then device,/close
end






