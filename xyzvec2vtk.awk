#
#
# convert x y z vx vy vz to VTK vectors
#
# Thorsten Becker, UT Austin
# thorstinski@gmail.com
#
#

BEGIN{
  # counters
  nsc=0;
  nsi=0;
  np=0;
  if(scale=="")
      s=1;
  else
      s=scale;
  
}
{
    if((substr($1,1)!="#")&&(NF>=6)){

	
      np++;

      x[np]=$1;
      y[np]=$2;
      z[np]=$3;

      cart_vec[np*3+1] = $4;
      cart_vec[np*3+2] = $5;
      cart_vec[np*3+3] = $6;
    }

}
END{
  print("# vtk DataFile Version 4.0");
  print("converted from GMT file");
  print("ASCII");
  print("DATASET POLYDATA");
  print("POINTS",np,"float")
  for(i=1;i<=np;i++)
    printf("%.6e %.6e %.6e\n",x[i],y[i],z[i]);
  print("");

  print("POINT_DATA ",np)
  print("VECTORS velocity float");
  for(i=1;i<=np;i++){
      printf("%g %g %g\n",s*cart_vec[i*3+1],s*cart_vec[i*3+2],s*cart_vec[i*3+3]);
  }



}

