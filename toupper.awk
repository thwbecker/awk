BEGIN{
}{
    for(i=1;i<=NF;i++){
	printf("%s ",toupper($i));
    }
    printf("\n");
}
