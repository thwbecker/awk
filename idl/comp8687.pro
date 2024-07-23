dir = "/wrk/arthur/becker/conman/subduct/"
a = dblarr(4, 16641)
b = dblarr(4, 16641)

openr, 1, dir+"87/fieldcomp4.new"
readf, 1, a
close, 1
openr, 1, dir+"86/fieldcomp4.new"
readf, 1, b
close, 1
x = rotate(reform(a(0, *), 129, 129), 4)
y = rotate(reform(a(1, *), 129, 129), 4)
u = rotate(reform(a(2, *), 129, 129), 4)
v = rotate(reform(a(3, *), 129, 129), 4)
u1 = rotate(reform(b(2, *), 129, 129), 4)
v1 = rotate(reform(b(3, *), 129, 129), 4)
FOR i=0, 128 DO BEGIN 
   FOR j=0, 128 DO BEGIN 
      IF(y(i, j) LT 0.8)THEN u(i, j) = u(i, j)+0.5
  ENDFOR 
ENDFOR 
set_plot, "PS"
device, file=dir+"87/compfield4.0.eps", /encapsulated, xsize=11, ysize=11
myvel,u-u1,v-v1, xmax=max(x), title="", nvecs=600, length=0.1
device, /close
END 
