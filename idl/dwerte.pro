FUNCTION dwerte,  lower,  upper 
   n = double(500)
   xwerte = (dindgen(n)/(n-1))*(upper-lower)+lower
   ;print, "Array runs from ", min(xwerte), " to ", max(xwerte)
   ;print, " and has ", n_elements(xwerte), " elements."
   return, xwerte
end
