function solverParams = mosekParamStrip(solverParams)
% Remove non-MOSEK parameters to avoid crashing the MOSEK solver interface
%
% USAGE:
%
%    solverParams = mosekParamStrip(solverParams)
%
% INPUTS:
%    solverParams:      Solver parameter structure with fields:
%
%                         * .timelimit - (optional) COBRA-style time limit in
%                           seconds; copied to `.MSK_DPAR_OPTIMIZER_MAX_TIME`
%                           before non-MOSEK fields are stripped
%                         * .MSK_DPAR_OPTIMIZER_MAX_TIME - (optional) MOSEK
%                           native time-limit parameter, set from `.timelimit`
%                           when the latter is present
%
% OUTPUTS:
%    solverParams:      Copy of the input structure retaining only fields
%                       whose name contains the substring `MSK_`, i.e. only
%                       recognised MOSEK-native parameters remain

if isfield(solverParams,'timelimit')
    solverParams.MSK_DPAR_OPTIMIZER_MAX_TIME = solverParams.timelimit;
end

% Get all field names
fieldNames = fieldnames(solverParams);

% Identify fields containing the pattern 'MSK_'
pattern = 'MSK_';
fieldsToRemove = fieldNames(~contains(fieldNames, pattern));

% Remove the identified fields
solverParams = rmfield(solverParams, fieldsToRemove);


end

