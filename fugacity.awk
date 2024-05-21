BEGIN{
    
#
# plot rheologies based on Hirth & Kohlstedt (2004), solutions to Problem Set # of GEOL534 
#
# pressure, from PREM, in Pa, when z is given in km, approximately
#
#p(z) = 1e5 + 3.043e7 * z + 7.79e3*z**2
#
# temperature as a function of depth, in K, where z is given in km
#
# 1350 + 273 = 1623
#
#T(z) = 1593 + 0.4*z
# gas constant
    R=8.314510;
#
# diffusion creep viscosity
#
# eta = d^m/A'' * exp((E+p*V)/(RT))
#
# where A'' has the water content (using C_H20=1000 for wet) in it,
# the conversion from weird units to SI and the conversion from
# differential stress to second invariant
# 
#
# dry/wet
#
    fw=1000000;
    if(diff=="")
	diff = 0;
    if(dry=="")
	dry = 0;
    if(mat=="")
	material = "ol";		
    else
	material = mat;
}
{
    if(substr($1,1,1)!="#" && NF>=4){
	p=$1;			# in Pa
	T=$2;			# K
	d=$3; # 4e-3
	e=$4; # 1e-15;

#printf("p %g MPa T %g d %e e %e\n",p/1e6,T,d,e) > "/dev/stderr"
	if(material == "ol"){
# grain size exponent
#
	    m=3.;
# power law
	    n=3.5;
	    #
	    # my values for viscosity 
	    #
	    if(diff){
		if(dry){
		    visc =   d**m/(4.5e-15) * exp((375.e3+p*6.e-6)/(R*T));
		}else{
		    visc =   d**m/(3.0e-15) * exp((335.e3+p*4.e-6)/(R*T));
		}
	    }else{
#
# dislocation creep viscosity, assuming constant strain
#
# eta = (1/A'')^(1/n) * eps_{II}^((1-n)/n) * exp((E+pV)/(nRT))
#

# dry/wet
# as function of strain
		if(dry){
		    visc = (1/7.4e-15)**(1/n) * e**((1.-n)/n) * (exp((530.e3+p*14.e-6)/(n*R*T)));
		}else{
		    visc = (1/2.4e-14)**(1/n) * e**((1.-n)/n) * (exp((480.e3+p*11.e-6)/(n*R*T)));
		}
	    }
            #
	    # RHEOL values for stress
            #
	    if(dry && !diff){
		#Hirth and Kohlstedt, 2003, dry olivine, dislocation creep
		
		n=3.5;
		Q=530*1000;
		V=18*1e-6;
		A=1.1e5*(1e-6)**n;
		B=2**((1+(3/n))/2)*A**(-1/n);
		lstress = B*exp((Q+P*V)/(n*R*T))*e**(1/n);
	    }else if(!dry && !diff){
#Hirth and Kohlstedt, 2003, wet olivine, dislocation creep
		n=3.5;
		p=1.2;
		Q=520*1000;
		V=22*1e-6;
		A=1600*(1e-6)**(n+p);
		B=2**((1+(3/n))/2)*A**(-1/n);
		lstress = B*exp((Q+P*V)/(n*R*T))*e**(1/n)*fw**(-p/n);
	    }else if(dry && diff){
#Hirth and Kohlstedt, 2003, dry olivine, diffusion creep
		n=1;
		m=3;
		Q=375*1000;
		V=10*1e-6;
		A=1.5e9*(1e-6)**(n+m);
		B=2**((1+(3/n))/2)*A**(-1/n);
		lstress = B*exp((Q+P*V)/(n*R*T))*e**(1/n)*d**(m/n);
	    }else if(!dry && diff){
#Hirth and Kohlstedt, 2003, wet olivine, diffusion creep
		n=1;
		m=3;
		p=1;
# Q=520*1000;
# A=4.9e6*(1e-6)**(n+m+p);
# Copied from Burgmann and Dresen, AREPS 2008
		Q=375*1000;
		V=20*1e-6;
		A=10**(7.4)*(1e-6)**(n+m+p);
		B=2**((1+(3/n))/2)*A**(-1/n);
		lstress = B*exp((Q+P*V)/(n*R*T))*e**(1/n)*d**(m/n)*fw**(-p/n);
	    }
	    # that would be for RHEOL stresses
	    #visc=lstress/2/e;
	    # override
	    lstress=visc*2*e;
	}else if(material == "qu1"){ # quarzite 1

	    if(dry){
		# Jaoul et al., 1984, dry quartzite
		n=2.8;
		Q=184*1000;
		A=3.85e-6*(1e-6)**(n);
		B=2**((1+(3/n))/2)*A**(-1/n);
		lstress=B*exp(Q/(n*R*T))*e**(1/n);
	    }else{
		# Jaoul et al., 1984, wet quartzite
		n=2.8;
		Q=163*1000;
		A=9.0e-6*(1e-6)**(n);
		B=2**((1+(3/n))/2)*A**(-1/n);
		lstress=B*exp(Q/(n*R*T))*e**(1/n);
	    }
	    visc=lstress/2/e;

	}else if(material == "qu2"){ # quarzite 2


	    # Rutter and Brodie, 2004, wet quartzite, diffusion creep
	    if(dry){
		n=1;
		m=2;
		Q=220*1000;
		A=(10**-0.4)*(1e-6)**(n+m);
		B=2**((1+(3/n))/2)*A**(-1/n);
		lstress=B*exp(Q/(n*R*T))*e**(1/n)*g**(m/n);
		
	    }else{
		# Rutter and Brodie, 2004, wet quartzite, dislocation creep
		n=3;
		Q=242*1000;
		p=1;
		A=10**(-4.9)*(1e-6)**(n+p);
		B=2**((1+(3/n))/2)*A**(-1/n);
		lstress=B*exp(Q/(n*R*T))*e**(1/n)*fw**(-p/n);
	    }

	    visc=lstress/2/e;
	}else if(material == "qu3"){
	    n=4;
	    Q=135*1000;
	    p=1;
	    A=10**(-11.2)*(1e-6)**(n+p);
	    B=2**((1+(3/n))/2)*A**(-1/n);
	    lstress = B*exp(Q/(n*R*T))*e**(1/n)*fw**(-p/n);
	    
	     visc=lstress/2/e;
	}else{
	    print("material ",material," error") > "/dev/stderr"
	    exit;
	}
	# viscosity and stress
	printf("%.6e %.6e\n",visc,lstress);
    }
}

