pro pstress,s11,s12,s22,fms,sms,deg


x1=double(0.0) & x2=double( 0.0) & r =double( 0.0)

x1=(s11 + s22)/2.0
x2=(s11 - s22)/2.0
r = sqrt(x2*x2 + s12 * s12 )
fms=x1 + r & sms = x1 - r
deg=45.0
if(x2 ne 0.0)then deg= 22.5*(atan(s12,x2)/atan(1.0))
end