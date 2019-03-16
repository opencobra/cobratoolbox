function surfNet(varargin)
% A simple and convenient tool to navigate through the metabolic network 
% interactively, possibly with given flux vectors, in the Matlab command 
% window using mouse once the starting point is called by command.
%
% USAGE:
%    surfNet(model, metrxn, metNameFlag, flux, nonzeroFluxFlag, showMets, printFields, charPerLine)
%    surfNet(model, metrxn, ... , 'name', 'value', ...)
%
% INPUT:
%    model:              COBRA model
%
% OPTIONAL INPUTS:
%    metrxn:             mets or rxns names, can be a cell array of multiple rxns and mets, or simply a string 
%                        (default: objective reactions or a random reaction)
%  (the arguments below can also be inputted as name-value pairs and partial matching is supported)
%    metNameFlag:        print model.metNames in reaction formulas. (default: false)
%    flux:               flux vectors for the model, a #reactions x #columns matrix. (default: [])
%                        If given, the producing and consuming reactions displayed are in accordance with the flux direction.
%    nonzeroFluxFlag:    show only reactions with nonzero fluxes if flux is given (default: true)
%    showMets:           show metabolites in a list when printing reactions (default: true)
%    printFields:        a cell array of field names of the fields to be printed for each met and rxn. 
%                        Default: {'metNames','metFormulas','rxnNames','lb','ub','grRules'}
%                        Use, e.g., {'default', 'rxnNotes'}, to print model.rxnNotes in addition to the defaulted fields.
%    charPerLine:        max. no. of characters per line for reaction formulas (default 0, the current width of the command window)
%
% EXAMPLES:
%
%    surfNet(model)  % for starting the navigation at the objective reaction
%    surfNet(model, 'glc-D[c]')  % for starting the navigation at D-glucose
%    surfNet(model, 'glc-D[c]', 'metNameFlag', 1)  % for printing model.metNames in reaction formulas
%    surfNet(model, 'glc-D[c]', 'm', 1)  % support partial mapping of the parameter name
%    surfNet(model, 'glc-D[c]', 'f', flux)  % for starting at glucose and show reactions with non-zero flux in 'flux' only
%    surfNet(model, 'EX_glc-D(e)', 's', 0)  % to show the reaction formulas only but not the details of metabolites during navigation
%    surfNet(model, 'EX_glc-D(e)', 'p', {'default', 'metKEGGID'})  % to print also the charge for each metabolite printed
%    surfNet(model, 'EX_glc-D(e)', 'p', {'d', 'metK'})  % support unambiguous partial matching
%    surfNet(model, {'glc-D[c]'; 'fru[c]'})  % to view several mets and rxns

fluxTol = 1e-8;  % tolerance for non-zero fluxes
[digitUB, digitLB] = deal(7, 5);  % largest digit and decimal places displayed for numbers (except stoich)
stoichDigit = 6;  % at most print six decimal places for stoichiometric coefficients
% default fields to be printed
field2printDefault = {{'metNames', 'metFormulas', 'metCharges'}, {'rxnNames', 'lb', 'ub', 'grRules'}};
%{'metNames'; 'metFormulas'; 'rxnNames'; 'lb'; 'ub'; 'grRules'; 'metCharges'};

% function handle to check cell string inputs
useIsString = ~isempty(which('isstring'));
isCellString = @(x) iscellstr(x) || (useIsString && isstring(x));
%% Handle input arguments
% define persistent variables for iterative calling
persistent pathLocal  % function output
persistent modelLocal  % local model for next iteration
persistent rxnFields  % rxn fields to be printed
persistent metFields  % met fields to be printed
persistent fluxLocal  % flux matrix

optionalArgin = {'metNameFlag', 'flux', 'nonzeroFluxFlag', 'showMets', 'printFields', 'charPerLine', 'iterOptions'};
defaultValues = {false, [], true, true, field2printDefault, 0, []};
validator = {@isscalar, @(x) isnumeric(x), @isscalar, @isscalar, ...
    @(x) isvalidPrintFields(x, isCellString), @isscalar, @(x) true};
[metrxn, tempargin, checkFields, stat, jArg] = deal([], {}, false, 0, 1);
if isempty(varargin)
    varargin = {[]};
