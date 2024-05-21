#
# compute power per degree
#
BEGIN{

    l=m=0;
    if(normalize=="")
	normalize = 1;
    if(have_lm=="")
	have_lm = 0;
    if(skip_header=="")
	skip_header = 0;
    sum=0;
    nc=0;
}
{
    if((!skip_header)&&(NR==1)){
	lmax = $1;
    }else{
	if(have_lm){
	    l=$1;m=$2;
	    a=$3;
	    b=$4;
	}else{
	    a=$1;
	    b=$2;
	}
	sum += a**2;
	nc++;
	if(m!=0){
	    sum += b**2;
	    nc++;
	}
	if(m==l){
	    if(normalize){
		# checks out 
		#print(2*l+1,nc) > "/dev/stderr"
		print(l,sum/(2*l + 1));
	    }else{
		print(l,sum);
	    }
	    sum = 0;
	    nc=0;
	}
	m++;
	if(m > l){
	    l++;
	    m=0;
	}
    }

}
