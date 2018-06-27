function returnedmappings = getDatabaseMappings(field,qualifiers)
% getDataBaseMappings returns information on known mappings of database
% entries to model field names, along with additional information about the
% fields.
%
% INPUT:
%
%    field:                 the basic model field to extract mappings for (e.g. 'met', 'gene', 'rxn')
%
% OPTIONAL INPUT:
%
%    qualifiers:            the qualifiers to restrict the selection to.
%                           These have to be part of the bioql modifiers
%                           definition (e.g. is, isDescribedBy, isEncodedBy
%                           etc) providing 'all' will return all associated 
%                           Database mappings. Default: 'all'
%
% OUTPUT:
%
%    returnedmappings:      The mappings known for the given field. The
%                           structure is:
%                           X{:,1} : the database ID (in identifiers.org/miriam annotation)
%                           X{:,2} : The qualifier associated with the DB
%                           X{:,3} : The model field associated with this db
%                           X{:,4} : The association field (met/rxn/gene/prot/comp)
%                           X{:,5} : The specified regular expression the identifier has to adhere to. 
%                           X{:,6} : The type of the qualifier (modelQualifier or bioQualifier)

if exist('qualifiers', 'var') && ...
    ((ischar(qualifiers) && isequal(qualifiers,'all')) || iscell(qualifiers) && any(ismember(qualifiers,'all')))
    %If it exists and either is 'all' or contains 'all', return all.
    qualifiers = 'all';
elseif ~exist('qualifiers','var')
    %if it doesn't exist also return all
    qualifiers = 'all';    
end

mappings = getDefinedFieldProperties('Database',true);

returnedmappings = mappings(strcmp(field,mappings(:,4)),:);
%If not all, restrict
if ~isequal(qualifiers,'all')
    returnedmappings = returnedmappings(ismember(returnedmappings(:,2),qualifiers),:);
end
