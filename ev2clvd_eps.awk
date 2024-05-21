{
    if((substr($1,1,1)!="#")&&(tolower($1)!="nan")){
	e[1]=$1;
	e[2]=$2;
	e[3]=$3;
	ev=(e[1]+e[2]+e[3])/3;
	for(i=1;i<=3;i++)
	    e[i] -= ev;
	
	fa1=sqrt(e[1]*e[1]);
	fa3=sqrt(e[3]*e[3]);
	if(fa1>fa3)
	    fa=fa1;
	else
	    fa=fa3;
	print(-e[2]/fa);
	
    }

}
