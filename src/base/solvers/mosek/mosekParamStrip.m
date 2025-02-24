function solverParams = mosekParamStrip(solverParams)
% Remove non-modek parameters to avoid crashing solver interface

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

