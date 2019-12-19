function p = printRxnFormulaLinked(model, rxnAbbrList, printFlag, metNameFlag, flux, nCharBreak, commandUsingMet)
% print reaction formulae in which the metabolites are hyperlinked to run a
% specific command involving the metabolites when displayed in the Matlab
% command window. Called by `surfNet.m`.
%
% USAGE:
%    p = printRxnFormulaLinked(model, rxnAbbrList, printFlag, metNameFlag, flux, nCharBreak, commandUsingMet)
%
% INPUTS:
%    model:                COBRA model
%
% OPTIONAL INPUTS:
%    rxnAbbrList:          cell array of reactions to be printed (default all reactions)
%    printFlag:            true to print, otherwise return the strings only (default true)
%    metNameFlag:          true to display met names in *.metNames instead of *.mets (default false)  
%    flux:                 the flux of the reaction. When non-empty, determine the arrow for the formula accordingly
%    nCharBreak:           max. number of character printed on each line
%    commandUsingMet:      string of Matlab command for the genes in the model, e.g., 'fprintf(''%s'')' where %s
%                          will be replaced by the metabolites (default [], not adding the field for hyperlinked grRules)
if nargin < 2 || isempty(rxnAbbrList)
    rxnAbbrList = model.rxns;
end
if nargin < 3 || isempty(printFlag)
    printFlag = true;
end
if nargin < 4 || isempty(metNameFlag)
    metNameFlag = false;
end
if nargin < 5
    flux = [];
end
if nargin < 6 || isempty(nCharBreak)
    nCharBreak = get(0, 'CommandWindowSize');
    nCharBreak = nCharBreak(1);
end
if nargin < 7 || isempty(commandUsingMet)
    commandUsingMet = 'fprintf(''%s\\n'')';
end

if ~ischar(rxnAbbrList) && ~(iscell(rxnAbbrList) && numel(rxnAbbrList) == 1)
    p = cell(numel(rxnAbbrList), 1);
    for j = 1:numel(rxnAbbrList)
        p(j) = printRxnFormulaLinked(model, rxnAbbrList{j}, printFlag, metNameFlag, flux, nCharBreak);
    end
    return
end

rxnID = findRxnIDs(model, rxnAbbrList);

% determine the arrow sign
arrow = '->';
if (isempty(flux) || flux == 0) && model.lb(rxnID) < 0 && model.ub(rxnID) > 0
    arrow = '<=>';
elseif (isempty(flux) || flux == 0) && model.lb(rxnID) < 0 && model.ub(rxnID) <= 0
    arrow = '<-';
elseif ~isempty(flux) && flux < 0
    arrow = '<-';
end

% reactant
metR = model.S(:, rxnID) < 0;
if ~any(metR)
    reactantSide = cell(2, 0);
    isMetR = false(2, 0);
    isMetRst = false(2, 0);
else% reactant stoichiometry
    metRst = cellfun(@num2str, num2cell(abs(model.S(metR, rxnID))), 'UniformOutput', false);
    % not printing the coefficient if it is 1
    metRst(model.S(metR, rxnID) == -1) = {''};
    reactantSide = [metRst(:)'; columnVector(model.mets(metR))'; repmat({'+'}, 1, sum(metR) - 1), {arrow}];
    isMetR = [false(1, sum(metR)); true(1, sum(metR)); false(1, sum(metR))];
    isMetRst = [true(1, sum(metR)); false(2, sum(metR))];
end

% product
metP = model.S(:, rxnID) > 0;
if ~any(metP)
    productSide = cell(2, 0);
    isMetP = false(2, 0);
    isMetPst = false(2, 0);
else
    % product stoichiometry
    metPst = cellfun(@num2str, num2cell(model.S(metP, rxnID)), 'UniformOutput', false);
    % not printing the coefficient if it is 1
    metPst(model.S(metP, rxnID) == 1) = {''};
    productSide = [metPst(:)'; columnVector(model.mets(metP))'; repmat({'+'}, 1, sum(metP) - 1), {''}];
    isMetP = [false(1, sum(metP)); true(1, sum(metP)); false(1, sum(metP))];
    isMetPst = [true(1, sum(metP)); false(2, sum(metP))];
end

formulaeParts = [reactantSide(:); productSide(:)];
isMet = [isMetR(:); isMetP(:)];
isStoich = [isMetRst(:); isMetPst(:)];
% remove empty cells
isMet(cellfun(@isempty, formulaeParts)) = [];
isStoich(cellfun(@isempty, formulaeParts)) = [];
formulaeParts(cellfun(@isempty, formulaeParts)) = [];
isArrow = strcmp(formulaeParts, arrow);

if metNameFlag
    productSide(2, :) = columnVector(model.metNames(metP))';
    reactantSide(2, :) = columnVector(model.metNames(metR))';
    formulaePartsToPrint = [reactantSide(:); productSide(:)];
    formulaePartsToPrint(cellfun(@isempty, formulaePartsToPrint)) = [];
else
    formulaePartsToPrint = formulaeParts;
end

    
%printFormulae(formulaeParts, dict, arrow, metNameFlag, nCharBreak, nCharBreakReal)

nChar = 0;  % number of characters printed in the current line
p = '';
[lineBreak, firstWordOnLine] = deal(false, true);

for jPart = 1:numel(formulaeParts)
    
    nChar = nChar + length(formulaePartsToPrint{jPart}) + 1;
    if ~isMet(jPart)  % not a metabolite name (stoich/'+'/'->'/'<=>')
        spaceAdded = 0;  % additional space for arrow
        if isArrow(jPart)
            spaceAdded = 4;
        end
        % check if a new line is needed
        if ~firstWordOnLine 
            if ~isStoich(jPart) && jPart < numel(formulaeParts)
                % not a stoich ('+'/'->'/'<=>'): new line if togther with the next stoich + met exceed the limit
                if isStoich(jPart + 1) && nChar + length(formulaePartsToPrint{jPart + 1}) + length(formulaePartsToPrint{jPart + 2}) + 1 + spaceAdded >= nCharBreak
                    lineBreak = true;
                elseif isMet(jPart + 1) && nChar + length(formulaePartsToPrint{jPart + 1}) + spaceAdded >= nCharBreak
                    lineBreak = true;
                end
            end
        end
        firstWordOnLine = false;
        if lineBreak
            p = [p '\n  '];
            nChar = length(formulaePartsToPrint{jPart}) + 3;  % 2 spaces before + 1 space after
            [lineBreak, firstWordOnLine] = deal(false, true);
            if isArrow(jPart)
                spaceAdded = 2;
            end
        end
        [spaceAddLeft, spaceAddRight] = deal('');
        if isArrow(jPart)
            if jPart < numel(formulaeParts)
                spaceAddRight = '  ';
            end
            if ~firstWordOnLine
                spaceAddLeft = '  ';
            end
            nChar = nChar + length(spaceAddLeft) + length(spaceAddRight);
        end
        p = [p, spaceAddLeft, formulaeParts{jPart}, spaceAddRight, ' '];
    else
        % print hyperlink if it is a metabolite name
        p = [p, printHyperlink(strrep(commandUsingMet, '%s', formulaeParts{jPart}), formulaePartsToPrint{jPart}, 0, false), ' '];
        firstWordOnLine = false;
    end
end
if printFlag
    fprintf(p);
end
p = {p};
end