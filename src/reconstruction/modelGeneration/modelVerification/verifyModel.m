function results = verifyModel(model,varargin)
%VERIFYMODEL checks the model for consistency with the COBRA Toolbox
%
% USAGE:
%
%    results = verifyModel(model, varargin)
%
% Example:
%    results = verifyModel(model,'simpleCheck')
%    results = verifyModel(model,'massBalance')
%    results = verifyModel(model,'fluxConsistency','massBalance')
%    results = verifyModel(model,'simpleCheck','requiredFields',{'S,'lb','ub','c'})
%
% INPUT :
%    model:         a structure that represents the COBRA model.
%
% OPTIONAL INPUT:
%    varargin       varargin contains additional Checks that shall be performed. provided as
%                   Strings The results of the individual checks are returned as a structure
%                   array containing the relevant values.
%                   Options are:
%                   * 'massBalance' (checks for Mass balance if the metFormula
%                     Field is present)
%                   * 'chargeBalance' (checks for charge Balance)
%                   * 'fluxConsistency' (checks for reaction flux consistency)
%                   * 'stoichiometricConsistency' (checks for Stoichiometric
%                     Consisteny, according to Gevorgyan, Bioinformatics,
%                     2008)
%                   * 'deadEndMetabolites' (metabolites which can either not
%                     be produced, or consumed)
%                   * 'simpleCheck' returns 0 if this is not a valid model
%                     and 1 if it is a valid model, ignored if any other
%                     option is selected.
%                   * 'requiredFields' sets the fields which are required,
%                     the argument must be firectly followed by the list of
%                     required fields.
%                     default({'S','b','csense','lb','ub','c','osense','rxns','mets','genes','rules'})
%                   * 'checkDatabaseIDs', check whether the database
%                     identifiers in specified fields (please have a look
%                     at the documentation), match to the expected patterns
%                     for those databases.
%                   * 'silentCheck', do not print any information. Only
%                     applies to the model structure check. (default is to
%                     print info)
%
% OUTPUT:
%
%    results:       a struct containing fields for each requested option and an
%                   additional field Errors indicating the problems with the
%                   model structure detected by the verifyModel function.
%
% Authors:
%     - Thomas Pfau May 2017


requiredFields = {'S','b','csense','lb','ub','c','osense','rxns','mets','genes','rules'};

if any(ismember(varargin,'requiredFields'))
    requiredFields = varargin{find(ismember(varargin,'requiredFields')) + 1};
end

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
if any(ismember(varargin,'massBalance'))
    results.massBalance = struct();
    if checkFields(results,'metFormulas',model)
        if ~checkFields(results,'metCharges',model)
            %it contains a metFormulas field, and metCharges is invalid...
            model.metCharges = zeros(size(model.metFormulas));
        end
        [massImbalance, imBalancedMass, imBalancedCharge, imBalancedRxnBool, Elements, missingFormulaeBool, balancedMetBool] = checkMassChargeBalance(model,0);
        results.massBalance.massImbalance = massImbalance;
        results.massBalance.imBalancedMass = imBalancedMass;
        results.massBalance.imBalancedRxnBool = imBalancedRxnBool;
        results.massBalance.Elements = Elements;
        results.massBalance.missingFormulaeBool = missingFormulaeBool;
        results.massBalance.balancedMetBool = balancedMetBool;
    else
        results.massBalance.missingFields = 'The metFormulas field is missing. Cannot determine the mass Balance';
    end
end

%Do charge Balance checks
if any(ismember(varargin,'chargeBalance'))
    results.massBalance = struct();
    if checkFields(results,'metCharges',model)
        if ~checkFields(results,'metFormulas',model)
            %it contains a metCharges
            model.metFormulas = cell(size(model.metCharges));
            model.metFormulas(:) = {''};
        end
        if ~exists('imBalancedCharge','var')
            [~, ~, imBalancedCharge, ~, ~, ~, ~] = checkMassChargeBalance(model,0);
        end
        results.chargeBalance.imBalanceCharge = imBalancedCharge;
    else
        results.chargeBalance.missingFields = 'The metCharges field is missing. Cannot determine the charge Balance';
    end
end

if any(ismember(varargin,'fluxConsistency'))
    ProblematicFields = checkFields(results,requiredFields(1:7,1),model);
    if ~all(ProblematicFields) %this is odd... shouldn't refer to 1:7...
        warning('Fields Missing for consistency Testing')
        results.consistency.problematicFields = requiredFields(ProblematicFields,1);
    else
        [mins,maxs] = fluxVariability(model);
        results.fluxConsistency = struct();
        if isfield(model,'rxns')
            results.fluxConsistency.consistentReactions = model.rxns((abs(mins) > 1e-12) | (abs(maxs) > 1e-12));
        end
        results.fluxConsistency.consistentReactionBool = ( (abs(mins) > 1e-12)| (abs(maxs) > 1e-12));
    end

end

if any(ismember(varargin,'deadEndMetabolites'))
    mets = detectDeadEnds(model);
    results.deadEndMetabolites = struct();
    results.deadEndMetabolites.DeadEndMetabolites = model.mets(mets);
end

if any(ismember(varargin,'stoichiometricConsistency'))
    [SConsistentMetBool,SConsistentRxnBool,SInConsistentMetBool,SInConsistentRxnBool,unknownSConsistencyMetBool,~]=...
        findStoichConsistentSubset(model,0,0);

    stoichiometricConsistency = struct();
    stoichiometricConsistency.SConsistentMetBool = SConsistentMetBool;
    stoichiometricConsistency.SConsistentRxnBool = SConsistentRxnBool;
    stoichiometricConsistency.SInConsistentMetBool = SInConsistentMetBool;
    stoichiometricConsistency.SInConsistentRxnBool = SInConsistentRxnBool;
    stoichiometricConsistency.unknownSConsistencyMetBool = unknownSConsistencyMetBool;
    stoichiometricConsistency.unknownSConsistencyRxnBool = ununknownSConsistencyRxnBool;

    results.stoichiometricConsistency = stoichiometricConsistency ;
end

if ~isempty(results) && ~any(ismember(varargin,'silentCheck'))
    if isfield(results, 'Errors')
        problems = fieldnames(results.Errors);
        disp('The following problems have been encountered in the model structure')
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

if any(ismember(varargin,'checkDatabaseIDs'))
    results = checkDatabaseIDs(model,results);
end

if any(ismember(varargin,'simpleCheck'))
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


function results = checkDatabaseIDs(model,results)
dbMappings = getDefinedFieldProperties('Database',true);

for i= 1:size(dbMappings,1)
    if isfield(model,dbMappings{i,3})
        fits = cellfun(@(x) isempty(x) || checkID(x,dbMappings{i,5}),model.(dbMappings{i,3}));
        if any(~fits)
            if ~isfield(results,'checkDatabaseIDs')
                results.checkDatabaseIDs = struct();
            end
            if ~isfield(results.checkDatabaseIDs,'invalidIDs')
                results.checkDatabaseIDs.invalidIDs = struct();
            end
            results.checkDatabaseIDs.invalidIDs.(dbMappings{i,3}) = cell(size(model.(dbMappings{i,3})));
            results.checkDatabaseIDs.invalidIDs.(dbMappings{i,3})(~fits) = model.(dbMappings{i,3})(~fits);
        end
    end
end
end

function accepted = checkID(id,pattern)
    ids = strsplit(id,';');
    matches = regexp(ids,pattern);
    accepted = all(~cellfun(@isempty,matches));    
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
        results.Errors.propertiesNotMatched.(testedField) = ['Field does not match the required properties: ' fieldProperties{presentFields(i),4} ];
    end

end
end