end
while jArg <= numel(varargin)
    if jArg == 1
        if isstruct(varargin{jArg})  % 1st input being a COBRA model
            % non-empty model input resets modelLocal, pathLocal and fluxLocal (initial function call)
            [modelLocal, pathLocal, fluxLocal] = deal(varargin{jArg}, {}, []);
            checkFields = true;  % check model's fields to be printed
        elseif isempty(modelLocal)
            error('The persistent variable modelLocal in surfNet is empty. Please supply a COBRA model.');
        elseif ~isempty(varargin{jArg})
            [stat, warnMsg] = MetRxnOrNameValue(varargin{jArg});
        end
    elseif jArg == 2  % check whether the 2nd input is metrxn
        [stat, warnMsg] = MetRxnOrNameValue(varargin{jArg});
    elseif ischar(varargin{jArg}) && (jArg ~= 7 || ~isfield(modelLocal, varargin{jArg}))
        break  % name-value pair input begins
    elseif jArg > 9 || (jArg == 9 && ~isempty(varargin{1}))
        error('Too many input arguments');
    elseif ~isempty(varargin{jArg}) || jArg == 4
        % convert direct inputs to name-value pair inputs. Only pass empty input for flux.
        % iterOptions allowed only if no input model is given (iterative calling)
        tempargin((end + 1):(end + 2)) = [optionalArgin(jArg - 2); varargin(jArg)];
    end
    if jArg <= 2
        if stat == 1  % input being metrxn
            [metrxn, jArg] = deal(varargin{jArg}, 2);  % skip jArg = 2 if the 1st input is metrxn
        elseif stat == 2  % input being name-value pair
            break
        elseif stat == 3  % incorrect input
            warning('%s is/are neither metabolite(s) nor reaction(s) of the model.', warnMsg)
            return
        end
    end
    jArg = jArg + 1;
end
varargin = [tempargin, varargin(jArg:end)];
% make sure printFields input not being char
for jArg = 1:numel(varargin)
    if jArg < numel(varargin) && ischar(varargin{jArg}) && ...
            strncmpi('printFields', varargin{jArg}, numel(varargin{jArg})) && ischar(varargin{jArg + 1})
        varargin{jArg + 1} = varargin(jArg + 1);
        break
    end
end
% parse the name-value arguments
parser = inputParser();
for jArg = 1:numel(optionalArgin)
    parser.addParameter(optionalArgin{jArg}, defaultValues{jArg}, validator{jArg});
end
parser.CaseSensitive = false;
parser.parse(varargin{:});

metNameFlag = parser.Results.metNameFlag;
flux = parser.Results.flux;
nonzeroFluxFlag  = parser.Results.nonzeroFluxFlag;
showMets = parser.Results.showMets;
field2print = parser.Results.printFields(:);
nCharBreak = parser.Results.charPerLine;
iterOptions = parser.Results.iterOptions;

if nonzeroFluxFlag ~= 1 && nonzeroFluxFlag > 0
    fluxTol = abs(nonzeroFluxFlag);
end
% if not using defaults and it is a cell string or string array input
if ~any(strcmp(parser.UsingDefaults, 'printFields')) && isCellString(field2print)
    % search for 'default' (allow short-hand input)
    idFieldDefault = find(cellfun(@(x) strncmpi(x, 'default', length(x)), field2print));
    % if more than one match, get the one matches the most
    [~, idFieldDefaultBest] = max(cellfun(@length, field2print(idFieldDefault)));
    idFieldDefault = idFieldDefault(idFieldDefaultBest);
    % if 'default' is in the input and not any field in the model is also called 'default' (usually not)
    if ~isempty(idFieldDefault) && ~any(strcmp(field2print(idFieldDefault), fieldnames(modelLocal)))
        % print default fields
        field2printDefaultInModel = [field2printDefault{1}(:); field2printDefault{2}(:)];
        field2printDefaultInModel = field2printDefaultInModel(ismember(field2printDefaultInModel, fieldnames(modelLocal)));
        field2print = [field2printDefaultInModel; field2print(setdiff(1:numel(field2print), idFieldDefault))];
    end
end
if isCellString(field2print)
    % make sure the fields are unique
    field2print = unique(field2print, 'stable');
    % check if .grRules exists. If not, try to get .grRules from .rules and .genes
    printGrRules = strcmp(field2print, 'grRules');
else
    % make sure the fields are unique
    field2print{1} = unique(field2print{1}, 'stable');
    field2print{2} = unique(field2print{2}, 'stable');
    % check if .grRules exists. If not, try to get .grRules from .rules and .genes
    printGrRules = strcmp(field2print{2}, 'grRules');
