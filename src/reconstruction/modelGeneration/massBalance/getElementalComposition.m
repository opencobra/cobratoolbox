function [Ematrix, elements] = getElementalComposition(formulae, elements, chargeInFormula)
% Get the complete elemental composition matrix. It supports formulae with 
% generic elements, parentheses and decimal places
%
% USAGE:
%    [Ematrix, elements] = getElementalComposition(formulae, elements, chargeInFormula)
%
% INPUT:
%    formulae:        cell array of strings of chemical formulae. Can contain any generic elements starting 
%                     with a capital letter followed by lowercase letters or '_', followed by a non-negative number. 
%                     Also support '()', '[]', '{}'. E.g. {'H2O'; '[H2O]2(CuSO4)Generic_element0.5'}
% OPTIONAL INPUTS:
%    elements:        elements from previous call to preserve the order (default {})
%    chargeInFormula: true to accept formulae containing the generic element 'Charge' representing the charges, 
%                     followed by a real number, e.g., 'HCharge1', 'SO4Charge-2' (default false).
%
% OUTPUTS:
%    Ematrix:         elemental composition matrix (#formulae x #elements)
%    elements:         cell array of elements corresponding to the columns of Ematrix
%
% E.g., [Ematrix, elements] = getElementalComposition({'H2O'; '[H2O]2(CuSO4)Generic_element0.5'}) would return:
%  elements = {'H', 'O', 'Cu', 'S', 'Generic_element'}
%  Ematrix = [ 2,   1,    0,   0,   0; 
%              4,   6,    1,   1,   0.5]
%
% Siu Hung Joshua Chan May 2017

if nargin < 3 || isempty(chargeInFormula)
    chargeInFormula = false;
else
    chargeInFormula = logical(chargeInFormula);
end
% for recalling the original formula at the top level if there are parentheses
% in the formula leading to iterative calling
persistent formTopLv
persistent formCurLv
% for storing error message during iterative calling
persistent errMsg
persistent errMsgInThisLoop
persistent topLvJ
persistent selfCall
if isempty(selfCall)
    selfCall = 0;
end
if ~selfCall
    [formTopLv, errMsg] = deal('');
end

if ~isstruct(formulae)
    if ~iscell(formulae)
        % make sure it is a cell array of strings
        formulae = {formulae};
    end
else
    % also accept COBRA model as input
    if isfield(formulae, 'metFormulas')
        formulae = formulae.metFormulas;
    else
        error('The 1st input ''formulae'' should be a cell array of strings of formulae or a COBRA model with *.metFormulas')
    end
end

if nargin < 2 || isempty(elements)
    elements = {};
elseif numel(unique(elements)) < numel(elements)
    error('Repeated elements in the input ''elements'' array.')
else
    elements = elements(:)';  % make sure it is a row vector
end

% the Ematrix
Ematrix = zeros(numel(formulae), numel(elements));
% replace all brackets and braces by parentheses
formulae = regexprep(formulae, '[\[\{]', '\(');
formulae = regexprep(formulae, '[\]\}]', '\)');
digit = floor(log10(numel(formulae))) + 1;
for j = 1:numel(formulae)
    if ~selfCall
        % reset top level information for each formula
        [formTopLv, topLvJ, errMsgInThisLoop] = deal(formulae{j}, j, false);
    end
    formulae{j} = strtrim(formulae{j});
    if ~isempty(formulae{j})
        % get all outer parentheses
        parenthesis = [];
        stP = [];
        stPpos = [];
        lv = 0;
        k = 1;
        while k <= length(formulae{j})
            if strcmp(formulae{j}(k),'(')
                if lv == 0
                    pStart = k;
                end
                lv = lv + 1;
            elseif strcmp(formulae{j}(k),')')
                if lv == 1
                    parenthesis = [parenthesis; [pStart k]];
                    % right parenthesis, get the following stoichiometry if any
                    stPre = regexp(formulae{j}(k+1:end), '^(\+|\-)?\d*\.?\d*', 'match');
                    if isempty(stPre)
                        stP = [stP; 1];
                        stPpos = [stPpos; k k];
                    else
                        stCheck = str2double(stPre{1});
                        s = '';
                        if isnan(stCheck)
                            s = 'Invalid';
                        elseif stCheck < 0
                            s = 'Negative';
                        end
                        if ~isempty(s)  % error if not convertible to number or negative
                            f = [formulae{j}(parenthesis(end,1):parenthesis(end,2)), stPre{1}];
                            addErrorMessage(sprintf('    %s stoichiometry in ''%s''\n', s, f))
                        end
                        % stoichiometry
                        stP = [stP; stCheck];
                        % position of the stoichiometry in the text
                        stPpos = [stPpos; k + 1, k + length(stPre{1})];
                        k = k + length(stPre{1});
                    end
                end
                lv = lv - 1;
            end
            k = k + 1;
        end
        if isempty(parenthesis)
        % No parenthesis, parse the formula
            re = regexp(formulae{j}, '([A-Z][a-z_]*)((?:\+|\-)?\d*\.?\d*)', 'tokens');
            s = strjoin(cellfun(@(x) strjoin(x,''), re, 'UniformOutput', false), '');
            errorFlag = 0;
            if ~strcmp(s, formulae{j})  % check if the entire formula is retrieved
                errorFlag = 1;
            else
                % check the stoichiometry
                eleCheck = cellfun(@(x) x{1}, re, 'UniformOutput', false);
                stCheck = cellfun(@(x) str2double(x{2}), re);
                stCheck(cellfun(@(x) isempty(x{2}), re)) = 1;  % empty value => stoichiometry = 1
                if any(isnan(stCheck))
                    f = strjoin(cellfun(@(x) strjoin(x, ''), re(isnan(stCheck)), 'UniformOutput', false), ''', ''');
                    [errorFlag, errMsgKey] = deal(2, 'Invalid');
                else
                    % if chargeInFormula is true, detect negative stoich for non-charge elements, else any negative stoich
                    negSt = (~chargeInFormula | ~strcmp(eleCheck, 'Charge')) & stCheck < 0;
                    if any(negSt)
                        f = strjoin(cellfun(@(x) strjoin(x, ''), re(negSt), 'UniformOutput', false), ''', ''');
                        [errorFlag, errMsgKey] = deal(2, 'Negative');
                    end
                end
            end
            if errorFlag > 0
                if selfCall <= 1
                    s2 = sprintf('from the part ''%s''', formulae{j});
                elseif selfCall == 2
                    s2 = sprintf('from the part ''(%s)''', formCurLv);
                elseif selfCall == 3
                    s2 = sprintf('from the part ''(%s)''', formulae{j});
                end
                if errorFlag == 1
                    s2 = sprintf(['    Only ''%s'' can be recognized %s.\n'...
                        '       Each element should start with a capital letter followed by lower case letters'...
                        ' or ''_'' with indefinite length and followed by a number.\n'], s, s2);
                elseif errorFlag == 2
                    s2 = sprintf('    %s stoichiometry in ''%s'' %s\n', errMsgKey, f, s2);
                end
                addErrorMessage(s2);
            end
            elementJ = repmat({''}, 1, numel(re));
            nEj = 0;
            stoichJ = zeros(numel(re),1);
            for k = 1:numel(re)
                [ynK,idK] = ismember(re{k}(1), elementJ(1:nEj));
                if ynK
                    k2 = idK;
                else
                    nEj = nEj + 1;
                    elementJ{nEj} = re{k}{1};
                    k2 = nEj;
                end
                if isempty(re{k}{2})
                    stoichJ(k2) = stoichJ(k2) + 1;
                else
                    stoichJ(k2) = stoichJ(k2) + str2double(re{k}{2});
                end
            end
            elementJ = elementJ(1:nEj);
            stoichJ = stoichJ(1:nEj);
            [ynE, idE] = ismember(elementJ, elements);  % map to existing elements
            if any(~ynE)
                idE(~ynE) = (numel(elements) + 1):(numel(elements) + sum(~ynE));
                Ematrix(:, (numel(elements) + 1):(numel(elements) + sum(~ynE))) = 0;
                elements = [elements, elementJ(~ynE)];
            end
            Ematrix(j, idE) = stoichJ;
        else
            % parentheses found. Iteratively get the formula inside parentheses
            rest = true(length(formulae{j}),1);
            for k = 1:size(parenthesis,1)
                selfCallCur = selfCall;
                selfCall = 3;
                [EmatrixK, elements] = getElementalComposition(formulae{j}(...
                    (parenthesis(k,1)+1):(parenthesis(k,2)-1)), elements, chargeInFormula);
                if numel(elements) > size(Ematrix, 2)
                    Ematrix(:, (size(Ematrix, 2) + 1):numel(elements)) = 0;
                end
                selfCall = selfCallCur;
                Ematrix(j, 1:numel(elements)) = Ematrix(j, 1:numel(elements)) + EmatrixK * stP(k);
                rest(parenthesis(k,1):stPpos(k,2)) = false;          
            end
            if any(rest)
                formCurLv = formulae{j};
                selfCallCur = selfCall;
                selfCall = 1 + (selfCall >= 1);
                while any(rest)
                    % get the consecutive part of the formula that is not in parentheses
                    [pStart, pEnd] = deal(find(rest, 1), find(~rest));
                    pEnd = min(pEnd(pEnd > pStart));
                    if isempty(pEnd)
                        pEnd = numel(rest);
                    else
                        pEnd = pEnd - 1;
                    end
                    [EmatrixK, elements] = getElementalComposition(formulae{j}(pStart:pEnd), elements, chargeInFormula);
                    if numel(elements) > size(Ematrix, 2)
                        Ematrix(:, (size(Ematrix, 2) + 1):numel(elements)) = 0;
                    end
                    Ematrix(j, 1:numel(elements)) = Ematrix(j, 1:numel(elements)) + EmatrixK;
                    rest(pStart:pEnd) = false;
                end
                selfCall = selfCallCur;
            end
        end
    else
        Ematrix(j,:) = NaN;
    end
end
Ematrix = Ematrix(:, 1:numel(elements));
if ~selfCall 
    selfCall = [];
    if ~isempty(errMsg)
        error(['%s\n', errMsg], 'Invalid formula input:')
    end
end

% nested function for adding error messages
    function addErrorMessage(s)
        if ~errMsgInThisLoop
            errMsg = [errMsg, sprintf(['#%0' num2str(digit) 'd:  %s\n'], topLvJ, formTopLv)];
            errMsgInThisLoop = true;
        end
        errMsg = [errMsg, s];
    end
end

