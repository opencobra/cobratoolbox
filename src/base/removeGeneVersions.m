function [modelOut] = removeGeneVersions(model)
% removeGeneVersions Removes gene versions from a COBRA model and updates 
%                   model.genes, model.grRules, model.rules, and model.rxnGeneMat.
%
% USAGE:
%           modelOut = removeGeneVersions(model)
%
% INPUTS:
%   model - COBRA model structure with fields 'genes' and 'grRules'
%
% OUTPUTS:
%   modelOut - Updated model with gene versions removed.
%
% EXAMPLE:
%   - Gene versions are removed:    
%                 Input GPR:   {(857.1 and 34.1) or 45.1}
%                 Output GPR:  {(857 and 34) or 45}
%
%   - Duplicate genes are removed: 
%                 Input GPR:   {(857.1 and 451.1) or (857.2 and 451.2)}
%                 Output GPR:  {(857 and 451)}
%
% AUTHORS: Farid Zare, April 2025

if ~isfield(model, 'genes')
    error('Input model must have the "genes" field.');
end

% Initialize output as a copy of the input model
modelOut = model;

% Step 1: Strip version numbers from model.genes using regex
modelOut.genes = regexprep(model.genes, '\.\d+$', '');

% Step 2: Strip version numbers from model.grRules using a single regex pass
if isfield(model, 'grRules')
    modelOut.grRules = regexprep(model.grRules, '\.\d+', '');
else
    warning('The input model does not have the "grRules" field.');
end

% Step 3: Remove duplicate genes while preserving original order
[~, ia] = unique(modelOut.genes, 'stable');
modelOut.genes = modelOut.genes(sort(ia));

% Remove old 'rules' field (if it exists) to generate a new one
if isfield(modelOut, 'rules')
    modelOut = rmfield(modelOut, 'rules');
end

% Step 4: Rebuild rxnGeneMat using the updated gene list and grRules
modelOut = buildRxnGeneMat(modelOut);

% Parse the GPR rules into rational format
parsedGPR = GPRparser(modelOut);

% Convert the rational format to a cell array format
modelOut.grRules = buildGrRules(parsedGPR);

% Regenerate rules if needed: remove old 'rules' field and generate new ones
if isfield(modelOut, 'rules')
    modelOut = rmfield(modelOut, 'rules');
    modelOut = generateRules(modelOut);
end

end
