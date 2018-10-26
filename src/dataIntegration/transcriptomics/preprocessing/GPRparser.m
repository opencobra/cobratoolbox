function parsedGPR = GPRparser(model, getCNFSets)
% Maps the GPR rules of the model to a specified format that is used by
% the model extraction methods 
%
% USAGE:
%   parsedGPR = GPRparser(model)
%
% INPUT:
%   model:       cobra model structure
%
% OPTIONAL INPUT:
%    getCNFSets:    whether to get the CNF sets (true) or DNF sets (false).
%                   DNF sets represent functional enzyme complexes, while
%                   CNF sets represent the possible subunits of a complex.
%                   (default: false , i.e. DNF sets)
%
% OUTPUT:
%   parsedGPR:   cell matrix containing parsed GPR rule
%
% AUTHORS: Thomas Pfau & Anne Richelle, May 2017

if ~exist('getCNFSets','var')
    getCNFSets = false;
end

parsedGPR = {};
fp = FormulaParser();
for i = 1:numel(model.rxns)
    if ~isempty(model.rules{i})
        head = fp.parseFormula(model.rules{i});
        currentSets = head.getFunctionalGeneSets(model.genes,getCNFSets)';
        parsedGPR{i}=currentSets;
    else
        parsedGPR{i}={''};
    end
end
parsedGPR=parsedGPR';
end