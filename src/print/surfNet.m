function surfNet(model, metrxn, metNameFlag, flux, NonzeroFluxFlag, showMets, nCharBreak, iterOptions)
% A simple and convenient tool to navigate through the metabolic network
% interactively, possibly with a given flux vector, in the Matlab command
% window using mouse once the starting point is called by command.
%
% USAGE:
%
%    surfNet(model, metrxn, metNameFlag, flux, NonzeroFluxFlag, nCharBreak)
%
% INPUTS:
%    model:              COBRA model
%    metrxn:             mets or rxns names, can be a cell array of multiple
%                        rxns and mets, or simply a string
%
% OPTIONAL INPUTS:
%    metNameFlag:        print model.metNames in reaction formulas. (false)
%    flux:               flux vector for the model. Show fluxes if given.([])
%                        If given, the producing and consuming reactions displayed
%                        are in accordance with the flux direction.
%    NonzeroFluxFlag:    show only reactions with nonzero flux if flux is given (true)
%    showMets:           show metabolites in a list when printing reactions (true)
%    nCharBreak:         max. no. of characters per line for reaction formulas (65)
%    iterOptions:        Not used for calling, for interactive calling only.
%                        Display the path of the previous navigation. (false)
% EXAMPLES:
%
%    surfNet(model, 'glc-D[c]')  % for starting the navigation at D-glucose
%    surfNet(model, 'EX_glc-D(e)')  % for starting the navigation at the glucose exchange reaction
%    surfNet(model, 'glc-D[c]', 1)  % for printing model.metNames in reaction formulas
%    surfNet(model, 'glc-D[c]', 0, flux, 1)  % for starting at glucose and show reactions with non-zero flux in 'flux' only
%    surfNet(model, 'EX_glc-D(e)', 0, [], [], 0)  % to show the reaction formulas only but not the details of metabolites during navigation
%    surfNet(model, {'glc-D[c]'; 'fru[c]'})  % to view several mets and rxns
%

fluxTol = 1e-8;  % tolerance for non-zero fluxes
% at most print two decimal places for upper and lower bounds
boundDigit = 2;
% at most print six decimal places for stoichiometric coefficients
stoichDigit = 6;

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
end
showPrev = false;
printShowPrev = true;
if nargin == 8
    if isfield(iterOptions, 'showPrev')
        showPrev = iterOptions.showPrev;
    end
    if isfield(iterOptions, 'printShowPrev')
        printShowPrev = iterOptions.printShowPrev;
    end
end
% nCharBreak is the maximum number of characters per line when printing
% equations
if nargin < 7 || isempty(nCharBreak)
    nCharBreak = 65;
end
if nargin < 6 || isempty(showMets)
    showMets = true;
end
if nargin < 5 || isempty(NonzeroFluxFlag)
    NonzeroFluxFlag = true;
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
        fluxLocal = flux;
    end
end
if ~isempty(fluxLocal)
    % reaction direction for determining consumption or production if flux
    % is given
    direction = ones(1, size(modelLocal.S, 2));
    if NonzeroFluxFlag
        nzFluxPrint = ' with non-zero fluxes ';
        direction(fluxLocal <= -fluxTol) = -1;
        direction(abs(fluxLocal) < fluxTol) = 0;
    else
        direction(fluxLocal < 0) = -1;
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
            if nChar > 0 && nChar + length(namePrint) > nCharBreak
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
            if nChar > 0 && nChar + length(pathLocal{jPast, 2}) > nCharBreak
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
    if ~isempty(fluxLocal)
        % pick a random reaction with non-zero flux
        metrxn = model.rxns{randsample(find(abs(fluxLocal) > fluxTol), 1)};
    else
        % pick a random reaction
        metrxn = model.rxns{randsample(numel(model.rxns), 1)};
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
            surfNet([], metrxn{jMR}, metNameFlag, 'none', 0, showMets, nCharBreak, iterOptionsCell);
        else
            surfNet([], metrxn{jMR}, metNameFlag, [], NonzeroFluxFlag, showMets, nCharBreak, iterOptionsCell);
        end
    end
    return
end

