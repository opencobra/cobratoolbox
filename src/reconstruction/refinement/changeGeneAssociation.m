function model = changeGeneAssociation(model, rxnName, grRule, geneNameList, systNameList, addRxnGeneMat)
% Change gene associations in a model
%
% USAGE:
%
%    model = changeGeneAssociation(model, rxnName, grRule, geneNameList, systNameList, addRxnGeneMat)
%
% INPUTS:
%    model:            COBRA Toolbox model structure with fields:
%
%                         * .rxns - `n x 1` cell array of reaction identifiers
%                         * .genes - `g x 1` cell array of gene identifiers
%                         * .rules - `n x 1` cell array of evaluatable GPR rules
%                         * .rxnGeneMat - (optional) `n x g` reaction-gene incidence matrix
%    rxnName:          Name of the new reaction
%    grRule:           Gene-reaction rule in boolean format (and/or allowed)
%
% OPTIONAL INPUTS:
%    geneNameList:     List of gene names (used only for translation from
%                      common gene names to systematic gene names)
%    systNameList:     List of systematic names
%    addRxnGeneMat:    adds rxnGeneMat to model structure (default = true)
%
% OUTPUT:
%    model:            COBRA Toolbox model structure with new gene reaction associations
%
% NOTE:
%
%    Feature 20261125-161147-blocker-fixes-two, 2026-11-25: three fixes of the 2017
%    refactoring to `parseGPR`, restoring the earlier behaviour.
%
%      * New genes extend every other gene field (`proteins`, `geneNames`, ...)
%        with its default value. Before, these fields stayed shorter than `genes`.
%      * With `geneNameList` and `systNameList`, each gene name of `grRule` is
%        translated by its own position in `geneNameList` (a name not in the list
%        is kept) before it is looked up in `model.genes`, so a translated gene
%        that is already in the model is reused. Before, the systematic names
%        were taken from the wrong positions, or the call stopped with an
%        indexing error.
%      * A requested `rxnGeneMat` that the model lacks is created as `n x g`
%        (reactions x genes). Before, it had one row per reaction up to the
%        changed one.
%
% .. Authors:
%       - Markus Herrgard 1/12/07
%       - Ines Thiele 08/03/2015, made rxnGeneMat optional
%       - IT: updated the nargin statement to accommodate the additional option

if (exist('geneNameList','var') && ~isempty(geneNameList)...
        && exist('systNameList','var') && ~isempty(systNameList))
    translateNamesFlag = true;
else
    translateNamesFlag = false;
end

if ~exist('addRxnGeneMat','var')
    if isfield(model,'rxnGeneMat')
        addRxnGeneMat = 1;
    else
        addRxnGeneMat = 0;
    end
end

[isInModel,rxnID] = ismember(rxnName,model.rxns);

if (~isInModel)
    error(['Reaction ' rxnName ' not in the model']);
end

if ~isfield(model,'genes')
    model.genes = {};
end

nGenes = length(model.genes);
nGenesInit = nGenes;
if (~isfield(model, 'rules') && isfield(model, 'grRules'))
    model = generateRules(model);
elseif (~isfield(model, 'rules') && ~isfield(model, 'grRules'))
    model.rules = repmat({''}, size(model.rxns));
end
model.rules{rxnID,1} = '';
if addRxnGeneMat ==1 
    if ~isfield(model,'rxnGeneMat')
        % a requested rxnGeneMat is created with one row per reaction (reactions x genes)
        model.rxnGeneMat = sparse(numel(model.rxns), nGenes);
    end
    model.rxnGeneMat(rxnID,1:nGenes) = sparse(false(1,nGenes));
end  

if translateNamesFlag && ~isempty(grRule)
    % translate each gene name of the rule (common name -> systematic name) before the
    % look-up in model.genes, so that a translated gene already in the model is reused
    translateGene = @(geneID) convertGeneID(geneID, systNameList, geneNameList);
    grRule = regexprep(preparseGPR(grRule), '([^\(\)\|\&\s]+)', '${translateGene($0)}');
end
[rule,~,newGenes] = parseGPR(grRule,model.genes);
model.genes = [model.genes;newGenes];
nGenes = length(model.genes);
if nGenes > nGenesInit
    % the other gene fields (and the columns of rxnGeneMat) get their defaults for the new genes
    model = extendModelFieldsForType(model,'genes','originalSize', nGenesInit, 'targetSize',nGenes);
end
model.rules{rxnID,1} = rule;

getGene = @(x) model.genes{str2num(x)};
if addRxnGeneMat
    res = regexp(model.rules{rxnID},'x\((?<ID>[0-9]+)\)','names');
    pos = cellfun(@str2num , {res.ID});
    model.rxnGeneMat(rxnID,pos) = true;
end

model = creategrRulesField(model,rxnID);

%make sure variables are column vectors
model.rules = columnVector(model.rules);


function geneID = convertGeneID(geneID, systNameList, geneNameList)
% translate one gene name to its systematic name; a name not in geneNameList is kept
[isInList, listPos] = ismember(geneID, geneNameList);
if isInList
    geneID = systNameList{listPos};
end