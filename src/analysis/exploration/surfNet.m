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

% define persistent variables for iterative calling
persistent pathLocal  % function output
persistent modelLocal  % local model for next iteration
% empty model input uses previous modelLocal
checkModel = false;
if ~isempty(model)
    % non-empty model input resets modelLocal
    modelLocal = model;
    pathLocal = {};
    checkModel = true;
elseif isempty(modelLocal)
    error('The persistent variables in surfNet have been cleared. Please re-call the function.');
end
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
if checkModel && (nargin < 7  || isempty(field2print))
    field2print = {{'metNames', 'metFormulas'}, {'rxnNames', 'lb', 'ub'}};
end
persistent rxnFields
persistent metFields
persistent showLB
persistent showUB

% check model's fields to be printed and their sizes
if checkModel 
    if ischar(field2print)
        field2print = {field2print};
    end
    if ~(numel(field2print) == 2 && all(cellfun(@iscellstr,field2print))) && ~iscellstr(field2print)
        % error if not 2 cells input, first contains field names for mets, second for rxns
        error(['Incorrect input for field2print. Must be (1) a cell array of two cells, '...
            '1st cell being a character array for met fields and 2nd for rxn fields, ' ...
            'or (2) a character array of field names recognizable from the field names or the sizes.']);
    else
        % check the existence of the fields
        rGMwarn = false;
        if iscellstr(field2print)
            field2print(strcmp(field2print, 'S')) = [];
            if any(strcmp(field2print, 'rxnGeneMat'))
                field2print(strcmp(field2print, 'rxnGeneMat')) = [];
                rGMwarn = true;
            end
            field2check = field2print;
        else
            for k = 1:2
                field2print{k}(strcmp(field2print{k}, 'S')) = [];
                if any(strcmp(field2print{k}, 'rxnGeneMat'))
                    field2print{k}(strcmp(field2print{k}, 'rxnGeneMat')) = [];
                    rGMwarn = true;
                end
            end
            field2check = [field2print{1}(:);field2print{2}(:)];
        end
        if rGMwarn
            warning('surfNet does not support showing rxnGeneMat. Ignore it.')
        end
        ynF = ismember(field2check,fieldnames(modelLocal));
        if ~all(ynF)
            error(['The following field(s) is(are) not in the model:' ...
                strjoin(repmat({' %s'}, 1, sum(~ynF)), ',')], field2check{~ynF})
        end
    end
    [nM, nR] = size(modelLocal.S);
    if iscellstr(field2print)
        ynF = ismember(field2print, {'rxns', 'mets'});
        field2print(ynF) = [];
        field2print = field2print(:);
        metF = strncmpi('met', field2print, 3);
        rxnF = strncmpi('rxn', field2print, 3);
        if all(metF | rxnF) 
            metFields = field2print(metF);
            rxnFields = field2print(rxnF);
        else
            if nM == nR
                warning('Same number of mets and rxns. Some met fields may be displayed as rxn fields.');
            end
            [metFields, rxnFields] = deal({});
            notMetRxnField = false(numel(field2print), 1);
            % do this to preserve the order in field2print
            for jF = 1:numel(field2print)
                if metF(jF)
                    metFields(end+1) = field2print(jF);
                elseif rxnF(jF)
                    rxnFields(end+1) = field2print(jF);
                else
                    % check sizes
                    if any(size(modelLocal.(field2print{jF})) == nR)
                        rxnFields(end+1) = field2print(jF);
                    elseif any(size(modelLocal.(field2print{jF})) == nM)
                        metFields(end+1) = field2print(jF);
                    else
                        notMetRxnField(jF) = true;
                    end
                end
            end
            if any(notMetRxnField)
                field2print = field2print(notMetRxnField);
                error(['The following field(s) cannot be recognized as met or rxn fields:' ...
                    strjoin(repmat({' %s'}, 1, numel(field2print)), ',')], field2print{:});
            end
        end
        field2print = {metFields, rxnFields}; 
    end
    metFields = field2print{1}(:);
    rxnFields = field2print{2}(:);
    % check datatype and if the sizes are equal to #mets 
    [badsizeM, notCellNumM] = deal(false(numel(metFields), 1));
    for jF = 1:numel(metFields)
        if size(modelLocal.(metFields{jF}), 1) ~= nM
            if size(modelLocal.(metFields{jF}), 2) == nM
                modelLocal.(metFields{jF}) = modelLocal.(metFields{jF})';
            else
                badsizeM(jF) = true;
            end
        end
        if ischar(modelLocal.(metFields{jF})) && ~badsizeM(jF)
            % also allow character arrays. Convert them into cell strings
            modelLocal.(metFields{jF}) = cellstr(modelLocal.(metFields{jF}));
        end
        notCellNumM(jF) = ~iscellstr(modelLocal.(metFields{jF})) & ~isnumeric(modelLocal.(metFields{jF}));
    end
    % check datatype and if the sizes are equal to #rxns 
    [badsizeR, notCellNumR] = deal(false(numel(rxnFields), 1));
    for jF = 1:numel(rxnFields)
        if size(modelLocal.(rxnFields{jF}), 1) ~= nR
            if size(modelLocal.(rxnFields{jF}), 2) == nR
                modelLocal.(rxnFields{jF}) = modelLocal.(rxnFields{jF})';
            else
                badsizeR(jF) = true;
            end
        end
        if ischar(modelLocal.(rxnFields{jF})) && ~badsizeR(jF)
            % also allow character arrays. Convert them into cell strings
            modelLocal.(rxnFields{jF}) = cellstr(modelLocal.(rxnFields{jF}));
        end
        notCellNumR(jF) = ~iscellstr(modelLocal.(rxnFields{jF})) & ~isnumeric(modelLocal.(rxnFields{jF}));
    end
    if any(badsizeM) || any(badsizeR) || any(notCellNumM) || any(notCellNumR)
        str = '';
        if any(badsizeM)
            p = metFields(badsizeM);
            str = [str sprintf(['Incorrect size of the following met field(s):', ...
                strjoin(repmat({' %s'}, 1, sum(badsizeM)), ','), '.'], p{:})];
        end
        if any(badsizeR)
            p = rxnFields(badsizeR);
            str = [str sprintf(['\nIncorrect size of the following rxn field(s):', ...
                strjoin(repmat({' %s'}, 1, sum(badsizeR)), ','), '.'], p{:})];
        end
        if any(notCellNumM)
            p = metFields(notCellNumM);
            str = [str sprintf(['\nThe following met field(s) is(are) neither numeric nor cell array of characters:', ...
                strjoin(repmat({' %s'}, 1, sum(notCellNumM)), ','), '.'], p{:})];
        end
        if any(notCellNumR)
            p = rxnFields(notCellNumR);
            str = [str sprintf(['\nThe following rxn field(s) is(are) neither numeric nor cell array of characters::', ...
                strjoin(repmat({' %s'}, 1, sum(notCellNumR)), ','), '.'], p{:})];
        end
        error('%s', str)
    end
    showLB = any(strcmp(rxnFields, 'lb'));
    showUB = any(strcmp(rxnFields, 'ub'));
    ynF = ismember(rxnFields, {'lb', 'ub'});
    rxnFields(ynF) = [];
