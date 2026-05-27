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


if isfield(model,'osenseStr') && ~isempty(model.osenseStr)
    osenseStr = model.osenseStr;
    % if osenseStr exists and not empty, it defines sense,
    % irrespectively of osense defined by user
    if strcmpi(osenseStr,'max') 
        osense = -1;
    elseif strcmpi(osenseStr,'min')
        osense = 1;
    else
        % if osenseStr is defined but it is neither 'min' or 'max',
        % and c does not exist or is all zeros, default is to min:
        if ~isfield(model,'c') || all(model.c==0)
            osense = 1;
            osenseStr = 'min';
        else
            error('Objective Sense must be either ''min'' or ''max'' ');
        end
    end
    return; % if osenseStr exists and not empty the above runs and following does not
end

% if osenseStr does not exist (the above does not run),
% but osense exists, sense is defined by osense
if isfield(model, 'osense') && ~isempty(model.osense)
    if model.osense == -1
        osense = -1;
        osenseStr = 'max';
    elseif model.osense == 1
        osense = 1;
        osenseStr = 'min';
    else
        error('Objective Sense must be either ''min'' or ''max'' ');
    end
    return;
end

% if neither osenseStr and osense is provided, set to default
osense = -1;
osenseStr = 'max';