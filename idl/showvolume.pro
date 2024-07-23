Pro SHOWVOLUME, vol, thresh, LOW = low
;Display the contour surface of a volume.

s = SIZE(vol)	;Get the dimensions of the volume.

IF s(0) NE 3 THEN BEGIN 
   print, "Must be 3d !"
   stop
ENDIF 

SCALE3, XRANGE=[0, S(1)], YRANGE=[0, S(2)], ZRANGE=[0, S(3)]

;Use SCALE3 to establish the 3D transformation and coordinate ranges.
IF N_ELEMENTS(low) EQ 0 THEN low = 0
;Default = view high side of contour surface.

SHADE_VOLUME, vol, thresh, v, p, LOW = low, /verbose
;Produce vertices and polygons.

TV, POLYSHADE(v,p,/T3D)	;Produce image of surface and display.

END
