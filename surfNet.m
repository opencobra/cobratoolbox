function surfNet(model, metrxn, metNameFlag, flux, NonzeroFluxFlag, nCharBreak, showMets, iterOptions)
%surfNet(model, metrxn, metNameFlag, flux, NonzeroFluxFlag, nCharBreak)
%
%A simple and convenient tool to nevigate through the metabolic network 
%interactively, possibly with a given flux vector, in the Matlab command 
%window using mouse.
%
%Input:
%   model:              COBRA model
%   metrxn:             mets or rxns names, can be a cell array or a string
%  Optional input (default value):
%   metNameFlag:        print model.metNames in reaction formulas. (false)
%   flux:               flux vector for the model. Show fluxes if given.([])
%   NonzeroFluxFlag:    show only reactions with nonzero flux. (true)
%   nCharBreak:         max. no. of characters per line for printing reaction 
%                       formulas (65)
%   showMets:           show metabolites in a list when printing reactions
%                       (true)
%   iterOptions:        Not used for calling, for interactive calling only.
%                       Display the path of the previous nevigation. 
%                       (false)


%tolerance for non-zero fluxes
fluxTol = 1e-8;
%define persistent variables for iterative calling
persistent pathLocal %function output
persistent modelLocal %local model for next iteration
%empty model input uses previous modelLocal
checkModel = false;
if ~isempty(model)
    %non-empty model input resets modelLocal
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
if nargin < 7 || isempty(showMets)
    showMets = true;
end
% nCharBreak is the maximum number of characters per line when printing
% equations
if nargin < 6 || isempty(nCharBreak)
    nCharBreak = 65;
end
if nargin < 5 || isempty(NonzeroFluxFlag)
    NonzeroFluxFlag = true;
end
%string indicating non-zero fluxes or not for printing
nzFluxPrint = '';
persistent fluxLocal %local flux vector for next iteration
if nargin < 4
    %calling with no flux arguement empties fluxLocal
    fluxLocal = [];
else
    %calling with empty flux arguement uses previous fluxLocal
    if strcmp(flux, 'none')
        %calling with 'none' also empties fluxLocal
        fluxLocal = [];
    elseif ~isempty(flux)
        %calling with non-empty flux arguement resets fluxLocal
        fluxLocal = flux;        
    end
end
if ~isempty(fluxLocal)
    %reaction direction for determining consumption or production
    direction = ones(1, size(modelLocal.S,2));
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

%show previous steps. Should be called from mouse clicking only
if showPrev
    fprintf('\n');
    nChar = 0;
    for jPast = 1:size(pathLocal)
        if ~isempty(pathLocal{jPast,1})
            if metNameFlag
                namePrint = modelLocal.metNames{findMetIDs(modelLocal,pathLocal{jPast,1})};
            else
                namePrint = pathLocal{jPast,1};
            end
            if nChar > 0 && nChar + length(namePrint) > nCharBreak
                fprintf('\n');
                nChar = 0;
            end
            nChar = nChar + length(namePrint) + 2;
            printFcn(pathLocal{jPast,1}, namePrint,0);
            fprintf('>>'); 
        end
        
        if ~isempty(pathLocal{jPast,2})
            if nChar > 0 && nChar + length(pathLocal{jPast,2}) > nCharBreak
                fprintf('\n');
                nChar = 0;
            end
            nChar = nChar + length(pathLocal{jPast,2}) + 2;
            printFcn(pathLocal{jPast,2}, pathLocal{jPast,2},0);
            fprintf('>>');
        end     
    end
    fprintf('\n');
    return
end

%handle other input arguements
if nargin < 2 || isempty(metrxn)
    metrxn = model.rxns{randsample(numel(model.rxns), 1)};
end
if nargin < 3 || isempty(metNameFlag)
    metNameFlag = false;
end


%check modelLocal's fields
if checkModel
    if ~isfield(modelLocal, 'metNames')
        modelLocal.metNames = modelLocal.mets;
    else
        noName = cellfun(@isempty,modelLocal.metNames);
        modelLocal.metNames(noName) = modelLocal.mets(noName);
    end
    if ~isfield(modelLocal, 'metFormulas')
        modelLocal.metFormulas = repmat({''}, numel(modelLocal.mets), 1);
    else
        modelLocal.metFormulas(cellfun(@isempty,modelLocal.metFormulas)) = {''};
    end
    if ~isfield(modelLocal, 'rxnNames')
        modelLocal.rxnNames = modelLocal.rxns;
    else
        noName = cellfun(@isempty,modelLocal.rxnNames);
        modelLocal.rxnNames(noName) = modelLocal.rxns(noName);
    end
