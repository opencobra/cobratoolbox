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
%                   * 'massBalance' (checks for Mass balance if the `metFormula` Field is present), (Default: false)
%                   * 'chargeBalance' (checks for charge Balance) (Default: false)
%                   * 'fluxConsistency' (checks for reaction flux consistency) (Default: false)
%                   * 'stoichiometricConsistency' (checks for Stoichiometric Consisteny, according to `Gevorgyan, Bioinformatics, 2008`) (Default: false)
%                   * 'deadEndMetabolites' (metabolites which can either not be produced, or consumed) (Default: false)
%                   * 'simpleCheck' returns false if this is not a valid model and true if it is a valid model, ignored if any other option is selected. (Default: false)
%                   * 'requiredFields' sets the fields which are required, the argument must be firectly followed by the list of required fields. (Default: {'S', 'lb', 'ub', 'c', 'rxns', 'mets', 'genes', 'rules'})
%                   * 'checkDatabaseIDs', check whether the database identifiers in specified fields (please have a look at the documentation), match to the expected patterns for those databases.
%                   * 'silentCheck', do not print any information. Only applies to the model structure check. (default is to print info)
%                   * 'restrictToFields' restricts the check to the listed fields. This will lead to requiredFields being reduced to those fields present in the restricted fields. If an empty cell array is provided no restriction is applied. (default: {})
%                   * 'FBAOnly' checks only fields relevant for FBA (default: false)
%
% OUTPUT:
%
%    results:     a struct containing fields for each requested option and an
%                 additional field `Errors` indicating the problems with the
%                 model structure detected by the `verifyModel` function.
%                 Results of additional options are returned in fields with
%                 the respective names.
%
% EXAMPLES:
%    1) Do a simple Field check with the default required fields.
%    results = verifyModel(model,'simpleCheck', true)
%    2) Do a mass balance check in addition to a field check.
%    results = verifyModel(model,'massBalance', true)
%    3) do a flux consistency and a mass Balance check.
%    results = verifyModel(model,'fluxConsistency', true,'massBalance', true)
%    4) do a simple check with a specified set of fields.
%    results = verifyModel(model,'simpleCheck', true,'requiredFields',{'S,'lb','ub','c'})
%
% .. Authors:
%       - Thomas Pfau, May 2017


optionalFields = getDefinedFieldProperties();

basicFields = optionalFields(cellfun(@(x) x, optionalFields(:,6)),1);
FBAFields = optionalFields(cellfun(@(x) x, optionalFields(:,8)),1);


parser = inputParser();
parser.addRequired('model',@isstruct);
parser.addParamValue('massBalance',false,@(x) isnumeric(x) || islogical(x));
parser.addParamValue('chargeBalance',false,@(x) isnumeric(x) || islogical(x));
parser.addParamValue('fluxConsistency',false,@(x) isnumeric(x) || islogical(x));
parser.addParamValue('deadEndMetabolites',false,@(x) isnumeric(x) || islogical(x));
parser.addParamValue('simpleCheck',false,@(x) isnumeric(x) || islogical(x));
parser.addParamValue('stoichiometricConsistency',false,@(x) isnumeric(x) || islogical(x));
parser.addParamValue('requiredFields',basicFields,@(x) iscell(x) && all(cellfun(@ischar, x)));
parser.addParamValue('checkDatabaseIDs',false,@(x) isnumeric(x) || islogical(x));
parser.addParamValue('silentCheck',false,@(x) isnumeric(x) || islogical(x));
parser.addParamValue('restrictToFields',{},@(x) iscell(x) && all(cellfun(@ischar, x)));
parser.addParamValue('FBAOnly',false,@(x) islogical(x) || isnumeric(x) );


parser.parse(model,varargin{:});

requiredFields = parser.Results.requiredFields;
massBalance = parser.Results.massBalance;
chargeBalance = parser.Results.chargeBalance;
fluxConsistency = parser.Results.fluxConsistency;
deadEndMetabolites = parser.Results.deadEndMetabolites;
simpleCheck = parser.Results.simpleCheck;
stoichiometricConsistency = parser.Results.stoichiometricConsistency;
checkDBs = parser.Results.checkDatabaseIDs;
silentCheck = parser.Results.silentCheck;
restrictToFields = parser.Results.restrictToFields;
FBAOnly = parser.Results.FBAOnly;

requiredFields = optionalFields(ismember(optionalFields(:,1), requiredFields),:);
optionalFields = optionalFields(~ismember(optionalFields(:,1), requiredFields(:,1)),:);

if ~isempty(restrictToFields)
    requiredFields = requiredFields(ismember(requiredFields(:,1),restrictToFields),:);
    optionalFields = optionalFields(ismember(optionalFields(:,1),restrictToFields),:);
end

if FBAOnly
    requiredFields = requiredFields(ismember(requiredFields(:,1),FBAFields),:);
    optionalFields = optionalFields(ismember(optionalFields(:,1),FBAFields),:);
end

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
    basicFBAFields = intersect(basicFields,FBAFields);
    ProblematicFields = checkFields(results,basicFBAFields,model);
    if ~all(ProblematicFields) %this is odd... shouldn't refer to 1:7...
        warning('Fields Missing for consistency Testing')
        results.consistency = struct();
        results.consistency.problematicFields = basicFBAFields(ProblematicFields,1);
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

if checkDBs
    results = checkDatabaseIDs(model,results);
end

%Print some info about the encountered problems if requested
if ~isempty(results) && ~silentCheck
    if isfield(results, 'Errors')
        problems = fieldnames(results.Errors);
        disp('verifyModel: The following problems have been encountered in the model structure')
        for i = 1:numel(problems)
            fprintf('%s:\n',problems{i})
            problem_data = results.Errors.(problems{i});
            if isstruct(problem_data)
                problematic_fields = fieldnames(problem_data);
                for field = 1: numel(problematic_fields)
                    fprintf('%s: %s\n',problematic_fields{field}, results.Errors.(problems{i}).(problematic_fields{field}));
                end
            else
                for field = 1:numel(problem_data)
                    fprintf('%s\n',problem_data{field});
                end
            end
        end
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
% Checks the given fields of the model in the results struct for
% consistency.
%
% USAGE:
%
%    valid = checkFields(results,FieldNames,model)
%
% INPUT:
%    results:     the results structure for this test
%    FieldNames:  The names of the fields to check.
%    model:       a structure that represents the COBRA model.
%
% OUTPUT:
%
%    valid:     whether the field is valid given the information in
%               results.
%
% .. Authors:
%       - Thomas Pfau, May 2017

if ischar(FieldNames)
    FieldNames = {FieldNames};
end
valid = cellfun(@(x) isfield(model,x) && ...
    (~isfield(results,'Errors') || ...                              %This condition checks,
    ~isfield(results.Errors,'inconsistentFields') || ...            %whether the fieldProperties field
    ~isfield(results.Errors.inconsistentFields,x)),FieldNames);  % is inconsistent, if it exists.
end