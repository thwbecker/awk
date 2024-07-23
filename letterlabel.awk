BEGIN{
    if(makecap=="")
	makecap=0;
}
{
    string="abcdefghijklmnopqrstuvwxyz";
    n=$1;
    if($1>26){
	cap=1;
	n-=26;
    }else{
	cap=0;
    }
    if(n>26){
	print("error",n) > "/dev/stderr";
    }
    if(cap || makecap)
	print(toupper(substr(string,n,1)));
    else
	print(substr(string,n,1));
}
