function testOK=testRank()
%tests the computation of the rank of a matrix using the LU solver termed
%LUSOL developed by Michael A. Saunders

%Ronan Fleming

load('iAF1260.mat')
A=model.S;
printLevel=1;
try
    [rankA,p,q] = getRankLUSOL(A,printLevel);
    if rankA~=1630
        testOK=0;
        warning('testRank: test of getRankLUSOL did not return the correct rank for iAF1260')
    else
        testOK=1;
    end
catch
    testOK=0;
end