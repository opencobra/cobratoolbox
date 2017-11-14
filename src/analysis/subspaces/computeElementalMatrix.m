function [Ematrix, elements] = computeElementalMatrix(model, metList, warnings, genericFormula, elements)
% Computes elemental matrix
%
% USAGE:
%
%    [Ematrix, element] = computeElementalMatrix(model, metList, warnings, acceptGenericFormula, element)
%
% INPUT:
%    model:       COBRA model structure (must define `.mets` and `.metFormulas`)
%
% OPTIONAL INPUTS:
%    metList:     Cell array of which metabolites to search for
%                 (Default = all metabolites in model)
%    warnings:    Display warnings if there are errors with the
%                 formula. (Default = true)
%    genericFormula: false to return composition for  [C N O H P other] only (Default = false).
%                    true to accept generic formulae containing any elements starting with 'A'-'Z', 
%                    followed by 'a'-'z' or '_' of indefinite length, followed by a real number (can be -ve),
%                    and also support '()', '[]', '{}'. E.g. '([H2O]2(CuSO4))2Generic_element-0.5'
%    elements:    'elements' from a previous run to preserve the order of the elements (used only if genericFormula = 1)
%
% OUTPUT:
%    Ematrix:     `m x 6` matrix of order [C N O H P other] if genericFormula = 0 
%                 `m x e` matrix if genericFormula = 1 given e elements in the chemical formulae
%    elements:    cell array of elements corresponding to the columns of Ematrix
%
% .. Author: - Richard Que (1/22/10) Extracted from computeMW.
if nargin < 5
    elements = [];
end

if nargin < 4 || isempty(genericFormula)
    genericFormula = false;
end

if nargin < 3 || isempty(warnings)
    warnings = true;
end

if nargin < 2 || isempty(metList)
    metIDs = 1:length(model.mets);
else
    metIDs = findMetIDs(model,metList);
end

metIDs = reshape(metIDs, length(metIDs),1);

if ~genericFormula
    elements = {'C', 'N', 'O', 'H', 'P', 'Other'};
    Ematrix = zeros(length(metIDs), 6);
    for n = 1:length(metIDs)
        i = metIDs(n);
        formula = model.metFormulas(i);
        [compounds, tok] = regexp(formula, '([A-Z][a-z]*)(\d*)', 'match', 'tokens');
        tok = tok{1,1};
        for j = 1:length(tok) % go through each token.
            t = tok{1,j};
            comp = t{1,1};
            q = str2num(t{1,2});
            if (isempty(q))
                q = 1;
            end
            switch comp
                case 'H'
                    Ematrix(n,4) = q;
                case 'C'
                    Ematrix(n,1) = q;
                case 'N'
                    Ematrix(n,2) = q;
                case 'O'
                    Ematrix(n,3) = q;
                case 'Na'
                    Ematrix(n,6) = Ematrix(n,6) + q;
                case 'Mg'
                    Ematrix(n,6) = Ematrix(n,6) + q;
                case 'P'
                    Ematrix(n,5) = q;
                case 'S'
                    Ematrix(n,6) = Ematrix(n,6) + q;
                case 'Cl'
                    Ematrix(n,6) = Ematrix(n,6) + q;
                case 'K'
                    Ematrix(n,6) = Ematrix(n,6) + q;
                case 'Ca'
                    Ematrix(n,6) = Ematrix(n,6) + q;
                case 'Mn'
                    Ematrix(n,6) = Ematrix(n,6) + q;
                case 'Fe'
                    Ematrix(n,6) = Ematrix(n,6) + q;
                case 'Ni'
                    Ematrix(n,6) = Ematrix(n,6) + q;
                case 'Co'
                    Ematrix(n,6) = Ematrix(n,6) + q;
                case 'Cu'
                    Ematrix(n,6) = Ematrix(n,6) + q;
                case 'Zn'
                    Ematrix(n,6) = Ematrix(n,6) + q;
                case 'As'
                    Ematrix(n,6) = Ematrix(n,6) + q;
                case 'Se'
                    Ematrix(n,6) = Ematrix(n,6) + q;
                case 'Ag'
                    Ematrix(n,6) = Ematrix(n,6) + q;
                case 'Cd'
                    Ematrix(n,6) = Ematrix(n,6) + q;
                case 'W'
                    Ematrix(n,6) = Ematrix(n,6) + q;
                case 'Hg'
                    Ematrix(n,6) = Ematrix(n,6) + q;
                otherwise
                    if warnings
                        display('Warning');
                        display(formula)
                        display(comp);
                    end
            end
        end
        
    end
