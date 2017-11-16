function [Ematrix, element, errMsg] = getElementalComposition(formulae, element, chargeInFormula, selfCall)
% Get the complete elemental composition matrix including generic elements
%
% USAGE:
%    [Ematrix, element] = parseGenericFormula(formulae, element, chargeInFormula)
%
% INPUT:
%    formulae:        cell array of strings of chemical formulae. Can contain any generic elements starting 
%                     with a capital letter followed by lowercase letters or '_', followed by a non-negative number. 
%                     Also support '()', '[]', '{}'. E.g. {'H2O'; '[H2O]2(CuSO4)Generic_element0.5'}
% OPTIONAL INPUT:
%    element:         element from previous call to preserve the order (default [])
%    chargeInFormula: true to accept formulae containing the generic element 'Charge' representing the charges, 
%                     followed by a real number, e.g., 'HCharge1', 'SO4Charge-2' (default false).
%
% OUTPUTS:
%    Ematrix:         elemental composition matrix (#formulae x #elements)
%    element:         cell array of elements corresponding to the columns of Ematrix
%
% E.g., [Ematrix, element] = getElementalComposition({'H2O'; '[H2O]2(CuSO4)Generic_element0.5'}) would return:
%  element = {'H', 'O', 'Cu', 'S', 'Generic_element'}
%  Ematrix = [ 2,   1,    0,   0,   0; 
%              4,   6,    1,   1,   0.5]
%
% Siu Hung Joshua Chan May 2017

if nargin < 4
    selfCall = 0;
end
if nargin < 3 || isempty(chargeInFormula)
    chargeInFormula = false;
else
    chargeInFormula = logical(chargeInFormula);
end
%for recalling the original formula at the top level if there are parentheses
%in the formula leading to iterative calling
persistent formTopLv
if ~selfCall
    formTopLv = '';
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

if nargin < 2 || isempty(element)
    element = {};
elseif numel(unique(element)) < numel(element)
    error('Repeated elements in the input ''element'' array.')
else
    element = element(:);  % make sure it is a column vector
end

% the Ematrix
Ematrix = zeros(numel(formulae), numel(element));
% replace all brackets and braces by parentheses
formulae = regexprep(formulae, '[\[\{]', '\(');
formulae = regexprep(formulae, '[\]\}]', '\)');
nE = numel(element);
errMsg = '';
digit = floor(log10(numel(formulae))) + 1;
for j = 1:numel(formulae)
    errMsgJ = '';
    formulae{j} = strtrim(formulae{j});
    if ~isempty(formulae{j})
        %get all outer parentheses
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
                        if any(isnan(stCheck))  % if any string is not convertible to number
                            f = [formulae{j}(parenthesis(end,1):parenthesis(end,2)), stPre{1}];
                            if isempty(formTopLv)
                                s2 = '';
                            elseif selfCall == 1
                                s2 = sprintf('from the part ''(%s)''', formulae{j});
                            elseif selfCall == 2
                                s2 = sprintf('from the part ''%s''', formulae{j});
                            end
                            errMsgJ = [errMsgJ, sprintf('    Invalid stoichiometry in ''%s'' %s\n', f, s2)];
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
                    % if chargeInFormula is true, detect negative stoich for non-charge element, else any negative stoich
                    negSt = (~chargeInFormula | ~strcmp(eleCheck, 'Charge')) & stCheck < 0;
                    if any(negSt)
                        f = strjoin(cellfun(@(x) strjoin(x, ''), re(negSt), 'UniformOutput', false), ''', ''');
                        [errorFlag, errMsgKey] = deal(2, 'Negative');
                    end
                end
            end
            if errorFlag > 0
                if isempty(formTopLv)
                    s2 = '';
                elseif selfCall == 1
                    s2 = sprintf('from the part ''(%s)''', formulae{j});
                elseif selfCall == 2
                    s2 = sprintf('from the part ''%s''', formulae{j});
                end
                if errorFlag == 1
                    errMsgJ = [errMsgJ, sprintf(['    Only ''%s'' can be recognized %s.\n'...
                        '       Each element should start with a capital letter followed by lower case letters'...
                        ' or ''_'' with indefinite length and followed by a number.\n'], s, s2)];
                elseif errorFlag == 2
                    errMsgJ = [errMsgJ, sprintf('    %s stoichiometry in ''%s'' %s\n', errMsgKey, f, s2)];
                end
            end
            elementJ = repmat({''},numel(re), 1);
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
            [ynE, idE] = ismember(elementJ, element);  % map to existing elements
            if any(~ynE)
                idE(~ynE) = (nE + 1):(nE + sum(~ynE));
                Ematrix(:, (nE + 1):(nE + sum(~ynE))) = 0;
                nE = nE + sum(~ynE);
                element = [element; elementJ(~ynE)];
            end
            Ematrix(j, idE) = stoichJ;
        else
            % parentheses found. iteratively get the formula inside parentheses
            rest = true(length(formulae{j}),1);
            if isempty(formTopLv)
                formTopLv = formulae{j};
            end
            for k = 1:size(parenthesis,1)
                [EmatrixK, element, errMsgK] = getElementalComposition(formulae{j}(...
                    (parenthesis(k,1)+1):(parenthesis(k,2)-1)), element, chargeInFormula, 1);
                if numel(element) > size(Ematrix, 2)
                    Ematrix(:, (size(Ematrix, 2) + 1):numel(element)) = 0;
                end
                negSt = (~chargeInFormula | ~strcmp(element, 'Charge')) & EmatrixK * stP(k) < 0;
                negSt2 = (~chargeInFormula | ~strcmp(element, 'Charge')) & EmatrixK ~= 0 & stP(k) < 0;
                if (isempty(errMsgK) && any(negSt)) || any(negSt2)
                    errMsgK = [errMsgK, sprintf(['    Negative stoichiometry in the part (%s)', ...
                        num2str(stP(k)), '\n'], formulae{j}((parenthesis(k,1)+1):(parenthesis(k,2)-1)))];
                end
                Ematrix(j, 1:numel(element)) = Ematrix(j, 1:numel(element)) + EmatrixK * stP(k);
                rest(parenthesis(k,1):stPpos(k,2)) = false;
                errMsgJ = [errMsgJ, errMsgK];
            end
            if any(rest)
                [EmatrixK, element, errMsgK] = getElementalComposition(formulae{j}(rest), element, chargeInFormula, 2);
                if numel(element) > size(Ematrix, 2)
                    Ematrix(:, (size(Ematrix, 2) + 1):numel(element)) = 0;
                end
                Ematrix(j, 1:numel(element)) = Ematrix(j, 1:numel(element)) + EmatrixK;
                errMsgJ = [errMsgJ, errMsgK];
            end
            formTopLv = '';
        end
    else
        Ematrix(j,:) = NaN;
    end
    if ~isempty(errMsgJ)
        if ~selfCall
            errMsg = [errMsg, sprintf(['#%0' num2str(digit) 'd:  %s\n'], j, formulae{j})];
        end
        errMsg = [errMsg, errMsgJ];
    end
end
Ematrix = Ematrix(:, 1:numel(element));
element = element(:)';
if ~selfCall && ~isempty(errMsg)
    error(['%s\n', errMsg], 'Invalid formula input:')
end
end