function [essentialRxns]=essentialRxnsTasks(model)
%   Calculate the minimal number of reactions needed to be active for each
%   task using Parsimoneous enzyme usage Flux Balance Analysis
%
%   model                   a model structure
%
%   essentialRxns           cell array with the names of the essential
%                           reactions for the task
%   
%
%   Essential reactions are those which, when constrained to 0, result in an
%   infeasible problem.
%
%   Usage: [essentialRxns]=essentialRxnsTasks(model)
%
%   Originally written for RAVEN toolbox by
%   Rasmus Agren, 2013-11-17
%   Adapted for cobratoolbox and modified to rely on pFBA by
%   Richelle Anne, 2017-05-18

    %Compute the minimal set of reactions
	[solMin modelIrrevFM]= minimizeModelFlux_local(model);
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

function [ MinimizedFlux modelIrrev]= minimizeModelFlux_local(model)
% This function finds the minimum flux through the network and returns the
% minimized flux and an irreversible model
    % Convert the model to amodel with only irreversible reactions
    modelIrrev = convertToIrreversible(model);

    % Add a pseudo-metabolite to measure flux through network
    modelIrrev.S(end+1,:) = ones(size(modelIrrev.S(1,:)));
    modelIrrev.b(end+1) = 0;
    modelIrrev.mets{end+1} = 'fluxMeasure';
    
    % Add a pseudo reaction that measures the flux through the network
    modelIrrev = addReaction(modelIrrev,'netFlux',{'fluxMeasure'},[-1],false,0,inf,0,'','');
    
    % Set the flux measuring demand as the objective
    modelIrrev.c = zeros(length(modelIrrev.rxns),1);
    modelIrrev = changeObjective(modelIrrev, 'netFlux');
    
    % Minimize the flux measuring demand (netFlux)
    MinimizedFlux = optimizeCbModel(modelIrrev,'min');

end