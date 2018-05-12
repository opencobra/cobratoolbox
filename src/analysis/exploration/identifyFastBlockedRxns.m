function [BlockedRxns] = identifyFastBlockedRxns(model,rxnList, printLevel)
% This function evaluates the presence of blocked reactions in a metabolic model
%
% USAGE:
%
%   [BlockedRxns] = identifyFastBlockedRxns(model,rxnList)
%
% INPUTS:
%   organisms:           model in COBRA model structure format
%   rxnList:             nx1 cell array with reactions to test
%   printLevel:          Verbose level (default: printLevel = 1)
%
% OUTPUT:
%   BlockedRxns:         nx1 cell array containing blocked reactions
%
% .. Author: Ines Thiele 2017-2018

if ~exist('printLevel', 'var')
    printLevel = 1;
end

Rxns2CheckF = rxnList;
L = length(Rxns2CheckF);

if printLevel > 0
    fprintf([' L = ' L '\n']);
end

Llast=L+1;
% do maximization
while L<Llast
    Llast = L;
    model.c=zeros(length(model.rxns),1);
    % Create an objective function with all the reactions of the model assigning them random coefficients in c vector
    model.c(find(ismember(model.rxns,Rxns2CheckF)))=rand(length(find(ismember(model.rxns,Rxns2CheckF))),1);
    solutionGF_O2 = optimizeCbModel(model,'max');
    % model.LPBasis = LPProblem.LPBasis;
    Rxns2Check = model.rxns;
    %Find reactions that carry flux (above solver tolerance)
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF);
    if printLevel > 0
       fprintf([' L = ' L '\n']);
    end
end

% do minimization
L = length(Rxns2CheckF);

if printLevel > 0
    fprintf([' L = ' L '\n']);
end

if L > 0
    Llast=L+1;
    while L<Llast
        Llast = L;
        model.c=zeros(length(model.rxns),1);
        % Create an objective function with all the reactions of the model assigning them random coefficients in c vector
        model.c(find(ismember(model.rxns,Rxns2CheckF)))=rand(length(find(ismember(model.rxns,Rxns2CheckF))),1);
        solutionGF_O2 = optimizeCbModel(model,'min');
        % model.LPBasis = LPProblem.LPBasis;
        Rxns2Check = model.rxns;
        %Find reactions that carry flux (above solver tolerance)
        Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
        Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
        L = length(Rxns2CheckF);
        if printLevel > 0
            fprintf([' L = ' L '\n']);
        end
    end
end
BlockedRxns=Rxns2CheckF;