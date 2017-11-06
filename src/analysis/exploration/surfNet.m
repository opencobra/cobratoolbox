function surfNet(model, metrxn, metNameFlag, flux, nonzeroFluxFlag, showMets,field2print, nCharBreak, iterOptions)
% A simple and convenient tool to navigate through the metabolic network 
% interactively, possibly with given flux vectors, in the Matlab command 
% window using mouse once the starting point is called by command.
%
% USAGE:
%
%    surfNet(model, metrxn, metNameFlag, flux, NonzeroFluxFlag, showMets,field2print, nCharBreak)
%
% INPUT:
%    model:              COBRA model
%
% OPTIONAL INPUTS:
%    metrxn:             mets or rxns names, can be a cell array of multiple rxns and mets, or simply a string 
%                        (default: objective reactions or a random reaction)
%    metNameFlag:        print model.metNames in reaction formulas. (default: false)
%    flux:               flux vectors for the model, a #reactions x #columns matrix. (default: [])
%                        If given, the producing and consuming reactions displayed
%                        are in accordance with the flux direction.
%    nonzeroFluxFlag:    show only reactions with nonzero fluxes if flux is given (default: true)
%    showMets:           show metabolites in a list when printing reactions (default: true)
%    field2print:        print fields associated with mets or rxns, e.g. metNames, rxnNames, grRules. Either: 
%                        (i) a cell array of two cells, 1st being a character array for met fields and 2nd for rxn fields
%                        or (ii) a character array of field names recognizable from the field names or the sizes
%                        (default: {{'metNames','metFormulas'}, {'rxnNames','lb','ub'}})
%    nCharBreak:         max. no. of characters per line for reaction formulas (default 0, the current width of the command window)
%
% EXAMPLES:
%
%    surfNet(model, 'glc-D[c]')  % for starting the navigation at D-glucose
%    surfNet(model, 'EX_glc-D(e)')  % for starting the navigation at the glucose exchange reaction
%    surfNet(model, 'glc-D[c]', 1)  % for printing model.metNames in reaction formulas
%    surfNet(model, 'glc-D[c]', 0, flux, 1)  % for starting at glucose and show reactions with non-zero flux in 'flux' only
%    surfNet(model, 'EX_glc-D(e)', 0, [], [], 0)  % to show the reaction formulas only but not the details of metabolites during navigation
%    surfNet(model, {'glc-D[c]'; 'fru[c]'})  % to view several mets and rxns

fluxTol = 1e-8;  % tolerance for non-zero fluxes
[digitUB, digitLB] = deal(7, 5);  % largest digit and decimal places displayed for numbers (except stoich)
stoichDigit = 6;  % at most print six decimal places for stoichiometric coefficients

%% Handle input arguments
% define persistent variables for iterative calling
persistent pathLocal  % function output
persistent modelLocal  % local model for next iteration
persistent rxnFields  % rxn fields to be printed
persistent metFields  % met fields to be printed
persistent fluxLocal  % flux matrix

checkFields = false;
if nargin >= 1 && ~isempty(model)
    % empty model input uses previous modelLocal (mouse clicking)
    % non-empty model input resets modelLocal, pathLocal and fluxLocal (initial function call)
    [modelLocal, pathLocal, fluxLocal] = deal(model, {}, []);
    checkFields = true;  % check model's fields to be printed 
elseif isempty(modelLocal)
    error('The persistent variable modelLocal in surfNet has been cleared. Please re-call the function.');
end

% options for showing previous steps
showPrev = false;
printShowPrev = true;
if nargin == 9
    if isfield(iterOptions, 'showPrev')
        showPrev = iterOptions.showPrev;
    end
    if isfield(iterOptions, 'printShowPrev')
        printShowPrev = iterOptions.printShowPrev;
    end
end

% nCharBreak is the maximum number of characters per line when printing equations
if nargin < 8 || isempty(nCharBreak) || nCharBreak == 0
    nCharBreak = 0;
    nCharBreakReal = get(0,'CommandWindowSize');
    nCharBreakReal = nCharBreakReal(1);
else
    nCharBreakReal = nCharBreak;
end

% defaulted fields to be printed
if checkFields && (nargin < 7  || isempty(field2print))
    field2print = {{'metNames', 'metFormulas'}, {'rxnNames', 'lb', 'ub'}};
    % remove fields that are not in the model
    field2print = cellfun(@(x) x(ismember(x, fieldnames(modelLocal))), field2print, 'UniformOutput', false);
end

if nargin < 6 || isempty(showMets)
    showMets = true;
end

if nargin < 5 || isempty(nonzeroFluxFlag)
    nonzeroFluxFlag = true;
end

fluxInputErr = false;
if nargin < 4
    % calling with no flux arguement empties fluxLocal
    fluxLocal = [];
else
    % calling with empty flux arguement uses previous fluxLocal
    if strcmp(flux, 'none')
        % calling with 'none' also empties fluxLocal
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
end

% default print metabolite abbreviation instead of full name
if nargin < 3 || isempty(metNameFlag)
    metNameFlag = false;
end

