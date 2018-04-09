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


if (isfield(model,'genes') && any(ismember(model.genes,geneIDs))) || numel(unique(geneIDs)) < numel(geneIDs)
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
for field = 1:2:numel(varargin)
    cfield = varargin{field};
    if any(ismember({'rxnGeneMat'},cfield)) || (~any(ismember(fieldDefs(:,1),cfield)) && ~any(ismember(modelGeneFields,cfield)))        
        warning('Field %s is excluded.',cfield);
        continue;
    end    
    if ~isfield(model,cfield)
        model = createEmptyFields(model,cfield);    
    end    
    if ~any(size(varargin{field+1}) == numel(geneIDs)) %something must fit
        error('Size of field %s does not fit to the rxnList size', varargin{field});
    end
    model.(cfield) = [model.(cfield);columnVector(varargin{field+1})];    
end
model.genes = [model.genes;columnVector(geneIDs)];
newmodel = extendModelFieldsForType(model,'genes','originalSize',nGenes);
