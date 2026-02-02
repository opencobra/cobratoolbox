function [B, L] = greedyExtremeRayBasis(model,leftRight,internal)
% Computes a non-negative basis for the left nullspace of the stoichiometric
% matrix using optimization to pick random extreme rays, then test a
% posteriori if each is linearly independent from the existing stored
% extreme rays.
%
% USAGE:
%
%    [B, L] = greedyExtremeRayBasis(model) <=> [B, L] = greedyExtremeRayBasis(model,'left')
%    Gives B*N = 0 or B*S = 0
%    Gives L*N = 0 or L*S = 0
%
%    [B, L] = greedyExtremeRayBasis(model,'right')
%    Gives N*B = 0 or S*B = 0
%    Gives N*L = 0 or S*L = 0
%
%
% INPUT:
%    model.S:    m x n + k stoichiometric matrix, where n are internal reactions and k are exchange reactions
%
% OUTPUTS:
%    B: non-negative linear basis for the left (right) nullspace of N (internal = 1) or S (internal = 0)
%    L: linear basis for the left (right) nullspace of N (internal = 1) or S (internal = 0)

if ~exist('leftRight','var')
    leftRight = 'left';
end

if ~exist('internal','var')
    internal = 0;
end

if internal
    if ~isfield(model,'SConsistentRxnBool')
        [~, ~, ~, ~, ~, ~, model, ~] = findStoichConsistentSubset(model, 1, 0);
    end
end

if ~any(model.SConsistentRxnBool) %check if positive vector in left nullspace
    B=[];
    L=[]; % Returning empty vector for left nullspace so if it is expected matlab will keep running
    return;
end

if internal
    model.S = model.S(:,model.SConsistentRxnBool);
end

switch leftRight
    case 'right'
        model.S = model.S';
end

[nMet,nRxn]=size(model.S);

%compute linear basis for left nullspace
printLevelL=0;
[L,rankS]=getNullSpace(model.S',printLevelL);
L=L';

B=sparse(nMet-rankS,nMet);

nPools=0;
nTry=0;
t1 = tic;
while nPools < (nMet-rankS)
    %[x, sol] = findExtremePool(model, obj, printLevel, positive, internal)
    %% note internal already applied above
    obj = rand(nMet,1);
    [x, ~] = findExtremePool(model,obj,0,1);
    B(nPools+1,:)=x';
    if nPools==0
        rankB=1;
    else
        nonZeroColumns=(B~=0);
        nonZeroColumns=sum(nonZeroColumns,1);
        rankB = getRankLUSOL(B(1:nPools+1,nonZeroColumns~=0));
        % %error as reports wrong rank if zero columns
        % rankB = getRankLUSOL(B(1:nPools+1,:));
    end
    if rankB==(nPools+1)
        t2 = tic;
        nPools=nPools+1;
        fprintf('%s\n',[int2str(nPools) ' of ' int2str(nMet-rankS) ' linearly independent kernel rays, at time ' num2str(toc)]);
    else
        % fprintf('%s\n','Linearly dependent pool vector discarded');
    end
    nTry=nTry+1;
    if 1
        if  toc(t2)>10 || toc(t1) > 100
            %B=B(end-1,:);
            fprintf('%s%u%s\n','Only ',nPools, ' computed.');
            break
        end
    end
end
fprintf('%s%g\n','Hit fraction ',(nMet-rankS)/nTry);


switch leftRight
    case 'right'
        L= L';
        B= B';
end