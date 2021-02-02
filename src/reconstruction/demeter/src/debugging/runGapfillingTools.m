function [model,gapfilledRxns] = runGapfillingTools(model,objectiveFunction,biomassReaction,osenseStr,database)
% This function runs a set of gapfillling functions on a reconstruction to
% refined as part of the DEMETER pipeline. Reactions are filled in to
% enable flux through an objective function, e.g., the biomass objective
% function.
%
% USAGE:
%
%   [model,gapfilledRxns] = runGapfillingTools(model,objectiveFunction,biomassReaction,osenseStr,database)
%
% INPUTS
% model:               COBRA model structure
% objectiveFunction    Reaction ID of the objective function for which flux
%                      will be enabled through gapfilling
% biomassReaction:     Reaction ID of the biomass objective function that
%                      will be restored afterwards (if objectiveFunction is 
%                      not biomassReaction)
% osenseStr:           Maximize ('max')/minimize ('min') linear part of the 
%                      objective
% database:            rBioNet reaction database containing min. 3 columns:
%                      Column 1: reaction abbreviation, Column 2: reaction
%                      name, Column 3: reaction formula.
%
% OUTPUT
% model:               COBRA model structure
% gapfilledRxns:       Reactions that were added to enable flux throough
%                      the objective function
%
% .. Author:
%       - Almut Heinken, 2016-2020

tol=0.0000001;


model = changeObjective(model, objectiveFunction);
modelOld=model;

% Perform gapfilling to enable growth
model = conditionSpecificGapFilling(model, database);

% If model is still unable to grow-test exchanges based on targeted
% metabolite analysis
FBA = optimizeCbModel(model,osenseStr);
if abs(FBA.f) < tol
model = targetedGapFilling(model,osenseStr,database);
end

FBA = optimizeCbModel(model,osenseStr);
if abs(FBA.f) < tol
% if nothing else works-try adding reactions from entire database
model = untargetedGapFilling(model,osenseStr,database);
end

% test if gapfilled reactions are really needed
model = verifyGapfilledReactions(model,osenseStr);

% Save the gapfilled reactions
gapfilledRxns = {};
fgf = 1;
for n = 1:length(model.rxns)
    if ~isempty(strfind(model.rxns{n, 1}, '_GF'))
        gapfilledRxns{fgf, 1} = strrep(model.rxns{n}, '_GF', '');
        fgf = fgf + 1;
    end
end

% remove the "gapfilled" IDs
for n = 1:length(model.rxns)
    if ~isempty(strfind(model.rxns{n, 1}, '_GF'))
        removeGF = strsplit(model.rxns{n, 1}, '_GF');
        model.rxns{n, 1} = removeGF{1, 1};
        model.grRules{n, 1} = 'demeterGapfill';
    end
end

% if the changes make no difference, reverse the changes
FBA = optimizeCbModel(model,osenseStr);
if abs(FBA.f) < tol
    model=modelOld;
    gapfilledRxns={};
end

% change back to biomass reaction
model=changeObjective(model,biomassReaction);

% relax constraints-cause infeasibility problems
relaxConstraints=model.rxns(find(model.lb>0));
model=changeRxnBounds(model,relaxConstraints,0,'l');

% change back to unlimited medium
% list exchange reactions
exchanges = model.rxns(strncmp('EX_', model.rxns, 3));
% open all exchanges
model = changeRxnBounds(model, exchanges, -1000, 'l');
model = changeRxnBounds(model, exchanges, 1000, 'u');

end