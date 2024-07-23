openr, 1, "/home/becker/courses/static_stress/a.dat"
temp = dblarr(100, 100)
!p.multi = [0, 2, 0, 0]
window, 0, xsize=800, ysize=400
WHILE NOT eof(1) DO BEGIN 
   readu, 1, temp
   plot, temp(*, 50)
   contour, temp, /follow
   tmp = get_kbrd(1)
   IF(tmp EQ 'q')THEN BEGIN 
      close, 1
      stop 
   ENDIF 
ENDWHILE 
close, 1


END
