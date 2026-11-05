BEGIN{
    string="acdghinstx123";
}
{
    if(($1<1)||($1>length(string)))
	out="+";
    else{
	out=substr(string,$1,1);
	if(out=="1")
	    out = "kdeltoid/";
 	else if(out=="2")
	    out = "ksectoid/";
    	else if(out=="3")
	    out = "khurricane/";
    }
    printf("-S%s",out);
}
