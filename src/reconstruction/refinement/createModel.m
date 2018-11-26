function model = createModel(varargin)
% Create a COBRA model from inputs or an empty model
% structure if no inputs are provided.
%
% USAGE:
%
%    model = createModel(rxnAbrList, rxnNameList, rxnList, revFlagList, lowerBoundList, upperBoundList, subSystemList, grRuleList, geneNameList, systNameList)
%
% INPUTS:
%    rxnAbrList:        List of names of the new reactions
%    rxnNameList:       List of names of the new reactions
%    rxnList:           List of reactions: format: {`A -> B + 2 C`}
%                       If the compartment of a metabolite is not
%                       specified, it is assumed to be cytoplasmic, i.e. [`c`]
%
% OPTIONAL INPUTS:
%    revFlagList:       List of reversibility flag (opt, default = 1)
%    lowerBoundList:    List of lower bound (Default = 0 or `-vMax`)
%    upperBoundList:    List of upper bound (Default = `vMax`)
%    subSystemList:     List of subsystem (Default = {''})
%    grRuleList:        List of gene-reaction rule in boolean format (and/or allowed)
%                       (Default = '');
%    geneNameList:      List of gene names (used only for translation
%                       from common gene names to systematic gene names)
%    systNameList:      List of systematic names
%    printLevel:        Verbosity (0 - no outputs, except warnings, 1- normal printout (default))
%
% OUTPUT:
%    model:             COBRA model structure
%
% EXAMPLES:
%
%    1) Create A model with two Reactions (R1 : 'A -> B + C', R2: 'C -> D')
%    model = createModel({'R1','R2'},{'Reaction 1','Reaction 2'},{'A -> B + C', 'C -> D'});
%    2) Also set the subSystems of the two Reactions (R1: Sub1, R2: Sub2):
%    model = createModel({'R1','R2'},{'Reaction 1','Reaction 2'},{'A -> B + C', 'C -> D'},...
%    'subSystemList', {'Sub1','Sub2'});
%    3) Also set upper and lower bounds:
%    model = createModel({'R1','R2'},{'Reaction 1','Reaction 2'},{'A -> B + C', 'C -> D'},...
%    'subSystemList', {'Sub1','Sub2'}, 'lowerBoundList',[-3 -1000],'upperBoundList',[120 17]);
%
%
% .. Author: - Ines Thiele 01/09
%            - Adjusted to Name/Value Pairs - Thomas Pfau May 2017



model = struct(); %create blank model, with all required fields.
model.rxns=cell(0,1);model.S=sparse(0,0);
model.lb=zeros(0,1);model.ub=zeros(0,1);model.c=zeros(0,1);
model.mets=cell(0,1);model.b=zeros(0,1);
model.rules=cell(0,1);
model.genes=cell(0,1);
model.osenseStr = 'max';
model.csense = char();
model.rxnGeneMat = sparse(0,0);
model.metComps = cell(0,1);
model.comps = cell(0,1);
%If no arguments are provided, return this empty model.
if nargin < 1
    return;
end

%Ok, some arguments are provided, we need at least three then.

optionalParameters = {'revFlagList',...
    'lowerBoundList','upperBoundList','subSystemList','grRuleList','geneNameList','systNameList','printLevel'};
oldOptionalOrder = {'revFlagList',...
    'lowerBoundList','upperBoundList','subSystemList','grRuleList','geneNameList','systNameList'};
if (numel(varargin) > 3 && (~ischar(varargin{4}) || ~any(ismember(varargin{4},optionalParameters))))
    %We have an old style thing....
    %Now, we need to check, whether this is a formula, or a complex setup

        tempargin = cell(1,3+2*(numel(varargin)-3));
        tempargin(1:3) = varargin(1:3);
        for i = 4:(numel(varargin))
                tempargin{2*(i-4)+4} = oldOptionalOrder{i-3};
                tempargin{2*(i-4)+5} = varargin{i};
        end
        varargin = tempargin;

