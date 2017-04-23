function model = createModel(rxnAbrList,rxnNameList,rxnList,revFlagList,...
    lowerBoundList,upperBoundList,subSystemList,grRuleList,geneNameList,...
    systNameList)
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

model = struct(); %create blank model
model.mets=cell(0,1);model.metNames=cell(0,1);model.metFormulas=cell(0,1);
model.rxns=cell(0,1);model.rxnNames=cell(0,1);model.subSystems=cell(0,1);
model.lb=zeros(0,1);model.ub=zeros(0,1);model.rev=zeros(0,1);
model.c=zeros(0,1);model.b=zeros(0,1);
model.S=sparse(0,0);
model.rxnGeneMat=sparse(0,0);
model.rules=cell(0,1);
model.grRules=cell(0,1);
model.genes=cell(0,1);
lbGivenFlag = true; %reversibility implied by lower bound
revGivenFlag = true; %reversibility implied by revFlag

if nargin < 1
    return;
end

nRxns = length(rxnNameList);
if nargin < 9
    geneNameList(1:nRxns,1) = {''};
    systNameList(1:nRxns,1) = {''};
end
if nargin < 8
    grRuleList(1:nRxns,1) = {''};
end
if nargin < 7
    subSystemList(1:nRxns,1) = {''};
end
if nargin < 5
    lowerBoundList = -1000*ones(nRxns,1);
    lbGivenFlag = false; %reversibility not implied by lower bound
end
if nargin < 6
    upperBoundList = 1000*ones(nRxns,1);
end
if nargin < 4
    revFlagList = ones(nRxns,1);
    revGivenFlag = false; %reversibility not implied by default revFlag
end
if isempty(revFlagList)
    revFlagList = zeros(nRxns,1);
    revFlagList(lowerBoundList< 0) = 1;
    revGivenFlag = false; %reversibility not implied by default revFlag
end

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
    if ~lbGivenFlag
        if ~revGivenFlag
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
