function [Ematrix, elements] = computeElementalMatrix(model, metList, warnings, genericFormula)
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
%
% OUTPUT:
%    Ematrix:     `m x 6` matrix of order [C N O H P other] if genericFormula = 0 
%                 `m x e` matrix if genericFormula = 1 given e elements in the chemical formulae
%    elements:    cell array of elements corresponding to the columns of Ematrix
%
% .. Author: - Richard Que (1/22/10) Extracted from computeMW.

persistent elementalWeightMatrix

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
    if isempty(elementalWeightMatrix)
        elementalWeightMatrix = getElementalWeightMatrix();
    end
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
            if isempty(q)
                q = 1;
            end
            elementpos = strcmp(elements, comp);
            isspecialElement = any(elementpos(1:(end - 1)));
            isElement = any(strcmp(elementalWeightMatrix(:, 1), comp));
            if isspecialElement
                Ematrix(n, elementpos) = Ematrix(n, elementpos) + q;
            elseif isElement
                Ematrix(n, end) = Ematrix(n, end) + q;
            else
                if warnings
                    display('Warning');
                    display(formula)
                    display(comp);
                end
            end
        end
        
    end
else
    [Ematrix, elements] = getElementalComposition(model.metFormulas(metIDs));
    % reorder the sequence of elements
    [yn, id] = ismember({'C', 'N', 'O', 'H', 'P'}', elements(:));
    idPrimeElement = id(yn);
    idOtherElement = setdiff(1:numel(elements), idPrimeElement);
    elements = elements([idPrimeElement; idOtherElement(:)]);
    Ematrix = Ematrix(:, [idPrimeElement; idOtherElement(:)]); 
end

end