function model = createModel(varargin)
% Create a COBRA model from inputs or an empty model
% structure if no inputs are provided.
%
% USAGE:
%
%    model = createModel(rxnAbrList, rxnNameList, rxnList, revFlagList, lowerBoundList, upperBoundList, subSystemList, grRuleList, geneNameList, systNameList)
%
% INPUTS:
%    rxnAbrList:            List of names of the new reactions
%    rxnNameList:           List of names of the new reactions
%    rxnList:               List of reactions: format: {`A -> B + 2 C`}
%                           If the compartment of a metabolite is not
%                           specified, it is assumed to be cytoplasmic, i.e. [`c`]
%
% OPTIONAL INPUTS:
%    revFlagList:           List of reversibility flag (opt, default = 1)
%    lowerBoundList:        List of lower bound (Default = 0 or ``-vMax`)
%    upperBoundList:        List of upper bound (Default = `vMax`)
%    subSystemList:         List of subsystem (Default = '')
%    grRuleList:            List of gene-reaction rule in boolean format (and/or allowed)
%                           (Default = '');
%    geneNameList:          List of gene names (used only for translation
%                           from common gene names to systematic gene names)
%    systNameList:          List of systematic names
%
% OUTPUT:
%    model:                 COBRA model structure
%
% .. Author: - Ines Thiele 01/09
%            - Adjusted to Name/Value Pairs - Thomas Pfau May 2017



model = struct(); %create blank model, with all required fields.
model.rxns=cell(0,1);model.S=sparse(0,0);
model.lb=zeros(0,1);model.ub=zeros(0,1);model.c=zeros(0,1);
model.mets=cell(0,1);model.b=zeros(0,1);
model.rules=cell(0,1);
model.genes=cell(0,1);
model.osense = -1;
model.csense = char();
model.rxnGeneMat = sparse(0,0);
%If no arguments are provided, return this empty model.
if nargin < 1
    return;
end

%Ok, some arguments are provided, we need at least three then.

optionalParameters = {'revFlagList',...
    'lowerBoundList','upperBoundList','subSystemList','grRuleList','geneNameList','systNameList'};
oldOptionalOrder = {'revFlagList',...
    'lowerBoundList','upperBoundList','subSystemList','grRuleList','geneNameList',...
    'systNameList'};
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
subSysDefault(1:nRxns) = {''};

grRuleDefault = {};
grRuleDefault(1:nRxns) = {''};

geneNameDefault = {};
systNameDefault = {};

    
parser = inputParser();
parser.addRequired('rxnAbrList',@iscell);
parser.addRequired('rxnNameList',@iscell);
parser.addRequired('rxnList',@iscell);
parser.addParameter('revFlagList',revDefault,@(x) isnumeric(x) || islogical(x));
parser.addParameter('lowerBoundList',lowerBoundDefault,@isnumeric);
parser.addParameter('upperBoundList',upperBoundDefault,@isnumeric);
parser.addParameter('subSystemList', subSysDefault ,@iscell);
parser.addParameter('grRuleList', grRuleDefault,@iscell);
parser.addParameter('geneNameList', geneNameDefault,@iscell);
parser.addParameter('systNameList', systNameDefault,@iscell);
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

for i = 1 : nRxns
    if i==nRxns
        %pause(eps)
    end
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
    [metaboliteList,stoichCoeffList,revFlag_i] = parseRxnFormula(rxnList{i});
    if  ~any(ismember('lowerBoundList',parser.UsingDefaults))
        if ~any(ismember('revFlagList',parser.UsingDefaults))
            %if both revFlag and lb are not given, update the revFlag
            %implied by the rxn formula
            revFlagList(i) = revFlag_i;
        end
        %update the lower bound implied by revFlag
        lowerBoundList(i) = revFlagList(i) * lowerBoundList(i);
    end
    for q=1:length(metaboliteList)
        if length(metaboliteList{q})<=3 || ~strcmp(metaboliteList{q}(end-2),'[')
            %assuming the default compartment is cytoplasmic
            metaboliteList{q}=[metaboliteList{q},'[c]'];
        end
    end
    model = addReaction(model,{rxnAbrList{i},rxnNameList{i}},metaboliteList,stoichCoeffList,...
        revFlagList(i),lowerBoundList(i),upperBoundList(i),0,...
        subSystemList{i},grRuleList{i},geneNameList,systNameList,false);
end
