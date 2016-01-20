function x=testFASTCORE()
%test FASTCORE algorithm and returns 1 for correct, else 0
%

% Ronan Fleming, August 2015

if 0
    changeCobraSolver('quadMinos','LP')
end
if 1
    changeCobraSolver('gurobi6','LP')
end

%load a model
load('Recon205_20150515Consistent.mat')
model=modelConsistent;

%randomly pick some reactions
[nMet,nRxn]=size(model.S);

s = RandStream('mt19937ar','Seed',0);

coreInd=find(rand(s,nRxn,1)>0.1);

epsilon=1e-4;
printLevel=1;

A = fastcore(coreInd, model, epsilon, printLevel);

if numel(A)==6975
    %|J|=0  |A|=6975
    %CBTLPSOLVER = quadMinos
    x=1;
else
    x=0;
end
    