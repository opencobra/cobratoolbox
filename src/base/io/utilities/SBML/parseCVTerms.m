function [databases, identifiers, relations, types] = parseCVTerms(CVTerms)
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
%    databases:       The databases stored in the ressources of the CVTerms.
%    identifiers:     The identifiers annotated for the databases.
%    relations:       The bio-qualifier relation encoded in the CVTerms.
%    types:           The types of qualifiers ('biological' or 'model')
%
% .. Authors:
%       - Thomas Pfau May 2017 

databases = {};
identifiers = {};
relations = {};
types = {};

if isempty(CVTerms)
    return;
end
[databases,identifiers,relations,types] = cellfun(@getDataBases, {CVTerms.resources}, {CVTerms.qualifier}, {CVTerms.qualifierType},'UniformOutput',0);

types = vertcat(types{:});
databases = vertcat(databases{:});
identifiers = vertcat(identifiers{:});
relations = vertcat(relations{:});
end