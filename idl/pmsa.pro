pro pmsa, n, m, stepn, stepm, x, y, fms, sms, deg, titlename
scale = (max(x)-min(x))
IF(max(y)-min(y) GT scale)THEN scale =  max(y)-min(y)
scale = scale*0.04
factor = max(abs(sms))
IF(max(abs(fms)) GT factor)THEN factor =  max(abs(fms))
factor = scale/factor

xoff=30
headsize = .4
yoff=xoff
step=2
deg=(deg/180.0)*3.14159265358979

plot, x, y, /nodata, title=titlename, xtitle="x", ytitle="y"
for i=0, n-1, stepn DO  BEGIN 
   FOR j=0,  m-1, stepm DO BEGIN 
      x0=x(i, j) & y0=y(i, j) 
      x1=x(i, j) + (fms(i, j)*cos(deg(i, j)))*factor
      y1=y(i, j) + (fms(i, j)*sin(deg(i, j)))*factor
      x2=x(i, j) - (sms(i, j)*sin(deg(i, j)))*factor
      y2=y(i, j) + (sms(i, j)*cos(deg(i, j)))*factor
      x3=x(i, j) - (fms(i, j)*cos(deg(i, j)))*factor
      y3=y(i, j) - (fms(i, j)*sin(deg(i, j)))*factor
      x4=x(i, j) + (sms(i, j)*sin(deg(i, j)))*factor
      y4=y(i, j) - (sms(i, j)*cos(deg(i, j)))*factor
      arrow,x0,y0,x1,y1,/solid,hsize= -headsize,/data
      arrow,x2,y2,x0,y0,/solid,hsize= -headsize, /data
      arrow,x0,y0,x3,y3,/solid,hsize= -headsize, /data
      arrow,x4,y4,x0,y0,/solid,hsize= -headsize, /data
   ENDFOR 
ENDFOR 


end









