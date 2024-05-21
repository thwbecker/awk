#
# take vx vy velocities as columns 1 and 2
# and rotate into vnormal vtangential along a track of azimuth azi deg CW from north
#
# vn points CW from azimuth positive, i.e. the new x and y and n and t
#
BEGIN{
    pif=57.295779513082320876798154814105;
    if(azi=="")
	azi=0;

    a = azi/pif;
    sina=sin(a);
    cosa=cos(a);
    #print("rotating into azimuth ",azi,sina,cosa) > "/dev/stderr";
}
{
    if((substr($1,1,1)!="#")&&(NF>=2)){
	vx = $1;
	vy = $2;
	vn = cosa * vx - sina * vy; # same as rotation of points CW from x
	vt = sina * vx + cosa * vy;
	printf("%g %g ",vn,vt);
	for(i=3;i<=NF;i++)
	    printf("%s ",$i);
	printf("\n");
    }

}
