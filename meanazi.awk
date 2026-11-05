#
# calculate arithmetic azimuth mean of col, if col is not set, use col=1
#
# for angular azimuths in deg
#
#
BEGIN{
    sx=sy=0.0;
    n=0;
    if(col==0)
	col=1;
    pif = 57.295779513082320876798154814105;
}

{
    if((substr($1,1,1)!="#") && ($col!="") && (!match(tolower($col),"nan"))){
	azi= ($(col))/pif;
	sx += sin(azi);
	sy += cos(azi);
	n++;
    }
}
END{
    if(n!=0){
	sx /= n;
	sy /= n;
	printf("%f\n",atan2(sx,sy)*pif);
    }else{
	print("NaN");
    }
}
