function returnedmappings = getDatabaseMappings(field,qualifiers)
%getDataBaseMappings returns known field -> uri mappings 
%INPUT 
%
% field:     the field to extract mappings for (e.g. 'mets', 'genes', 'rxns')
%
% OPTIONAL INPUT
%
% qualifiers: the qualifiers to restrict the selection to.
%
% OUTPUT
%
% returnedmappings:      The mappings known for the given field

mappings = getDefinedFieldProperties('Database',true);

returnedmappings = mappings(strcmp(field,mappings(:,4)),:);
if nargin > 1
    returnedmappings = returnedmappings(ismember(returnedmappings(:,2),qualifiers),:);
end
