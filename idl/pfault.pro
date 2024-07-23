close,1
openr,1,"/home/geodyn/becker/fenetze/faultcoord"
readf,1,nrflt
plot,[1,1],/nodata,xrange=[0,1000],yrange=[0,1000],xstyle=1,ystyle=1
polyfill,[0,1000,1000,0],[0,0,1000,1000],color=10
for i=0,nrflt-1 do begin
	readf,1,x1,x2,x3,x4
	plots,x1,x2
	plots,x3,x4,/continue
end
close,1
end