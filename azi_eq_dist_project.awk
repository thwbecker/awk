#
# azimuthal equidistant projection
#
# forward and inverse, implemented based on
# https://mathworld.wolfram.com/AzimuthalEquidistantProjection.html
#
# tested medium well
#
#
BEGIN{
    pif = 57.295779513082320876798154814105;
    if(plon=="")
	plon=0;
    if(plat=="")
	plat=0;
    if(R=="")
	R=1;
    if(inverse=="")
	inverse = 0;
    #
    # projection latitude
    p1 = plat/pif;			# wolfram notation... 
    #
    # projection longitude
    l0 = plon/pif;
    #
    sin_p1=sin(p1);
    cos_p1=cos(p1);
}
{
    if(substr($1,1,1)==">")
	print($0);
    else
	if((NF>=2)&&(substr($1,1,1)!="#")){
	    if(inverse){
		x = $1/R;
		y = $2/R;
		c = sqrt(x**2+y**2);
		if(c==0){
		    l = l0;
		    p = p1;
		}else{
		    cos_c=cos(c);
		    sin_c=sin(c);
		    
		    p = asin(cos_c * sin_p1 + (y * sin_c * cos_p1)/c);
		    if(plat == 90)
			l = l0 + atan2(-x,y);
		    else if(plat == -90)
			l = l0 + atan2(x,y);
		    else
			l = l0 + atan2(x * sin_c,
				       c * cos_p1 * cos_c - y * sin_p1 * sin_c);
		}
		printf("%22.15e %22.15e ",l*pif,p*pif);
	    }else{
		l = $1/pif;			# longitude
		p = $2/pif;			# latitude
		
		sin_p=sin(p);
		cos_p=cos(p);
		
		ld = l-l0;
		cos_ld=cos(ld);
		sin_ld=sin(ld);
		
		c = acos(sin_p1 * sin_p + cos_p1 * cos_p * cos_ld);
		if(c==0)
		    k=0;
		else
		    k = c/sin(c);
		
		x = k * cos_p * sin_ld;
		y = k * (cos_p1 * sin_p - sin_p1 * cos_p * cos_ld);
		
		printf("%22.15e %22.15e ",x*R,y*R);
	    }
	    for(i=3;i<=NF;i++)
		printf("%s ",$i);
	    printf("\n");
	}
}


function acos(x) {
    return atan2(sqrt(1.0-x*x), x);

}


function asin( x ) {
    return atan2(x,sqrt(1.0-x*x));
}
