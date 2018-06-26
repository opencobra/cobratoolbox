function newmodel = addGenes(model,geneIDs,varargin)
% Add Genes (or a single gene) to the model 
%
% USAGE:
%    model = addGenes(model,geneIDs,varargin)
%
% INPUT:
%    model:             The model to add the Metabolite batch to.
%    geneIDs:           The IDs of the genes that shall be added.
%    varargin:          fieldName, Value pairs. The given fields will be set
%                       according to the values. Only defined COBRA fields may be
%                       used. The following fields will be ignored (as they
%                       are dependent on the existing model structure):
%
%                        * rxnGeneMat - The size will be extended, but no associations will be set. 
% OUTPUT:
%    newmodel:     The model structure with the additional reactions.
%
% EXAMPLE:
%    %To add genes with specific fields use:
%    `model = addGenes(model, {'G1', 'Gene2', 'InterestingGene'}, 'proteins', {'Protein1','Protein B','Protein Alpha'}, 'geneField2', {'D','E','F'})`
%
% NOTE:
%    All fields (geneField1/geneField2) have to be present in
%    the model, or defined in the field definitions, otherwise they are
%    ignored.
%    


if (isfield(model,'genes') && ~isempty(model.genes) && any(ismember(model.genes,geneIDs))) || numel(unique(geneIDs)) < numel(geneIDs)
    error('Duplicate Reaction ID detected.');
end

if ~isfield(model,'genes') % Should not happen but if, lets add it.
    model.genes = cell(0,1);
end  

nGenes = numel(model.genes);

%We have make sure, that the new fields are in sync, so we create those
%first.
fieldDefs = getDefinedFieldProperties();
fieldDefs = fieldDefs(cellfun(@(x) strcmp(x,'genes'), fieldDefs(:,2)) | cellfun(@(x) strcmp(x,'genes'), fieldDefs(:,3)));
modelGeneFields = getModelFieldsForType(model,'genes');
model.genes = [model.genes;columnVector(geneIDs)];

for field = 1:2:numel(varargin)
    %If the field does not exist and is not defined, we will not add that
    %information, as we don't know how the field should look.
    cfield = varargin{field};
    if strcmp('rxnGeneMat',cfield) || (~any(ismember(fieldDefs(:,1),cfield)) && ~any(ismember(modelGeneFields,cfield)))        
        warning('Field %s is excluded.',cfield);
        continue;
    end
    
    if ~any(size(varargin{field+1}) == numel(geneIDs)) %something must fit
        error('Size of field %s does not fit to the rxnList size', varargin{field});
    end
    %Now add the field data.     
    if ~isfield(model,cfield)
        %If its not yet in the model, create it
        %according to its defaults and replace the final elements.        
        model = createEmptyFields(model,cfield);    
        model.(cfield)((end-numel(varargin{field+1})+1):end) = columnVector(varargin{field+1});    
    else    
        %Or just extend it with the supplied data.        
        model.(cfield) = [model.(cfield);columnVector(varargin{field+1})];
    end    

        
end
%Extend the remaining fields, to keep the fields in sync
newmodel = extendModelFieldsForType(model,'genes','originalSize',nGenes);
