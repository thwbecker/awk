FUNCTION  pstressfms,s11,s12,s22
x1=double(0.0) & x2=double(0.0) & r =double(0.0)
x1=(s11 + s22)/2.0
x2=(s11 - s22)/2.0
r = sqrt(x2*x2 + s12 * s12 )
fms=x1 + r & sms = x1 - r
return, fms
end
