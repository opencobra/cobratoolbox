function [model, rxnIDexists] = addReaction(model, rxnID, varargin)
% Adds a reaction to the model or modify an existing reaction
%
% USAGE:
%
%    [model, rxnIDexists] = addReaction(model, rxnID, varargin)
%
% INPUTS:
%    model:             COBRA model structure
%    rxnID:             Reaction name abbreviation (i.e. 'ACALD')
%
% OPTIONAL INPUTS:
%    varargin:          Input of additional information as parameter/Value pairs
%
%                         * reactionName - a Descriptive name of the reaction
%                           (default ID)
%                         * metaboliteList - Cell array of metabolite names. Either this
%                           parameter or reactionFormula are required.
%                         * stoichCoeffList - List of stoichiometric coefficients (reactants -ve,
%                           products +ve), if not provided, all stoichiometries
%                           are assumed to be -1 (Exchange, or consumption).
%                         * reactionFormula - A Reaction formula in string format ('A + B -> C').
%                           If this parameter is provided metaboliteList MUST
%                           be empty, and vice versa.
%                         * reversible - Reversibility flag (Default = true)
%                         * lowerBound - Lower bound (Default = 0 or -vMax`)
%                         * upperBound - Upper bound (Default = `vMax`)
%                         * objectiveCoef - Objective coefficient (Default = 0)
%                         * subSystem - Subsystem (Default = {''})
%                         * geneRule - Gene-reaction rule in boolean format (and/or allowed)
%                           (Default = '');
%                         * geneNameList - List of gene names (used only for translation from
%                           common gene names to systematic gene names) (Default empty)
%                         * systNameList - List of systematic names (Default empty)
%                         * checkDuplicate - Check `S` matrix too see if a duplicate reaction is
%                           already in the model (Deafult false)
%                         * printLevel - default = 1
%
% OUTPUTS:
%    model:             COBRA model structure with new reaction
%    rxnIDexists:       Empty if the reaction did not exist previously, or if
%                       checkDuplicate is false. Otherwise it contains the ID
%                       of an identical reaction already present in the model.
%
% EXAMPLES:
%
%    %1) Add a new irreversible reaction using the formula approach
%    model = addReaction(model,'newRxn1','reactionFormula','A -> B + 2 C')
%    %2) Add a the same reaction using the list approach
%    model = addReaction(model,'newRxn1','metaboliteList',{'A','B','C'},'stoichCoeffList',[-1 1 2], 'reversible',false);
%    %3) Add a new irreversible reaction using the formula approach with a
%    given GPR Rule
%    model = addReaction(model,'newRxn1','reactionFormula','A -> B + 2 C',... 
%                        'geneRule', 'Gene1 or Gene2');
%    %4) Add a the same reaction but also mark it as being in the
%    Glycolysis subSystem
%    model = addReaction(model,'newRxn1','reactionFormula','A -> B + 2 C', ...
%                        'subSystem', 'Glycolysis', 'geneRule', 'Gene1 or Gene2');
%
% .. Authors:
%       - Markus Herrgard 1/12/07
%       - Richard Que 11/13/2008 Modified the check to see if duplicate reaction already is in model by using S matrix coefficients to be able to handle larger matricies
%       - Ines Thiele 08/03/2015, made rxnGeneMat optional
%       - Thomas Pfau May 2017  Change To parameter Value pairs

optionalParameters = {'reactionName','reactionFormula','metaboliteList','stoichCoeffList',...
    'reversible','lowerBound','upperBound',...
    'objectiveCoef','subSystem','geneRule','geneNameList','systNameList','checkDuplicate','printLevel','notes'}; % check for backward compatability
oldOptionalOrder = {'metaboliteList','stoichCoeffList',...
    'reversible','lowerBound','upperBound',...
    'objectiveCoef','subSystem','geneRule','geneNameList','systNameList','checkDuplicate','printLevel'};
oldStyle = false;

origargin = varargin;

if (numel(varargin) > 0 && (~ischar(varargin{1}) || ~any(ismember(varargin{1},optionalParameters)))) || iscell(rxnID)
    %We have an old style thing....
    %Now, we need to check, whether this is a formula, or a complex setup
    oldStyle = true;
    tempargin = cell(0);
    if iscell(rxnID)
            %we just add it to the end.
            tempargin(end+1:end+2) = {'reactionName', rxnID{2}};
            rxnID = rxnID{1};
    end
    if (nargin < 4)
        if (~iscell(varargin{1}))
            tempargin(end+1:end+2) = {'reactionFormula',varargin{1}};
        else
            error('Missing stoichiometry information');
        end
    else
        start = 1;
        if isempty(varargin{2})
            tempargin(end+1:end+2) = {'reactionFormula',varargin{1}};
            start = 2;
        end
        %convert the input into the new format.
        for i = start:numel(varargin)
            if ~isempty(varargin{i})
                %Since we look for non empty, we should not have empty
                %elements.
                tempargin{end+1} = oldOptionalOrder{i};
                tempargin{end+1} = varargin{i};
            end
        end
    end
    varargin = tempargin;
end

% Figure out if reaction already exists
nRxns = length(model.rxns);
[reactionpresence,rxnPos] = ismember(rxnID,model.rxns);
if any(reactionpresence)
    warning('Reaction with the same name already exists in the model, updating the reaction');
    oldRxnFlag = true;
else
    rxnPos = nRxns+1;
    oldRxnFlag = false;
end
%Set default values
maxavailableBound = max([1000,max(abs(model.lb)), max(abs(model.ub))]);
defaultLowerBound = -maxavailableBound;
defaultUpperBound = maxavailableBound;
defaultObjective = 0;
defaultSubSystem = {''};
defaultgeneRule = '';
defaultMetaboliteList = {};
defaultStoichCoefList = [];
defaultReactionName = rxnID;
defaultReversibility = 1;
defaultGeneNameList = {};
defaultSystNameList = {};
if oldRxnFlag
    %Overwrite them if modifing a reaction
    defaultLowerBound = model.lb(rxnPos);
    defaultUpperBound = model.ub(rxnPos);
    defaultObjective = model.c(rxnPos);
    if isfield(model,'subSystem')
        defaultSubSystem = model.subSystem{rxnPos};
    end
    if isfield(model,'grRules')
        defaultgeneRule = model.grRules{rxnPos};
    end

    defaultMetaboliteList = model.mets(model.S(:,rxnPos)~=0);
    defaultStoichCoefList = model.S(model.S(:,rxnPos)~=0,rxnPos);
    if isfield(model,'rxnNames')
        defaultReactionName = model.rxnNames{rxnPos};
    end
    defaultReversibility = model.lb(rxnPos) < 0;
end

parser = inputParser();
parser.addRequired('model',@isstruct) % we only check, whether its a struct, no details for speed
parser.addRequired('rxnID',@ischar)
parser.addParamValue('reactionName',defaultReactionName,@ischar)
parser.addParamValue('metaboliteList',defaultMetaboliteList, @iscell);
parser.addParamValue('stoichCoeffList',defaultStoichCoefList, @(x) isnumeric(x) || isempty(x));
parser.addParamValue('reactionFormula','', @ischar);
parser.addParamValue('reversible',defaultReversibility, @(x) islogical(x) || isnumeric(x) );
parser.addParamValue('lowerBound',defaultLowerBound, @(x) isempty(x) || isnumeric(x));
parser.addParamValue('upperBound',defaultUpperBound, @(x) isempty(x) || isnumeric(x));
parser.addParamValue('objectiveCoef',defaultObjective,@(x) isempty(x) || isnumeric(x));
parser.addParamValue('subSystem',defaultSubSystem, @(x) isempty(x) || ischar(x) || iscell(x) && all(cellfun(@(y) ischar(y),x)));
parser.addParamValue('geneRule',defaultgeneRule, @(x) isempty(x) || ischar(x));
parser.addParamValue('checkDuplicate',0, @(x) isnumeric(x) || islogical(x));
parser.addParamValue('printLevel',1, @(x) isnumeric(x) );
parser.addParamValue('notes','', @ischar );
parser.addParamValue('systNameList',defaultGeneNameList, @(x) isempty(x) || iscell(x));
parser.addParamValue('geneNameList',defaultSystNameList, @(x) isempty(x) || iscell(x));

try
    parser.parse(model,rxnID,varargin{:});
catch ME
    if oldStyle
        if ischar(origargin{1}) || isstring(origargin{1})
            if ~any(ismember(origargin{1},optionalParameters))
                error('''%s'' is not a valid parameter name or it does not fit to the deprecated signature of addReaction.',origargin{1});
            end
        end    
    else
        rethrow(ME)
    end
end
printLevel = parser.Results.printLevel;
metaboliteList = parser.Results.metaboliteList;
reactionFormula = parser.Results.reactionFormula;
stoichCoeffList = parser.Results.stoichCoeffList;
revFlag = parser.Results.reversible;
geneNameList = parser.Results.geneNameList;
systNameList = parser.Results.systNameList;
%Check variant, if both, return error
if isempty(metaboliteList) && isempty(reactionFormula)
    error('No stoichiometry found! Set stoichiometry either by ''reactionFormula'' or by ''metaboliteList'' parameters.\nModel was not modified.')
end
%if this is not an old reaction and we have two definitions
if ~oldRxnFlag && ~isempty(metaboliteList) && ~isempty(reactionFormula)
    error('Two stoichiometry definitions found! Please set stoichiometry either by ''reactionFormula'' or by ''metaboliteList'' parameters but do not use both.\nModel was not modified.')
end

parseFormulaFlag = 0;
if ~isempty(reactionFormula)
    parseFormulaFlag = 1;
end
rxnIDexists = [];




% Parse formula
if (parseFormulaFlag)
    [metaboliteList,stoichCoeffList,revFlag] = parseRxnFormula(reactionFormula);
end

if any(ismember(parser.UsingDefaults,'lowerBound')) && ~revFlag
    %adjust lower bounds to a requested default irreversible reaction
    lowerBound = 0;
else
    lowerBound = parser.Results.lowerBound;
end
upperBound = parser.Results.upperBound;
objCoeff = parser.Results.objectiveCoef;
subSystem = parser.Results.subSystem;

if ischar(subSystem)
    subSystem = {subSystem};
end

grRule = parser.Results.geneRule;
checkDuplicate=parser.Results.checkDuplicate;


nMets = length(model.mets);
Scolumn = sparse(nMets,1);

modelOrig = model;

% Update model fields
model.rxns{rxnPos,1} = rxnID;
% set the reaction lower bound
%a Valid model has to have the lb and ub as well as c fields.
model.lb(rxnPos,1) = lowerBound;
model.ub(rxnPos,1) = upperBound;
model.c(rxnPos,1) = objCoeff;

%if a reactionname is requested, create the respective field if necessary
if isfield(model,'rxnNames') || ~any(ismember(parser.UsingDefaults,'reactionName'))
    if ~isfield(model,'rxnNames')
       model.rxnNames = cell(size(model.rxns));
       model.rxnNames(:) = {''};
   end
    model.rxnNames{rxnPos,1} = parser.Results.reactionName;
end

if ~any(ismember(parser.UsingDefaults,'subSystem'))
    if ~isfield(model,'subSystems')
        model.subSystems = cell(numel(model.rxns),1);
        model.subSystems(:) = {{''}};
    end
end

% 
if (isfield(model,'subSystems'))
    model.subSystems{rxnPos,1} = subSystem;
end
%This will have to be modified once the model structure is set.


%Give warning and combine the coeffeicient if a metabolite appears more than once
[metaboliteListUnique,~,IC] = unique(metaboliteList);
if numel(metaboliteListUnique) ~= numel(metaboliteList)
    warning('Repeated mets in the formula for rxn ''%s''. Combine the stoichiometry.', rxnID)
    stoichCoeffListUnique = zeros(size(metaboliteListUnique));
    for nMetsUnique = 1:numel(metaboliteListUnique)
        stoichCoeffListUnique(nMetsUnique) = sum(stoichCoeffList(IC == nMetsUnique));
    end
    %preserve the order of metabolites:
    metOrder = [];
    for i = 1:numel(IC)
        if ~ismember(IC(i), metOrder)
            metOrder = [metOrder; IC(i)];
        end
    end
    metaboliteList = metaboliteListUnique(metOrder);
    stoichCoeffList = stoichCoeffListUnique(metOrder);
end

% Figure out which metabolites are already in the model
[isInModel,metID] = ismember(metaboliteList,model.mets);

nNewMets = sum(~isInModel);

% Construct S-matrix column
newMetsCoefs=zeros(0);
for i = 1:length(metaboliteList)
    if (isInModel(i))
        Scolumn(metID(i),1) = stoichCoeffList(i);
    else
        warning(['Metabolite ' metaboliteList{i} ' not in model - added to the model']);
        model = addMetabolite(model,metaboliteList{i},metaboliteList{i});
        Scolumn(end+1,1) = stoichCoeffList(i);
    end
end



% if ~oldRxnFlag, model.rxnGeneMat(rxnID,:)=0; end

if (isfield(model,'genes'))
    if isempty(parser.Results.systNameList)
        model = changeGeneAssociation(model,rxnID,grRule);
    else
        model = changeGeneAssociation(model,rxnID,grRule,geneNameList,systNameList);
    end
end

% Figure out if the new reaction already exists
rxnInModel=false;
duplicatePos = [];
Stmp = model.S;
if ~((nNewMets > 0) && isempty(find(newMetsCoefs == 0, 1)))
    if (checkDuplicate)
        duplicatePos = find(all(Stmp == Scolumn(:, ones(1, size(Stmp, 2))), 1)); % Fucntionally equivalent to, but faster than find(ismember(Stmp',Scolumn','rows'));
        rxnIDexists = duplicatePos(~ismember(duplicatePos,rxnPos));
        if numel(rxnIDexists) > 1
            rxnIDexists = rxnIDexists(1);
        end
    end
end

%If the reaction is already present, and the updated reaction is not one of
%the reactions, which actually is matching.
if any(~(duplicatePos == rxnPos))
    warning(['Model already has the same reaction you tried to add: ' modelOrig.rxns{rxnIDexists}]);
    model = modelOrig;
else
    if (oldRxnFlag)
        model.S = Stmp;
        model.S(:,rxnPos) = Scolumn;
    else
        try
        model.S = [Stmp Scolumn];
        model = extendModelFieldsForType(model,'rxns');
        catch
            disp('test')
        end

    end
    if printLevel>0
        printRxnFormula(model,rxnID);
    end
end

end