else
    [Ematrix, elements] = parseGenericFormula(model.metFormulas(metIDs), elements);
    [yn, id] = ismember({'C', 'N', 'O', 'H', 'P'}', elements(:));
    idPrimeElement = id(yn);
    idOtherElement = setdiff(1:numel(elements), idPrimeElement);
    elements = elements([idPrimeElement; idOtherElement(:)]);
    Ematrix = Ematrix(:, [idPrimeElement; idOtherElement(:)]); 
end

end

function [Ematrix, element] = parseGenericFormula(formulae, element, selfCall)
% Get the complete elemental composition matrix including generic elements
%
% USAGE:
%    [Ematrix, element] = parseGenericFormula(formulae, element)
%
% INPUT:
%    formulae:        cell array of strings of chemical formulae. Can contain any generic elements starting 
%                     with a capital letter followed by lowercase letters or '_', followed by a real number (can be -ve). 
%                     Also support '()', '[]', '{}'. E.g. {'H2O'; '[H2O]2(CuSO4)Generic_element-0.5'}
% OPTIONAL INPUT:
%    element:         element from previous call to preserve the order
%
% OUTPUTS:
%    Ematrix:         elemental composition matrix (#formulae x #elements)
%    element:         cell array of elements corresponding to the columns of Ematrix
%
% E.g., [Ematrix, element] = parseGenericFormula({'H2O'; '[H2O]2(CuSO4)Generic_element-0.5'}) would return:
%  element = {'H'; 'O'; 'Cu'; 'S'; Generic_element}
%  Ematrix = [2, 1, 0, 0; 4, 6, 1, 1, -0.5]
%
% Siu Hung Joshua Chan May 2017

if nargin < 3
    selfCall = false;
end
%for recalling the original formula at the top level if there are parentheses
%in the formula leading to iterative calling
persistent formTopLv
if ~selfCall
    formTopLv = '';
end

nE_max = 150;  % maximum number of different elements

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
        error('The 1st input ''formulae'' should be a cell array of strings of formulae or a COBRA model')
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
Ematrix = zeros(numel(formulae), max([nE_max,numel(element)]));
% replace all brackets and braces by parentheses
formulae = regexprep(formulae, '[\[\{]', '\(');
formulae = regexprep(formulae, '[\]\}]', '\)');
nE = numel(element);
for j = 1:numel(formulae)
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
                    %closed parenthesis, get the following stoichiometry if any
                    stPre = regexp(formulae{j}(k+1:end), '^(\+|\-)?\d*\.?\d*', 'match');
                    if isempty(stPre)
                        stP = [stP; 1];
                        stPpos = [stPpos; k k];
                    elseif isnan(str2double(stPre{1}))
                        f = [formulae{j}(parenthesis(end,1):parenthesis(end,2)), stPre{1}];
                        if isempty(formTopLv)
                            s2 = sprintf('the input formula ''%s''',formulae{j});
                        else
                            s2 = sprintf('''(%s)'' in the input formula ''%s''',formulae{j},formTopLv);
                        end
                        error(['#%d: Invalid stoichiometry in chemical formula. ''%s''',...
                            ' from %s'],j,f,s2);
                    else
                        %stoichiometry
                        stP = [stP; str2double(stPre{1})];
                        %position of the stoichiometry in the text
                        stPpos = [stPpos; k+1, k+length(stPre{1})];
                        k = k + length(stPre{1});
                    end
                end
                lv = lv - 1;
            end
            k = k + 1;
        end
        if isempty(parenthesis)
        %if isempty(strfind(form{j}, '(')) %&& ~strcmp(form{j}, 'none')
        %No parenthesis, parse the formula
            re = regexp(formulae{j}, '([A-Z][a-z_]*)((?:\+|\-)?\d*\.?\d*)', 'tokens');
            s = strjoin(cellfun(@(x) strjoin(x,''),re,'UniformOutput',false),'');
            errorFlag = 0;
            if ~strcmp(s,formulae{j})
                errorFlag = 1;
                
            else
                f = cellfun(@(x) ~isempty(x{2}) & isnan(str2double(x{2})),re);
                if any(f)
                    f = strjoin(cellfun(@(x) strjoin(x,''),re(f),'UniformOutput',false),''', ''');
                    errorFlag = 2;
                end
            end
            if errorFlag > 0
                if isempty(formTopLv)
                    s2 = sprintf('the input formula ''%s''',formulae{j});
                else
                    s2 = sprintf('''(%s)'' in the input formula ''%s''',formulae{j},formTopLv);
                end
                if errorFlag == 1
                    error(['#%d: Invalid chemical formula. Only ''%s'' can be recognized' ...
                        ' from %s.\n'...
                        'Each element should start with a capital letter followed by lower case letters '...
                        'or ''_'' with indefinite length and followed by a number.\n'],...
                        j, s, s2)
                elseif errorFlag == 2
                    error(['#%d: Invalid stoichiometry in chemical formula. ''%s''',...
                        ' from %s'],j,f,s2);
                end
            end
            elementJ = repmat({''},numel(re), 1);
            nEj = 0;
            stoichJ = zeros(numel(re),1);
            for k = 1:numel(re)
                [ynK,idK] = ismember(re{k}(1),elementJ(1:nEj));
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
            [ynE, ~] = ismember(elementJ, element);
            nE = nE + sum(~ynE);
            element = [element; elementJ(~ynE)];
            [~, idE] = ismember(elementJ, element);
            Ematrix(j, :) = 0;
            Ematrix(j, idE) = stoichJ;
        else
            %parentheses found. iteratively get the formula inside
            %parentheses
            rest = true(length(formulae{j}),1);
            if isempty(formTopLv)
                formTopLv = formulae{j};
            end
            for k = 1:size(parenthesis,1)
                [EmatrixK, element] = parseGenericFormula(formulae{j}(...
                    (parenthesis(k,1)+1):(parenthesis(k,2)-1)), element, true);
                Ematrix(j,1:numel(element)) = Ematrix(j,1:numel(element)) + EmatrixK * stP(k);
                rest(parenthesis(k,1):stPpos(k,2)) = false;
            end
            if any(rest)
                [EmatrixK, element] = parseGenericFormula(formulae{j}(rest), element, true);
                Ematrix(j,1:numel(element)) = Ematrix(j,1:numel(element)) + EmatrixK;
            end
            formTopLv = '';
        end
    else
        Ematrix(j,:) = NaN;
    end
end
Ematrix = Ematrix(:, 1:numel(element));

end
