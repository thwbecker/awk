close, 1
dev='X'
;dev='PS'
if dev eq 'PS' then loadct,0		;for B and W
if dev eq 'X' then loadct,13		;for rainbow coloring

openr, 1, 'disp'
readf, 1, nrnd		;nrel is number of elements (element mids)
disp=fltarr(5,nrnd)	;stress array to read from
readf, 1, disp
close, 1

n=round(sqrt(nrnd))
disp=congrid(disp,5,n*n)

sdisp=disp(*,sort(disp(1,*)))

ssdisp=fltarr(5,n,n)

for i=0,n-1 do begin
	for j=0,n-1 do begin
		if (j*n+i lt nrnd-1) then ssdisp(*,j,i)=sdisp(*,j*n+i)
	end
end
sorteddisp=fltarr(5,n,n)
for i=0, n-1 do begin
	sorteddisp(*,*,i)=ssdisp(*,sort(ssdisp(2,*,i)),i)
end

z=fltarr(n,n)
x=fltarr(n,n)
y=fltarr(n,n)
z(*,*)=sorteddisp(3,*,*)
x(*,*)=sorteddisp(1,*,*)
y(*,*)=sorteddisp(2,*,*)

window,1
shade_surf,z,ax=90,az=0

end



