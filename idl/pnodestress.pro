close,1
filedir="/datdyn/becker/finel/model_b/"

openr,1,filedir+"nodestress"
n=0
while not eof(1) do begin
	readf,1,t1,tau1,nos1,cstr1
	if(n ne 0)then begin
		if(t1 ne t2)then begin 
			n=n+1
			t2=t1 
		end
	end
	if(n eq 0) then begin
		t2=t1 & n=1
	end
end
close,1
print,n,' different time steps'
s=dblarr(4,n) & stest=dblarr(4)
openr,1,filedir+"nodestress"
i=0
while not eof(1)do begin
	readf,1,stest
	if(i eq 0)then begin
		s(*,i)=stest
		i=i+1
	endif else begin
		if(s(0,i-1) eq stest(0))then begin
			s(*,i-1)=stest
		endif else begin
			s(*,i)=stest
			i=i+1
		endelse
	endelse
end	


close,1

end