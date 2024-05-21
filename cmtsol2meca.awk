BEGIN{
    #    f=1.0/ln(10.0);
    logf=0.4342944819032518;
}
{
    if($1=="depth:")depth=$2;
    if($1=="longitude:")lon=$2;
    if($1=="latitude:")lat=$2;
    if($1=="Mrr:")mrr=$2;
    if($1=="Mtt:")mtt=$2;
    if($1=="Mpp:")mpp=$2;
    if($1=="Mrt:")mrt=$2;
    if($1=="Mrp:")mrp=$2;
    if($1=="Mtp:"){mtp=$2;
	
	scale = mrr;if(scale<0)scale=-scale;
	iexp=int(log(scale)*logf+0.5);
	
	scale = 10**iexp;
	#X Y depth mrr mtt mff mrt mrf mtf exp [newX newY] [event_title].

	print(lon,lat,depth,mrr/scale,mtt/scale,mpp/scale,mrt/scale,mrp/scale,mtp/scale,iexp,lon,lat);
	mrr=mtt=mpp=mrt=mtp=mtp=0;
    }
}
END{
}
