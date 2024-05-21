#
# sum up power to produce first moment
#
BEGIN{
  s1=0;
  s2=0;
  nc=0;
}
{
  l=$1;
  if(l>0){
    nc++;
    z=$2;
    p=$3*(2.*l+1.);
    if((nc==1)||(z==oldz)){
      s1 += l * p;
      s2 += p;
      n++;
    }else{
      if(s2 != 0)
	print(s1/s2,oldz);
      else
	print(0,oldz);
      s1 = l * p;
      s2 = p;
      n = 1;
    }
    oldz=z;
  }
}
END{
    if(s2 != 0)
	print(s1/s2,z);
    else
	print(0,z);
}
