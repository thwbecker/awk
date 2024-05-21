#
# compute mean values for all columns with leading weight
#
BEGIN{
}
{
  if((substr($1,1,1)!="#")){
    if(NF-1 > nfmax)
      nfmax=NF-1;
    for(i=2;i <= NF;i++){
      if(tolower($i) != "nan"){
	sum[i-1] += $i * w;
	w[i-1] += $1;
      }
    }
  }
}
END{
  for(i=1;i <= nfmax;i++){
    if(w[i] == 0)
      printf("NaN ");
    else
      printf("%22.16e ",sum[i]/w[i]);
  }
  printf("\n");
}
