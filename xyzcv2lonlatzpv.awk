#
# converts data in x y z v_x v_y v_z (Cartesian location and velocities)
# to polar coordinates and polar velocities
# input is 
#
# x y z v_x v_y v_z ....
#
# output is 
#
# lon lat z v_r v_theta v_phi ....
#
# which is
#
# longitude latitude v_UP v_SOUTH v_EAST
#
BEGIN{
   f=0.017453292519943296;	# pi/1u0
}
{
  if((substr($1,1,1)!="#") && (NF>=6)){
      # coordinates
      x = $1;
      y = $2;
      z = $3;

      # Cartesian velocities 
      vx=$4;
      vy=$5;
      vz=$6;

      
      tmp1 = x*x + y*y;
      tmp2=tmp1 + z*z;
      if(tmp2 > 0.0)
	  R = sqrt(tmp2);
      else
	  R = 0.0;
      theta=atan2(sqrt(tmp1),z);
      phi=atan2(y,x);
      
# coords
      lon = phi/f;
      lat = 90-theta/f;
    
# base vecs
      ct=cos(theta);cp=cos(phi);
      st=sin(theta);sp=sin(phi);
    # r base vec
      polar_base_x[1]= st * cp;
      polar_base_y[1]= st * sp;
      polar_base_z[1]= ct;
      # theta base vec
      polar_base_x[2]= ct * cp;
      polar_base_y[2]= ct * sp;
      polar_base_z[2]= -st;
      # phi base vec
      polar_base_x[3]= -sp;
      polar_base_y[3]=  cp;
      polar_base_z[3]= 0.0;
# convert vector
      for(i=1;i<=3;i++){
	  polar_vec[i]  = polar_base_x[i] * vx;
	  polar_vec[i] += polar_base_y[i] * vy;
	  polar_vec[i] += polar_base_z[i] * vz;
      }
      printf("%20.15e %20.15e %20.15e %20.15e %20.15e %20.15e ",
	     lon,lat,R,polar_vec[1],polar_vec[2],polar_vec[3]);
      for(i=7;i<=NF;i++)
	  printf("%s ",$i);
      printf("\n");
  }
}