end
if any(printGrRules)
    if ~isfield(modelLocal, 'grRules') || all(cellfun(@isempty, modelLocal.grRules))
        % if .grRules does not exist or is all empty
        if isfield(modelLocal, 'rules') && any(~cellfun(@isempty, modelLocal.rules))
            % if non-empty .rules exists
            if any(~cellfun(@isempty, modelLocal.genes))
                % if non-empty .genes exist, generate .grRules
                modelLocal = rules2grRules(modelLocal);
            else
                % else print .rules
                if isCellString(field2print)
                    field2print{printGrRules} = 'rules';
                else
                    field2print{2}{printGrRules} = 'rules';
                end
            end
        else
            % else print nothing about GPR
            if isCellString(field2print)
                field2print(printGrRules) = [];
            else
                field2print{2}(printGrRules) = [];
            end
        end
    end
end
% options for showing previous steps
[showPrev, printShowPrev] = deal(false, true);
if ~isempty(iterOptions)
    if isfield(iterOptions, 'showPrev')
        showPrev = iterOptions.showPrev;
    end
    if isfield(iterOptions, 'printShowPrev')
        printShowPrev = iterOptions.printShowPrev;
    end
end

% nCharBreak is the maximum number of characters per line when printing equations
if nCharBreak == 0
    nCharBreakReal = get(0,'CommandWindowSize');
    nCharBreakReal = nCharBreakReal(1);
else
    nCharBreakReal = nCharBreak;
end

fluxInputErr = false;
if any(strcmp(parser.UsingDefaults, 'flux'))
    % calling with no flux arguement empties fluxLocal
    fluxLocal = [];
else
    if isscalar(flux) && isnan(flux)
        % calling with NaN also empties fluxLocal
        fluxLocal = [];
    elseif ~isempty(flux)
        % calling with non-empty flux arguement resets fluxLocal
        if size(flux, 2) == numel(modelLocal.rxns)
            flux = flux';
        elseif size(flux, 1) ~= numel(modelLocal.rxns)
            fluxInputErr = true;
        end
        fluxLocal = flux;        
    end
    % otherwise, calling with empty flux arguement uses previous fluxLocal
end

% if a reaction or metabolite is not given
if ~showPrev && isempty(metrxn)
    if any(modelLocal.c) && (isempty(fluxLocal) || any(abs(fluxLocal(modelLocal.c ~= 0, 1)) > fluxTol))
        % print objective function if no flux vector is given or the objective function value in the flux vector is nonzero 
        metrxn = modelLocal.rxns(modelLocal.c ~= 0);
    else
        % pick a random reaction otherwise
        if ~isempty(fluxLocal)
            sample = find(abs(fluxLocal(:, 1)) > fluxTol);
            metrxn = modelLocal.rxns{sample(randi(length(sample),1))};
        else            
            metrxn = modelLocal.rxns{randi(numel(modelLocal.rxns), 1)};
        end
    end
end

