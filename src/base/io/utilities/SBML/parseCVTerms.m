function [databases, identifiers, relations] = parseCVTerms(CVTerms)
%parseCVTerms extracts the annotations deposited in cvterms in an SBML struct
%
% USAGE:
%
%    [databases, identifiers, relations] = parseCVTerms(CVTerms)
%
% INPUT:
%
%    CVTerms:      the CVTerms field of an SBML model field 
%
% OUTPUT:
%
%    databases:     the databases stored in the ressources of the CVTerms.
%    identifiers:   The identifiers annotated for the databases.
%    relations:     The bio-qualifier relation encoded in the CVTerms.
%
% .. Authors:
%       - Thomas Pfau May 2017 

databases = {};
identifiers = {};
relations = {};
if isempty(CVTerms)
    return;
end
[databases,identifiers,relations] = cellfun(@getDataBases, {CVTerms.resources}, {CVTerms.qualifier},'UniformOutput',0);

databases = vertcat(databases{:});
identifiers = vertcat(identifiers{:});
relations = vertcat(relations{:});
end