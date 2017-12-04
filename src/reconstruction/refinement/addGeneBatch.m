function newmodel = addGeneBatch(model,geneIDs,varargin)
%Add a batch of genes to the model.
% USAGE:
%
%    model = addMetaboliteBatch(model,metIDs,varargin)
%
% INPUTS:
%    model:             The model to add the Metabolite batch to.
%    geneIDs:           The IDs of the genes that shall be added.
%    varargin:          fieldName, Value pairs. The given fields will be set
%                       according to the values. Only defined COBRA fields may be
%                       used. The following fields will be ignored (as they
%                       are dependent on the existing model structure):
%                       rxnGeneMat - The size will be extended, but no associations will be set. 
% OUTPUTS:
%
%    newmodel:     The model structure with the additional reactions.
%
% EXAMPLE:
%
%    To add metabolites, with charges, formulas and KEGG ids:
%    model = addMetaboliteBatch(model,{'A','b','c'},'metCharges', [ -1 1
%    0], 'metFormulas', {'C','CO2','H2OKOPF'}, 'metKEGGID',{'C000012','C000023','C000055'})
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
        warning('Field %s is excluded.');
        continue;
    end    
    if ~isfield(model,cfield)
        model = createEmptyFields(model,cfield);    
    end    
    model.(cfield) = [model.(cfield);columnVector(varargin{field+1})];    
end
model.genes = [model.genes;columnVector(geneIDs)];
newmodel = extendModelFieldsForType(model,'genes','originalSize',nGenes);