%% Check model's fields to be printed
if checkFields 
    % remove fields that are not in the model if using the defaulted field2print
    if any(strcmp(parser.UsingDefaults, 'printFields'))
        field2print = cellfun(@(x) x(ismember(x, fieldnames(modelLocal))), field2print, 'UniformOutput', false);
    end
    
    % unsupported fields
    uspField = {'S', 'rxnGeneMat'};
    % find unsupported fields in the input
    if isCellString(field2print)
        uspFieldInput = ismember(field2print, uspField);
        uspField = field2print(uspFieldInput);
        field2print(uspFieldInput) = [];
        field2check = field2print;
    else
        uspFieldInput = cellfun(@(x) ismember(x(:), uspField), field2print, 'UniformOutput', false);
        uspField = [columnVector(field2print{1}(uspFieldInput{1})); columnVector(field2print{2}(uspFieldInput{2}))];
        for k = 1:2
            field2print{k}(uspFieldInput{k}) = [];
        end
        field2check = [field2print{1}(:); field2print{2}(:)];
    end
    if ~isempty(uspField)
        warning('surfNet does not support showing %s. Ignore.', strjoin(uspField, ', '));
    end
    
    % check the existence of the fields
    fn = fieldnames(modelLocal);
    ynF = true(numel(field2check), 1);
    multiPartialMatch = repmat({''}, numel(field2check), 1);
    msgMPM = '';
    for j = 1:numel(field2check)
        % perfect match
        ynJ = strcmp(field2check{j}, fn);
        if ~any(ynJ)
            % partial match
            ynJ = strncmp(field2check{j}, fn, length(field2check{j}));
            if sum(ynJ) == 1
                % okay for unique partial match
                if isCellString(field2print)
                    field2print(strcmp(field2print, field2check{j})) = fn(ynJ);
                else
                    field2print{1}(strcmp(field2print{1}, field2check{j})) = fn(ynJ);
                    field2print{2}(strcmp(field2print{2}, field2check{j})) = fn(ynJ);
                end
            elseif sum(ynJ) > 1
                % multiple partial match
                multiPartialMatch{j} = fn(ynJ);
                msgMPM = [msgMPM, '\nThe partial input "' field2check{j} ...
                    '" matches to >1 fields: ', strjoin(fn(ynJ), ', ')];
            else
                ynF(j) = false;
            end
        end 
    end
    msgErr = '';
    if ~all(ynF)
        msgErr = ['The following field(s) is(are) not in the model: ', ...
                strjoin(field2check(~ynF), ', ')];
    end
    msgErr = [msgErr, msgMPM];
    if ~isempty(msgErr)
        error(msgErr)
    end
    
    % identify fields for metabolites and reactions
    nS = size(modelLocal.S);
    if isCellString(field2print)
        ynF = ismember(field2print, {'rxns', 'mets'});
        field2print = columnVector(field2print(~ynF));
        % fields starting with 'rxn' or 'met' or other standard fields
        rxnF = strncmpi('rxn', field2print, 3) | ismember(field2print, {'rev'; 'lb'; 'ub'; 'c'; 'rules'; 'grRules'; 'subSystems'});
        metF = strncmpi('met', field2print, 3) | ismember(field2print, {'b'; 'csense'});
        % assign fields as rxn or met fields by their sizes
        [metF(cellfun(@(x) any(size(modelLocal.(x)) == nS(1)), field2print) & ~rxnF), ...
            rxnF(cellfun(@(x) any(size(modelLocal.(x)) == nS(2)), field2print) & ~metF)] = deal(true);
        if any(metF & rxnF)
            warning('Same number of mets and rxns. The following field(s) is(are) displayed as rxn field(s): %s.', ...
                strjoin(field2print(metF & rxnF), ', '));
        end
        if any(~metF & ~rxnF)
            error('The following field(s) cannot be recognized as met or rxn field(s): %s', ...
                strjoin(field2print(~metF & ~rxnF), ', '));
        end
        field2print = {field2print(metF & ~rxnF), field2print(rxnF)}; 
    end
    
    % check data type and if the sizes are equal to #mets or #rxns
    [badsize, notCellNum, MetOrRxn, errMsg] = deal(cell(2, 1), cell(2, 1), {'met'; 'rxn'}, '');
    for i = 1:2
        [badsize{i}, notCellNum{i}] = deal(false(numel(field2print{i}), 1));
        % loop over met and rxn fields respectively
        for jF = 1:numel(field2print{i})
            % check sizes
            if size(modelLocal.(field2print{i}{jF}), 1) ~= nS(i)
                if size(modelLocal.(field2print{i}{jF}), 2) == nS(i)
                    modelLocal.(field2print{i}{jF}) = modelLocal.(field2print{i}{jF})';
                else
                    badsize{i}(jF) = true;
                end
            end
            % check data type
            if ischar(modelLocal.(field2print{i}{jF})) && ~badsize{i}(jF)
                % allow character arrays. Convert them into cell strings
                modelLocal.(field2print{i}{jF}) = cellstr(modelLocal.(field2print{i}{jF}));
            elseif iscell(modelLocal.(field2print{i}{jF})) && ~badsize{i}(jF)
                % make sure all empty cell has '' as content instead of []
                modelLocal.(field2print{i}{jF})(cellfun(@isempty, modelLocal.(field2print{i}{jF}))) = {''};
            end
            % unsupported data type
            notCellNum{i}(jF) = ~isnumeric(modelLocal.(field2print{i}{jF})) & (~iscell(modelLocal.(field2print{i}{jF})) ...
                || ~all(cellfun(@(x) ischar(x) || isCellString(x), modelLocal.(field2print{i}{jF}))));
        end
        % error message for incorrect sizes or unsupported datatypes
        if any(badsize{i})
            errMsg = sprintf('%sIncorrect size of the following %s field(s): %s\n', ...
                errMsg, MetOrRxn{i}, strjoin(field2print{i}(badsize{i}), ', ')); 
        end
        if any(notCellNum{i})
            errMsg = sprintf('%sThe following %s field(s) is(are) neither numeric nor cell array of characters: %s\n', ...
                errMsg, MetOrRxn{i}, strjoin(field2print{i}(notCellNum{i}), ', ')); 
        end
    end
    
    % error message
    if ~isempty(errMsg)
        error('%s', strtrim(errMsg))
    end
    
    % define metFields and rxnFields
    metFields = field2print{1}(:);
    rxnFields = field2print{2}(:);    
