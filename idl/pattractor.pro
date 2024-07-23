N = 12500
d = fltarr(5, N)
;;dir =  '/wrk/arthur/becker/nonlinproject/lorenz/'
dir =  '/wrk/arthur/becker/nonlinproject/attractor/'

;;file = 'd.0.dat'
file = 't.2.big.dat'
openr, 1,dir+file
readf, 1, d
close, 1
loadct, 0

set_plot, 'PS'
device, file=dir+'idla.eps', $
  /encapsulated, xsize=20, ysize=17, bits_per_pixel=16
myp3d, d(1, *), d(2, *), d(3, *), gridstyle=-1, wallcolor=200, $
  /xy_plane,   xtitle="x", ytitle="y", ztitle="z", $
  /xz_plane, /yz_plane, charsize=2
device, /close
set_plot, 'X'
END 



