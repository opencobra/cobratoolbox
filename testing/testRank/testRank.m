load('iAF1260.mat')
A=model.S;
printLevel=1;
[rankA,p,q] = getRankLUSOL(A,printLevel);
if rankA~=1630
    warning('testRank: test of getRankLUSOL did not return the correct rank for iAF1260')
end