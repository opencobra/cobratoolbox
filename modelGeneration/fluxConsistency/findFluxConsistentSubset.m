function [FConsistentMetBool,FConsistentRxnBool,FInConsistentMetBool,FInConsistentRxnBool,model] = findFluxConsistentSubset(model,epsilon,printLevel)
%finds the subset of S that is flux consistent using various algorithms,
%but fastcc from fastcore by default
%
%INPUT
% model
%    .S             m x n stoichiometric matrix
%
%OPTIONAL INPUT
% epsilon           (1e-4) minimum nonzero mass 
% printLevel
%
%OUTPUT
% FConsistentMetBool            m x 1 boolean vector indicating flux consistent mets
% FConsistentRxnBool            n x 1 boolean vector indicating flux consistent rxns
% FInConsistentMetBool          m x 1 boolean vector indicating flux inconsistent mets  
% FInConsistentRxnBool          n x 1 boolean vector indicating flux inconsistent rxns

if ~exist('epsilon','var')
    epsilon=1e-4;
end
if ~exist('printLevel','var')
    printLevel=1;
end

[mlt,nlt]=size(model.S);

modeFlag=0;

%find flux consistent subset using fastcc
[N,~,V] = fastcc(model,epsilon,printLevel,modeFlag);
FConsistentRxnBool=false(nlt,1);
FConsistentRxnBool(N)=1;

%get the corresponding rows
FConsistentMetBool = getCorrespondingRows(model.S,true(mlt,1),FConsistentRxnBool,'inclusive');

FInConsistentMetBool=~FConsistentMetBool;
FInConsistentRxnBool=~FConsistentRxnBool;

model.FConsistentMetBool=FConsistentMetBool;
model.FConsistentRxnBool=FConsistentRxnBool;
model.FInConsistentMetBool=FInConsistentMetBool;
model.FInConsistentRxnBool=FInConsistentRxnBool;

end