end

% raise error after checking model to avoid errors in iterative calls
if fluxInputErr
    error('Input flux vector has incorrect dimension.')
end

% print lb, ub or not
[showLB, showUB] = deal(any(strcmp(rxnFields, 'lb')), any(strcmp(rxnFields, 'ub')));
rxnFieldsForInfo = rxnFields(~ismember(rxnFields, {'lb', 'ub'}));


%% Show previous steps (called by mouse clicking only)
if showPrev
    fprintf('\n');
    nChar = 0;
    for jPast = 1:size(pathLocal, 1)
        % print each of the previous metabolites navigated
        if ~isempty(pathLocal{jPast, 1})
            if metNameFlag
                % print the metabolite name
                namePrint = modelLocal.metNames{findMetIDs(modelLocal, pathLocal{jPast, 1})};
            else
                % or print the metabolite abbreviation
                namePrint = pathLocal{jPast, 1};
            end
            % line break if exceeding character per line
            if nChar > 0 && nChar + length(namePrint) + 2 > nCharBreakReal
                fprintf('\n');
                nChar = 0;
            end
            nChar = nChar + length(namePrint) + 2;
            printFcn(pathLocal{jPast, 1}, namePrint, 0);
            fprintf('>>'); 
        end
        % print each of the previous reactions navigated
        if ~isempty(pathLocal{jPast, 2})
            % line break if exceeding character per line
            if nChar > 0 && nChar + length(pathLocal{jPast, 2}) > nCharBreakReal
                fprintf('\n');
                nChar = 0;
            end
            nChar = nChar + length(pathLocal{jPast, 2}) + 2;
            printFcn(pathLocal{jPast, 2}, pathLocal{jPast, 2}, 0);
            fprintf('>>');
        end     
    end
    fprintf('\n');
    return
end

%% iteractive calling if the input is a list of reactions and metabolites
if iscell(metrxn)
    if numel(metrxn) == 1
        metrxn = metrxn{1};
    else
        iterOptionsCell.printShowPrev = false;
        for jMR = 1:numel(metrxn)
            if jMR == numel(metrxn)
                iterOptionsCell.printShowPrev = true;
            end
            if isempty(fluxLocal)
                surfNet([], metrxn{jMR}, metNameFlag, NaN, 0, showMets, [], nCharBreak, iterOptionsCell);
            else
                surfNet([], metrxn{jMR}, metNameFlag, [], nonzeroFluxFlag, showMets, [], nCharBreak, iterOptionsCell);
            end
        end
        return
    end
end

%% input is a reaction
% string indicating non-zero fluxes or not for printing
nzFluxPrint = '';
if ~isempty(fluxLocal)
    % reaction direction for determining consumption or production if flux is given
    direction = ones(1, size(modelLocal.S, 2));
    if nonzeroFluxFlag
        nzFluxPrint = ' with non-zero fluxes ';
        direction(fluxLocal(:, 1) <= -fluxTol) = -1;
        direction(all(abs(fluxLocal) < fluxTol, 2)) = 0;
    else
        direction(fluxLocal(:, 1) < 0) = -1;
    end
else
    direction = 1;
end

