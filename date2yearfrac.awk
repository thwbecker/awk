#
# convert year month day hour min sec to fraction of year
#

BEGIN{
    if(utc=="")
	utc = 1;
}
{
    if((substr($1,1,1)!="#")&&(NF>=6)){


	the_time = sprintf("%04i %02i %02i %02i %02i %02.0f",
		     $1,$2,$3,$4,$5,$6)
	tsec = mktime(the_time,utc);
	
	year = strftime("%Y",tsec);
	first_sec = mktime(sprintf("%04i %02i %02i %02i %02i %02i",year,1,1,0,0,0),1);
	last_sec  = mktime(sprintf("%04i %02i %02i %02i %02i %02i",year,12,31,23,59,59),1);
	tyear = year + (tsec-first_sec)/(last_sec-first_sec);
	printf("%13.8f ",tyear)
	for(i=7;i<=NF;i++)
	    printf("%s ",$i);
	printf("\n");
	

    }
}
