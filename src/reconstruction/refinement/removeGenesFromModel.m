function [model, affectedRxns, originalGPRs, deletedReactions] = removeGenesFromModel(model, geneList, varargin)
% Removes the given genes from the model. GPR rules will be adjusted to reflect the removal.
% By default, the rules are converted to DNF and all clauses containing any of the given
% genes are removed. Note, that this function is not supposed to be used to model
% single gene deletions.
%
% USAGE:
%
%    [model, affectedRxns, originalGPRs, deletedReactions] = removeGenesFromModel(model, geneList)
%
% INPUT:
%    model:               COBRA model with the appropriate constrains for a
%                         particular condition
%    geneList:            List of genes to be deleted as cell array, or a
%                         single gene as char
%
% OPTIONAL INPUTS:
%    varargin:            Additional Parameter/value pairs or a parameter
%                         struct with the following parameter names:
%                           * keepReactions - Whether to keep reactions if its GPR is
%                             hanged to an empty GPR, i.e. all complexes catalyzing
%                             it are removed. (default: true)
%                           * keepClauses - Do not remove clauses containing the gene,
%                             but instead just remove the gene from the clause (default: false).
%
% OUTPUTS:
%    model:               COBRA model with the selected genes deleted
%    affectedRxns:        A list of reactions which have their rules altered
%    originalGPRs:        The original GPR rules for the affected reactions
%                         in grRules format.
%    deletedReactions:    The list of reactions removed from the model (if
%                         keepReaction was false).
%
% .. Authors:
%       - Thomas Pfau Oct 2018


parser = inputParser();
parser.addParameter('keepReactions', true, @(x) islogical(x) || (isnumeric(x) && (x==1 || x==0)));
parser.addParameter('keepClauses', true, @(x) islogical(x) || (isnumeric(x) && (x==1 || x==0)));
parser.parse(varargin{:});

keepReactions = parser.Results.keepReactions;
keepClauses = parser.Results.keepClauses;

% Convert single gene IDs for better handling.
if ischar(geneList)
    geneList = {geneList};
end

% get the gene Pos ition
[pres,pos] = ismember(geneList,model.genes);

if any(~pres)
    warning('The following genes were not part of the model:\n%s',strjoin(geneList(~pres),', '));
end
% if rules does not exist, but grRules does, create it.
if isfield(model,'grRules') && ~isfield(model,'rules')
    model = generateRules(model);
end

% store those reactions which have an empty rule.
if ~keepReactions
    rxnsWithoutGPR = cellfun(@isempty, model.rules);
else
    deletedReactions = {};
end


% get the affected reactions
if isfield(model,'rxnGeneMat')
    % if the rxnGeneMat is present, we simply derive it from there
    relreacs = find(any(model.rxnGeneMat(:,pos(pres)),2));
elseif isfield(model,'rules')
    relreacs = find(~cellfun(@isempty, regexp(model.rules,['x\((' strjoin(cellfun(@num2str , num2cell(pos(pres)),'uniform',0),'|'), ')\)'])));
else
    warning('There are no gene rules assigned in the model. Doing nothing')
    return
end
affectedRxns = model.rxns(relreacs);

if nargout > 2
    if ~isfield(model,'grRules')
        model = creategrRulesField(model);
    end
    originalGPRs = model.grRules(relreacs);
end

% convert the literals to strings
geneLiterals = arrayfun(@num2str, pos(pres),'uniform',0);

fp = FormulaParser;
% Now, update the rules field.
for i = 1:numel(relreacs)
    head = fp.parseFormula(model.rules{relreacs(i)});
    literals = head.getLiterals();
    litsToRemove = intersect(geneLiterals,literals);
    head.deleteLiterals(litsToRemove,keepClauses);
    model.rules{relreacs(i)} = head.toString(1);
end

if isfield(model,'grRules')
    model = creategrRulesField(model,relreacs);
end

if ~keepReactions
    newEmptyGPRs = cellfun(@isempty,model.rules);
    rxnsToDelete = newEmptyGPRs & ~rxnsWithoutGPR;
    deletedReactions = model.rxns(rxnsToDelete);
    model = removeRxns(model,model.rxns(rxnsToDelete));
end

model = removeFieldEntriesForType(model,pos(pres),'genes',numel(model.genes));

