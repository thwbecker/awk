BEGIN{
#
# WSM data extraction script - originally part of iGMT
#
# thwbecker@post.harvard.edu (c) 2002-2025 
#
#    
# this awk script deals with the WSM format of the World Stress Map by
# Zoback et al. (1992), Mueller et al. (1997,2000), Heidbach et
# al. (2008, 2016, 2025), Rajabi et al. (2025)
#
# Rajabi, M., Lammers, S., & Heidbach, O. (2025). WSM database
#  description and guidelines for analysis of horizontal stress
#  orientation from borehole logging. GFZ Data
#  Services. https://doi.org/10.48440/WSM.2025.001
#
#Heidbach, Oliver; Rajabi, Mojtaba; Di Giacomo, Domenico; Harris,
# James; Lammers, Steffi; Morawietz, Sophia; Pierdominici, Simona;
# Reiter, Karsten; von Specht, Sebastian; Storchak, Dmitry; Ziegler,
# Moritz O. (2025): World Stress Map Database Release 2025. GFZ Data
# Services. https://doi.org/10.5880/WSM.2025.001
#
# Heidbach, Oliver; Rajabi, Mojtaba; Reiter, Karsten; Ziegler, Moritz (2016): World
#    Stress Map 2016. GFZ Data Services. http://doi.org/10.5880/WSM.2016.002     
#
# http://www.world-stress-map.org
#
# the script reads the original data and prints output to stdout that can be used
# for plotting with GMT psvelo. output has the format
# 
# lon lat e1 e2 azi [weight]
#
# where e1 and e2 are the (fake) principal strains, compression negative, e1 > e2
# and azi is the azimuth of e2 in degrees clockwise from North
#
# weight is only added when the add_weights flag is set and detemrined based on the 
# quality of the measurement (see below)
# 
# the user can supply sort criteria as follows
#
# input parameters are (pregime, pquality, and type only apply for add_weights<2)
#
# pregime: 1 means plot only extensional mechanism derived 
#            compressional stress axis direction 
#          2 means plot only strike-slip mechanism derived..
#          3 only compressional
#          4 only undetermined
#          5 all mechanisms output as e1=1 e2=-1 (default)
#
#
# pquality: 1 means plot only A class data points
#           2 means A and B (DEFAULT)
#           and so on to 5 which will include qualities A, B, C, D, and E
#           and 6 which doesn't use the quality criterion at all
#
# type:     t1: if 1, plot focal mechanism derived data (default)
#           t2: include borehole breakouts
#           t3: include hydro frac
#           t4: include overcoring
#           t5: include geological indicators
#           t6: include also those wihtout any indicators
#           t7: include seismic anisotropy based indicators
#
#           you can give more than one type switch 1/0
# 
#           if you want really all indicators, use tall=1
#
# add_weights: 0: print out (default)
#              1: if set to 1, will determine weight factor based  on quality
#              2: will print out all information, not applying criteria
#
#
#
# default values
#
# check if sort criteria are set, if not use defaults
    if(pregime == 0)
	pregime=5;
# A and B quality data
    if(pquality == 0)
	pquality=2;
    if(tall == 0){
        # only focal mechanism derived data  
	if(t1 == 0 && t2 == 0 && t3 == 0 && t4 == 0 && t5 == 0 && t6==0 && t7==0){
	    t1=1;t2=0;t3=0;t4=0;t5=0;t6=0;t7=0;
	}
    }else{
	t1=t2=t3=t4=t5=t6=t7=1;
    }

    debug=0;
    if(debug){
	# careful!
	err_log_file="sortwsm.err.log";
	sstring=sprintf("rm %s 2> /dev/null",err_log_file);
	system(sstring);
	nerr=0;
    }
}
{
    #
    # skip header line but try to determine which version of 
    # stress map we are dealing with
    #
    if (NR == 1) {
	if($1=="ISO"){		# 2008 release
	    offset=1;
	    # separator
	    FS=";";
	    id_col=-1;
	}else if($1=="SITE"){		# older release
	    offset=0;
	    FS=";";
	    id_col=1;
        }else if(match(substr($1,1,10),"ID,ISC_ID")){		# 2025 release
	    FS=",";
	    offset=2;
	    FPAT = "\"[^\"]*\"|[^,]*" # for fields where commas are quoted
	    id_col=1;
	}else if(substr($1,1,3)=="ID,"){		# 2016 release, same meaning as 2008, but now with "," as FS....
	    FS=",";
	    offset=1;
	    id_col=1;
	}else{
	    print("sortwsm: error, cannot detect version of WSM data file") > "/dev/stderr"
	    exit;
	}
	next;
    }
    n++;
    if(id_col>0)
	id = $(id_col);
    else
	id = "NaN";
# coordinates
    lon=$(3+offset);
    lat=$(2+offset);
    if((lon=="")||(lat=="")){
	if(debug){
	    nerr++;
	    print("entry line ",NR," has missing lon or lat info: ",$0) >> err_log_file;
	}
	next;
    }
# azimuth 
    azi=$(4+offset);
#
# sort out according to type of measurement      
    type=$(5+offset);
 
    quality=substr($(7+offset),1,1);

  
# assign type
# assign regime  
    reg=substr($(8+offset),1,2);

#    print(lon,lat,azi,type,quality,reg,NR,id) >> "tmp.log"

#    exit
    if(reg == "NF"){
	regime=1;
    }else if(reg == "NS")
	regime=2;
    else if(reg == "SS")
	regime=3;
    else if(reg == "TS")
	regime=4;
    else if(reg == "TF")
	regime=5;
    else 			# undefined
	regime=-1;
    #
    # output only if fits criteria
    #
    if(add_weights < 2){

# sort out quality
	if(quality == "A"){
	    w=1.0;
	}else if(quality == "B"){
	    if(pquality < 2)
		next;
	    w=0.5;
	}else if(quality == "C"){
	    if(pquality < 3)
		next;
	    w=0.33333;
	}else if(quality == "D"){
	    if(pquality < 4)
		next;
	    w=0.2;
	}else if(quality == "E"){
	    if(pquality < 5)
		next;
	    w=0.2;
	}else{
# no quality measure
	    if(pquality != 6)
		next;
	}
	#
	# skip depending on mechanisms
	#
	if(substr(type,1,2) == "FM"){ # FMA, FMF, FMS
	    #FMF: formal inversion of several focal mechanisms
	    #FMS: single focal mechanism solution
	    #FMA: average of focal mechanisms 
	    if(t1 == 0)
		next;
	}else if((type == "BO")||(type == "BS")||(type == "DIF")){
	    #BO: interpretation of borehole breakouts
	    #BS: borehole slotter
	    #DIF: drilling-induced tensile fractures of the borehole wall. 
	    if(t2 == 0)
		next;
	}else if(substr(type,1,2) == "HF"){
	    #HF: Fractures in sub-vertical wells
	    #HFP: testing of pre-existing fractures (HTPF)
	    #HFH: Fractures in sub-horizontal wells
	    #HFS: Seismicity on hydraulic faults 
	    if(t3==0)
		next;
	}else if(type == "OC"){
	    #OC: overcoring or other strain relief 
	    if(t4 == 0)
		next;
	}else if((substr(type,1,2) == "GF")||(type == "GVA")){ # GFI, GFM, GVA
	    #GFI: inversion of fault-slip data
	    #GFM: paleo-focal mechanism
	    #GVA: geologic-volcanic vent alignment 
	    if(t5 == 0)
		next;
	}else if(substr(type,1,2) == "SW"){
	    #SWB: anisotropy of seismic waves in boreholes from sonic logs
	    #SWL: anisotropy of seismic waves in laboratory
	    #SWS: anisotropy of seismic waves in seismology 
	    if(t7 == 0)
		next;
	}else{  			# no indication of where the data came from
	    if(!match(type,"U"))
		print("error",type,NR) > "/dev/stderr"
	    if(t6 == 0)
		next;
	}
    }
    if(add_weights==0){
	#
	# no weights in output 
	#
	if(pregime == 5){
	    print(lon,lat,1,-1,azi);np++;
	}
	else
	    if(pregime == 1){ # extensional mechanism output
		if(regime == 1) {# pure
		    print(lon,lat,1,0,azi);np++;
		}else if(regime == 2) {# with strike slip component
		    print(lon,lat,1,-0.5,azi);np++;
		}
	    }else if(pregime == 2){# pure strike slip mech. out
		if(regime == 3){
		    print(lon,lat,1,-1,azi);np++;
		}
	    }else if(pregime == 3){# compressional mech. out
		if(regime == 4) {# with ss
		    print(lon,lat,0.5,-1,azi);np++;
		}
		else if(regime == 5) {# pure 
		    print(lon,lat,0,-1,azi);np++;
		}
	    }else if(pregime == 4 && regime== -1){#undetermined, no mechanism
		print(lon,lat,0,-1,azi);np++;
	    }
    }else if(add_weights==1){
	#
	# weights
	#
	if(pregime == 5){
	    print(lon,lat,1,-1,azi,w);np++;
	}else{
	    if(pregime == 1){ # extensional mechanism output
		if(regime == 1) {# pure
		    print(lon,lat,1,0,azi,w);np++;
		}
		else if(regime == 2) {# with strike slip component
		    print(lon,lat,1,-0.5,azi,w);np++;
		}
	    }else if(pregime == 2){# pure strike slip mech. out
		if(regime == 3){
		    print(lon,lat,1,-1,azi,w);np++
		}
	    }else if(pregime == 3){# compressional mech. out
		if(regime == 4) {# with ss
		    print(lon,lat,0.5,-1,azi,w);np++;
		}
		else if(regime == 5) {# pure 
		    print(lon,lat,0,-1,azi,w);np++;
		}
	    }else if(pregime == 4 && regime== -1){#undetermined, no mechanism
		print(lon,lat,0,-1,azi,w);np++;
	    }
	}
    }else if(add_weights ==2){
	# output is lon lat azimuth type quality regime
	printf("%12.5f %12.5f %6.1f %2s %1s %2s\n",lon,lat,azi,type,quality,reg);
	np++;
    }
}
END{
    if(debug)
	printf("sortwsm.awk: printed %i out of %i (t:%i%i%i%i%i%i%i, pq:%i), %i incomplete records in %s\n",
	       np,n,t1,t2,t3,t4,t5,t6,t7,pquality,nerr,err_log_file) > "/dev/stderr";
    else
	printf("sortwsm.awk: printed %i out of %i (t:%i%i%i%i%i%i%i, pq:%i)\n",
	       np,n,t1,t2,t3,t4,t5,t6,t7,pquality) > "/dev/stderr";

	

}
