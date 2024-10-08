#
# calculate the standard deviation of the col column, 
# fast (and inaccurate) if fast is set to unity, default is slow
# if col is not set, uses col=1
#
# $Id: standarddev.awk,v 1.5 2012/06/23 22:20:39 becker Exp becker $
BEGIN {
    sum = sum2 = 0.0;n = i = 0;	# initialize summations
    if(col=="")			# default is to use first column
	col = 1;
    if(use_n=="")
	use_n=0;		# 0: use N-1 1: use N
    if(fast=="")
	fast=0;
    if(use_n)
	fast = 0;
}
{
    if((NF>=col)&&(substr($1,1,1)!="#")&&(tolower($col)!="nan")){ # we can use this line
	if(fast){			# fast, inaccurate way
	    sum += $col;sum2 += $col * $col;n++;
	}else{			# slow way
	    n++;x[n]=$col;sum += $col;
	}
    }
}
END {
    if(n > 1){
	if(fast){
	    std = sqrt ((n * sum2 - sum * sum) / (n*(n-1)));
	    # mean would be  sum / n;
	    printf("%.15e\n",std)
	}else{
	    mean = sum / n;
	    sum2 = 0.0;
	    for(i=1;i<=n;i++){
		x[i] -= mean;
		sum2 += x[i]*x[i];
	    }
	    if(use_n)
		printf("%.15e\n",sqrt(sum2/n)); # population standard deviation, mean kwown
	    else
		printf("%.15e\n",sqrt(sum2/(n-1))); # sample standard deviation, mean not known
	}
    }else{
	print("NaN");
    }
}
