function  [typeFields,longNames] = getCobraTypeFields()
% Get the Type fields defined in the COBRA toolbox (e.g. rxns, mets, etc)
% USAGE:
%    typeFields = getCobraTypeFields()
%
% OUTPUT:
%    typeFields:        A cell array of strings for the type fields.
%    longNames:         More descriptive long names of the fields.
%

persistent types
persistent names

if isempty(types)
    fieldProps = getDefinedFieldProperties();
    types = fieldProps([fieldProps{:,9}],1);
    names = fieldProps([fieldProps{:,9}],10);
end
typeFields = types;
longNames = names;

