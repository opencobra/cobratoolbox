function [rxnList, rxnFormulaList] = findRxnsFromMets(model, metList, varargin)
% Returns a list of reactions in which at least one
% metabolite listed in metList participates.
%
% USAGE:
%
%    [rxnList, rxnFormulaList] = findRxnsFromMets(model, metList, printFlag)
%
% INPUTS:
%    model:             COBRA model structure
%    metList:           Metabolite list
%
% OPTIONAL INPUTS:
%    printFlag:          Print reaction formulas to screen (Default = false)
%    Property/Value:    Allowed Properties are:
%                        * `containsAll` - If true only reactions containing all metabolites in metList are returned (Default: false)
%                        * `printFlag` - as above, will overwrite a `printFlag` set individually (Default: false)
%                        * `producersOnly` - Only return reactions which produce any of the given metabolites. (Default: false)
%                        * `consumersOnly` - Only return reactions which consume any of the given metabolites. (Default: false)
%
% OUTPUTS:
%    rxnList:           List of reactions
%    rxnFormulaList:    Reaction formulas coresponding to `rxnList`
%
% .. Authors:
%       - Richard Que (08/12/2010)
%       - Almut Heinken (09/25/2015)- made change so formulas are not printed if reaction list is empty.
%       - Thomas Pfau (21/1/2016) - Additional Options, and minimal speedup of the indexing, also updated behaviour of verbFlag to accurately reflect the description.

verbFlag = false;
containsAll = false;
if isa(metList,'char')
    metList = {metList};
end


if mod(numel(varargin), 2) == 1 % the first argument has to be verbFlag, the remaining are property/value pairs
    verbFlag = varargin{1};
    if numel(varargin) > 1
        varargin = varargin(2:end);
    end
end

parser = inputParser();
parser.addParameter('containsAll',false,@(x) (isnumeric(x) && (x==1 || x ==0)) || islogical(x));
parser.addParameter('producersOnly',false,@(x) (isnumeric(x) && (x==1 || x ==0)) || islogical(x));
parser.addParameter('consumersOnly',false,@(x) (isnumeric(x) && (x==1 || x ==0)) || islogical(x));
parser.addParameter('printFlag',verbFlag,@(x) isnumeric(x) );
parser.addParameter('verbFlag',verbFlag,@(x) isnumeric || islogical(x) ); % backward compatability

parser.parse(varargin{:});
%Verbosity flag backward compatability
if ismember('verbFlag',parser.UsingDefaults)
    verbFlag = parser.Results.printFlag;
elseif ismember('printFlag',parser.UsingDefaults)
    verbFlag = parser.Results.verbFag;
else
    verbFlag = max([parser.Results.printFlag,parser.Results.verbFlag]);
end

containsAll = parser.Results.containsAll;
producersOnly = parser.Results.producersOnly;
consumersOnly = parser.Results.consumersOnly;


%Find met indicies
index = ismember(model.mets,metList);

if producersOnly && consumersOnly
    producers = sum(model.S(index,:) > 0,1)';
    consumers = sum(model.S(index,:) < 0,1)';
    rels = producers > 0 & model.ub > 0 | consumers > 0 & model.lb < 0 | producers > 0 & model.lb < 0 | consumers > 0 & model.ub > 0;    
    totals = producers + consumers;
elseif producersOnly
    producers = sum(model.S(index,:) > 0,1)';
    consumers = sum(model.S(index,:) < 0,1)';
    rels = producers > 0 & model.ub > 0 | consumers > 0 & model.lb < 0;    
    totals = producers + consumers;
elseif consumersOnly
    producers = sum(model.S(index,:) > 0,1)';
    consumers = sum(model.S(index,:) < 0,1)';
    rels = producers > 0 & model.lb < 0 | consumers > 0 & model.ub > 0;        
    totals = producers + consumers;
else
    totals = sum(model.S(index,:) ~= 0,1);
    rels = totals > 0;
end

if containsAll
   rxnList = model.rxns(totals == numel(metList) & rels);
else
    %rxns = repmat(model.rxns,1,length(index));
    %find reactions i.e. all columns with at least one non zero value
    rxnList = model.rxns(totals > 0 & rels);
end


if (nargout > 1) || verbFlag
    if ~isempty(rxnList)
        rxnFormulaList = printRxnFormula(model,rxnList,verbFlag);
    else
        rxnFormulaList={};
    end
end
