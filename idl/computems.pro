n = 100

comp=-1.0

azi=135.0
phi = (90.0-azi)*(3.141592653589/180.0)


clb1 = dblarr(n, n) &  deg=dblarr(n, n)
clb2 = dblarr(n, n)
clb3 = dblarr(n, n)
fms = dblarr(n, n)
sms = dblarr(n, n)
cs = dblarr(n, n)

clb1 = clb1-comp*0.5*(1.0+cos(2*phi))
clb3 = clb3-comp*0.5*(1.0-cos(2*phi))
clb2 = clb2-comp*0.5*cos(2*phi)*tan(2*phi)
   

x1=double(0.0) & x2=double( 0.0) & r =double( 0.0)
for i=0,n-1 do begin
   for j=0,n-1 do begin
      x1=(clb1(i,j) + clb3(i,j))/2.0
      x2=(clb1(i,j) - clb3(i,j))/2.0
      r = sqrt((x2*x2) + (clb2(i,j) * clb2(i,j)) )
      fms(i,j)=x1 + r & sms(i,j) = x1 - r
      deg(i,j)=45.0
      if(x2 ne 0.0)then $
       deg(i,j)= 22.5*(atan(clb2(i,j),x2)/atan(1.0))
   end
end
 
clb1= -clb1 & clb2 = -clb2 & clb3 = -clb3
cs= -sms & sms= -fms & fms= cs &  deg=deg +90.0


print,"fms", min(fms), max(fms)
print,"sms", min(sms), max(sms)
print,"deg", min(deg), max(deg)

end  
