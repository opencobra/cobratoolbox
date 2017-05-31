function [essentialRxns] = essentialRxnsTasks(model)
% Calculates the minimal number of reactions needed to be active for each
% task using Parsimoneous enzyme usage Flux Balance Analysis
%
% USAGE:
%
%    [essentialRxns] = essentialRxnsTasks(model)
%
% INPUT:
%    model:            a model structure
%
% OUTPUT:
%    essentialRxns:    cell array with the names of the essential
%                      reactions for the task
%
% NOTE:
%
%    Essential reactions are those which, when constrained to 0, result in an
%    infeasible problem.
%
% .. Authors:
%   		- Originally written for RAVEN toolbox by Rasmus Agren, 2013-11-17
%   		- Adapted for cobratoolbox and modified to rely on pFBA by Richelle Anne, 2017-05-18

	[solMin modelIrrevFM]= minimizeModelFlux(model); %Compute the minimal set of reactions
	modelIrrevFM = changeRxnBounds(modelIrrevFM,'netFlux',solMin.f,'b');

    %Define the list of reactions to test
	rxnsToCheck=modelIrrevFM.rxns(abs(solMin.x)>10^-6);

    % Loop that set to 0 each reaction to test and check if the problem
    % still has a solution
	essentialRxns={};
    for i=1:numel(rxnsToCheck)
        modelIrrevFM.lb(findRxnIDs(modelIrrevFM,rxnsToCheck(i)))=0;
        modelIrrevFM.ub(findRxnIDs(modelIrrevFM,rxnsToCheck(i)))=0;
        modelIrrevFM.csense(1:length(modelIrrevFM.mets),1) = 'E';
        modelIrrevFM.osense = -1;
        modelIrrevFM.A=modelIrrevFM.S;
        sol=solveCobraLP(modelIrrevFM);

       if sol.stat==0 || isempty(sol.full)
           essentialRxns=[essentialRxns;rxnsToCheck(i)];
       end
    end

    rxns_kept=unique(essentialRxns);
    rxns_final={};

    %% Analysis part
    for i=1: length(rxns_kept)
        string=rxns_kept{i};
        if strcmp('_f', string(end-1:end))==1
            rxns_final{i}= string(1:end-2);
        elseif strcmp('_b', string(end-1:end))==1
            rxns_final{i}= string(1:end-2);
        elseif strcmp('_r', string(end-1:end))==1
            rxns_final{i}= string(1:end-2);
        else
            rxns_final{i}=string;
        end
    end
    essentialRxns=unique(rxns_final);
end