{
    if(NR==1){
	print($1,$2);

    }else{
	print($1-1e-6,vold);
	print($1,$2);
    }
    vold=$2;    
}
END{
    print(1,vold)
}