id = findRxnIDs(modelLocal, metrxn);
if id ~= 0
%% input is a reaction
    if isempty(pathLocal), pathLocal{1, 1} = ''; end
    pathLocal{end, 2} = metrxn;
    % handle reaction flux
    fluxPrint = '';
    if ~isempty(fluxLocal)
        fluxPrint = sprintf('(%.6f)', fluxLocal(id));
    end
    % find the digits of the bounds to be printed
    lbDigit = 0;
    while lbDigit <= boundDigit
        if floor(modelLocal.lb(id) * 10 ^ (lbDigit)) / (10 ^ (lbDigit)) == modelLocal.lb(id)
            break
        end
        lbDigit = lbDigit + 1;
    end
    ubDigit = 0;
    while lbDigit <= boundDigit
        if floor(modelLocal.ub(id) * 10 ^ (ubDigit)) / (10 ^ (ubDigit)) == modelLocal.ub(id)
            break
        end
        ubDigit = ubDigit + 1;
    end
    % print reaction info [ID | rxn | rxnName | flux (if given) | LB/UB]
    fprintf(['\nRxn #%d  %s, %s  %s Bd: %.' num2str(lbDigit) 'f / %.' num2str(ubDigit) 'f\n'], ...
            id, metrxn, modelLocal.rxnNames{id}, fluxPrint, modelLocal.lb(id), modelLocal.ub(id));
    % print equation
    p = printRxnFormula(modelLocal, metrxn, 0, 1, 0);
    dirRxn = 1;
    if ~isempty(fluxLocal)
        % direction of the reaction. If flux is given, non-negative flux
        % treated as forward direction and -ve flux as reverse direction
        dirRxn = sign(direction(id) + 0.1);
    end
    % all the metabolite involved
    m = {find(modelLocal.S(:, id) * dirRxn < 0); find(modelLocal.S(:, id) * dirRxn > 0)};
    % dictionary for printing mets or metNames in equation
    dict = modelLocal.mets([m{1}; m{2}]);
    if metNameFlag
        dict(:, 2) = modelLocal.metNames([m{1}; m{2}]);
    end
    % get each part of the reaction formula and add hyperlink
    formPart = strsplit(p{1});
    nChar = 0;
    lineBreak = false;
    for jPart = 1:numel(formPart)
        metEqPrint = '';
        f = strcmp(dict(:, 1), formPart{jPart});
        % if the current part is a metabolite
    if any(f), metEqPrint = dict{f, 1 + metNameFlag}; end
    % have a new line if exceeding character per line
    if nChar > 0 && nChar + length(metEqPrint) + isempty(metEqPrint) * length(formPart{jPart}) > nCharBreak
            lineBreak = true;
        end
        nChar = nChar + length(metEqPrint) + isempty(metEqPrint) * length(formPart{jPart}) + 1;  % +1 for the space
        if isempty(metEqPrint)
            % if it is not a metabolite name (stoich/'+'/'->'/'<=>'), print directly
            if lineBreak, fprintf('\n  '); nChar = 0; lineBreak = false; end
            fprintf('%s ', formPart{jPart});
        else
            % print hyperlink if it is a metabolite name
            printFcn(formPart{jPart}, metEqPrint, 0);
            fprintf(' ');
        end
    end
    if showMets
        % print reactants and products in detail
        % max. met's length
        dispLen1 = max(cellfun(@length, modelLocal.mets([m{1}; m{2}])));
        dis1 = ['  %-' num2str(dispLen1) 's'];
        % max. met's ID length
        dispLen2 = max([m{1}; m{2}]);
        dis1 = ['  %-' num2str(ceil(log10(dispLen2)) + 1) 's' dis1];
        dis2 = [' #%-' num2str(ceil(log10(dispLen2)) + 1) 'd'];
        fprintf(['\n' dis1 '  Stoich     Name, Formula\n'], 'id', 'Met');
        for jRP = 1:numel(m)
            if jRP == 1
                fprintf('Reactant:\n');
            else
                fprintf('Product:\n');
            end
            for j = 1:numel(m{jRP})
                % format the printing of the stoichiometric coefficient
                if floor(modelLocal.S(m{jRP}(j), id)) ~= modelLocal.S(m{jRP}(j), id)
                    % at most display 6 decimal places, or use scientific notation
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
                if iscell(modelLocal.metNames{m{jRP}(j)})
                    % handle if metNames{id} is a cell array of strings
                    metNamePrint = strjoin(modelLocal.metNames{m{jRP}(j)}, '|');
                else
                    metNamePrint = modelLocal.metNames{m{jRP}(j)};
                end
                % print stoichiometric coefficients, metNames and metFormulas
                fprintf(['  ' stForm '  %s, %s\n'], full(modelLocal.S(m{jRP}(j), id)), ...
                        metNamePrint, modelLocal.metFormulas{m{jRP}(j)});
            end
        end
    end