end
if nargin < 6 || isempty(showMets)
    showMets = true;
end
if nargin < 5 || isempty(nonzeroFluxFlag)
    nonzeroFluxFlag = true;
end
% string indicating non-zero fluxes or not for printing
nzFluxPrint = '';
persistent fluxLocal  % local flux vector for next iteration
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
        if size(flux, 2) == numel(model.rxns)
            flux = flux';
        elseif size(flux, 1) ~= numel(model.rxns)
            error('Input flux vector has incorrect dimension.')
        end
        fluxLocal = flux;        
    end
end
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

% show previous steps. Should be called by mouse clicking only
if showPrev
    fprintf('\n');
    nChar = 0;
    for jPast = 1:size(pathLocal)
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

% if a reaction or metabolite is not given
if nargin < 2 || isempty(metrxn)
    if any(model.c) && (isempty(fluxLocal) || any(abs(fluxLocal(model.c~=0, 1)) > fluxTol))
        % print objective function if no flux vector is given or the objective function value in the flux vector is nonzero 
        metrxn = model.rxns(model.c~=0);
    else
        % pick a random reaction otherwise
        if ~isempty(fluxLocal)
            metrxn = model.rxns{randsample(find(abs(fluxLocal) > fluxTol), 1)};
        else
            metrxn = model.rxns{randsample(numel(model.rxns), 1)};
        end
    end
end
% default print metabolite abbreviation instead of full name
if nargin < 3 || isempty(metNameFlag)
    metNameFlag = false;
end
% check modelLocal's fields to ensure no error
if checkModel
    if ~isfield(modelLocal, 'metNames')
        modelLocal.metNames = modelLocal.mets;
    else
        noName = cellfun(@isempty, modelLocal.metNames);
        modelLocal.metNames(noName) = modelLocal.mets(noName);
    end
    if ~isfield(modelLocal, 'metFormulas')
        modelLocal.metFormulas = repmat({''}, numel(modelLocal.mets), 1);
    else
        modelLocal.metFormulas(cellfun(@isempty, modelLocal.metFormulas)) = {''};
    end
    if ~isfield(modelLocal, 'rxnNames')
        modelLocal.rxnNames = modelLocal.rxns;
    else
        noName = cellfun(@isempty, modelLocal.rxnNames);
        modelLocal.rxnNames(noName) = modelLocal.rxns(noName);
    end
