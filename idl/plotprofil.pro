close,1
openr,1,'disp_profil1'
readf,1,n
d1=dblarr(4,n)
readf,1,d1
close,1

openr,1,'disp_profil2'
readf,1,n
d2=dblarr(4,n)
readf,1,d2
close,1

set_plot,'X'
plot,d1plot,d1(0,*),d1(2,*),psym=7

end