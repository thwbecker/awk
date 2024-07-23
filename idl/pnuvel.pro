PRO pnuvel, col=col, thickness

if n_elements(col) le 0 then col=255
m = 1616
nuvel = fltarr(2, m)
openr, 1, 'nuvel.xy'
readf, 1, nuvel
close, 1
i = 0
plots, nuvel(0, i), nuvel(1, i), /data, color=col
FOR i=1, m-1 DO BEGIN 
   IF(nuvel(0, i) EQ 99 AND nuvel(1, i) EQ 99 AND i NE m-1)THEN BEGIN 
      plots, nuvel(0, i+1), nuvel(1, i+1), /data, color=col 
      i = i+1
      ;;tmp = get_kbrd(1)
   ENDIF ELSE BEGIN 
      plots, nuvel(0, i), nuvel(1, i), /continue, /data, color=col, thick=thickness
   ENDELSE 
ENDFOR 
END

