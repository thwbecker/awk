BEGIN{vfac=3600.0*24.0*365.25*100.;
    sph=-1;
    cig=0;solver=0;
}{
    if(substr($1,1,1)!="#"){
	for(i=1;i<=NF;i++){
	    if(substr($i,1,1)!="#"){
		if(match($i,"nodex=")){split($i,a,"=");nodex=a[2];}
		if(match($i,"nodey=")){split($i,a,"=");nodey=a[2];}
		if(match($i,"nodez=")){split($i,a,"=");nodez=a[2];}
		if(match($i,"restart=")){split($i,a,"=");if((a[2]=="on")||(a[2]==1))restart=1;else if(a[2]=="off")restart=0;else restart=a[2];}
		if(match($i,"tic_method=")){split($i,a,"=");tic_method=a[2];}
		if(match($i,"solution_cycles_init=")||match($i,"restart_timesteps=")){split($i,a,"=");sinit=a[2];}
		if(match($i,"nproc_surf=")){split($i,a,"=");nproc_surf=a[2];}
		if(match($i,"nprocx=")){split($i,a,"=");nprocx=a[2];}
		if(match($i,"nprocy=")){split($i,a,"=");nprocy=a[2];}
		if(match($i,"nprocz=")){split($i,a,"=");nprocz=a[2];}
		if(match($i,"mgunitx=")){split($i,a,"=");mgunitx=a[2];}
		if(match($i,"mgunity=")){split($i,a,"=");mgunity=a[2];}
		if(match($i,"mgunitz=")){split($i,a,"=");mgunitz=a[2];}
		if(match($i,"minstep=")){split($i,a,"=");tstepmin=a[2];}
		if(match($i,"maxstep=")){split($i,a,"=");tmax=a[2];}
		if(match($i,"storage_spacing=")){split($i,a,"=");dt=a[2];}
		if(match($i,"thermdiff=")){split($i,a,"=");diff=a[2];}
		if(match($i,"layerd=")){split($i,a,"=");layerd=a[2];}
		if(match($i,"radius=")){split($i,a,"=");radius=a[2];}
		if(match($i,"levels=")){split($i,a,"=");levels=a[2];}    
		if(match($i,"rheol=")){split($i,a,"=");rheol=a[2];}    
		if(match($i,"Solver=")){split($i,a,"=");if(a[2]=="cgrad")solver=1;}
		if(match($i,"Geometry=")){
		    split($i,a,"=");geom=a[2];
		    if(geom=="Rsphere")sph= 1;else 
			if(geom=="sphere") sph=-1;else sph=0;}
	    }
	}
    }
    if(match($0,"CIG"))cig = 1;
}END{
    if(cig){
	if(sph==-1)sph=-2;
    }
    if(layerd=="")
	layerd=radius;
    if(nproc_surf==0)nproc_surf=1;
    printf("%i %i %i %i %i %i %i %15.7e %15.7e %15.7e %i %i %i %i %i %i %i %i %i %i %i %i %i %i\n",
	   nodex,nodey,nodez,nproc_surf,tstepmin,dt,tmax,
	   layerd,diff,diff/layerd*vfac,
	   nproc_surf,restart,sinit,nprocx,nprocy,nprocz,
	   levels,mgunitx,mgunity,mgunitz,sph,rheol,tic_method,solver);
 }
 
