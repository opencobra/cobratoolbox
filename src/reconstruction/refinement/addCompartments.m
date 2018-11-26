function model = addCompartments(model, compIDs, varargin)
% Add a set of compartments to the model. varargin are 'parameter',values pairs that can contain any existing
% field linked to comps, a field as defined by the Model field properties,
% or a valid annotation field with the correct syntax
% USAGE:
%    model = addCompartments(model, compIDs, varargin)
%
% INPUTS:
%    model:        The COBRA model to add the compartment to.
%    compIDs:      The IDs of the compartments to add
% 
% OPTIONAL INPUTS:
%    varargin:     'Parameter', value pairs, with parameter names
%                  representing model fields (either existing fields linked
%                  to comps, defined model fields, or valid annotation
%                  fields.
%                  'printLevel' is an additional parameter that can be
%                  supplied for verbose output (default 0);
%
% OUTPUT:
%    model:        The model with the added compartments.
%
% ..Author:     Thomas Pfau 2018


if numel(unique(compIDs)) < numel(compIDs)
    % check, if there are either duplicate metabolite IDS to be added OR if
    % any metabolite is already in the model.
    error('Duplicate compartment ID in the given IDs detected.');
end

if checkIDsForTypeExist(model,compIDs,'comps')
    % check, if there are either duplicate metabolite IDS to be added OR if
    % any metabolite is already in the model.
    [tf,dups] = checkIDsForTypeExist(model,compIDs,'comps');    
    if any(ismember(model.comps,dups))
        pres = ismember(model.comps,dups);        
        error('The following Compartment ID(s) are already present in the model:\n%s',strjoin(model.comps(pres),'\n'));    
    end
end

%We extract those fields which are either associated with the mets field
%(2nd or 3rd column contains 'mets' in the definitions), and we also look up which fields are in the model and
%associated with the mets field (from the sizes)
fieldDefs = getDefinedFieldProperties();
fieldDefs = fieldDefs(cellfun(@(x) strcmp(x,'comps'), fieldDefs(:,2)) | cellfun(@(x) strcmp(x,'comps'), fieldDefs(:,3)));
modelCompFields = getModelFieldsForType(model,'comps');

% extract additional parameters which are not fields (currently only
% printLevel
printLevel = 0;

for parameter = 1:2:numel(varargin)
    if strcmp(varargin{parameter},'printLevel')
        printLevel = varargin{parameter+1};
    end
end    
% get the number of original Compartments
nComps = numel(model.comps);

%Then we add the ids.
model.comps= [model.comps;columnVector(compIDs)];
if printLevel > 0
    fprintf('Adding the following Compartments to the model:\n%s\n',strjoin(compIDs,'\n'));
end

%Now, add the the data from the additional supplied fields, and check that
%they are in sync
for field = 1:2:numel(varargin)
    %If the field does not exist and is not defined, we will not add that
    %information, as we don't know how the field should look.
    cfield = varargin{field};
    isAnnotation = isAnnotationField(cfield,'comps');
    if ~isAnnotation && ~any(ismember(modelCompFields,cfield)) && ~any(ismember(fieldDefs,cfield))
        if printLevel > 0 && ~strcmp('printLevel',cfield)
            warning('Field %s is excluded',cfield);
        end
        continue;
    end
    % if its not a field of the model yet, add it.
    if ~isfield(model,cfield)
        if printLevel > 2
            fprintf('Creating model field %s\n',cfield);
        end
        if isAnnotation
            % if its an annotation field, we don't have a spec, but they
            % are in general the same.
            fieldSpec = makeFieldDefinition(cfield,'comps',1,'cell');
            model = createEmptyFields(model,cfield,fieldSpec);
        else
            model = createEmptyFields(model,cfield);
        end
        model.(cfield)((end-numel(varargin{field+1})+1):end) = columnVector(varargin{field+1});
    else
        model.(cfield) = [model.(cfield);columnVector(varargin{field+1})];
    end
    
end       

model = extendModelFieldsForType(model,'comps','originalSize',nComps);
