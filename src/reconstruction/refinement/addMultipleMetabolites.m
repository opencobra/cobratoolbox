function newmodel = addMultipleMetabolites(model,metIDs,varargin)
% Simultaneously add multiple metabolites. Allows the use of the field
% names of the model struct to specify additional properties of the
% metabolites added.
% USAGE:
%
%    model = addMultipleMetabolites(model,metIDs,varargin)
%
% INPUTS:
%    model:     The model to add the Metabolite batch to.
%    metIDs:    The metabolite IDs to add. No duplicate IDs may be provided
%               and no ID may be present in the supplied model.
%
% OPTIONAL INPUTS:
%    varargin:  fieldName, Value pairs. 
%               The given fields will be set according to the values. 
%               Only defined COBRA fields may be used. The S matrix will 
%               always be extended by the number of metabolites, but cannot 
%               be updated in this function. 
%               Examples: 
%               'metNames',{'Glucose';'Pyruvate'}            
%               'metCharges',[0;-2]
%               or any field name associated with mets 
%               (except for S ) as defined in the COBRA
%               Model field definitions or present in the model.
% OUTPUTS:
%
%    newmodel:     The model structure with the additional metabolites.
%
% EXAMPLE:
%
%    To add metabolites, with charges, formulas and KEGG ids:
%    model = addMultipleMetabolites(model,{'A','b','c'},'metCharges', [ -1 1
%    0], 'metFormulas', {'C','CO2','H2OKOPF'}, 'metKEGGID',{'C000012','C000023','C000055'})
%    

%Check, if there are either duplicate metabolite IDS to be added OR if
%any metabolite is already in the model.
if (any(ismember(model.mets,metIDs)) || numel(unique(metIDs)) < numel(metIDs))
    error('Duplicate Metabolite ID detected.');
end

nMets = numel(model.mets);

%We have make sure, that the new fields are in sync, so we create those
%first.
fieldDefs = getDefinedFieldProperties();
fieldDefs = fieldDefs(cellfun(@(x) strcmp(x,'mets'), fieldDefs(:,2)) | cellfun(@(x) strcmp(x,'mets'), fieldDefs(:,3)));
modelMetFields = getModelFieldsForType(model,'mets');

%First, add the metabolite IDs
model.mets = [model.mets;columnVector(metIDs)];

%Now, add the the data from the additional supplied fields
for field = 1:2:numel(varargin)
    %If the field does not exist and is not defined, we will not add that
    %information, as we don't know how th field should look.
    cfield = varargin{field};
    if strcmp('S',cfield) || (~any(ismember(fieldDefs(:,1),cfield)) && ~any(ismember(modelMetFields,cfield)))
        warning('Field %s is excluded',cfield);
        continue;
    end
    %Now add the field data. 
    if ~isfield(model,cfield)
        %If its not yet in the model, create it
        %according to its defaults and replace the final elements.
        model = createEmptyFields(model,cfield);    
        model.(cfield)((end-numel(varargin{field+1})+1):end) = columnVector(varargin{field+1});    
    else
        %Or just extend it with the supplied data.0
        model.(cfield) = [model.(cfield);columnVector(varargin{field+1})];    
    end    
    
end       

%Extend the remaining fields.
newmodel = extendModelFieldsForType(model,'mets','originalSize',nMets);
    
