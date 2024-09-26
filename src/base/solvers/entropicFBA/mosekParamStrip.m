function solverParams = mosekParamStrip(solverParams)
% Remove non-modek parameters to avoid crashing solver interface

% Get all field names
fieldNames = fieldnames(solverParams);

% Identify fields containing the pattern 'MSK_'
pattern = 'MSK_';
fieldsToRemove = fieldNames(~contains(fieldNames, pattern));

% Remove the identified fields
solverParams = rmfield(solverParams, fieldsToRemove);


end

