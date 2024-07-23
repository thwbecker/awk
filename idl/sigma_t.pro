function sigma_t,s11,s12,s22,n,t

sum=double(0.0)

sum=((s12*(n(0) * t(1)+ n(1)* t(0)))+(s11* n(0) * t(0))+(s22* n(1) * t(1)))
     
return,sum
end