id = findRxnIDs(modelLocal, metrxn);
if id ~= 0
    if isempty(pathLocal)
        pathLocal = {'', ''}; 
    end
    if ~isempty(pathLocal{end, 2})
        pathLocal(end + 1, :) = {'', ''}; 
    end
    pathLocal{end, 2} = metrxn;
    
    % print reaction flux
    fprintf('\nRxn #%d  %s%s', id, metrxn, printFlux(id));
    
    % print bounds
    printBounds(id);
    
    % print rxn info
    printMetRxnInfo(id, rxnFieldsForInfo, 1, true, 'rxnNames');
    
    % print reaction formula
    p = printRxnFormula(modelLocal, metrxn, 0, 1, 0);
    dirRxn = 1;  % direction of the reaction
    if ~isempty(fluxLocal)
        % If flux is given, non-negative flux treated as forward direction and -ve flux as reverse direction
        dirRxn = sign(direction(id) + 0.1);
    end
    % all the metabolite involved
    m = {find(modelLocal.S(:, id) * dirRxn <0); find(modelLocal.S(:, id) * dirRxn > 0)};
    % dictionary for printing mets or metNames in equation
    dict = modelLocal.mets([m{1}; m{2}]);
    if metNameFlag 
        dict(:, 2) = modelLocal.metNames([m{1}; m{2}]);
    end
    % get each part of the reaction formula and add hyperlink
    formPart = strsplit(p{1});
    % use the default arrow
    arrow = 'o';
    if ~isempty(fluxLocal)
        % use '->' for +ve flux, use '<-' for -ve flux
        if fluxLocal(id) > 0
            arrow = '->';
        elseif fluxLocal(id) < 0
            arrow = '<-';
        end
    end
    printFormulae(formPart, dict, arrow);

    % print reactants and products in detail
    if showMets
        % max. met's length
        dispLen1 = max(cellfun(@length, modelLocal.mets([m{1};m{2}])));
        dis1 = ['  %-' num2str(dispLen1) 's'];
        % max. met's ID length
        dispLen2 = max([m{1};m{2}]);
        dis1 = ['  %-' num2str(ceil(log10(dispLen2)) + 1) 's' dis1];
        dis2 = [' #%-' num2str(ceil(log10(dispLen2)) + 1) 'd'];
        fprintf(['\n' dis1 '  Stoich     '], 'id', 'Met');
        for jF = 1:numel(metFields)
            if jF > 1
                fprintf(', ');
            end
            fprintf('%s', metFields{jF});
        end
        fprintf('\n');
        for jRP = 1:numel(m)
            if jRP == 1
                fprintf('Reactant:\n');
            else
                fprintf('Product:\n');
            end
            for j = 1:numel(m{jRP})
                % format the printing of the stoichiometric coefficient
                if floor(modelLocal.S(m{jRP}(j), id)) ~= modelLocal.S(m{jRP}(j), id)
                % use exponential notation if there are too many decimal places
                    d = 0;
                    x = modelLocal.S(m{jRP}(j), id);
                    while x ~= round(x, d) && d <= stoichDigit
                        d = d + 1;
                    end
                    if round(x, d) == 0
                        stForm = '%-9.2e';
                    else
                        stForm = ['%-9.' num2str(d) 'f'];
                    end
                else
                    stForm = '%-9.0f';
                end
                % print metabolite ID
                fprintf([dis2 '  '], m{jRP}(j));
                % print metabolite with hyperlink
                printFcn(modelLocal.mets{m{jRP}(j)}, modelLocal.mets{m{jRP}(j)}, dispLen1);
                % print stoichiometric coefficients and other called fields
                fprintf(['  ' stForm '  '], full(modelLocal.S(m{jRP}(j), id)));
                % print met fields
                printMetRxnInfo(m{jRP}(j), metFields, 2, false, '');
            end
        end
    else
        fprintf('\n');
    end
else
    %% input is a metabolite
    id = findMetIDs(modelLocal, metrxn);
    pathLocal(end + 1, :) = {metrxn, ''};
    fprintf('\nMet #%d  %s', id, modelLocal.mets{id});

    % print met fields
    printMetRxnInfo(id, metFields, 1, true, {'metNames'; 'metFormulas'});
    fprintf('\n');
    
    for jCP = 1:2
        if jCP == 1
            % print consuming reactions (taking into account of flux direction if given)
            r = find(modelLocal.S(id, :) .* direction < 0);
            fprintf('Consuming reactions%s:', nzFluxPrint);
        else
            % print producing reactions (taking into account of flux direction if given)
            r = find(modelLocal.S(id, :) .* direction > 0);
            fprintf('Producing reactions%s:', nzFluxPrint);
        end
        if isempty(r)
            fprintf(' none\n');
        else
            % print all connected reactions
            fprintf('\n');
            p = printRxnFormula(modelLocal, modelLocal.rxns(r), 0, 1, 0);            
            for j = 1:numel(r)
                % print reaction info
                fprintf('  #%d  ', r(j));
                printFcn(modelLocal.rxns{r(j)}, modelLocal.rxns{r(j)}, 0);
                
                % print flux
                fprintf('%s', printFlux(r(j)));
                
                % print bounds
                printBounds(r(j));

                % print rxn info
                printMetRxnInfo(r(j), rxnFieldsForInfo, 1, true, 'rxnNames');

                % print reaction formula
                m = find(modelLocal.S(:, r(j)));
                % dictionary for printing mets or metNames in equation
                dict = modelLocal.mets(m);
                if metNameFlag
                    dict(:, 2) = modelLocal.metNames(m);
                end
                % similarly get each part of the formula
                formPart = strsplit(p{j});
                % use the default arrow
                arrow = 'o';
                if ~isempty(fluxLocal)
                    % use '->' for +ve flux, use '<-' for -ve flux
                    if fluxLocal(r(j)) > 0
                        arrow = '->';
                    elseif fluxLocal(r(j)) < 0
                        arrow = '<-';
                    end
                end
                printFormulae(formPart, dict, arrow);
                fprintf('\n');
            end
        end
    end
