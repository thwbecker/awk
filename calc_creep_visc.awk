BEGIN{
    

# gas constant
    R=8.314510;
#

    # set material with mat=
    # optional dry (default: 0)
    # optional diff (default: 0)
    #
    # input:
    #
    # pressure[Pa] temperature[K] grainsize[m] strain-rate[1/s]/stress[Pa] fugacity[Pa]
    #
    # output: viscosity and differential stress/strain-rate
    #
    # strain-rate --> stress is the default
    # stress --> strain-rate for calc_strainrate=1
    #
    if(diff=="")
	diff = 0;
    if(dry=="")
	dry = 0;
    if(mat=="")
	material = "ol1";		
    else
	material = mat;
    if(calc_strainrate == "")
	ce = 0;
    else
	ce = calc_strainrate;

}
{
    if((substr($1,1,1)!="#") && (NF>=5)){
	pressure = $1;			# in Pa
	T = $2;			# K
	grain = $3; # 4e-3
	if(ce)
	    stress = $4;	# Pa
	else
	    strain = $4;    # 1e-15;
	fw = $5;			# fugacity or C_OH 
	
#printf("p %g MPa T %g d %e e %e\n",p/1e6,T,d,e) > "/dev/stderr"
	if(material == "ol1"){
# grain size exponent
#'
	    name="ol-HK04-TWB";
# power law
	    if(diff){		# diff
		m=3;
		n=1;
		if(dry){
		    A = 4.5e-15;Q=375.e3;V=6.e-6;
		}else{
		    A = 3.0e-15;Q=335.e3;V=4.e-6;
		}
	    }else{		# disl
		m=0;
		n=3.5;
		if(dry){
		    A = 7.4e-15;Q=530.e3;V=14.e-6;
		}else{
		    A = 6.0e-15;Q=480.e3;V=11.e-6;
		}
	    }
	    
	    if(ce){
		visc="NaN";
		if(diff)
		    strain =  A * stress * grain**(-m) * exp(-(Q+pressure*V)/(R*T));
		else
		    strain =  A * stress**n            * exp(-(Q+pressure*V)/(R*T));
	        visc = stress/4/strain;
	    }else{
		#visc = (1/A)**(1/n) * grain**m * strain**((1-n)/n) * (exp((Q+pressure*V)/(n*R*T)));
		if(diff)
		    visc = (grain**m)/A * exp((Q+pressure*V)/(R*T));
		else
		    visc = (1/A)**(1/n) * strain**((1.-n)/n) * (exp((Q+pressure*V)/(n*R*T)));
		stress=4*strain*visc;
	    };
	}else if(material == "ol2"){ # from Lauent
            #
	    # RHEOL values for stress
            #
	    name="ol-HK04"
	    if(dry && !diff){
		#Hirth and Kohlstedt, 2003, dry olivine, dislocation creep
		n=3.5;
		Q=530*1000;
		V=18*1e-6;	# 
		#V=14*1e-6;	# 
		A=1.1e5*(1e-6)**n; # 
		B=2**((1+(3/n))/2)*A**(-1/n);
		if(ce)
		    strain = (stress/B)**n*exp(-(Q+pressure*V)/(R*T));
		else
		    stress = B*exp((Q+pressure*V)/(n*R*T))*strain**(1/n);
	    }else if(!dry && !diff){
#Hirth and Kohlstedt, 2003, wet olivine, dislocation creep
		n=3.5;
		p=1.2;
		Q=520*1000;
		V=22*1e-6;
		A=1600*(1e-6)**(n+p);
		B=2**((1+(3/n))/2)*A**(-1/n);
		#
		if(ce)
		    strain = (stress/B)**n*exp(-(Q+pressure*V)/(R*T))**fw**p;
		else
		    stress = B*exp((Q+pressure*V)/(n*R*T))*strain**(1/n)*fw**(-p/n);
	    }else if(dry && diff){
#Hirth and Kohlstedt, 2003, dry olivine, diffusion creep
		n=1;
		m=3;
		Q=375*1e3;
		#V=10*1e-6;	# 2...10
		V=6*1e-6;	# I use 6, in the middle in 2006
		A=1.5e9*(1e-6)**(n+m); # as in Hirth 2003 (diff in Korenaga)
		B=2**((1+(3/n))/2) * A**(-1/n);
		if(ce)
		    strain = (stress/B)*exp(-(Q+pressure*V)/(R*T))*grain**(-m);
		else
		    stress = B*exp((Q+pressure*V)/(n*R*T))*strain**(1/n)*grain**m;
	    }else if(!dry && diff){
#Hirth and Kohlstedt, 2003, wet olivine, diffusion creep
		n=1;
		m=3;
		p=1;	 # 0.7...1
		Q=375*1000;
		V=10*1e-6;		     # 0....20 
		A=10**(7.398)*(1e-6)**(n+m+p); # checks 
		B=2**((1+(3/n))/2)*A**(-1/n);
		if(ce)
		    strain = (stress/B)*exp(-(Q+pressure*V)/(R*T))*grain**(-m)*fw**p;
		else
		    stress = B*exp((Q+pressure*V)/(n*R*T))*strain*grain**m*fw**(-p);
	    }
	    visc=stress/strain;
	}else if(material == "ol-gbs1"){
	    name="ol-GBS"
	    #Hirth and Kohlstedt, 2003, dry olivine, grain boundary sliding
	    if(T < 1250+273){
		n=3.5;
		Q=400*1000;
		V=18*1e-6;	# 
		A0=6500;
		m=2;
	    }else{
		n=3.5;
		Q=600*1000;
		V=18*1e-6;	# 
		A0=4.7e10;
		m=2;
	    }
	    A=A0*(1e-6)**(n+m); # 
	    B=2**((1+(3/n))/2)*A**(-1/n);
	    if(ce)
		strain = (stress/B)**n*exp(-(Q+pressure*V)/(R*T))*grain**(-m);
	    else
		stress = B*exp((Q+pressure*V)/(n*R*T))*strain**(1/n)*grain**(m/n);
	    visc=stress/strain;
	    
	}else if(material == "pe1"){ # Goetze peierls creep
	    name="olp-G"	     # 
	    q=2;
	    Q=536*1000;
	    A=5.7e11 # 1/s;
	    sP=8.5e9; # Peierls stress [Pa]
	    n=1
	    B=2**((1+(3/n))/2)*A**(-1/n);
	    if(ce){
		if(stress < 300e6){
	         #if(stress < 400e6)
		    strain = 1e-100;
		}else{		# should this be corrected by 1/4?
		    strain = 1/B*exp(-(Q/(R*T))*((1-stress/sP)**q));
		    #strain = A*exp(-(Q/(R*T))*((1-stress/sP)**q));
		}
	    }else{
		stress = sP*(1-(((R*T/Q)*log(A/strain))**(1/q)));
	    }
	    visc=stress/strain;
	}else if(material == "pe2"){ # Mei 2010 peierls creep (only strain-rate)
	    name="olp-M"	     # 
	    n=2;
	    Q=320*1000;
	    sP=5.9e9; # Peierls stress [Pa]
	    A=1.4e-7*(1e-6)**(n);
	    B=2**((1+(3/n))/2)*A**(-1/n);
	    #
	    if(ce){
		if(T > 1250+275){
		    strain = 1e-100;
		}else{
		    strain = (stress/B)**n*exp(-Q/(R*T)*(1-sqrt(stress/sP)));
		}
	    }else
		stress = "NaN"; # no analytical solution (?)
	    
	    if(stress == "NaN")
		visc = "NaN";
	    else
		visc=stress/strain;
	}else if(material == "pe3"){ # Demouchy 2013 peierls creep
	    name="olp-D"	     # 
	    p=0.5;
	    q=2;
	    Q=450*1000;
	    A=1e6 # 1/s;
	    n=1;
	    B=2**((1+(3/n))/2)*A**(-1/n);
	    sP=15e9; # Peierls stress [Pa]
	    if(ce){
				# should this be corrected by 1/4?
		strain = 1/B*exp(-(Q/(R*T))*((1-(stress/sP)**p)**q));
		#strain = A*exp(-(Q/(R*T))*((1-(stress/sP)**p)**q));
	    }else{
		stress = sP*((1-((R*T/Q)*log(A/strain))**(1/q))**(1/p));
	    }
	    visc=stress/strain;
	}else if(material == "pe4"){ # Idrissei 2016 peierls creep
	    name="olp-I"	     # 
	    p=0.5;
	    q=2;
	    Q=566*1000;
	    A=1e6 # 1/s;
	    sP=3.8e9; # Peierls stress [Pa]
	    n=1;
	    B=2**((1+(3/n))/2)*A**(-1/n);
	    if(ce){
				# should this be corrected by 1/4?
		strain = 1/B*exp(-(Q/(R*T))*((1-(stress/sP)**p)**q));
		#strain = A*exp(-(Q/(R*T))*((1-(stress/sP)**p)**q));
	    }else{
		stress = sP*((1-((R*T/Q)*log(A/strain))**(1/q))**(1/p));
	    }
	    visc=stress/strain;
	}else if(material == "qu1"){ # quarzite 1
	    name="qu-J84"
	    if(diff){
		print("error, law ",name," only defined for dislocation creep") > "/dev/stderr";
		visc="NaN";stress="NaN";
	    }else{
		if(dry){
		    # Jaoul et al., 1984, dry quartzite
		    n=2.8;
		    Q=184*1000;
		    A=3.85e-6*(1e-6)**(n);
		    B=2**((1+(3/n))/2)*A**(-1/n);
		    if(ce)
			strain = (stress/B)**n * exp(-Q/(R*T));
		    else
			stress= B*exp(Q/(n*R*T))*strain**(1/n);
		}else{
		    # Jaoul et al., 1984, wet quartzite
		    n=2.8;
		    Q=163*1000;
		    A=9.0e-6*(1e-6)**(n);
		    B=2**((1+(3/n))/2)*A**(-1/n);
		    if(ce)
			strain = (stress/B)**n*exp(-Q/(R*T));
		    else
			stress=B*exp(Q/(n*R*T))*strain**(1/n);
		}
		
		visc=stress/strain;
	    }
	}else if(material == "qu2"){ # quarzite 2
	    name="qu-RB04"
	    if(dry){
		print("error, law ",name," only defined for wet") > "/dev/stderr";
		visc="NaN";stress="NaN";
	    }else{
		# Rutter and Brodie, 2004, wet quartzite, diffusion creep
		if(diff){
		    n=1;
		    m=2;
		    Q=220*1000;
		    A=(10**-0.4)*(1e-6)**(n+m);
		    B=2**((1+(3/n))/2)*A**(-1/n);
		    if(ce)
			strain = (stress/B)**n*exp(-Q/(R*T))*grain**(-m);
		    else
			stress=B*exp(Q/(n*R*T))*strain**(1/n)*grain**(m/n);
		}else{
		    # Rutter and Brodie, 2004, wet quartzite, dislocation creep
		    n=3;
		    Q=242*1000;
		    p=1;
		    A=10**(-4.9)*(1e-6)**(n+p);
		    B=2**((1+(3/n))/2)*A**(-1/n);
		    if(ce)
			strain = (stress/B)**n*exp(-Q/(R*T));
		    else
			stress=B*exp(Q/(n*R*T))*strain**(1/n)*fw**(-p/n);
		}
		visc=stress/strain;
	    }
	}else if(material == "qu3"){
	    name="qu-H01"
	    if(diff){
		print("error, law ",name," only defined for dislocation creep") > "/dev/stderr";
		visc="NaN";stress="NaN";
	    }else{
		# Hirth
		if(dry){
		    #print("error no dry for qu3") > "/dev/stderr"
		    visc="NaN"
		    stress="NaN";
		}else{
		    n=4;
		    Q=135*1000;
		    p=1;
		    A=10**(-11.2)*(1e-6)**(n+p);
		    B=2**((1+(3/n))/2)*A**(-1/n);
		    if(ce)
			strain = (stress/B)**n*exp(-Q/(R*T))*fw**p;
		    else
			stress = B*exp(Q/(n*R*T))*strain**(1/n)*fw**(-p/n);
		    visc=stress/strain;
		}
	    }
	}else if(material == "qu4"){ # Tokle et al
	    name="qu-T19";
	    if(diff){
		print("error, law ",name," only defined for dislocation creep") > "/dev/stderr";
		visc="NaN";stress="NaN";
	    }else{
		if(dry){
		    #print("error no dry for qu4") > "/dev/stderr"
		    visc="NaN"
		    stress="NaN";
		}else{
		    n=3;
		    Q=115*1000;
		    p=1.2;
		    A=10**(-11.9586073148418)*(1e-6)**(n+p);
		    B=2**((1+(3/n))/2)*A**(-1/n);
		    if(ce)
			strain = (stress/B)**n*exp(-Q/(R*T))*fw**p;
		    else
			stress=B*exp(Q/(n*R*T))*strain**(1/n)*fw**(-p/n);
		    visc=stress/strain;
		}
	    }
	}else if(material == "qu4b"){ # Tokle et al - GBS
	    name="qu-T19-GBS";
	    if(diff){
		print("error, law ",name," only defined for dislocation creep") > "/dev/stderr";
		visc="NaN";stress="NaN";
	    }else{
		if(dry){
		    #print("error no dry for qu4") > "/dev/stderr"
		    visc="NaN"
		    stress="NaN";
		}else{
                    # n = 4 extrapolated version for GBS
		    n=4;
		    Q=125*1000;
		    p=1;
		    A=10**(-11.7569619513137)*(1e-6)**(n+p);
		    B=2**((1+(3/n))/2)*A**(-1/n);
		    if(ce)
			strain = (stress/B)**n*exp(-Q/(R*T))*fw**p;
		    else
			stress=B*exp(Q/(n*R*T))*strain**(1/n)*fw**(-p/n);
		    visc=stress/strain;
		}
	    }
	}else if(material == "qu5"){ # Lu and Jianag 2019
	    name="qu-LJ19"
	    if(diff){
		print("error, law ",name," only defined for dislocation creep") > "/dev/stderr";
		visc="NaN";stress="NaN";
	    }else{
		if(dry){
		    #print("error no dry for qu5") > "/dev/stderr"
		    visc="NaN"
		    stress="NaN";
		}else{	
		    n=3;
		    E=132*1000;
		    V=35.3e-6;
		    p=2.7;
		    A=10**(-14.2218)*(1e-6)**(n+p);
		    B=2**((1+(3/n))/2)*A**(-1/n);
		    if(ce)
			strain = (stress/B)**n*exp(-(Q+pressure*V)/(R*T))*fw**p;
		    else
			stress = B*exp((E+pressure*V)/(n*R*T))*strain**(1/n)*fw**(-p/n);
		    visc=stress/strain;
		}
	    }
	}else if(material == "qu6"){ # Lusk et al. 2021
	    name="qu-L21"
	    if(diff){
		print("error, law ",name," only defined for dislocation creep") > "/dev/stderr";
		visc="NaN";stress="NaN";
	    }else{
		if(dry){
		    print("error no dry for qu6") > "/dev/stderr"
		    visc="NaN"
		    stress="NaN";
		}else{
		    switch_p=1;
		    if(switch_p){
			if(pressure < .7e9){ # low pressure
			    n=3.5;
			    p=0.49;
			    Q=118*1000;
			    V=2.59e-6;
			    A=10**(-9.30)*(1e-6)**(n+p);
			}else{	# high pressure
			    n=2;
			    Q=77*1000;
			    V=2.59e-6;
			    p=0.49;
			    A=10**(-7.9)*(1e-6)**(n+p);
			}
		    }else{
			n=2.1;
			Q=94*1000;
			V=1.44e-6;
			p=0.20;
			A=10**(-6.36)*(1e-6)**(n+p);

		    }
		    B=2**((1+(3/n))/2)*A**(-1/n);
		    if(ce)
			strain = (stress/B)**n*exp(-(Q+pressure*V)/(R*T))*fw**p;
		    else
			stress = B*exp((Q+pressure*V)/(n*R*T))*strain**(1/n)*fw**(-p/n);
		    visc=stress/strain;
		}
	    }
	}else if(material == "fe1"){
	    name="fe-RD06"
	    if(diff){
		print("error, law ",name," only defined for dislocation creep") > "/dev/stderr";
		visc="NaN";stress="NaN";
	    }else{
		if(dry){
		    # Rybacki and Dresen 2006, dry An100 in dislocation creep
		    n=3.0;
		    Q=641*1000;
		    V=24*1e-6;
		    A=10**(12.7)*(1e-6)**(n);
		    B=2**((1+(3/n))/2)*A**(-1/n);
		    if(ce)
			strain = (stress/B)**n*exp(-(Q+pressure*V)/(R*T));
		    else
			stress= B*exp((Q+pressure*V)/(n*R*T))*strain**(1/n);
		}else{
		    # Rybacki and Dresen 2006, wet An100 in dislocation creep
		    
		    n=3;
		    p=1;
		    Q=345*1000;
		    V=38*1e-6;
		    A=(10**0.2)*(1e-6)**(n+p);
		    B=2.**((1+(3/n))/2)*A**(-1/n);
		    if(ce)
			strain = (stress/B)**n*exp(-(Q+pressure*V)/(R*T))*fw**p;
		    else
			stress=              B*exp((Q+pressure*V)/(n*R*T))*strain**(1/n)*fw**(-p/n);
		}
		visc=stress/strain;
	    }
		
	}else{
	    print("material ",material," error") > "/dev/stderr"
	    exit;
	}
	if(print_name){
	    print(name);
	}else{
	    #
	    # viscosity and differential stress 
	    #
	    if(visc != "NaN"){
		if(ce)
		    printf("%.8e %.8e\n",visc,strain); # strain output
		else
		    printf("%.8e %.8e\n",visc,stress); # stress output
	    }else
		print("NaN","NaN");
	}
	
    }
}


