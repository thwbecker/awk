PRO cms2, n, m, s11,s12,s22, fms, sms, deg
   fms = dblarr(n, m)
   sms = dblarr(n, m)
   deg = dblarr(n, m)
   x1=double(0.0) & x2=double(0.0) & r=double(0.0)
   FOR  i = 0, n-1 DO  BEGIN 
      FOR  j = 0, m-1 DO  begin
         x1 = (s11(i,j) + s22(i,j))/2.0
         x2 = (s11(i,j) - s22(i,j))/2.0
         r = sqrt(x2*x2 + s12(i,j) * s12(i,j) )
         fms(i,j) = x1 + r 
         sms(i,j) = x1 - r
         deg(i,j)=45.0
         IF(x2 NE  0.0)THEN  $
           deg(i,j)= 22.5*(atan(s12(i,j),x2)/atan(1.0))
      END  
   END   
   
END 
