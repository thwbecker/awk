FUNCTION length, a
   l = size(a)
   IF(l(0)EQ 0) THEN return, 1 ELSE $
    return, l(1)
END 
