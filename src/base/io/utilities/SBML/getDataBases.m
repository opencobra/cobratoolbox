function [databases,ids,qualifiers] = getDataBases(Ressource,qualifier)
%extract databases and ids from Ressources.
%Currently two different schemes are accepted: 
%urn:miriam:DatabaeID:EntryID
%http://identifiers.org/databaseid/EntryID
% For this IO, we will NOT check the annotations.
tokens = cellfun(@(x) regexp(x,'http://identifiers\.org/([^/]*)/(.*)','tokens'),Ressource);
if isempty(tokens)
    tokens = regexp(Ressource,'urn:miriam:([^:]*):(.*)','tokens');
end
databases = {};
ids = {};
if ~isempty(tokens)
    databases = columnVector(cellfun(@(x) x{1}, tokens,'UniformOutput',0));
    ids = columnVector(cellfun(@(x) x{2}, tokens,'UniformOutput',0));
    qualifiers = repmat({qualifier},numel(databases),1);
end

end