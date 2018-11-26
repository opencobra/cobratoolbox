function  [typeFields,longNames] = getCobraTypeFields()
% Get the Type fields defined in the COBRA toolbox (e.g. rxns, mets, etc)
% USAGE:
%    typeFields = getCobraTypeFields()
%
% OUTPUT:
%    typeFields:        A cell array of strings for the type fields.
%    longNames:         More descriptive long names of the fields.
%

fieldProps = getDefinedFieldProperties();
typeFields = fieldProps([fieldProps{:,9}],1);
longNames = fieldProps([fieldProps{:,9}],10);

