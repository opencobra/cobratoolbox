function [OptExchRxns] = findOptExchRxns(model,Ex_Rxns,parFVA)
% USAGE:
%
%    [OptExchRxns] = findOptExchRxns(model, Ex_Rxns, parFVA)
%
% INPUTS:
%    model:         Metabolic model
%    Ex_Rxns:       Vector of exchange reactions for FVA
%    fastFVA:       use FastFVA (default=0)
%
% OUTPUTS:
%    OptExchRxns:
%
% .. Authors:
%       - Ines Thiele 2014
%       - Maike K. Aurich 27/05/15, remove hidden values 

tol = -1e-6;  % Default tolerance

if ~exist('parFVA','var') || parFVA == 0
   
    matlabpool = 0;
    parFVA = 0; % default no parallelization of FVA
end
    

[a1(:,1),a1(:,2)]=fluxVariability(model,1,[],Ex_Rxns);
% find all uptakes that have ub=0;
if size(a1,1)==length(Ex_Rxns)
    OptSecr = Ex_Rxns;
    R = OptSecr(find(a1(:,2)<abs(tol)));
    R = [R; OptSecr(find(a1(:,1)>abs(tol)))];
    OptSecr(ismember(OptSecr, R))=[];% remove obligate uptake
    clear R
    OptUptake = Ex_Rxns;
    R = OptUptake(find(a1(:,2)<(tol)));
    R = [R; OptUptake(find(a1(:,1)>(tol)))];
    OptUptake(ismember(OptUptake, R))=[];% remove obligate uptake
    OptExchRxns = [OptUptake;OptSecr];
else
    OptExchRxns=[];
end
