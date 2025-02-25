function model = loadMinimalWBM(modPath)
% This function loads the smallest possible combination of WBM model fields
% needed to perform FBA. Loading the minimal model can 
% decrease loading times by 6X.
%
% Author: Tim Hensen, November 2024

% Load model
model = load(modPath,'ID','S','ub','lb','rxns','mets','c','d','csense','dsense','osenseStr','sex', 'SetupInfo', 'C');

% If any fields are missing, load the full model
fieldsToCheck = {'ID','S','ub','lb','rxns','mets','c','d','csense','dsense','osenseStr', 'C'};
if any(~matches(fieldsToCheck,fieldnames(model)))
    % Load model
    model = load(modPath);
    % Check if model is a structured array or is nested
    if isscalar(fieldnames(model))
        model=model.(string(fieldnames(model)));
    end
end
end