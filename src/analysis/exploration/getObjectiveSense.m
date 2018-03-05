function [osenseStr,osense] = getObjectiveSense(model)
% Get the objective sense of the model (both the osenseStr ('max' or 'min')
% and the correspdoning osense value (-1 or 1)
%
% USAGE:
%    [osenseStr,osense] = getObjectiveSense(model)
%
% INPUTS:
%    model:     The model to obtain the sense for. If the model has a
%               osenseStr field, it has to be either 'min' or 'max' (case
%               insensitive) otherwise this function will error.
%
% OUTPUS:
%    osenseStr:     'min' or 'max'
%    osense:        1 or -1;
%
%

if isfield(model,'osenseStr')
    osenseStr = model.osenseStr;
else
    osenseStr = 'max'; %Default is maximisation
end

if ~strcmpi(osenseStr,'max') && ~strcmpi(osenseStr,'min')
    error('Objective Sense must be either ''min'' or ''max'' ');
else
    if strcmpi(osenseStr,'max')
        osense = -1;
    else
        osense = 1;
    end
end