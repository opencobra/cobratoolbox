function [databases, identifiers, relations] = parseCVTerms(CVTerms)
% Extracts the annotations deposited in CVTerms in an SBML struct
%
% USAGE:
%
%    [databases, identifiers, relations] = parseCVTerms(CVTerms)
%
% INPUT:
%    CVTerms:       the CVTerms field of an SBML model field, struct array with fields:
%
%                     * .resources - cell array of resource URIs/URNs for the term
%                     * .qualifier - the bio-qualifier name for the term
%
% OUTPUT:
%    databases:       the databases stored in the resources of the CVTerms.
%    identifiers:     the identifiers annotated for the databases.
%    relations:       the bio-qualifier relation encoded in the CVTerms.
%
% .. Authors:
%       - Thomas Pfau, May 2017

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