else
%% input is a metabolite
    id = findMetIDs(modelLocal, metrxn);
    if id == 0
        warning('The 2nd input is neither a metabolite or reaction of the model.');
        return
    end
    pathLocal(end + 1, :) = {metrxn, ''};
    if iscell(modelLocal.metNames{id})
        % handle if metNames{id} is a cell array of strings
        metNamePrint = strjoin(modelLocal.metNames{id}, '|');
    else
        metNamePrint = modelLocal.metNames{id};
    end
    % print metabolite details: [ID | mets | metNames | metFormulas]
    fprintf('\nMet #%d  %s, %s, %s\n', id, modelLocal.mets{id}, ...
            metNamePrint, modelLocal.metFormulas{id});
    for jCP = 1:2
        if jCP == 1
            % print consuming reactions (taking into account of flux
            % direction if given)
            r = find(modelLocal.S(id, :) .* direction < 0);
            fprintf('Consuming reactions%s:', nzFluxPrint);
        else
            % print producing reactions (taking into account of flux
            % direction if given)
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
                    fluxPrint = sprintf('(%.6f)', fluxLocal(r(j)));
                end
                % print reaction info
                fprintf('#%d  ', r(j));
                printFcn(modelLocal.rxns{r(j)}, modelLocal.rxns{r(j)}, 0);
                fprintf('  %s  %s\n  ', modelLocal.rxnNames{r(j)}, fluxPrint);
                % print equation
                m = find(modelLocal.S(:, r(j)));
                % dictionary for printing mets or metNames in equation
                dict = modelLocal.mets(m);
                if metNameFlag, dict(:, 2) = modelLocal.metNames(m); end
                % similarly get each part of the formula
                formPart = strsplit(p{j});
                nChar = 0;
                lineBreak = false;
                for jPart = 1:numel(formPart)
                    metEqPrint = '';
                    f = strcmp(dict(:, 1), formPart{jPart});
                    % if the current part is a metabolite
                if any(f), metEqPrint = dict{f, 1 + metNameFlag}; end
                % have a new line if exceeding character per line
                if nChar > 0 && nChar + length(metEqPrint) + isempty(metEqPrint) * length(formPart{jPart}) > nCharBreak
                        lineBreak = true;
                    end
                    nChar = nChar + length(metEqPrint) + isempty(metEqPrint) * length(formPart{jPart}) + 1;  % +1 for the space
                    if isempty(metEqPrint)
                        % if it is not a metabolite name (stoich/'+'/'->'/'<=>'), print directly
                        if lineBreak, fprintf('\n  '); nChar = 0; lineBreak = false; end
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
% print the button leading to show previous navigated mets and rxns
if printShowPrev
    if ~isempty(fluxLocal)
        fprintf('\n<a href="matlab: surfNet([],[],%d, [], %d, %d, %d, struct(''showPrev'',true));">%s</a>\n', ...
                metNameFlag, NonzeroFluxFlag, showMets, nCharBreak, 'Show previous steps...');
    else
        fprintf('\n<a href="matlab: surfNet([],[],%d, ''none'', 0, %d, %d, struct(''showPrev'',true));">%s</a>\n', ...
                metNameFlag, showMets, nCharBreak, 'Show previous steps...');
    end
end
% define the nested print function for printing strings on command line with
% interactive calling
function printFcn(abb, name, digit)
    if ~isempty(fluxLocal)
        sPrint = ['<a href="matlab: surfNet([],''%s'',%d,[],%d, %d, %d);">%' num2str(digit) 's</a>'];
        fprintf(sPrint, abb, metNameFlag, NonzeroFluxFlag, showMets, nCharBreak, name);
    else
        sPrint = ['<a href="matlab: surfNet([],''%s'',%d, ''none'', 0, %d, %d);">%' num2str(digit) 's</a>'];
        fprintf(sPrint, abb, metNameFlag, showMets, nCharBreak, name);
    end
end

end
