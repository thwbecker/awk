# convert GEM faults
BEGIN{
    if(lw=="")
	lw = 2;
    if(double_active=="")
	double_active=0;
    if(show_type=="")
	show_type = 0;		# 0: all 1: normal 2: ss slip 3: reverse 11,12,13: active only
    if(flip_color=="")
	flip_color=0;
}
{
    if(substr($1,1,1)!="#"){
	if(plot)
	    print($0);
    }else if(NR>10){
	
	split($0,info,"|");
	
	ftype=info[9];		# sometimes dash, sometimes underscore is used
	gsub("_","-",ftype);
	ntypes = split(ftype,ftypes,"-");
	if(ntypes>1)
	    ftype_first = ftypes[1];
	else
	    ftype_first = ftype;
	# all faults are active but some have a neotectonics flags
	active=(info[14] != "")?(info[14]):("NaN");
	is_active = ((active == 1)||(active == 2))?(1):(0);
	plot=0;
	#print(ftype,ftype_first,active) > "/dev/stderr";
	switch(ftype_first){
	    case "Reverse":
		ftype=3;
		if(flip_color)
		    col="blue"
		else
		    col="darkred";
	    break;
	    case "Normal":
		ftype=1;
		if(flip_color)
		    col="red";
		else
		    col="darkblue";
	    break;
	    case "Sinistral":
		ftype=2;
		col="darkcyan";
	    break;
	    case "Dextral":
		ftype=2;
		col="darkgreen";
	    break;
	    default:
		ftype=-1;
		col="black";
	    break;
	}
	if(show_type==0)
	    plot = 1;
	else if(show_type>10){
	    if(is_active){
		show_type -= 10;
		if((show_type == 1) && (ftype == 1))
		    plot = 1;
		else if((show_type == 2) && (ftype == 2))
		    plot = 1;
		else if((show_type == 3) && (ftype == 3))
		    plot = 1;
		else
		    plot = 0;
	    }else{
		plot = 0;
	    }
	}else{
	    if((show_type == 1) && (ftype == 1))
		plot = 1;
	    else if((show_type == 2) && (ftype == 2))
		plot = 1;
	    else if((show_type == 3) && (ftype == 3))
		plot = 1;
	    else
		plot = 0;
	}
	if(plot)
	    if(double_active && is_active)
		printf("> -W%g,%s\n",lw*3,col);
	    else
		printf("> -W%g,%s\n",lw,col);
    }
}

