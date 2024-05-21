# convert p[Pa] T[K] fw [Pa] into COH [H/1e6 Si]
BEGIN{
    R=8.314510;
    
    a=26;
    E=40e3;
    V=10e-6;

}
{
    if(substr($1,1,1)!="#" && tolower($1)!="NaN" && (NF>=3)){
	p = $1;
	T = $2;
	fw = $3/1e6;		# convert to MPa
	
	coh = a*exp(-(E+p*V)/(R*T))*fw;
	print(p,T,fw*1e6,coh)
    }
}
