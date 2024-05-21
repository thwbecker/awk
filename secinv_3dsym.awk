#
# read a 3d symmetric tensor in upper right triangle format
# 1   2  3  4  5 6
# xx xy xz yy yz zz
#
# and print second deviatoric invariant
#
BEGIN{
}
{
    if(NF>=6 && substr($1,1,1)!="#"){
	a[1][1]=$1;
	a[1][2]=a[2][1]=$2;
	a[1][3]=a[3][1]=$3;
	a[2][2]=$4;
	a[2][3]=a[3][2]=$5;
	a[3][3]=$6;    
	
	printf("%.8e ",sec_inv(a));
	for(i=7;i<=NF;i++)
	    printf("%s ",$i);
	printf("\n");
    }
}

function sec_inv(a) {
# make trace free
    trace = 0;
    for(i=1;i<=3;i++)
	trace += a[i][i];
    # second invariant of deviatoric tensor
    for(i=1;i<=3;i++)
	a[i][i] -= trace;
    s2 = 0;
    for(i=1;i<=3;i++)
	for(j=1;j<=3;j++)
	    s2 += a[i][j] * a[i][j];
    s2 = sqrt(s2/2);
    return s2;

}



