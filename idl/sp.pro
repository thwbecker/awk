function sp,a,b
sum=0.0
if(n_params() ne 2)then message,'Braucht zwei Vektoren!'
if(n_elements(a) ne n_elements(b))then begin
	message,' a un b haben verschiedene Elementanzahl !'

end
for j=0,n_elements(a)-1 do begin
	sum=sum + a(j)*b(j)
end
return,sum
end