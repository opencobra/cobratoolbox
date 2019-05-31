function identifiersDBs = getRegisteredDatabases()
% Get all databases registered with identifiers.org along with their
% pattern and and prefix data.
%
% USAGE:  
%    identifiersDBs = getRegisteredDatabases()
%
% OUPUTS:
%    identifiersDBs:        A Struct with data on each database registered
%                           with identifiers.org (needs web access).
%                           The struct will have the following fields:
%                            * .name:       The name of the database
%                            * .pattern:    A regexp pattern allowed with the db.
%                            * .prefix:     The prefix of the db on identifiers.org

persistent databases

if isempty(databases)
    % load from external site        
    try
        dbs = webread('https://registry.api.identifiers.org/resolutionApi/getResolverDataset');        
    catch
        error('Could not load the databases registered with identifiers.org.\nThis is likely due to a missing internet connection.\nPlease try this again later');
    end
    dbs = dbs.payload.namespaces;
    % extract relevant information
    dbnames = {dbs.name};
    dbpatterns = {dbs.pattern};
    dbprefix = {dbs.prefix};    
    % collate as struct
    databases = struct('name',dbnames,'pattern',dbpatterns,'prefix',dbprefix);
end

identifiersDBs = databases;