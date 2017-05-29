function [databases, identifiers, relations] = parseCVTerms(CVTerms)
%CVTErms is a struct containing the fields qualifierType, qualifier,
%ressources. 
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