end
%set up defaults
nRxns = length(varargin{1});
upperBoundDefault = 1000*ones(nRxns,1);
lowerBoundDefault = -1000*ones(nRxns,1);
revDefault = 1*ones(nRxns,1);
subSysDefault = {};
subSysDefault(1:nRxns) = {{''}};

grRuleDefault = {};
grRuleDefault(1:nRxns) = {''};

geneNameDefault = {};
systNameDefault = {};


parser = inputParser();
parser.addRequired('rxnAbrList',@iscell);
parser.addRequired('rxnNameList',@iscell);
parser.addRequired('rxnList',@iscell);
parser.addParamValue('revFlagList',revDefault,@(x) isnumeric(x) || islogical(x));
parser.addParamValue('lowerBoundList',lowerBoundDefault,@isnumeric);
parser.addParamValue('upperBoundList',upperBoundDefault,@isnumeric);
parser.addParamValue('subSystemList', subSysDefault ,@iscell);
parser.addParamValue('grRuleList', grRuleDefault,@iscell);
parser.addParamValue('geneNameList', geneNameDefault,@iscell);
parser.addParamValue('systNameList', systNameDefault,@iscell);
parser.addParamValue('printLevel',1,@isnumeric);
parser.parse(varargin{:});

rxnAbrList = parser.Results.rxnAbrList;
rxnNameList = parser.Results.rxnNameList;
rxnList = parser.Results.rxnList;
systNameList = parser.Results.systNameList;
geneNameList = parser.Results.geneNameList;
grRuleList = parser.Results.grRuleList;
revFlagList = parser.Results.revFlagList;
lowerBoundList = parser.Results.lowerBoundList;
upperBoundList = parser.Results.upperBoundList;
subSystemList = parser.Results.subSystemList;
printLevel = parser.Results.printLevel;

if ischar([subSystemList{:}])
    subSystemList = cellfun(@(x) strsplit(x,';'), subSystemList, 'UniformOutput',0);
end
metaboliteLists = cell(nRxns,1);
coefLists = cell(nRxns,1);
for i = 1 : nRxns
    if ~isempty(grRuleList{i})
        if ~isempty(strfind(grRuleList{i},','))
          grRuleList{i}= (regexprep(grRuleList{i},',',' or '));
        end
        if ~isempty(strfind(grRuleList{i},'&'))
           grRuleList{i} = (regexprep(grRuleList{i},'&',' and '));
        end
       if ~isempty(strfind(grRuleList{i},'+'))
          grRuleList{i}= (regexprep(grRuleList{i},'+',' and '));
       end
    end
    [metaboliteList,coefLists{i},revFlag_i] = parseRxnFormula(rxnList{i});
    if  any(ismember('lowerBoundList',parser.UsingDefaults))
        if any(ismember('revFlagList',parser.UsingDefaults))
            %if both revFlag and lb are not given, update the revFlag
            %implied by the rxn formula
            revFlagList(i) = revFlag_i;
        end
        %update the lower bound implied by revFlag
        if lowerBoundList(i) < 0
            lowerBoundList(i) = revFlagList(i) * lowerBoundList(i);
        end
    end
    hasComp = cellfun(@(x) ~isempty(regexp(x,'\[[^\[]*\]$','ONCE')),metaboliteList);
    metaboliteList(~hasComp) = strcat(metaboliteList(~hasComp),'[c]');
    metaboliteLists{i} = metaboliteList;
end
metabs = unique([metaboliteLists{:}]);
model = addMultipleMetabolites(model,metabs,'metNames',columnVector(metabs),'printLevel',printLevel);
stoich = zeros(numel(metabs),nRxns);
for i = 1:nRxns
    [pres,pos] = ismember(metaboliteLists{i},metabs);
    stoich(pos(pres),i) = coefLists{i};
end

model = addMultipleReactions(model,rxnAbrList,metabs,stoich,'lb',lowerBoundList,...
    'ub',upperBoundList,'subSystems',subSystemList,'grRules',grRuleList,'printLevel',printLevel,'rxnNames',columnVector(rxnAbrList));

end