function results = verifyModel(model, varargin)
% Checks the model for consistency with the COBRA Toolbox
%
% USAGE:
%
%    results = verifyModel(model, varargin)
%
% INPUT:
%    model:       a structure that represents the COBRA model.
%
% OPTIONAL INPUT:
%    varargin:    varargin describes the additional checks (except the
%                 basic check whether a models fields adhere to the field
%                 definitions. They are to be provided as ParameterName,
%                 Value pairs (e.g. verifyModel(model, 'massBalance', true)
%                 Options are:
%
%                   * 'massBalance' (checks for Mass balance if the
%                     `metFormula` Field is present), (Default: false)
%                   * 'chargeBalance' (checks for charge Balance) (Default: false)
%                   * 'fluxConsistency' (checks for reaction flux
%                     consistency) (Default: false)
%                   * 'stoichiometricConsistency' (checks for Stoichiometric
%                     Consisteny, according to `Gevorgyan, Bioinformatics,
%                     2008`) (Default: false)
%                   * 'deadEndMetabolites' (metabolites which can either not
%                     be produced, or consumed) (Default: false)
%                   * 'simpleCheck' returns 0 if this is not a valid model
%                     and 1 if it is a valid model, ignored if any other
%                     option is selected. (Default: false)
%                   * 'requiredFields' sets the fields which are required,
%                     the argument must be firectly followed by the list of
%                     required fields.
%                     (Default: {'S', 'b', 'csense', 'lb', 'ub', 'c', 'osense', 'rxns', 'mets', 'genes', 'rules'})
%
% OUTPUT:
%
%    results:     a struct containing fields for each requested option and an
%                 additional field `Errors` indicating the problems with the
%                 model structure detected by the `verifyModel` function.
%                 Results of additional options are returned in fields with
%                 the respective names. 
%
% EXAMPLE:
%
%    results = verifyModel(model,'simpleCheck')
%    results = verifyModel(model,'massBalance')
%    results = verifyModel(model,'fluxConsistency','massBalance')
%    results = verifyModel(model,'simpleCheck','requiredFields',{'S,'lb','ub','c'})
%
% .. Authors:
%       - Thomas Pfau, May 2017

fluxConsistencyFields = {'S','b','csense','lb','ub','c','osense','rxns','mets','genes','rules'};

parser = inputParser();
parser.addRequired('model',@isstruct);
parser.addParameter('massBalance',false,@(x) isnumeric(x) || islogical(x));
parser.addParameter('chargeBalance',false,@(x) isnumeric(x) || islogical(x));
parser.addParameter('fluxConsistency',false,@(x) isnumeric(x) || islogical(x));
parser.addParameter('deadEndMetabolites',false,@(x) isnumeric(x) || islogical(x));
parser.addParameter('simpleCheck',false,@(x) isnumeric(x) || islogical(x));
parser.addParameter('stoichiometricConsistency',false,@(x) isnumeric(x) || islogical(x));
parser.addParameter('requiredFields',fluxConsistencyFields,@(x) iscell(x) && all(cellfun(@ischar, x)));

parser.parse(model,varargin{:});

requiredFields = parser.Results.requiredFields;
massBalance = parser.Results.massBalance;
chargeBalance = parser.Results.chargeBalance;
fluxConsistency = parser.Results.fluxConsistency;
deadEndMetabolites = parser.Results.deadEndMetabolites;
simpleCheck = parser.Results.simpleCheck;
stoichiometricConsistency = parser.Results.stoichiometricConsistency;

[optionalFields] = getDefinedFieldProperties();
requiredFields = optionalFields(ismember(optionalFields(:,1), requiredFields),:);
optionalFields = optionalFields(~ismember(optionalFields(:,1), requiredFields(:,1)),:);

results = struct();
results.Errors = struct();
%First, check for missing required Fields
missingFields = setdiff(requiredFields(:,1),fieldnames(model));
if ~isempty(missingFields)
    results.Errors.missingFields = missingFields;
end

results = checkPresentFields(requiredFields,model,results);
results = checkPresentFields(optionalFields,model,results);
if checkFields(results,'fieldProperties',model)
    results = checkPresentFields(model.fieldProperties,model,results);
end

if isempty(fieldnames(results.Errors))
    results = struct();
end

%Do mass Balance Checks
if massBalance || chargeBalance
    doChargeBalance = false;
    if chargeBalance
         if checkFields(results,'metCharges',model)
             doChargeBalance = true;
         else
             results.chargeBalance = struct();
             results.chargeBalance.missingFields = 'The metCharges field is missing. Cannot determine the charge Balance';
         end
    end
    doMassBalance = false;
    if massBalance
         if checkFields(results,'metFormulas',model)
             doMassBalance = true;
         else
             results.massBalance = struct();
             results.massBalance.missingFields = 'The metFormulas field is missing. Cannot determine the mass Balance';
         end
    end
    
    if doMassBalance || doChargeBalance
        %Add missing fields, because at least one of the fields is present
        %and valid.
        if ~checkFields(results,'metCharges',model)
            model.metCharges = NaN(size(model.metFormulas));
        end
        if ~checkFields(results,'metFormulas',model)
            model.metFormulas = cell(size(model.metCharges));
            model.metFormulas(:) = {''};
        end
        [massImbalance, imBalancedMass, imBalancedCharge, imBalancedRxnBool, Elements, missingFormulaeBool, balancedMetBool] = checkMassChargeBalance(model,0);
        %put the fields, if simpleCheck is active and there are imbalanced,
        %or if simplecheck is not active.
        if doMassBalance && (~simpleCheck || any(imBalancedRxnBool))            
            results.massBalance = struct();
            results.massBalance.massImbalance = massImbalance;
            results.massBalance.imBalancedMass = imBalancedMass;
            results.massBalance.imBalancedRxnBool = imBalancedRxnBool;
            results.massBalance.Elements = Elements;
            results.massBalance.missingFormulaeBool = missingFormulaeBool;
            results.massBalance.balancedMetBool = balancedMetBool;            
        end
        %Add the fields, if its either not a simple Check or if 
        if doChargeBalance && (~simpleCheck || any(imBalancedCharge ~= 0))            
            results.chargeBalance = struct();
            results.chargeBalance.imBalanceCharge = imBalancedCharge;
        end
    end
end

if fluxConsistency
    ProblematicFields = checkFields(results,fluxConsistencyFields(1:7),model);
    if ~all(ProblematicFields) %this is odd... shouldn't refer to 1:7...
        warning('Fields Missing for consistency Testing')
        results.consistency = struct();
        results.consistency.problematicFields = fluxConsistencyFields(ProblematicFields,1);
    else
        [mins,maxs] = fluxVariability(model);
        %if this is not a simple check, or we have reactions which can't
        %carry flux.
        if ~simpleCheck || any( ~(abs(mins) > 1e-12)| (abs(maxs) > 1e-12)) 
            results.fluxConsistency = struct();
            if isfield(model,'rxns')
                results.fluxConsistency.consistentReactions = model.rxns((abs(mins) > 1e-12) | (abs(maxs) > 1e-12));
            end
            results.fluxConsistency.consistentReactionBool = ( (abs(mins) > 1e-12)| (abs(maxs) > 1e-12));
        end
    end

end

if deadEndMetabolites
    mets = detectDeadEnds(model);
    if ~simpleCheck || any(mets)
        results.deadEndMetabolites = struct();
        results.deadEndMetabolites.DeadEndMetabolites = model.mets(mets);
    end
end

if stoichiometricConsistency
    [SConsistentMetBool,SConsistentRxnBool,SInConsistentMetBool,SInConsistentRxnBool,unknownSConsistencyMetBool,~]=...
        findStoichConsistentSubset(model,0,0);
    if ~simpleCheck || any(SInConsistentMetBool) || any(SInConsistentRxnBool)
        stoichiometricConsistency = struct();
        stoichiometricConsistency.SConsistentMetBool = SConsistentMetBool;
        stoichiometricConsistency.SConsistentRxnBool = SConsistentRxnBool;
        stoichiometricConsistency.SInConsistentMetBool = SInConsistentMetBool;
        stoichiometricConsistency.SInConsistentRxnBool = SInConsistentRxnBool;
        stoichiometricConsistency.unknownSConsistencyMetBool = unknownSConsistencyMetBool;
        stoichiometricConsistency.unknownSConsistencyRxnBool = ununknownSConsistencyRxnBool;
        results.stoichiometricConsistency = stoichiometricConsistency ;
    end
end

if simpleCheck
    if isempty(fieldnames(results))
        results = true;
    else
        results = false;
    end
end
end

function valid = checkFields(results,FieldNames,model)
if ischar(FieldNames)
    FieldNames = {FieldNames};
end
valid = cellfun(@(x) isfield(model,x) && ...
    (~isfield(results,'Errors') || ...                              %This condition checks,
    ~isfield(results.Errors,'inconsistentFields') || ...            %whether the fieldProperties field
    ~isfield(results.Errors.inconsistentFields,x)),FieldNames);  % is inconsistent, if it exists.
end


function results = checkPresentFields(fieldProperties,model, results)
presentFields = find(ismember(fieldProperties(:,1),fieldnames(model)));

%Check all Field Sizes
for i = 1:numel(presentFields)
    testedField = fieldProperties{presentFields(i),1};
    [x_size,y_size] = size(model.(testedField));
    xFieldMatch = fieldProperties{presentFields(i),2};
    yFieldMatch = fieldProperties{presentFields(i),3};

    checkX = ~isnan(xFieldMatch);
    checkY = ~isnan(yFieldMatch);
    if checkX
        if ischar(xFieldMatch)
            x_pres = numel(model.(xFieldMatch));
        elseif isnumeric(xFieldMatch)
            x_pres = xFieldMatch;
        end
        if x_pres ~= x_size
            if ~isfield(results.Errors,'inconsistentFields')
                results.Errors.inconsistentFields = struct();
            end
            results.Errors.inconsistentFields.(testedField) = sprintf('%s: Size of %s does not match elements in %s', xFieldMatch,testedField,xFieldMatch);
        end
    end
    if checkY
        if ischar(yFieldMatch)
            y_pres = numel(model.(yFieldMatch));
        elseif isnumeric(yFieldMatch)
            y_pres = yFieldMatch;
        end
        if y_pres ~= y_size
            if ~isfield(results.Errors,'inconsistentFields')
                results.Errors.inconsistentFields = struct();
            end
            results.Errors.inconsistentFields.(testedField) = sprintf('%s: Size of %s does not match elements in %s', yFieldMatch,testedField,yFieldMatch);
        end
    end
    %Test the field content properties
    %x is necessary here, since it is used for the eval below!
    x = model.(testedField);
    try
        propertiesMatched = eval(fieldProperties{presentFields(i),4});
    catch
        propertiesMatched = false;
    end
    if ~propertiesMatched
        if ~isfield(results.Errors,'inconsistentFields')
            results.Errors.propertiesNotMatched = struct();
        end
        results.Errors.propertiesNotMatched.(testedField) = 'Field does not match the required properties';
    end

end
end
