function [databases,ids,qualifiers] = getDataBases(Ressources,qualifier)
%getDataBases extracts database and correspdoning id from a ressource string in an sbml
% USAGE:
%
%       [databases,ids,qualifiers] = getDataBases(Ressource,qualifier)
%
% INPUT:
%
%    Ressources:    The Ressource String(s) as a cell array
%    qualifier:     The bio-qualifier of the ressource
%
% OUTPUT:
%
%    databases:    The databases of the ressources
%    ids:          The identifiers of the ressource strings
%    qualifier:    The bio-qualifiers associated (the same as the input)
%
% .. Authors:
%       - Thomas Pfau May 2017
%
% NOTE:
%  Currently two different schemes are accepted:
%  urn:miriam:DatabaeID:EntryID
%  https://identifiers.org/databaseid/EntryID
%  The correctness of the entries is NOT checked!

try
    %Try to parse identifiers.org ids. if this doesn't work leave them
    %empty.
    tokens = cellfun(@(x) regexp(x,'http://identifiers\.org/([^/]*)/(.*)','tokens'),Ressources);
catch
    tokens = {};
end
if isempty(tokens)
    try
        %Try parsing urn.miriam IDs. if this doesn't work leave them empty.
        tokens = cellfun(@(x) regexp(x,'urn:miriam:([^:]*):(.*)','tokens'),Ressources);
    catch
        tokens = {};
    end
end
databases = {};
ids = {};
if ~isempty(tokens)
    databases = columnVector(cellfun(@(x) x{1}, tokens,'UniformOutput',0));
    ids = columnVector(cellfun(@(x) x{2}, tokens,'UniformOutput',0));
    qualifiers = repmat({qualifier},numel(databases),1);
end

end
