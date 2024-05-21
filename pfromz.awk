# get approximate PREM pressure in GPa from depth in km
{
    if((substr($1,1,1)!="#")&&($1!="")){
	z=$1;
	p=-0.0480888 + 0.030771*z + 7.30972e-06*z**2;
	printf("%g ",p);
	for(i=2;i<=NF;i++)
	    printf("%s ",$i);
	printf("\n");
    }
}