end
if iscell(metrxn)
    iterOptionsCell.printShowPrev = false;
    for jMR = 1:numel(metrxn)
        if jMR == numel(metrxn)
            iterOptionsCell.printShowPrev = true;
        end
        if isempty(fluxLocal)
            surfNet([], metrxn{jMR}, metNameFlag, 'none', 0, nCharBreak, showMets, iterOptionsCell);
        else
            surfNet([], metrxn{jMR}, metNameFlag, [], NonzeroFluxFlag, nCharBreak, showMets, iterOptionsCell);
        end
    end
    return
end

id = findRxnIDs(modelLocal,metrxn);
if id ~= 0
    %% input is a reaction
    if isempty(pathLocal), pathLocal{1,1} = ''; end
    pathLocal{end, 2} = metrxn;
    %handle reaction flux
    fluxPrint = '';
    if ~isempty(fluxLocal)
        fluxPrint = sprintf('(%.6f)',fluxLocal(id));
    end
    %print reaction info
    fprintf('\nRxn #%d  %s, %s  %s\n', id, metrxn, modelLocal.rxnNames{id}, fluxPrint);
    
    % print equation
    p = printRxnFormula(modelLocal, metrxn,0, 1, 0);
    dirRxn = 1;
    if ~isempty(fluxLocal)
        dirRxn = sign(direction(id) + 0.1);
    end
    m = {find(modelLocal.S(:,id) * dirRxn <0);find(modelLocal.S(:,id) * dirRxn > 0)};
    %dictionary for printing mets or metNames in equation
    dict = modelLocal.mets([m{1}; m{2}]);
    if metNameFlag 
        dict(:,2) = modelLocal.metNames([m{1}; m{2}]);
    end
    formPart = strsplit(p{1});
    nChar = 0;
    lineBreak = false;
    for jPart = 1:numel(formPart)
        metEqPrint = '';
        f = strcmp(dict(:,1), formPart{jPart});
        if any(f), metEqPrint = dict{f, 1 + metNameFlag}; end
        if nChar > 0 && nChar + length(metEqPrint) + isempty(metEqPrint) * length(formPart{jPart}) > nCharBreak
            lineBreak = true;
        end
        nChar = nChar + length(metEqPrint) + isempty(metEqPrint) * length(formPart{jPart}) + 1; %+1 for the space
        if isempty(metEqPrint)
            if lineBreak, fprintf('\n  '); nChar = 0; lineBreak = false; end
            fprintf('%s ', formPart{jPart});
        else
            printFcn(formPart{jPart}, metEqPrint, 0);
            fprintf(' ');
        end
    end
    if showMets
        %print reactants and products in detail
        %max. met's length
        dispLen1 = max(cellfun(@length,modelLocal.mets([m{1};m{2}])));
        dis1 = ['  %-' num2str(dispLen1) 's'];
        %max. met's ID length
        dispLen2 = max([m{1};m{2}]);
        dis1 = ['  %-' num2str(ceil(log10(dispLen2)) + 1) 's' dis1];
        dis2 = [' #%-' num2str(ceil(log10(dispLen2)) + 1) 'd'];
        fprintf(['\n' dis1 '  Stoich     Name, Formula\n'], 'id','Met');
        for jRP = 1:numel(m)
            if jRP == 1
                fprintf('Reactant:\n');
            else
                fprintf('Product:\n');
            end
            for j = 1:numel(m{jRP})
                if floor(modelLocal.S(m{jRP}(j), id)) ~= modelLocal.S(m{jRP}(j), id)
                %at most display 6 decimal places, or use scientific notation
                    d = 0;
                    x = modelLocal.S(m{jRP}(j), id);
                    while x ~= round(x, d) && d <= 6
                        d = d + 1;
                    end
                    if round(x,d) == 0
                        stForm = '%-9.2e';
                    else
                        stForm = ['%-9.' num2str(d) 'f'];
                    end
                else
                    stForm = '%-9.0f';
                end
                fprintf([dis2 '  '], m{jRP}(j));
                printFcn(modelLocal.mets{m{jRP}(j)}, modelLocal.mets{m{jRP}(j)},dispLen1);
                if iscell(modelLocal.metNames{m{jRP}(j)})
                    metNamePrint = strjoin(modelLocal.metNames{m{jRP}(j)},'|');
                else
                    metNamePrint = modelLocal.metNames{m{jRP}(j)};
                end
                fprintf(['  ' stForm '  %s, %s\n'], full(modelLocal.S(m{jRP}(j),id)), metNamePrint, modelLocal.metFormulas{m{jRP}(j)});
            end
        end
    end
