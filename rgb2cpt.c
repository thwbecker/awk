/********************************************************************************/
/*                     rgb2cpt                                                  */
/*                                                                              */
/*  creates GMT cpt files using IDL color tables in rgb-code                    */
/*  alexander braun, 20.6.1996                                                  */
/*  c-version thorsten becker, 21.06.1996                                       */
/********************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#ifndef DATAPATH
#define DATAPATH "/net/gmt/lib/"
#endif
#ifndef INFILENAME
#define INFILENAME "idlrgb"
#endif
#ifndef OUTFILENAME
#define OUTFILENAME "color.cpt"
#endif
#ifndef HELPFILE
#define HELPFILE "/home/www/local/info/rgb2cpt"
#endif

#ifndef FIRST_FILE_NUMBER 
#define FIRST_FILE_NUMBER 1
#endif

#ifndef LAST_FILE_NUMBER 
#define LAST_FILE_NUMBER 37
#endif



#ifndef MM
#define MM 235
#endif

void main(int argc, char *argv[])
{
  double min= -1.0,max = 1.0,delta,r[MM],b[MM],g[MM];
  char filename[4][60],tmp2[80],tmp[5];
  FILE *infile,*outfile;
  int nrfile= -666,nc=25,i,cs=1,ncc;

  if((argc < 2)||(argc > 6))
    {
      printf("\nrgb2cpt <Nr. of %s.# File OR filename>\n\t[<Min(-1.0) Max(1.0)>]",INFILENAME);
      printf(" [# colors (50)] [color smear (1)]\n\n");
      
      printf("\tThis program converts IDL RGB-color files into GMT\n");
      printf("\tCPT-color tables. You can select from %i RGB files:\n",
	      LAST_FILE_NUMBER-FIRST_FILE_NUMBER+1);
      printf("\t\"%s.%i\" to \"%s.%i\" in the \"%s\" directory.\n\tRight now the RGB files ",
	     INFILENAME,FIRST_FILE_NUMBER,INFILENAME,LAST_FILE_NUMBER,DATAPATH);
      printf("should contain %i colors.\n\tIf you like to create",MM);
      printf(" your own IDL RGB file using sliders \n\tand functions");
      printf(" in IDL, follow the next steps:\n");
      
      printf("\tStart IDL (licence required to save the results!),\n");
      printf("\ttype xloadct, select desired colors and adjust them.\n");
      printf("\tType \"tvlct,r,g,b,/get\" to store colors in r,g,b.\n");
      printf("\tOpen a file : \"openw,1,\'filename\'\",\n");
      printf("\tstart a loop: \".run\n");
      printf("\t- for i=0,%i do begin\n",MM-1);
      printf("\t- printf,1,r(i),g(i),b(i)\n");
      printf("\t- endfor\n");
      printf("\t- end\"\n");
      printf("\tAfter \"close,1\" \'filename\' should contain your RGB file.\n");
      printf("\tThen continue converting with \"rgb2cpt filename\".\n");
      printf("\tAdditional information in \"%s\".\n",HELPFILE);
      printf("\tA.B. \tThB 03.09.1996\n\n");
      
      exit(-1);
    };

  if(argc >= 2)
    {
      if((sscanf(argv[1],"%i", &nrfile)) != 1)
	{
	  /* printf("\nPlease give a filenumber as first parameter !\n\n"); */
	  /* 	  exit(-1); */
	  nrfile = -666;
	  strcpy(&filename[0][0],argv[1]);
	}
      else
	{
	  if((nrfile < FIRST_FILE_NUMBER)||(nrfile > LAST_FILE_NUMBER ))
	    {
	      printf("\n\tPlease give a number from %i to %i !\n\n",
		     FIRST_FILE_NUMBER,LAST_FILE_NUMBER);
	      exit(-1);
	    };
	  strcpy(&filename[0][0],DATAPATH);strcat(&filename[0][0],INFILENAME);
	  if(nrfile < 10){sprintf(tmp,".0%1i",nrfile);}else{sprintf(tmp,".%2i",nrfile);};
	  strcat(&filename[0][0],tmp);
	};
      if((infile=fopen(&filename[0][0],"r"))==NULL)
	{
	  printf("\n\tError opening %s.\n\n",&filename[0][0]);
	  exit(-1);
	};
    };




  

  if(argc == 3)
    printf("\tskipping %s.\n",argv[2]);

  if(argc >= 4)
    if(((sscanf(argv[2],"%lf", &min))!=1)||((sscanf(argv[3],"%lf", &max))!=1))
      {
	printf("Please give min and max values of your dataset as two parameters !\n\n");
	exit(-1);
      };

  if(argc >= 5)
    if((sscanf(argv[4],"%i", &nc))!=1)
      {
	printf("Please give a integer number 1 to %i as nr. of colours !\n\n",MM);
	exit(-1);
      };
  
  if(argc == 6)
    if((cs != 0)&&(cs != 1)){printf("Enter \"1\" or \"0\" for color smear !\n\n");exit(-1);};
  
  
 

