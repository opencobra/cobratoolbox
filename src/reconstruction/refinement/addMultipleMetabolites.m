function newmodel = addMultipleMetabolites(model, metIDs, varargin)
% Simultaneously add multiple metabolites. Allows the use of the field names of the model struct to specify additional properties of the metabolites added.
%
% USAGE:
%
%    newmodel = addMultipleMetabolites(model, metIDs, varargin)
%
% INPUTS:
%    model:         The model to add the Metabolite batch to.
%    metIDs:        The metabolite IDs to add. No duplicate IDs may be provided
%                   and no ID may be present in the supplied model.
%
% OPTIONAL INPUTS:
%    varargin:      fieldName, Value pairs with additional properties for the
%                   added metabolites. In addition, a 'printLevel' flag can be used (default: 0). 
%                   The given values fields will be set according to the values. 
%                   Only fields associated with mets defined in the COBRA definitions (except `S`) 
%                   or fields already in the model may be used.  
%                   Examples for this use would be:  
%
%                     * 'metNames',{'Glucose';'Pyruvate'}              
%                     * 'metCharges',[0;-2]  
%
% OUTPUTS:
%
%    newmodel:     The model structure with the additional metabolites.
%
% EXAMPLE:
%
%    % To add metabolites, with charges, formulas and KEGG ids:
%    model = addMultipleMetabolites(model,{'A','b','c'},'metCharges', [ -1 1 0], 'metFormulas', {'C','CO2','H2OKOPF'}, 'metKEGGID',{'C000012','C000023','C000055'})
%    

if numel(unique(metIDs)) < numel(metIDs)
    % check, if there are either duplicate metabolite IDS to be added OR if
    % any metabolite is already in the model.
    error('Duplicate Metabolite ID in the given IDs detected.');
end

if checkIDsForTypeExist(model,metIDs,'mets')
    % check, if there are either duplicate metabolite IDS to be added OR if
    % any metabolite is already in the model.
    [tf,dups] = checkIDsForTypeExist(model,metIDs,'mets');    
    if any(ismember(model.mets,dups))
        pres = ismember(model.mets,dups);        
        error('The following Metabolite ID(s) are already present in the model:\n%s',strjoin(model.mets(pres),'\n'));
    else
        error('The following Metabolite ID(s) are already present Ids of constraints in the model:\n%s',strjoin(dups,'\n'));
    end
end

nMets = numel(model.mets);

%We extract those fields which are either associated with the mets field
%(2nd or 3rd column contains 'mets' in the definitions), and we also look up which fields are in the model and
%associated with the mets field (from the sizes)
fieldDefs = getDefinedFieldProperties();
fieldDefs = fieldDefs(cellfun(@(x) strcmp(x,'mets'), fieldDefs(:,2)) | cellfun(@(x) strcmp(x,'mets'), fieldDefs(:,3)));
modelMetFields = getModelFieldsForType(model,'mets');

% extract additional parameters which are not fields (currently only
% printLevel
printLevel = 0;

for parameter = 1:2:numel(varargin)
    if strcmp(varargin{parameter},'printLevel')
        printLevel = varargin{parameter+1};
    end
end    

%Then we add the ids.
model.mets = [model.mets;columnVector(metIDs)];
if printLevel > 0
    fprintf('Adding the following Metabolites to the model:\n%s\n',strjoin(metIDs,'\n'));
end

%Now, add the the data from the additional supplied fields, and check that
%they are in sync
for field = 1:2:numel(varargin)
    %If the field does not exist and is not defined, we will not add that
    %information, as we don't know how the field should look.
    cfield = varargin{field};
    if strcmp('S',cfield) || (~any(ismember(fieldDefs(:,1),cfield)) && ~any(ismember(modelMetFields,cfield)))
        if printLevel > 0 && ~strcmp('printLevel',cfield)
            warning('Field %s is excluded',cfield);
        end
        continue;
    end
    %Now add the field data. 
    if ~isfield(model,cfield)
        %If its not yet in the model, create it
        %according to its defaults and replace the final elements.
        if printLevel > 2
            fprintf('Creating model field %s\n',cfield);
        end
        model = createEmptyFields(model,cfield);    
        model.(cfield)((end-numel(varargin{field+1})+1):end) = columnVector(varargin{field+1});    
    else
        %Or just extend it with the supplied data.0
        model.(cfield) = [model.(cfield);columnVector(varargin{field+1})];    
    end    
    
end       

%Extend the remaining fields, to keep the fields in sync
newmodel = extendModelFieldsForType(model,'mets','originalSize',nMets);
