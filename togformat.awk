BEGIN{

}
{
    if(substr($1,1,1)!="#"){
	for(i=1;i<=NF;i++){
	    if(tolower($i)=="nan")
		printf("NaN ")
	    else
		printf("%lg ",$i);
	}
	printf("\n");
  }
}
