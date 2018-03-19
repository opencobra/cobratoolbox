function newmodel = addMultipleMetabolites(model,metIDs,varargin)
%Add a batch of metabolites to the model.
% USAGE:
%
%    model = addMultipleMetabolites(model,metIDs,varargin)
%
% INPUTS:
%    model:     The model to add the Metabolite batch to.
%    metIDs:    The metabolite IDs to add
%    varargin:  fieldName, Value pairs. the given fields will be set
%               according to the values. Only defined COBRA fields may be
%               used. The S matrix will always be extended by the number of
%               metabolites, but cannot be updated in this function.
%               Varargin can also contain the parameter/Value pair
%               "checkDuplicate", with value true or false.
%
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


if numel(varargin) > 0 
    if any(ismember(varargin(1:2:end),'checkDuplicate'))
        checkDupPos = 2 * find(ismember(varargin(1:2:end),'checkDuplicate'));
        checkDuplicate = varargin{checkDupPos};
        varargin([checkDupPos-1,checkDupPos]) = []; %Remove the values.
    end   
end
  
if ~exist('checkDuplicate','var')
    checkDuplicate = true;
end

if checkDuplicate && (any(ismember(model.mets,metIDs)) || numel(unique(metIDs)) < numel(metIDs))
    error('Duplicate Metabolite ID detected.');
end

nMets = numel(model.mets);

%We have make sure, that the new fields are in sync, so we create those
%first.
fieldDefs = getDefinedFieldProperties();
fieldDefs = fieldDefs(cellfun(@(x) strcmp(x,'mets'), fieldDefs(:,2)) | cellfun(@(x) strcmp(x,'mets'), fieldDefs(:,3)));
modelMetFields = getModelFieldsForType(model,'mets');

%First, check which fields already exist, and create those which don't
%exist yet.

model.mets = [model.mets;columnVector(metIDs)];

for field = 1:2:numel(varargin)
    cfield = varargin{field};
    if strcmp('S',cfield) || (~any(ismember(fieldDefs(:,1),cfield)) && ~any(ismember(modelMetFields,cfield)))
        continue;
    end
    cfield = varargin{field};
    if strcmp('S',cfield) || (~any(ismember(fieldDefs(:,1),cfield)) && ~any(ismember(modelMetFields,cfield)))
        warning('Field %s is excluded',cfield);
        continue;
    end
    if ~isfield(model,cfield)
        model = createEmptyFields(model,cfield);    
        model.(cfield)((end-numel(varargin{field+1})+1):end) = columnVector(varargin{field+1});    
    else
        model.(cfield) = [model.(cfield);columnVector(varargin{field+1})];    
    end    
    
end       

%Extend the remaining fields.
newmodel = extendModelFieldsForType(model,'mets','originalSize',nMets);
    
