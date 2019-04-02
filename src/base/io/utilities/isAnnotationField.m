function tf = isAnnotationField(fieldName, targetField)
% test whether a given fieldname is potentially an annotation field, i.e.
% whether it sticks to the format [basefieldType qualifier
% USAGE:
%    tf = isAnnotationField(fieldName)
%
% INPUT:
%    fieldName:         The field name to test
%
% OPTIONAL INPUT:
%    targetField:       the target field of the qualifier. Will restrict
%                       the options.
% OUTPUT:
%    tf:                Whether the field is a potential annotation field

bioQualifiers = getBioQualifiers();
if ~exist('targetField','var')
    typeFields = getCobraTypeFields();
else
    if ~iscell(targetField)
        targetField = {targetField};
    end
end

pat = ['((' strjoin(regexprep(typeFields,'s$',''),')|('),'))((' strjoin(bioQualifiers,')|(') ')).*ID$'];

tf = ~isempty(regexp(fieldName,pat,'once'));

