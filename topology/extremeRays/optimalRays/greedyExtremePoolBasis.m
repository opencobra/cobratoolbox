function [B,L] = greedyExtremePoolBasis(model)
% compute a non-negative basis for the left nullspace of the stoichiometric
% matrix using optimization to pick random extreme rays, then test a
% posteriori if each is linearly independent from the existing stored
% extreme rays. 

%check stoichiometric consistency
%check if positive vector in left nullspace
[inform,molecularVector]=checkStoichiometricConsistency(model,0);
if inform~=1
    B=[];
    return;
end

[nMet,nRxn]=size(model.S);

%compute linear basis for left nullspace
printLevelL=0;
[L,rankS]=getNullSpace(model.S',printLevelL);
L=L';

B=sparse(nMet-rankS,nMet);

nPools=0;
nTry=0;
tic;
while nPools < (nMet-rankS)
    [x, output] = findExtremePool(model);
    B(nPools+1,:)=x';
    if nPools==0
        rankB=1;
    else
        if 1
            nonZeroColumns=(B~=0);
            nonZeroColumns=sum(nonZeroColumns,1);
            rankB = getRankLUSOL(B(1:nPools+1,nonZeroColumns~=0));
        else
            %error as reports wrong rank if zero columns
            rankB = getRankLUSOL(B(1:nPools+1,:));
            %pause(eps)
        end
    end
    if rankB==(nPools+1)
        nPools=nPools+1;
        fprintf('%s\n',[int2str(nPools) ' of ' int2str(nMet-rankS) ' linearly independent pool vectors, at time ' num2str(toc)]);
    else
        %fprintf('%s\n','Linearly dependent pool vector discarded');
    end
    nTry=nTry+1;
    if toc > 100
        B=B(end-1,:);
        fprintf('%s%u%s\n','Only ',nPools, ' computed.');
        break
    end
end
fprintf('%s%g\n','Hit fraction ',(nMet-rankS)/nTry);

