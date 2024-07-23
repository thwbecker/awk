close, 1
openr, 1, "dugmtx.dat.xyz"
readf, 1, n
m = sqrt(n)
x = dblarr(3, n)
readf, 1, x
close, 1
ux = x(2, *)
ux = reform(ux, m, m)

openr, 1, "dugmty.dat.xyz"
readf, 1, n
m = sqrt(n)
y = dblarr(3, n)
readf, 1, y
close, 1
uy = y(2, *)
uy = reform(uy, m, m)






END
