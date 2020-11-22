function [modelOut, metRemoveList] = removeRxns(model, rxnRemoveList, varargin)
% Removes reactions from a model
%
% USAGE:
%
%    model = removeRxns(model, rxnRemoveList, varargin)
%
% INPUTS:
%    model:             COBRA model structure
%    rxnRemoveList:     Cell array of reaction abbreviations to be removed
%
% OPTIONAL INPUTS:
%    varargin:          Parameters in ParameterName, Value pair representation. 
%                       Available parameters are:
%
%                       * irrevFlag:   Irreverseble (true) or reversible (false) reaction
%                         format (Default = false)
%                       * metFlag:   Remove unused metabolites (Default = true)
%
% OUTPUT:
%    model:             COBRA model w/o selected reactions
%    metRemoveList:     Cell array of metabolite abbreviations that were removed
%
% Optional inputs are used as parameter value pairs
%
% EXAMPLES:
%    1) Remove the reactions 'ATPM' and 'TKT1' from the given model
%    model = removeRxns(model,{'ATPM','TKT1'});
%    2) Remove the same reactions but keep any metabolites which would now
%    be not present in any reaction:
%    model = removeRxns(model,{'ATPM','TKT1'}, 'metFlag', false);
%
% .. Authors:
%       - Markus Herrgard 7/22/05
%       - Fatima Liliana Monteiro and Hulda Haraldsdóttir, November 2016
%       - Thomas Pfau - changed to Parameter Value pairs
optionalParameters = {'irrevFlag','metFlag','metRemoveMethod','ctrsRemoveMethod'};
if (numel(varargin) > 0 && (~ischar(varargin{1}) || ~any(ismember(varargin{1},optionalParameters))))
    if ischar(varargin{1})
        error('Invalid parameter provided. %s is not an accepted parameter',varargin{1});
    end
    %We have an old style thing....
    %Now, we need to check, whether this is a formula, or a complex setup
        tempargin = cell(1,2*(numel(varargin)));
        for i = 1:numel(varargin)
                tempargin{2*(i-1)+1} = optionalParameters{i};
                tempargin{2*(i-1)+2} = varargin{i};
        end
        varargin = tempargin;
end

parser = inputParser();
parser.addRequired('model',@isstruct) % we only check, whether its a struct, no details for speed
parser.addRequired('rxnRemoveList',@(x) iscell(x) || ischar(x))
parser.addParameter('irrevFlag',false,@(x) isnumeric(x) || islogical(x))
parser.addParameter('metFlag',true,@(x) isnumeric(x) || islogical(x));
parser.addParameter('metRemoveMethod', 'exclusive', @(x) ischar(x))
parser.addParameter('ctrsRemoveMethod', 'exclusive', @(x) ischar(x))

parser.parse(model,rxnRemoveList,varargin{:})

model = parser.Results.model;
rxnRemoveList = parser.Results.rxnRemoveList;
irrevFlag = parser.Results.irrevFlag;
metFlag = parser.Results.metFlag;
metRemoveMethod = parser.Results.metRemoveMethod;
ctrsRemoveMethod = parser.Results.ctrsRemoveMethod;

[nMets, nRxns] = size(model.S);
if isfield(model, 'genes')
    nGenes = length(model.genes);
else
    nGenes = 0;
end

% Find indices to rxns in the model
[isValidRxn, removeInd] = ismember(rxnRemoveList, model.rxns);
removeInd = removeInd(isValidRxn);

% Remove reversible tag from the reverse reaction if the reaction to be
% deleted is reversible
if irrevFlag
    for i = 1:length(removeInd)
        remRxnID = removeInd(i);
        if model.match(remRxnID) > 0
            revRxnID = model.match(remRxnID);
            model.rxns{revRxnID} = model.rxns{revRxnID}(1:end-2);
        end
    end
end

% Construct vector to select rxns to be included in the model rapidly
selectRxns = true(nRxns, 1);
selectRxns(removeInd) = false;

% Construct new model
modelOut = removeFieldEntriesForType(model,~selectRxns,'rxns',numel(model.rxns));

% Reconstruct the match list
if irrevFlag
    modelOut.match = reassignFwBwMatch(model.match,selectRxns);
end

% Remove metabolites that are not used anymore
if metFlag
    switch metRemoveMethod
        case 'exclusive'
            %metabolites exclusively involved in removed reactions
            removeMets = getCorrespondingRows(model.S,true(size(model.S,1),1),~selectRxns,'exclusive');
        case 'inclusive'
            %any metabolite involved in one or more removed reactions
            removeMets = getCorrespondingRows(model.S,true(size(model.S,1),1),~selectRxns,'inclusive');
    end

    metRemoveList = model.mets(removeMets);
    
    if ~isempty(metRemoveList)
        modelOut = removeMetabolites(modelOut, metRemoveList, false);
    end
else
    metRemoveList =[];
end

%Also if there is a C field, remove all empty Constraints (i.e. constraints
%with nnz = 0)
if isfield(modelOut,'C')
    switch ctrsRemoveMethod
        case 'legacy'
            %this was the default behaviour, to remove empty
            %it seems equivalent to 'exclusive', but kept for completeness
            removeConstraints = getEmptyConstraints(modelOut);
            modelOut = removeCOBRAConstraints(modelOut,removeConstraints);
            bool=0;
        case 'exclusive'
            %only remove constraints exclusively involved in removed reactions
            selectConstraints = getCorrespondingRows(model.C,true(size(model.C,1),1),selectRxns,'exclusive');
            bool=1;
        case 'inclusive'
            %any constraint involved in a removed reaction is to be removed
            selectConstraints = getCorrespondingRows(model.C,true(size(model.C,1),1),selectRxns,'inclusive');
            bool=1;
        case 'infeasible'
            bool=0;
            %If a removed reaction involves any constraint then remove that
            %constraint, unless the constraint is still feasible.
            involvedConstraintInd = find(~getCorrespondingRows(model.C,true(size(model.C,1),1),selectRxns,'inclusive'));
            
            selectConstraints = true(size(model.C,1),1);
            for i=1:length(involvedConstraintInd)
                LPproblem.A = model.C(involvedConstraintInd(i),:);
                LPproblem.A(:,selectRxns)=0;
                LPproblem.b = model.d(involvedConstraintInd(i));
                LPproblem.lb = model.lb;
                LPproblem.ub = model.ub;
                LPproblem.csense = model.dsense(involvedConstraintInd(i));
                LPproblem.osense = 1;
                LPproblem.c = zeros(size(model.C,2),1);
                solution = solveCobraLP(LPproblem);
                if solution.stat~=1
                    %infeasible constraint to be removed
                    selectConstraints(involvedConstraintInd(i))=0;
                    bool=1;
                end
            end
            
    end
    if bool==1 && any(~selectConstraints)
        %remove using boolean indexing
        modelOut.C = model.C(selectConstraints,selectRxns);
        modelOut.d = model.d(selectConstraints,1);
        modelOut.dsense = model.dsense(selectConstraints,1);
        if isfield(model,'ctrs')
            modelOut.ctrs = model.ctrs(selectConstraints,1);
        end
        if isfield(model,'ctrNames')
            modelOut.ctrNames = model.ctrNames(selectConstraints,1);
        end
        if size(modelOut.C,2)~=size(modelOut.S,2)
            error('size(modelOut.C,2)~=size(modelOut.S,2)')
        end
        fprintf('%s\n',[num2str(nnz(~selectConstraints)) ' model.C constraints removed'])
    end
end

