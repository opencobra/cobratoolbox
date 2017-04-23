function [model,hasEffect,constrRxnNames,upRegulatedGenes] = upRegulateModelGenes(model,geneList,upRegFraction)
%upRegulateModelGenes Upregulate one or more genes and constrain the reactions
%affected to zero and appends '_upregulated' to the gene(s)
%
%  [model,hasEffect,constrRxnNames,upregulatedGenes] =
%  upRegulateModelGenes(model,geneList,upRegFraction)
%
%INPUT
% model             COBRA model with the appropriate constrains for a
%                   particular condition
%
%OPTIONA INPUTS
% geneList          List of genes to be upregulated (Default =  all genes in
%                   model)
% upRegFraction   Fraction of the original lower bounds that the reactions
%                   corresponding to upregulated genes will be assigned
%                   (Default = 0.5 corresponding to a 50% upregulation)
%
%OUTPUTS
% model             COBRA model with the selected genes upregulated
% hasEffect         True if the gene upregulation has an effect on the model
% constrRxnNames    Reactions that are associated to the genes in geneList
% upRegulatedGenes      The list of genes upregulated from the model.
%
% IT -7/20/12

if (nargin < 2)
    geneList = model.genes;
end

if (nargin < 3)
    upRegFraction = 0.5;
end

if (~iscell(geneList))
    geneName = geneList;
    clear geneList;
    geneList{1} = geneName;
end

if (~isfield(model,'genes'))
    error('Gene-reaction associations not included with the model');
end

hasEffect = false;
constrRxnNames = {};
%deletedGenes is a cell array for returning the genes that are
%eliminated from the model.
upRegulatedGenes = {};



% Find gene indices in model
[isInModel,geneInd] = ismember(geneList,regexprep(model.genes,'_upregulated',''));

if (all(isInModel))
    
    %If there are any zero elements in geneInd remove them from the
    %geneList and the geneInd because they correspond to genes that
    %are not in the model.
    upRegulatedGenes = geneList( find( geneInd ) );
    geneInd = geneInd( find( geneInd ) );
    
    %mark genes for deletion
    model.genes(geneInd) = strcat(model.genes(geneInd),'_upregulated');
    
    % Find rxns associated with this gene
    rxnInd = find(any(model.rxnGeneMat(:,geneInd),2));
    if (~isempty(rxnInd))
        x = true(size(model.genes));
        % set genes marked "_deleted" to false
        x(~cellfun('isempty',(regexp(model.genes,'_upregulated')))) = false;
        constrainRxn = false(length(rxnInd),1);
        % Figure out if any of the reaction states is changed
        for j = 1:length(rxnInd)
            if (~eval(model.rules{rxnInd(j)}))
                constrainRxn(j) = true;
            end
        end
        % Constrain flux through the reactions associated with these genes
        if (any(constrainRxn))
            constrRxnNames = model.rxns(rxnInd(constrainRxn));
            % optimize for each reaction and set constraint accordingly
            for r = 1: length(constrRxnNames)
                model.c=0*model.c;
                model = changeObjective(model,constrRxnNames(r));
                FBA = optimizeCbModel(model,'max');
                if FBA.f >0
                    model = changeRxnBounds(model,constrRxnNames(r),upRegFraction*FBA.f,'l');
                else
                    FBA = optimizeCbModel(model,'min');
                    model = changeRxnBounds(model,constrRxnNames(r),upRegFraction*FBA.f,'l');
                    model = changeRxnBounds(model,constrRxnNames(r),1000,'u');
                end
            end
            hasEffect = true;
        end
    end
else
    error(['Gene',' ',geneList{~isInModel}, ' not in model!']);
end