end

% print the button for showing previously navigated mets and rxns
if printShowPrev
    if ~isempty(fluxLocal)
        fprintf('\n<a href="matlab: surfNet([], [], %d, [], %d, %d, [], %d, struct(''showPrev'', true));">%s</a>\n', ...
            metNameFlag, nonzeroFluxFlag, showMets, nCharBreak, 'Show previous steps...');
    else
        fprintf('\n<a href="matlab: surfNet([], [], %d, NaN, 0, %d, [], %d, struct(''showPrev'', true));">%s</a>\n', ...
            metNameFlag, showMets, nCharBreak, 'Show previous steps...');
    end
end

% nested print function for printing strings on command window with interactive calling
    function printFcn(abb, name, digit)
        if ~isempty(fluxLocal)
            sPrint = ['<a href="matlab: surfNet([], ''%s'', %d, [], %d, %d, [], %d);">%' num2str(digit) 's</a>'];
            fprintf(sPrint, abb, metNameFlag, nonzeroFluxFlag, showMets, nCharBreak, name);
        else
            sPrint = ['<a href="matlab: surfNet([], ''%s'', %d, NaN, 0, %d, [], %d);">%' num2str(digit) 's</a>'];
            fprintf(sPrint, abb, metNameFlag, showMets, nCharBreak, name);
        end 
    end

% nested function for determining the number of digits to be printed
    function s = digit2disp(f, cellOut)
        if ~isscalar(f)
            s = cell(numel(f), 1);
            for jD = 1:numel(f)
                s{jD} = digit2disp(f(jD));
            end
            return
        end
        if abs(f) >= 1e-12 && (abs(f) >= 10^digitUB || abs(f) <= 10^(-digitLB))
            s = sprintf('%.2e', f);  % exponential notation for very large and small values
        else
            if isfloat(f)
                % decimal place or integer rounded to
                digitRound = floor(log10(abs(f)));
                digitRound = digitRound + (digitRound < 6);
                digitRound = min(digitLB, digitUB - digitRound - 1);
                % need to use roundn(f, -digitRound) instead for R2014a or before
                s = sprintf(['%.' num2str(digitLB) 'f'], round(f, digitRound));
                % trim trailing zeros
                s = regexprep(regexprep(s, '\.0+$', ''), '(\.\d*[1-9])0+$', '$1');
            else
                s = num2str(f); %convert to string directly for non-floating values (integer)
            end
        end
        if nargin == 2 && cellOut
            s = {s};
        end
    end

% nested function for formating fluxes to be printed
    function fluxStr = printFlux(rxnId)
        fluxStr = '';
        if ~isempty(fluxLocal)
            fluxStr = [' (' strjoin(digit2disp(fluxLocal(rxnId,:), true), ', ') ')'];
        end
    end

% nested function for printing flux bounds
    function printBounds(rxnId)
        if showLB && showUB
            fprintf(', Bd: %s / %s', digit2disp(modelLocal.lb(rxnId)), digit2disp(modelLocal.ub(rxnId)));
        elseif showLB
            fprintf(', LB: %s', digit2disp(modelLocal.lb(rxnId)));
        elseif showUB
            fprintf(', UB: %s', digit2disp(modelLocal.ub(rxnId)));
        end
    end

