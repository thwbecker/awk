# convert moment in Nm to magnitude
BEGIN{
    if(col=="")
	col=1;
}
{
    if(substr($1,1,1)!="#"){
	for(i=1;i<col;i++)
	    printf("%s ",$i);
	mag = 2./3. * (0.4342944819032518*log($col)-9.1);
	printf("%.5f ",mag);
	for(i=col+1;i<=NF;i++)
	    printf("%s ",$i);
	printf("\n");
    }
}
