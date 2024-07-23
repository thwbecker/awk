; projects hypocenters onto a slice centered at lon0 lat0
; spherical geometry is not taken into account for projection


PRO hypo_slice, lon0, lat0, azi, width

   symbol = 8
   size = 1
   USERSYM, [-.75,0,.75,0],[0,.75,0,-.75], /FILL

   x = dindgen(100)*10
   plot, x, xrange=[-1000, 1000], yrange=[5000, 6371]

   hypo_project, '/home/becker/quakes/vdhilst/hypocenters.mo', 77106, $
     lon0, lat0, azi, width, symbol, 255, size
   hypo_project, '/home/becker/quakes/schoeffel/harvard.xyzm', 363, $
     lon0, lat0, azi, width, symbol, 155, size
   
END 
