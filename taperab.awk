BEGIN{
#    pi=atan2(1,1)*4;
    if(lc=="")
	lc=8;
}
{
    if(NR==1){
	lmax=$1;
	l=0;
	m=0;

    }else{
	a=$1;b=$2;
	fac = l/lc;
	#print(l,m,a,b,fac)
	m++;
	if(m>l){
	    m=0;
	    l++;
	}
    }
    
}
