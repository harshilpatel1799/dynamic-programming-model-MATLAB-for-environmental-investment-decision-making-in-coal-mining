function investmentCost = costFunction(St,Pt,Et,r,I,Xt,t)
% 
    LOt=Xt*I;
    PNt=max(0,(Et-St)*Pt);
    investmentCost= (LOt+PNt)/(1+r)^t;
end