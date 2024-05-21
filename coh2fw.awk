BEGIN{
    c0=-7.9859;
    c1= 4.3559;
    c2=-0.5742;
    c3= 0.0337;
}{
    #
    # Li et al. (2008) empiral conversion of water content to fugacity IS WRONG
    #
    # input C_OH in H/10^6Si, output in Pa
    #
    # if(substr($1,1,1)!="#" && tolower($1)!="NaN"){
    # 	lcoh=log($1);
    # 	lfw = c0 + c1*lcoh + c2*lcoh**2 + c3*lcoh**3;
    # 	print(exp(lfw)*1e6);
    # }

}
