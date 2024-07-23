FUNCTION u2disp, x
   a = 1.0
   y = (abs(x)-sqrt(x^2-a^2))*signum(x)
   
   return, y
   
   

END 
