function newmodel = addReactionBatch(model,rxnIDs,metList,Stoichiometries,varargin)
%Add a batch of metabolites to the model.
% USAGE:
%
%    model = addMetaboliteBatch(model,metIDs,varargin)
%
% INPUTS:
%    model:             The model to add the Metabolite batch to.
%    rxnIDs:            The IDs of the reactions that shall be added.
%    metList:           A list of metabolites for which stoichiometric coefficients are given
%    Stoichiometries:   A Stoichiometric matrix of dimension
%                       numel(metList) x numel(rxnID). 
%    varargin:          fieldName, Value pairs. The given fields will be set
%                       according to the values. Only defined COBRA fields may be
%                       used. The S Matrix may not be given.
%
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

[metPres,metPos] = ismember(metList,model.mets);
if any(metPos == 0)
    error('The following Metabolites are not part of the model:\n%s',strjoin(metList(metPos==0)));
end
 
if any(ismember(model.rxns,rxnIDs)) || numel(unique(rxnIDs)) < numel(rxnIDs)
    error('Duplicate Reaction ID detected.');
end

if numel(unique(metList)) < numel(metList)
    error('Duplicate Metabolite ID detected.');
end

nRxns = numel(model.rxns);

%We have make sure, that the new fields are in sync, so we create those
%first.
fieldDefs = getDefinedFieldProperties();

for field = 1:2:numel(varargin)
    cfield = varargin{field};
    if strcmp('S',cfield) || (~any(ismember(fieldDefs(:,1),cfield)) && ~isfield(model,cfield))
        warning('Field %s is excluded');
        continue;
    end
    if ~isfield(model,cfield)
        model = createEmptyFields(model,cfield);    
    end    
    model.(cfield) = [model.(cfield);columnVector(varargin{field+1})];    
end
model.rxns= [model.rxns;columnVector(rxnIDs)];
newmodel = extendModelFieldsForType(model,'rxns','originalSize',nRxns);
%Now, we have extended the S matrix. So lets fill it.
newmodel.S(metPos,(nRxns+1):end) = Stoichiometries;
    