% if a reaction or metabolite is not given
if ~showPrev && (nargin < 2 || isempty(metrxn))
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
    if ischar(field2print)
        field2print = {field2print};
    end
    if ~iscellstr(field2print) && ~(numel(field2print) == 2 && all(cellfun(@iscellstr,field2print)))
        % error if not cellstr of field names nor 2 cells input, first contains field names for mets, second for rxns
        error(['Incorrect input for field2print. Must be (1) a cell array of two cells, '...
            '1st cell being a character array for met fields and 2nd for rxn fields, ' ...
            'or (2) a character array of field names recognizable from the field names or the sizes.']);
    else
        % unsupported fields
        uspField = {'S', 'rxnGeneMat'};
        % find unsupported fields in the input
        if iscellstr(field2print)
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
        ynF = ismember(field2check,fieldnames(modelLocal));
        if ~all(ynF)
            error(['The following field(s) is(are) not in the model:' ...
                strjoin(repmat({' %s'}, 1, sum(~ynF)), ',')], field2check{~ynF})
        end
    end
    
    % identify fields for metabolites and reactions
    nS = size(modelLocal.S);
    if iscellstr(field2print)
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
                || ~all(cellfun(@(x) ischar(x) || iscellstr(x), modelLocal.(field2print{i}{jF}))));
        end
        % error message for incorrect sizes or unsupported datatypes
        if any(badsize{i})
            errMsg = [errMsg, sprintf('Incorrect size of the following %s field(s): %s\n', ...
                MetOrRxn{i}, strjoin(field2print{i}(badsize{i}), ', '))]; 
        end
        if any(notCellNum{i})
            errMsg = [errMsg, sprintf('The following %s field(s) is(are) neither numeric nor cell array of characters: %s\n', ...
                MetOrRxn{i}, strjoin(field2print{i}(notCellNum{i}), ', '))]; 
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
    iterOptionsCell.printShowPrev = false;
    for jMR = 1:numel(metrxn)
        if jMR == numel(metrxn)
            iterOptionsCell.printShowPrev = true;
        end
        if isempty(fluxLocal)
            surfNet([], metrxn{jMR}, metNameFlag, 'none', 0, showMets, [], nCharBreak, iterOptionsCell);
        else
            surfNet([], metrxn{jMR}, metNameFlag, [], nonzeroFluxFlag, showMets, [], nCharBreak, iterOptionsCell);
        end
    end
    return
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
    printFormulae(formPart, dict);

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
    if id == 0
        warning('The 2nd input is neither a metabolite nor reaction of the model.');
        return
    end
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
                printFormulae(formPart, dict);
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
        fprintf('\n<a href="matlab: surfNet([], [], %d, ''none'', 0, %d, [], %d, struct(''showPrev'', true));">%s</a>\n', ...
            metNameFlag, showMets, nCharBreak, 'Show previous steps...');
    end
end

% nested print function for printing strings on command window with interactive calling
    function printFcn(abb, name, digit)
        if ~isempty(fluxLocal)
            sPrint = ['<a href="matlab: surfNet([], ''%s'', %d, [], %d, %d, [], %d);">%' num2str(digit) 's</a>'];
            fprintf(sPrint, abb, metNameFlag, nonzeroFluxFlag, showMets, nCharBreak, name);
        else
            sPrint = ['<a href="matlab: surfNet([], ''%s'', %d, ''none'', 0, %d, [], %d);">%' num2str(digit) 's</a>'];
            fprintf(sPrint, abb, metNameFlag, showMets, nCharBreak, name);
        end 
    end

% nested function for determining the number of digits to be printed
    function s = digit2disp(f)
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
                s = regexprep(s, '\.0+$', '');
                s = regexprep(s, '(\.\d*[1-9])0+$', '$1');
            else
                s = num2str(f); %convert to string directly for non-floating values (integer)
            end
        end
    end

% nested function for formating fluxes to be printed
    function fluxStr = printFlux(rxnId)
        fluxStr = '';
        if ~isempty(fluxLocal)
            fluxStr = ' (';
            for kF = 1:size(fluxLocal, 2)
                % format numbers into string using digit2disp
                if kF < size(fluxLocal, 2)
                    fluxStr = [fluxStr, digit2disp(fluxLocal(rxnId, kF)), ', '];
                else
                    fluxStr = [fluxStr, digit2disp(fluxLocal(rxnId, kF)), ')'];
                end
            end
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
                    %fprintf('%s', modelLocal.(fields{kF}){metrxnId});
                else
                    % cell array of strings
                    ToPrint = modelLocal.(fields{kF}){metrxnId};
                end
            else
                % if it is a value, format it properly
                ToPrint = digit2disp(modelLocal.(fields{kF})(metrxnId));
                %fprintf('%s', digit2disp(modelLocal.(fields{kF})(metrxnId)));
            end
            fprintf('%s', ToPrint);
        end
        fprintf('\n');
    end

% nested function for printing formulae
    function printFormulae(formulaeParts, dict)
        nChar2 = 0;  % number of characters per line
        lineBreak = false;
        
        for jPart = 1:numel(formulaeParts)
            
            metEqPrint = '';
            f = strcmp(dict(:, 1), formulaeParts{jPart});
            % if the current part is a metabolite
            if any(f)
                metEqPrint = dict{f, 1 + metNameFlag};
            end
            nChar2 = nChar2 + length(metEqPrint) + isempty(metEqPrint) * length(formulaeParts{jPart}) + 1;  % +1 for the space
            
            if isempty(metEqPrint)
                % not a metabolite name (stoich/'+'/'->'/'<=>'): check if a new line is needed
                if nChar2 > 0  % nChar2 > 0 implies something has been printed on the line
                    if isnan(str2double(formulaeParts{jPart})) || jPart == numel(formulaeParts)
                        % not a stoich ('+'/'->'/'<=>'): new line if current nChar2 exceeds the limit
                        if nChar2 -1 > nCharBreakReal
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
end

