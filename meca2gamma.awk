# read psmeca format
#       3            6           9  10    11   12      13            14 15 16
# X Y depth mrr mtt mff mrt mrf mtf exp [newX newY] [event_title]    e1 e2 e3 
# compte CLVD gamma
BEGIN{
    gamma_fac = 3.*sqrt(6.);
    s2f = 1./sqrt(2.);
}
{
    if((substr($1,1,1)!="#")&&(NF>=16)){
	m[1][1]=$4;
	m[2][2]=$5;
	m[3][3]=$6;
	m[1][2]=m[2][1]=$7;
	m[1][3]=m[3][1]=$8;
	m[2][3]=m[3][2]=$9;
	mdet=det(m);
	mnorm=norm(m);

	ev[1]=$14;
	ev[2]=$15;
	ev[3]=$16;
	#eig(m,ev);
	#print(ev[1],ev[2],ev[3]);
	
	gamma = gamma_fac * mdet/mnorm**3;
	if(gamma>1)
	    gamma = 1;
	if(gamma < -1)
	    gamma = -1;
	
	eps = epsilon(ev);
	if((eps < -0.5)||(eps > 0.5)){
	    print("out out range ",m[1][1],m[1][2],m[1][3],m[2][2],m[2][3],m[3][3]) > "/dev/stderr";
	}
# output is gamma, scalar moment,  determinant, and depth
	print(gamma,mnorm*s2f,mdet,$3,eps);
#	if((gamma>1)||(gamma<-1)){
#	    print("large gamma")  > "/dev/stderr"
#	    print(gamma,mnorm,mdet)  > "/dev/stderr"
#	    print($0) > "/dev/stderr"
#	}
    }
}

# /sqrt(2) norm
function norm(a)
{
    rnorm = 0;
    for(i=1;i<=3;i++)
	for(j=1;j<=3;j++)
	    rnorm += a[i][j]**2;
    return sqrt(rnorm);
}

function det(a) {
    
    rdet  = a[1][1]*(a[2][2]*a[3][3] - a[2][3]*a[3][2]);
    rdet -= a[1][2]*(a[2][1]*a[3][3] - a[2][3]*a[3][1]);
    rdet += a[1][3]*(a[2][1]*a[3][2] - a[2][2]*a[3][1]);
    
    return rdet;

}
function eig(a,ev) {
    cmd = sprintf("echo %20.15e  %20.15e  %20.15e  %20.15e  %20.15e  %20.15e | eigenvalues3ds",
		  a[1][1],a[1][2],a[1][3],a[2][2],a[2][3],a[3][3]);
    cmd | getline evs;
    split(evs,ev," ");
}

function epsilon (ev) {
    aev1 = (ev[1]>0)?(ev[1]):(-ev[1]);
    aev3 = (ev[3]>0)?(ev[3]):(-ev[3]);

    max = (aev1> aev3)?(aev1):(aev3);
    return -ev[2]/max;
}
