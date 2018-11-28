function [bioQualifier,dbName] = getBioQualifierAndDBFromFieldName(fieldName,type)
% extract the bioqualifier from a given field name knowning the type of
% field.
% USAGE:
%    bioqualifier = getBioQualifierFromDBField(fieldName,type)
%
% IPNUT:
%    fieldName:         The name of the field to extract the qualifier from.
% 
% OPTIONAL INPUT:
%    type:          	The type field (e.g. rxns, mets) the field belongs to.
%                       If not provided, will try to autodetect.
%
% OUTPUT:
%   bioQualifier:       The bioqualifier assoicated with the given field.
%   dbName:             The database name contained in this field.


if ~exist('type','var')
    types = union({'model'},getCobraTypeFields());    
    for i = 1:numel(types)
        type = regexprep(types{i},'s$','');        
        if strncmp(type,fieldName,length(type))
            % found the correct one
            break
        end
    end
end

type = regexprep(type,'s$',''); % remove a trailing s
if strncmp(fieldName,type,length(type))
    fieldName = fieldName(length(type)+1:end);
else
    error('The given fieldName does not match the given type.')
end

qualifiers = getBioQualifiers();
if strcmp(type,'model')
    qualifiers = [strcat('m',qualifiers),strcat('b',qualifiers)];
end
for qual = 1:numel(qualifiers)
    bioQualifier = qualifiers{qual};
    if strncmp(bioQualifier,fieldName,length(bioQualifier))
        %correct one found.
        if nargout < 2
            return
        else
            dbName = convertSBMLID(regexprep(fieldName,['^' bioQualifier '(.*)ID$'],'$1'),0);
            return
        end
    end
end
%if we are here, we failed.
error('The given field does not have a valid qualifier.')

