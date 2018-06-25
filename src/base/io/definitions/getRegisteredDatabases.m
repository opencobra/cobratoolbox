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
    %Load from external site        
    dbs = webread('http://identifiers.org/rest/collections');        
    % extract relevant information
    dbnames = cellfun(@(x) x.name, dbs,'Uniform',0);
    dbpatterns = cellfun(@(x) x.pattern, dbs,'Uniform',0);
    dbprefix = cellfun(@(x) x.prefix, dbs,'Uniform',0);    
    %Collate as struct
    databases = struct('name',dbnames,'pattern',dbpatterns,'prefix',dbprefix);
end

identifiersDBs = databases;