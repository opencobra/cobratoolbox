function modelOut = removeRxns(model, rxnRemoveList, varargin)
% Removes reactions from a model
%
% USAGE:
%
%    model = removeRxns(model, rxnRemoveList, varargin)
%
% INPUTS:
%    model:             COBRA model structure
%    rxnRemoveList:     Cell array of reaction names to be removed
%
% OPTIONAL INPUTS:
%    varargin:          Parameters in ParameterName, Value pair representation. 
%                       Available parameters are:
%                       * irrevFlag:   Irreverseble (true) or reversible (false) reaction
%                         format (Default = false)
%                       * metFlag:   Remove unused metabolites (Default = true)
%
% OUTPUT:
%    model:             COBRA model w/o selected reactions
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
optionalParameters = {'irrevFlag','metFlag'};
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

parser.parse(model,rxnRemoveList,varargin{:})

model = parser.Results.model;
rxnRemoveList = parser.Results.rxnRemoveList;
irrevFlag = parser.Results.irrevFlag;
metFlag = parser.Results.metFlag;

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
    selMets = modelOut.mets(any(sum(abs(modelOut.S), 2) == 0, 2));
    if ~isempty(selMets)
        modelOut = removeMetabolites(modelOut, selMets, false);
    end
end