% nested function for printing rxn/met info
    function printMetRxnInfo(metrxnId, fields, firstFieldWtComma, printFieldName, fieldNameNotPrinted)
        for kF = 1:numel(fields)
            if kF >= firstFieldWtComma
                fprintf(', ');
            end
            if printFieldName && ~any(strcmp(fields{kF}, fieldNameNotPrinted))
                fprintf('%s: ', fields{kF});
            end
            if iscell(modelLocal.(fields{kF}))
                % if it is a cell array
                if iscell(modelLocal.(fields{kF}){metrxnId})
                    % concatenate if the cell content is a cell array of strings
                    ToPrint = strjoin(modelLocal.(fields{kF}){metrxnId}, '|');
                else
                    % cell array of strings
                    ToPrint = modelLocal.(fields{kF}){metrxnId};
                end
            else
                % if it is a value, format it properly
                ToPrint = digit2disp(modelLocal.(fields{kF})(metrxnId));
            end
            fprintf('%s', ToPrint);
        end
        fprintf('\n');
    end

% nested function for printing formulae
    function printFormulae(formulaeParts, dict, arrow)
        nChar2 = 0;  % number of characters per line
        lineBreak = false;
        
        for jPart = 1:numel(formulaeParts)
            
            metEqPrint = '';
            f = strcmp(dict(:, 1), formulaeParts{jPart});
            % if the current part is a metabolite
            if any(f)
                metEqPrint = dict{f, 1 + metNameFlag};
            end
            nChar2 = nChar2 + length(metEqPrint);
            
            if isempty(metEqPrint)
                % not a metabolite name (stoich/'+'/'->'/'<=>')
                % change the arrow if neeeded
                if ~strcmp(arrow, 'o') && (any(formulaeParts{jPart} == '<') || any(formulaeParts{jPart} == '>'))
                    formulaeParts{jPart} = arrow;
                end
                % check if a new line is needed
                nChar2 = nChar2 + length(formulaeParts{jPart}) + 1;  % +1 for the space
                if nChar2 > 0  % nChar2 > 0 implies something has been printed on the line
                    if isnan(str2double(formulaeParts{jPart})) || jPart == numel(formulaeParts)
                        % not a stoich ('+'/'->'/'<=>'): new line if current nChar2 exceeds the limit
                        if nChar2 - 1 > nCharBreakReal
                            lineBreak = true;
                        end
                    else
                        % stoich coeff: new line if together with the coming metID, #characters exceeds the limit
                        if nChar2 + length(formulaeParts{jPart + 1}) > nCharBreakReal
                            lineBreak = true;
                        end
                    end
                end
                if lineBreak && jPart > 1
                    fprintf('\n  ');
                    nChar2 = length(formulaeParts{jPart}) + 3;  % 2 spaces before + 1 space after
                    lineBreak = false;
                end
                fprintf('%s ', formulaeParts{jPart});
            else
                % print hyperlink if it is a metabolite name
                printFcn(formulaeParts{jPart}, metEqPrint, 0);
                fprintf(' ');
            end
        end
    end
    
% nested function for checking whether an input is metrxn or name-value pair
    function [stat, warnMsg] = MetRxnOrNameValue(x)
        [stat, warnMsg] = deal(1, '');
        if ~isempty(x)
            if ischar(x) 
                if ~(findRxnIDs(modelLocal, x) || findMetIDs(modelLocal, x))
                    stat = 2;  % input being name-value pair
                    if ~any(strncmpi(x, optionalArgin, numel(x)))
                        [stat, warnMsg] = deal(3, x);  % incorrect char input
                    end
                end
            elseif ~isCellString(x)
                [stat, warnMsg] = deal(3, 'metrxn input');
            else
                ismetrxn = findRxnIDs(modelLocal, x) | findMetIDs(modelLocal, x);
                if ~all(ismetrxn)
                    [stat, warnMsg] = deal(3, strjoin(x(~ismetrxn), ', '));
                end 
            end
        end
    end
end

function model = rules2grRules(model)
% generate model.grRules from model.rules and model.genes
model.grRules = model.rules;
for j = 1:numel(model.grRules)
    re = regexp(model.grRules{j}, 'x\((\d+)\)', 'tokens');
    if ~isempty(re)
        for k = 1:numel(re)
            id = str2double(re{k}{1});
            model.grRules{j} = strrep(model.grRules{j}, ['x(', re{k}{1}, ')'], strtrim(regexprep(model.genes{id}, '\s', '')));
        end
    end
end
end

function isvalidPrintFields(x, isCellString)
% for checking the input for printFields
if ~(ischar(x) || isCellString(x) || (numel(x) == 2 && all(cellfun(@iscellstr,x))))
    error(['Must be (1) a cell array of two cells, '...
        '1st cell being a character array for met fields and 2nd for rxn fields, ' ...
        'or (2) a character array of field names recognizable from the field names or the sizes.']);
end
end