#
#
# fugacity(p, T)
# 14 elements
#ph20="100000000	150000000	200000000	250000000	300000000	350000000	400000000	450000000	500000000	600000000	700000000	800000000	900000000	1000000000.00000";
# 10 elements
#TH20="373.150000000000	473.150000000000	573.150000000000	673.150000000000	773.150000000000	873.150000000000	973.150000000000	1073.15000000000	1173.15000000000	1273.15000000000";
# 10 x 14
gamma="0.00200000000000000	0.00200000000000000	0.00200000000000000	0.00200000000000000	0.00200000000000000	0.00200000000000000	0.00300000000000000	0.00300000000000000	0.00300000000000000	0.00500000000000000	0.00700000000000000	0.00900000000000000	0.0140000000000000	0.0200000000000000
0.0240000000000000	0.0200000000000000	0.0190000000000000	0.0200000000000000	0.0200000000000000	0.0220000000000000	0.0240000000000000	0.0270000000000000	0.0300000000000000	0.0380000000000000	0.0500000000000000	0.0660000000000000	0.0880000000000000	0.119000000000000
0.105000000000000	0.0880000000000000	0.0820000000000000	0.0810000000000000	0.0830000000000000	0.0870000000000000	0.0920000000000000	0.100000000000000	0.109000000000000	0.132000000000000	0.163000000000000	0.205000000000000	0.259000000000000	0.330000000000000
0.263000000000000	0.219000000000000	0.202000000000000	0.197000000000000	0.199000000000000	0.206000000000000	0.216000000000000	0.229000000000000	0.245000000000000	0.287000000000000	0.343000000000000	0.414000000000000	0.504000000000000	0.618000000000000
0.459000000000000	0.389000000000000	0.361000000000000	0.351000000000000	0.353000000000000	0.361000000000000	0.376000000000000	0.395000000000000	0.418000000000000	0.478000000000000	0.556000000000000	0.654000000000000	0.776000000000000	0.925000000000000
0.632000000000000	0.557000000000000	0.523000000000000	0.510000000000000	0.512000000000000	0.523000000000000	0.540000000000000	0.564000000000000	0.594000000000000	0.668000000000000	0.763000000000000	0.881000000000000	1.02400000000000	1.19500000000000
0.762000000000000	0.700000000000000	0.671000000000000	0.660000000000000	0.664000000000000	0.678000000000000	0.700000000000000	0.728000000000000	0.762000000000000	0.848000000000000	0.956000000000000	1.08800000000000	1.24600000000000	1.43200000000000
0.848000000000000	0.807000000000000	0.788000000000000	0.786000000000000	0.795000000000000	0.813000000000000	0.838000000000000	0.871000000000000	0.909000000000000	1.00400000000000	1.12100000000000	1.26200000000000	1.42800000000000	1.62100000000000
0.905000000000000	0.883000000000000	0.875000000000000	0.880000000000000	0.895000000000000	0.917000000000000	0.947000000000000	0.982000000000000	1.02400000000000	1.12400000000000	1.24600000000000	1.39100000000000	1.56100000000000	1.75500000000000
0.940000000000000	0.930000000000000	0.932000000000000	0.945000000000000	0.964000000000000	0.990000000000000	1.02000000000000	1.05500000000000	1.09600000000000	1.19300000000000	1.31500000000000	1.46000000000000	1.63100000000000	1.82600000000000"
