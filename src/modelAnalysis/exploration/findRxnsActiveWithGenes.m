function Reaclist = findRxnsActiveWithGenes(model, genes)
% Finds all reactions for which the provided genes
% show sufficient evidence (i.e. are usfficient according to the GPRs)
%
% USAGE:
%
%    [Reaclist] = findRxnsActiveWithGenes(model, genes)
%
% INPUT:
%    model:        COBRA model structure
%    genes:        A list of gene identifiers
%
% OUTPUTS:
%    Reaclist:     Cell array of reactions which are supported by the provided genes
%
% NOTE:
%
%    Only reactions which do have a GPR are considered for this function.
%    Reactions without GPRs are ignored, as we don't have evidence.
%
% .. Author: - 04/03/15 Thomas Pfau


genepos = find(ismember(model.genes,genes));
%get the positions of the provided genes (anything not in the model will
%simply be ignored)
Reaclist = {};
%Set up the x vector for evaluation of the GPR rules
x = zeros(size(model.genes));
x(genepos) = 1;

%Evaluate all reactions (ignoring those which have no GPR i.e. where we
%have no idea
for i=1:numel(model.rules)
    if ~isempty(model.rules{i})
        res = eval(model.rules{i});
        if res
            Reaclist{end+1} = model.rxns{i};
        end
    end
end
