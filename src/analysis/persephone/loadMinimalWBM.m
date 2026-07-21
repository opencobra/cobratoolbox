function model = loadMinimalWBM(modPath)
% Load the smallest combination of WBM model fields needed to perform FBA
%
% Loading only the minimal set of fields can reduce model loading times by
% roughly 6x compared with loading the full model. If any of the required
% fields are missing from the stored file, the complete model is loaded
% instead.
%
% USAGE:
%
%    model = loadMinimalWBM(modPath)
%
% INPUT:
%    modPath:    char or string, path to the `.mat` file that stores the
%                whole-body metabolic (WBM) model
%
% OUTPUT:
%    model:      struct, the loaded WBM model. It contains at least the fields
%                `ID`, `S`, `ub`, `lb`, `rxns`, `mets`, `c`, `d`, `csense`,
%                `dsense`, `osenseStr`, and `C` (with `sex` and `SetupInfo`
%                added when the minimal load succeeds)
%
% .. Author: - Tim Hensen, November 2024

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