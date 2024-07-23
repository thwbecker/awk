pr = 0
   nyu = 0.25
   feunorm = 0.01
   aunorm = 0.75
   virh = 60
   
   ;;approx = "plane_strain"

   amodedir = '/home/becker/courses/static_stress/'

   openr, 1, amodedir+"stress.dat"
   readf, 1, n
   m = sqrt(n)
   stress = dblarr(8,n)
   readf, 1, stress
   close, 1

   csense = 0
   sense = 4

   x = rotate(reform(stress(0, *, *), m, m), csense)
   y = rotate(reform(stress(1, *, *), m, m), csense)
   sxx = rotate(reform(stress(2, *, *), m, m), sense)
   sxy = rotate(reform(stress(3, *, *), m, m), sense)   
   syy = rotate(reform(stress(4, *, *), m, m), sense)
   sxz = rotate(reform(stress(5, *, *), m, m), sense)
   syz = rotate(reform(stress(6, *, *), m, m), sense)
   szz = rotate(reform(stress(7, *, *), m, m), sense)
   close, 1


   

   cms, sxx, sxy, syy, fms, sms, deg
   cs = cstress(fms,sms,a,hp,b)        - cstress(tau0,-tau0,a,hp,b)
   tcs = abs(sxy+0.5*(sxx+syy)/2.0

   window, 0
   shade_surf, cs, shade=bytscl(cs), 
   contour,cs,max_value=10,nlevels=29, /follow, /overplot
   set_plot, 'X'
END








