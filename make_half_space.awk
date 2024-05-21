BEGIN{
  
    if(plate_age=="")		# plate age in Myr
	plate_age=50;

   

    sec_per_year = 365.25*24.*60.*60.; # seconds per year
    #kappa = 0.7272e-6;		# diffusivity
    kappa = 1e-6;		# diffusivity

    age_s = plate_age * 1.e6 * sec_per_year; # age of plate in s 
    erf_scale = 2.*sqrt(kappa*age_s)/1e3;		# error function scale in km
    slab_thick = 1.15 * erf_scale * sqrt(2.); # TBL (2.23/2) times sqrt(2) for case D
    
    for(z=0;z<=200;z+=1){
	printf("%g %g\n",z,Ttop + (Tbot-Ttop)*erf(z/erf_scale));
	
    }
    
}

function erf(x)
{
    command = ( "echo " x " | myerf" )
    command | getline ret
    return ret
}  