else
    id = findMetIDs(modelLocal,metrxn);
    if id == 0
        warning('The 2nd input is neither a metabolite or reaction of the model.');
        return
    end
    pathLocal(end + 1, :) = {metrxn, ''};
    %input is a metabolite
    if iscell(modelLocal.metNames{id})
        metNamePrint = strjoin(modelLocal.metNames{id},'|');
    else
        metNamePrint = modelLocal.metNames{id};
    end
    fprintf('\nMet %s, %s, %s\n', modelLocal.mets{id}, metNamePrint, modelLocal.metFormulas{id});
    for jCP = 1:2
        if jCP == 1
            r = find(modelLocal.S(id,:) .* direction < 0);
            fprintf('Consuming reactions%s:',nzFluxPrint);
        else
            r = find(modelLocal.S(id,:) .* direction > 0);
            fprintf('Producing reactions%s:',nzFluxPrint);
        end
        if isempty(r)
            fprintf(' none\n');
        else
            %print rxn formulas
            fprintf('\n');
            p = printRxnFormula(modelLocal, modelLocal.rxns(r),0, 1, 0);            
            for j = 1:numel(r)
                %handle reaction flux
                fluxPrint = '';
                if ~isempty(fluxLocal)
                    fluxPrint = sprintf('(%.6f)',fluxLocal(r(j)));
                end
                %print reaction info
                fprintf('#%d  ', r(j));
                printFcn(modelLocal.rxns{r(j)}, modelLocal.rxns{r(j)}, 0);
                fprintf('  %s  %s\n  ', modelLocal.rxnNames{r(j)}, fluxPrint);
                % print equation
                m = find(modelLocal.S(:,r(j)));
                %dictionary for printing mets or metNames in equation
                dict = modelLocal.mets(m);
                if metNameFlag, dict(:,2) = modelLocal.metNames(m); end
                formPart = strsplit(p{j});
                nChar = 0;
                lineBreak = false;
                for jPart = 1:numel(formPart)
                    metEqPrint = '';
                    f = strcmp(dict(:,1), formPart{jPart});
                    if any(f), metEqPrint = dict{f, 1 + metNameFlag}; end
                    if nChar > 0 && nChar + length(metEqPrint) + isempty(metEqPrint) * length(formPart{jPart}) > nCharBreak
                        lineBreak = true;
                    end
                    nChar = nChar + length(metEqPrint) + isempty(metEqPrint) * length(formPart{jPart}) + 1; %+1 for the space
                    if isempty(metEqPrint)
                        if lineBreak, fprintf('\n  '); nChar = 0; lineBreak = false; end
                        fprintf('%s ', formPart{jPart});
                    else
                        printFcn(formPart{jPart}, metEqPrint, 0);
                        fprintf(' ');
                    end
                end
                fprintf('\n');
            end
        end
    end
    
end
if printShowPrev
    if ~isempty(fluxLocal)
        fprintf('\n<a href="matlab: surfNet([],[],%d, [], %d, %d, %d, struct(''showPrev'',true));">%s</a>\n',...
            metNameFlag, NonzeroFluxFlag, nCharBreak, showMets, 'Show previous steps...');
    else
        fprintf('\n<a href="matlab: surfNet([],[],%d, ''none'', 0, %d, %d, struct(''showPrev'',true));">%s</a>\n',...
            metNameFlag, nCharBreak, showMets, 'Show previous steps...');
    end
end
%define the nested print function for printing strings on command line with
%interactive calling
    function printFcn(abb, name, digit)
        if ~isempty(fluxLocal)
            sPrint = ['<a href="matlab: surfNet([],''%s'',%d,[],%d, %d, %d);">%' num2str(digit) 's</a>'];
            fprintf(sPrint, abb, metNameFlag,NonzeroFluxFlag, nCharBreak, showMets, name);
        else
            sPrint = ['<a href="matlab: surfNet([],''%s'',%d, ''none'', 0, %d, %d);">%' num2str(digit) 's</a>'];
            fprintf(sPrint, abb, metNameFlag, nCharBreak, showMets, name);
        end 
    end

end

