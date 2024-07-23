datadir = "/home/datdyn2/becker/finel/"
filedir = datadir+"/"
emodul = 5e10
nyu = 0.25
virh = 1.0


start = 1 & stop=1
FOR test=start,  stop DO BEGIN 

   openr, 1, filedir+"realdispx."+strtrim(test, 1)+".xyz"
   openr, 2, filedir+"realdispy."+strtrim(test, 1)+".xyz"
   readf, 1, m
   readf, 2, m
   n = sqrt(m)
   x = dblarr(n, n)
   y = dblarr(n, n)
   dux = dblarr(n, n)
   duy = dblarr(n, n)
   temp = dblarr(3, m)
   readf, 1, temp
   x = reform(temp(0, *), n, n)
   y = reform(temp(1, *), n, n)
   dux = reform(temp(2, *), n, n)

   readf, 2, temp
   duy = reform(temp(2, *), n, n)

   close, 1, 2
   openr, 1, filedir+"stre11."+strtrim(test, 1)+".xyz"
   openr, 2, filedir+"stre12."+strtrim(test, 1)+".xyz"
   openr, 3, filedir+"stre22."+strtrim(test, 1)+".xyz"
   readf, 1, a1, fmyu, a2, a3, hp, a5 & readf, 1, m
   readf, 2, a1, fmyu, a2, a3, hp, a5 & readf, 2, m
   readf, 3, a1, fmyu, a2, a3, hp, a5 & readf, 3, m
   readf, 1, temp
   IF(sqrt(m) NE n)THEN print, "Array size mismatch between stresses and displacements !"
   n = sqrt(m)
   s11 = reform(temp(2, *), n, n)
   readf, 2, temp
   s12 = reform(temp(2, *), n, n)
   readf, 3, temp
   s22 = reform(temp(2, *), n, n)
   close, 1, 2, 3
   duz = virh*(-(nyu/emodul)*(s11+s22))

ENDFOR 


end


