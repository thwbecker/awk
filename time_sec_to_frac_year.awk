# read unix time in epoch and convert to fractional year
{
    if(substr($1,1,1)!="#"){
	tsec = $1;
	year = strftime("%Y",tsec);
	first_sec = mktime(sprintf("%04i %02i %02i %02i %02i %02i",year,1,1,0,0,0));
	last_sec  = mktime(sprintf("%04i %02i %02i %02i %02i %02i",year,12,31,23,59,59));
	printf("%20.15f ",year + (tsec-first_sec)/(last_sec-first_sec));
	for(i=2;i<=NF;i++)
	    printf("%s ",$i);
	printf("\n");
    }

}