#ifdef VERBOSE
  printf("rgb2cpt v1.0\n\tReading from %s.\n",&filename[0][0]);
  if((outfile=fopen(OUTFILENAME,"w"))==NULL)
    {
      printf("\n\tError opening %s.\n",OUTFILENAME);
      exit(-1);
    }
  else
    {
      printf("\tWriting to %s.\n",OUTFILENAME);
    };
  
  printf("\tusing min: %g max: %g nr. of col.:%i color smear:%i\n",min,max,nc,cs);
#endif
  delta=(max-min)/(double)nc;
  ncc=(int)(235.0/(double)nc);

  if(nrfile == -666)
    nrfile=MM;
  else 
    nrfile=235;
  for(i=1;i <= nrfile;i++)
    if((fscanf(infile,"%lf %lf %lf",(r+i),(g+i),(b+i)))!=3)
      {printf("Error reading %s, line %i !\n\n",&filename[0][0],i);exit(-1);};
  fclose(infile);
  min = min - delta;
  for(i=1;i<=nc;i++)
    {
      min = min + delta;
      max = min + delta;
#ifdef VERBOSE
      if(cs) 
	fprintf(outfile,"%g %i %i %i %g %i %i %i\n",
		min,(int)r[i*ncc],(int)g[i*ncc],(int)b[i*ncc],
		max,(int)r[i*ncc],(int)g[i*ncc],(int)b[i*ncc]);
      else 
	fprintf(outfile,"%g %i %i %i %g %i %i %i\n",
		min,(int)r[i*ncc],(int)g[i*ncc],(int)b[i*ncc],
		max,(int)r[(i+1)*ncc],(int)g[(i+1)*ncc],(int)b[(i+1)*ncc]);
#else
      if(cs) 
	printf("%g %i %i %i %g %i %i %i\n",
		min,(int)r[i*ncc],(int)g[i*ncc],(int)b[i*ncc],
		max,(int)r[i*ncc],(int)g[i*ncc],(int)b[i*ncc]);
      else 
	printf("%g %i %i %i %g %i %i %i\n",
		min,(int)r[i*ncc],(int)g[i*ncc],(int)b[i*ncc],
		max,(int)r[(i+1)*ncc],(int)g[(i+1)*ncc],(int)b[(i+1)*ncc]);


#endif
      
    };

#ifdef VERBOSE
  fclose(outfile);

  printf("\tShowing the palette.\n");
  for(i=0;i<4;i++)
    tmpnam(&filename[i][0]);
  sprintf(tmp2,"grep MEASURE_UNIT $HOME/.gmtdefaults | wc -c > %s",&filename[0][0]);system(tmp2);
  infile=fopen(&filename[0][0],"r");fscanf(infile,"%i",&i);fclose(infile);
  infile=fopen(&filename[3][0],"w");fprintf(infile,"quit\n\n");fclose(infile);
  if(i == 21)
    sprintf(tmp2,"psscale  -C%s -D4.25/6.35/8.28/.2h -LTOPO -B\":Units:\" > %s",
	    OUTFILENAME,&filename[1][0]);
  else
    sprintf(tmp2,"psscale  -C%s -D10/10/18/2h  -LTOPO -B\":Units:\" > %s",
	    OUTFILENAME,&filename[1][0]);
  system(tmp2);


  sprintf(tmp2,"gs -q -r80 -sDEVICE=gif8 -sOutputFile=%s %s < %s", 
   	  &filename[2][0],&filename[1][0],&filename[3][0]); 
  system(tmp2); 
  sprintf(tmp2,"xv %s -rotate -90 -acrop & sleep 2",&filename[2][0]);system(tmp2); 

  /* sprintf(tmp2,"gs %s",&filename[1][0]);system(tmp2); */
  
  for(i=0;i<4;i++)
    {sprintf(tmp2,"rm %s",&filename[i][0]);system(tmp2);};
      

  printf("Done.\n\n");

#endif
}

