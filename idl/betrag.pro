function betrag,x
if n_params() ne 1 then message,'Brauche einen Vektor !'
sum=dblarr(1)
sum=0.0
for i=0,n_elements(x)-1 do begin
	sum = sum + double(x(i)) * double(x(i))
end
sum=sqrt(sum)
return,sum
end