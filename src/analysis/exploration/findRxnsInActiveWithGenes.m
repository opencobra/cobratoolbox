function Reaclist = findRxnsInActiveWithGenes(model, genes)
% Finds all reactions for which the provided genes
% show sufficient evidence of their absence. (i.e. make the corresponding GPRs always be zero)
%
% USAGE:
%
%    [Reaclist] = findRxnsActiveWithGenes(model, genes)
%
% INPUTS:
%    model:        COBRA model structure
%    genes:        A list of gene identifiers
%
% OUTPUT:
%    Reaclist:     Cell array of reactions which are supported by the provided genes
%
% NOTE:
%
%    Only reactions which do have a GPR are considered for this function.
%    Reactions without GPRs are ignored, as we don't have evidence.
%
% .. Author: - Thomas Pfau 04/03/15

genepos = find(ismember(model.genes,genes));
%get the positions of the provided genes (anything not in the model will
%simply be ignored)
Reaclist = {};
%Set up the x vector for evaluation of the GPR rules
x = ones(size(model.genes));
x(genepos) = 0;

%Evaluate all reactions (ignoring those which have no GPR i.e. where we
%have no idea
for i=1:numel(model.rules)
    if ~isempty(model.rules{i})
        res = eval(model.rules{i});
        if ~res
            Reaclist{end+1} = model.rxns{i};
        end
    end
end
