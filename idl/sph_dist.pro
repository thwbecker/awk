FUNCTION sph_dist, lon1, lat1, lon2, lat2
   f1 = 3.14159265358/180.0
   tmp = sin(lat1*f1)*sin(lat2*f1)
   tmp = tmp + cos(lat1*f1)*cos(lat2*f1)*cos((lon1-lon2)*f1)
   return, acos(tmp)
END 
