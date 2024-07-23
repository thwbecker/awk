IMAGE = TIFF_READ("out.tif", R, G, B)
;;TVLCT, R, G, B

window, 1
window, 2

wset, 1
plot,histogram(image)
wset, 2
tv, image
end
