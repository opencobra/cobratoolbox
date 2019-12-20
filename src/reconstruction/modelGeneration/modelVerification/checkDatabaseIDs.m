function results = checkDatabaseIDs(model,results)
% Checks the model for validity of database identifiers
%
% USAGE:
%
%    results = checkDatabaseIDs(model,results)
%
% INPUT:
%    model:       a structure that represents the COBRA model.
%    results:     the results structure for this test
%
% OUTPUT:
%
%    results:     a struct with problematic database ids added.
%
% .. Authors:
%       - Thomas Pfau, May 2017

dbMappings = getDefinedFieldProperties('Database',true);

for i= 1:size(dbMappings,1)
    if isfield(model,dbMappings{i,3})
        fits = cellfun(@(x) isempty(x) || checkID(x,dbMappings{i,5}),model.(dbMappings{i,3}));
        %Only add the something if we really have wrong IDs.
        if any(~fits)
            if ~isfield(results,'checkDatabaseIDs')
                results.checkDatabaseIDs = struct();
            end
            if ~isfield(results.checkDatabaseIDs,'invalidIDs')
                results.checkDatabaseIDs.invalidIDs = struct();
            end
            results.checkDatabaseIDs.invalidIDs.(dbMappings{i,3}) = cell(size(model.(dbMappings{i,3})));
            results.checkDatabaseIDs.invalidIDs.(dbMappings{i,3})(:) = {'valid'};
            results.checkDatabaseIDs.invalidIDs.(dbMappings{i,3})(~fits) = model.(dbMappings{i,3})(~fits);
        end
    end
end
end


function accepted = checkID(id,pattern)
% Checks the the given id(s), i.e. strings split by ; versus the pattern
%
% USAGE:
%
%    accepted = checkID(id,pattern)
%
% INPUT:
%    id:          A String representing ids (potentially separated by ;)
%    pattern:     The pattern to check the id(s) against.
%
% OUTPUT:
%
%    accepted:     Whether all ids are ok.
%
% .. Authors:
%       - Thomas Pfau, May 2017
ids = strsplit(id,';');
matches = regexp(ids,pattern);
accepted = all(~cellfun(@isempty,matches));
end
