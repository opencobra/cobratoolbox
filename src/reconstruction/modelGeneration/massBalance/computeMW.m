function [MW, Ematrix] = computeMW(model, metList, warnings, genericFormula)
% Computes molecular weight and elemental matrix of compounds
%
% USAGE:
%
%    [MW, Ematrix] = computeMW(model, metList, warnings)
%
% INPUT:
%    model:       COBRA model structure (must define .mets and .metFormulas)
%
% OPTIONAL INPUTS:
%    metList:     Cell array of which metabolites to search for. (Default = all metabolites in model)
%    warnings:    Display warnings if there are errors with the formula. (Default = true)
%    genericFormula: true to accept generic formulae containing any elements starting with 'A'-'Z', 
%                    followed by 'a'-'z' or '_' of indefinite length, followed by a real number (can be -ve). 
%                    Support '()', '[]', '{}'. E.g. '([H2O]2(CuSO4))2Generic_element-0.5' (Default = false)
%
% OUTPUTS:
%    MW:          Vector of molecular weights
%    Ematrix:     `m` x 6 matrix of order [C N O H P other]
%
% .. Author: - Jan Schellenberger (Nov. 5, 2008)

if nargin < 4
    genericFormula = false;
end

if nargin < 3 || isempty(warnings)
    warnings = true;
end

if nargin < 2 || isempty(metList)
    metList = model.mets;
    metIDs = 1:length(model.mets);
else
    metIDs = findMetIDs(model,metList);
end

metIDs = reshape(metIDs, length(metIDs),1);

% molecular weight of elements in a structure
elementMwStruct = struct('H', 1, 'C', 12, 'N', 14, 'O', 16, 'Na', 23, 'Mg', 24, 'P', 31, ...
    'S', 32, 'Cl', 35, 'K', 39, 'Ca', 40, 'Mn', 55, 'Fe', 56, 'Ni', 58, 'Co', 59, ...
    'Cu', 63, 'Zn', 65, 'As', 75, 'Se', 80, 'Ag', 107, 'Cd', 114, 'W', 184, 'Hg', 202);
elementNames = fieldnames(elementMwStruct);  % elements' names

if ~genericFormula
    MW = zeros(size(metIDs));

    for n = 1:length(metIDs)
        i = metIDs(n);
        formula = model.metFormulas(i);
        [compounds, tok] = regexp(formula, '([A-Z][a-z]*)(\d*)', 'match', 'tokens');
        tok = tok{1, 1};
        for j = 1:length(tok) % go through each token.
            t = tok{1,j};
            comp = t{1,1};
            q = str2num(t{1, 2});
            if (isempty(q))
                q = 1;
            end
            mwt = 0;
            if any(strcmp(elementNames, comp))
                % if the element is in the structure, give it a weight
                mwt = elementMwStruct.(comp);
            elseif warnings
                display('Warning');
                display(formula)
                display(comp);
            end
            MW(n) = MW(n) + q * mwt;
        end
    end
    Ematrix = computeElementalMatrix(model,metList,false);
else
    % elements' MWs in a vector
    elementMwVector = struct2array(elementMwStruct);
    [Ematrix, elements] = computeElementalMatrix(model, metList, false, true);
    [yn, id] = ismember(elements, elementNames);
    MW = Ematrix(:, yn) * columnVector(elementMwVector(id(yn)));
end
