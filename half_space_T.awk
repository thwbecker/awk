#
# read depth in km, produce temp in K
#
BEGIN{
  
    if(plate_age=="")		# plate age in Myr
	plate_age=50;
    if(use_adiabat=="")
	use_adiabat = 0;

    Ttop = 273;
    Tbot = Ttop + 1350.;
    
    sec_per_year = 365.25*24.*60.*60.; # seconds per year
    #kappa = 0.7272e-6;		# diffusivity
    kappa = 1e-6;		# diffusivity

    age_s = plate_age * 1.e6 * sec_per_year; # age of plate in s 
    erf_scale = 2.*sqrt(kappa*age_s)/1e3;		# error function scale in km

    adiabat_g = 0.4;		# T/km 100...300 from pyrolite 
    za = 0;
    #slab_thick = 1.15 * erf_scale * sqrt(2.); # TBL (2.23/2) times sqrt(2) for case D
    
    
}
{
    z = $1;
    if(use_adiabat){
	if(z > za)
	    dt = adiabat_g *(z-za);
	else
	    dt = 0;
	printf("%g\n",Ttop + (Tbot-Ttop)*erf(z/erf_scale) + dt);

    }else{
	printf("%g\n",Ttop + (Tbot-Ttop)*erf(z/erf_scale));
    }
	

}

function erf(x)
{
    command = ( "echo " x " | erf" )
    command | getline ret
    return ret
}  
