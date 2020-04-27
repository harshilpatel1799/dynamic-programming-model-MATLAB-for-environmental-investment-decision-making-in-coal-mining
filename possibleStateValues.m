function stgTstatevarStvalues = possibleStageValues(S1,t)
% function to determine all possiple stage-t state var St values
   x=S1;
   for i = 1:t-1
       maxDec=max(feasibleDecisions(x));
       x=x+maxDec;
   end
    stgTstatevarStvalues= S1:0.05:x;
end