function cstress,t,n,myu,hp,off
sum=double(0.0)
sum = abs(t) - myu * (n+hp) - off
return,sum
end
