# compute the eigenvalues of a symmetric 3x3 matrix
#
BEGIN{
    pi = 3.1415926535897932384626433832795;

}
{
    if((substr($1,1,1)!="#")&&(NF>=6)){
	cmd = sprintf("echo %20.15e  %20.15e  %20.15e  %20.15e  %20.15e  %20.15e | eigenvalues3ds",
		      $1,$2,$3,$4,$5,$6);
	cmd | getline evs
	split(evs,ev," ");
	print(ev[3],ev[2],ev[1]) # now in descending sorting
    }

}
