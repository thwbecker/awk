function sigma_n,s11,s12,s22,n,t


sum=double(0.0)


sum=((n(0)^2 * s11)+(2.0 * n(0) * n(1) * s12)+(n(1)^2 * s22))
return,sum
end