end

% iteractive calling if the input is a list of reactions and metabolites
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
id = findRxnIDs(modelLocal, metrxn);
if id ~= 0
    if isempty(pathLocal)
        pathLocal{1, 1} = ''; 
    end
    pathLocal{end, 2} = metrxn;
    % handle reaction flux
    fluxPrint = '';
    if ~isempty(fluxLocal)
        fluxPrint = ' (';
        for nFlux = 1:size(fluxLocal, 2)
            if nFlux < size(fluxLocal, 2)
                fluxPrint = [fluxPrint, digit2disp(fluxLocal(id, nFlux)), ', '];
            else
                fluxPrint = [fluxPrint, digit2disp(fluxLocal(id, nFlux)), ')'];
            end
        end
    end
    fprintf('\nRxn #%d  %s%s', id, metrxn, fluxPrint);
    % print bounds
    if showLB && showUB
        fprintf(', Bd: %s / %s', digit2disp(modelLocal.lb(id)), digit2disp(modelLocal.ub(id)));
    elseif showLB
        fprintf(', LB: %s', digit2disp(modelLocal.lb(id)));
    elseif showUB
        fprintf(', UB: %s', digit2disp(modelLocal.ub(id)));
    end
    % print rxn info
    for jF = 1:numel(rxnFields)
        fprintf(', ');
        if ~strcmp(rxnFields{jF}, 'rxnNames')
            fprintf('%s: ', rxnFields{jF});
        end
        if iscell(modelLocal.(rxnFields{jF}))
            fprintf('%s', modelLocal.(rxnFields{jF}){id});
        else
            fprintf('%s', digit2disp(modelLocal.(rxnFields{jF})(id)));
        end
    end
    fprintf('\n');
    % print equation
    p = printRxnFormula(modelLocal, metrxn, 0, 1, 0);
    dirRxn = 1;
    if ~isempty(fluxLocal)
        % direction of the reaction. If flux is given, non-negative flux treated as forward direction and -ve flux as reverse direction
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
    nChar = 0;  % number of characters per line
    lineBreak = false;
    for jPart = 1:numel(formPart)
        metEqPrint = '';
        f = strcmp(dict(:, 1), formPart{jPart});
        % if the current part is a metabolite
        if any(f)
            metEqPrint = dict{f, 1 + metNameFlag}; 
        end
        nChar = nChar + length(metEqPrint) + isempty(metEqPrint) * length(formPart{jPart}) + 1;  % +1 for the space
        if isempty(metEqPrint) 
            % not a metabolite name (stoich/'+'/'->'/'<=>'): check if a new line is needed
            if nChar > 0  % nChar > 0 implies something has been printed on the line
                if isnan(str2double(formPart{jPart})) || jPart == numel(formPart)
                    % not a stoich ('+'/'->'/'<=>'): new line if current nChar exceeds the limit
                    if nChar -1 > nCharBreakReal
                        lineBreak = true;
                    end
                else
                    % stoich coeff: new line if together with the coming metID, #characters exceeds the limit
                    if nChar + length(formPart{jPart + 1}) > nCharBreakReal
                        lineBreak = true;
                    end
                end
            end
            if lineBreak
                fprintf('\n  '); 
                nChar = length(formPart{jPart}) + 3;  % 2 spaces before + 1 space after
                lineBreak = false; 
            end
            fprintf('%s ', formPart{jPart});
        else
            % print hyperlink if it is a metabolite name
            printFcn(formPart{jPart}, metEqPrint, 0);
            fprintf(' ');
        end
    end
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
                for jF = 1:numel(metFields)
                    if jF > 1
                        fprintf(', ');
                    end
                    if iscell(modelLocal.(metFields{jF}))
                        % if it is a cell array
                        if iscell(modelLocal.(metFields{jF}){m{jRP}(j)})
                            % concatenate if the cell content is a cell array of strings
                            ToPrint = strjoin(modelLocal.(metFields{jF}){m{jRP}(j)}, '|');
                        else
                            ToPrint = modelLocal.(metFields{jF}){m{jRP}(j)};
                        end
                    else
                        % if it is a value, format it properly
                        ToPrint = digit2disp(modelLocal.(metFields{jF})(m{jRP}(j)));
                    end
                    fprintf('%s', ToPrint);
                end
                fprintf('\n');
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
    for jF = 1:numel(metFields)
        fprintf(', ');
        if ~any(strcmp(metFields{jF}, {'metFormulas';'metNames'}))
            fprintf('%s: ', metFields{jF});
        end
        if iscell(modelLocal.(metFields{jF}))
            % if it is a cell array
            if iscell(modelLocal.(metFields{jF}){id})
                % concatenate if the cell content is a cell array of strings
                ToPrint = strjoin(modelLocal.(metFields{jF}){id}, '|');
            else
                ToPrint = modelLocal.(metFields{jF}){id};
            end
        else
            % if it is a value, format it properly
            ToPrint = digit2disp(modelLocal.(metFields{jF})(id));
        end
        fprintf('%s', ToPrint);
    end
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
            % print rxn formulas
            fprintf('\n');
            p = printRxnFormula(modelLocal, modelLocal.rxns(r), 0, 1, 0);            
            for j = 1:numel(r)
                % print at most six decimal places of reaction fluxes
                fluxPrint = '';
                if ~isempty(fluxLocal)
                    fluxPrint = ' (';
                    for nFlux = 1:size(fluxLocal, 2)
                        if nFlux < size(fluxLocal, 2)
                            fluxPrint = [fluxPrint, digit2disp(fluxLocal(r(j), nFlux)), ', '];
                        else
                            fluxPrint = [fluxPrint, digit2disp(fluxLocal(r(j), nFlux)), ')'];
                        end
                    end
                end
                % print reaction info
                fprintf('  #%d  ', r(j));
                printFcn(modelLocal.rxns{r(j)}, modelLocal.rxns{r(j)}, 0);
                fprintf('%s', fluxPrint);
                % print bounds
                if showLB && showUB
                    fprintf(', Bd: %s / %s', digit2disp(modelLocal.lb(r(j))), digit2disp(modelLocal.ub(r(j))));
                elseif showLB
                    fprintf(', LB: %s', digit2disp(modelLocal.lb(r(j))));
                elseif showUB
                    fprintf(', UB: %s', digit2disp(modelLocal.ub(r(j))));
                end
                % print rxn info
                for jF = 1:numel(rxnFields)
                    fprintf(', ');
                    if ~strcmp(rxnFields{jF}, 'rxnNames')
                        fprintf('%s: ', rxnFields{jF});
                    end
                    if iscell(modelLocal.(rxnFields{jF}))
                        fprintf('%s', modelLocal.(rxnFields{jF}){r(j)});
                    else
                        fprintf('%s', digit2disp(modelLocal.(rxnFields{jF})(r(j))));
                    end
                end
                fprintf('\n  ');
                % print equation
                m = find(modelLocal.S(:, r(j)));
                % dictionary for printing mets or metNames in equation
                dict = modelLocal.mets(m);
                if metNameFlag
                    dict(:, 2) = modelLocal.metNames(m);
                end
                % similarly get each part of the formula
                formPart = strsplit(p{j});
                nChar = 0;
                lineBreak = false;
                for jPart = 1:numel(formPart)
                    metEqPrint = '';
                    f = strcmp(dict(:, 1), formPart{jPart});
                    % if the current part is a metabolite
                    if any(f)
                        metEqPrint = dict{f, 1 + metNameFlag};
                    end
                    nChar = nChar + length(metEqPrint) + isempty(metEqPrint) * length(formPart{jPart}) + 1;  % +1 for the space
                    if isempty(metEqPrint)
                        % not a metabolite name (stoich/'+'/'->'/'<=>'). Check if a new line is needed
                        if nChar > 0  % nChar > 0 implies something has been printed on the line
                            if isnan(str2double(formPart{jPart})) || jPart == numel(formPart)
                                % not a stoich ('+'/'->'/'<=>'): new line if current nChar exceeds the limit
                                if nChar -1 > nCharBreakReal
                                    lineBreak = true;
                                end
                            else
                                % stoich coeff: new line if together with the coming metID, #characters exceeds the limit
                                if nChar + length(formPart{jPart + 1}) > nCharBreakReal
                                    lineBreak = true;
                                end
                            end
                        end
                        if lineBreak
                            fprintf('\n  ');
                            nChar = length(formPart{jPart}) + 3;  % 2 spaces before + 1 space after
                            lineBreak = false;
                        end
                        fprintf('%s ', formPart{jPart});
                    else
                        % print hyperlink if it is a metabolite name
                        printFcn(formPart{jPart}, metEqPrint, 0);
                        fprintf(' ');
                    end
                end
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
end

