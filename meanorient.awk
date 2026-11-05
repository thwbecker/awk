#
# calculate mean orientation of col, if col is not set, use col=1
#
# for angular azimuths in deg, 0..180 periodic
#
# there is also orientmean which can use weights
# and average_orientational
BEGIN{
    sx=sy=0.0;
    n=0;
    if(col==0)
	col=1;
    pif = 57.295779513082320876798154814105;
}

{
    if((substr($1,1,1)!="#") && ($col!="") && (!match(tolower($col),"nan"))){
	azi2= 2*($(col))/pif;
	sx += sin(azi2);
	sy += cos(azi2);
	n++;
    }
}
END{
    if(n!=0){
	sx /= n;
	sy /= n;
	ma=atan2(sx,sy)*pif/2;
	if(ma<0)
	    ma+=360;
	if(ma>180)
	    ma-=180;
	printf("%f\n",ma);
    }else{
	print("NaN");
    }
}
