function [Zpos, Z] = greedyExtremeRayBasis(model,param)
% Computes a non-negative basis for the left nullspace of the stoichiometric
% matrix using optimization to pick random extreme rays, then test a
% posteriori if each is linearly independent from the existing stored
% extreme rays.
%
% USAGE:
%
%    [L, Zt] = greedyExtremeRayBasis(model) <=> [B, L] = greedyExtremeRayBasis(model,'left')
%    Gives Zpos*N = 0 or Zpos*S = 0
%    Gives Z*N = 0 or Z*S = 0
%
%    [B, L] = greedyExtremeRayBasis(model,'right')
%    Gives N*Zpos = 0 or S*Zpos = 0
%    Gives N*Z = 0 or S*Z = 0
%
%
% INPUT:
%    model.S:    m x n + k stoichiometric matrix, where n are internal reactions and k are exchange reactions
%
% OUTPUTS:
%    Zpos : non-negative linear basis for the left (right) nullspace of N (internal = 1) or S (internal = 0)
%    Z    : linear basis for the left (right) nullspace of N (internal = 1) or S (internal = 0)

if ~exist('param','var')
    param = struct();
end

if ~isfield(param,'printLevel')
    param.printLevel = 1;
end

if ~isfield(param,'leftRight')
    param.leftRight = 'left';
end

if ~isfield(param,'internalStoichiometriMatrixLeftNullspace')
    param.internalStoichiometriMatrixLeftNullspace = 0;
end

if ~isfield(param,'maxNewBasisTime')
    param.maxTime = 100;
end
if ~isfield(param,'maxNewBasisTime')
    param.maxNewBasisTime = 10000;
end

if ~isfield(param,'feasTol')
    param.feasTol = 1e-6;
end


if param.internalStoichiometriMatrixLeftNullspace
    if ~isfield(model,'SConsistentRxnBool')
        [~, ~, ~, ~, ~, ~, model, ~] = findStoichConsistentSubset(model, 1, 0);
    end
end

if ~any(model.SConsistentRxnBool) %check if positive vector in left nullspace
    Zpos=[];
    Z=[]; % Returning empty vector for left nullspace so if it is expected matlab will keep running
    return;
end

if param.internalStoichiometriMatrixLeftNullspace
    model.S = model.S(:,model.SConsistentRxnBool);
end

switch param.leftRight
    case 'right'
        model.S = model.S';
end

[nVar,nRxn]=size(model.S);

%compute linear basis for left nullspace
printLevelL=0;
[Z,rankS]=getNullSpace(model.S',printLevelL);

Z=Z';

Zpos=sparse(nVar-rankS,nVar);



nBases=0;
nTry=0;
t1 = tic;
nfail=0;
nfailMax = 5;
while nBases < (nVar-rankS)
    if nBases<2
        obj = rand(nVar,1);
    else
        obj = rand(nVar,1);
        if nfail < nfailMax
            %zero out metabolites that already have support in left nullspace
            obj(nonZeroColumnsBool)=0;
        else
            if param.printLevel>1
                fprintf('%s\n',[int2str(nBases) ' of ' int2str(nVar-rankS) ' linearly independent kernel rays, at time ' num2str(round(toc)) ', not zeroing out, with ' num2str(nfail+1) ' attempt(s).']);
                %disp('not zeroing out metabolites that already have support in left nullspace');
            end
        end
    end
    positive = 1;
    [x, sol] = findExtremePool(model,obj,param.printLevel-2,positive);
    
    if contains(sol.origStat,'WARNING')
        nfail = nfailMax;
    end

    if norm(model.S'*x,inf) > param.feasTol
        continue
    end

    if positive && min(x)<0
        error('findExtremePool returned negative coefficient')
    end
    Zpos(nBases+1,:)=x';
    if nBases==0
        rankB=1;
    else
        nonZeroColumnsBool=(Zpos~=0);
        nonZeroColumnsBool=sum(nonZeroColumnsBool,1)~=0;
        rankB = getRankLUSOL(Zpos(1:nBases+1,nonZeroColumnsBool));
        % %error as reports wrong rank if zero columns
        % rankB = getRankLUSOL(B(1:nBases+1,:));
    end
    if rankB==(nBases+1)
        t2 = tic;
        nBases=nBases+1;
        if param.printLevel>1
            fprintf('%s\n',[int2str(nBases) ' of ' int2str(nVar-rankS) ' linearly independent kernel rays, at time ' num2str(round(toc)) ', with ' num2str(nfail+1) ' attempt(s).']);
        end
        nfail=0;
    else
        nfail = nfail+1;
        if param.printLevel>2
            fprintf('%s\n','Linearly dependent pool vector discarded');
        end
    end
    nTry=nTry+1;
    if  toc(t2)>param.maxNewBasisTime 
        disp('greedyExtremeRayBasis timed out. Increase param.maxNewBasisTime ?')
        break
    end
    if  toc(t1) > param.maxNewBasisTime
        disp('greedyExtremeRayBasis timed out. Increase param.maxNewBasisTime ?')
        break
    end
end

if param.printLevel>0
    if nBases == (nVar-rankS)
        fprintf('%u%s\n',nVar-rankS, ' extreme rays. Basis complete.');
        fprintf('%.2f%% nozero Zpos.\n', 100 * (nnz(Zpos) / (nVar * (nVar - rankS))));
        fprintf('%.2f%% nozero Z.\n', 100 * (nnz(Z) / (nVar * (nVar - rankS))));
    else
        fprintf('%u%s\n',nBases, ' extreme rays computed.');
        fprintf('%u%s\n',nVar-rankS, ' extreme rays required. Basis incomplete.');

    end
    fprintf('%s%g\n','Hit fraction ',(nVar-rankS)/nTry);
end

if param.printLevel>0
    fprintf('%s%g\n','|| S''*Zpos||_inf ',norm(Zpos*model.S,inf));
    fprintf('%s%g\n','|| S''*Z||_inf ',norm(Z*model.S,inf));
end

switch param.leftRight
    case 'right'
        Z= Z';
        Zpos= Zpos';
end


