function [MW, Ematrix, elements, knownWeights, unknownElements] = computeMW(model, metList, warnings, generalFormula, isotopeAbundance)
% Computes molecular weight and elemental matrix of compounds
%
% USAGE:
%    [MW, Ematrix, elements, knownWeights, unknownElements] = computeMW(model, metList, warnings, generalFormula, isotopeAbundance)
%
% INPUT:
%    model:       COBRA model structure (must define .mets and .metFormulas)
%
% OPTIONAL INPUTS:
%    metList:            Cell array of which metabolites to search for. (Default = all metabolites in model)
%    warnings:           Display warnings if there are errors with the formula. (Default = true)
%    generalFormula:     * (default) false to calculate MWs for formulae containing consisting of common 
%                          biological elements using their mass numbers (instead of the standard atomic mass)
%                        * true to support formulae with brackets, decimal places and any chemical elements 
%                          including undefined groups (e.g., '([H2O]2(CuSO4))2Generic_element0.5').
%                          MW = NaN for any formulae with chemical elements of unknown weights
%                          except the reserved formula 'Mass0' for denoting truly massless metabolites (e.g., photon)
%    (isotopeAbundance is used only if genericFormula = true)
%    isotopeAbundance:   * (default) false to use standard atomic weights 
%                        * true to use the weights of naturally predominant isotopes for biological 
%                            elements and standard weights for other elements.
%                        * `m` x 3 cell arrray with user defined isotope abundance:
%                            isotopeAbundance{i, 1} = 'Atomic_Symbol';
%                            isotopeAbundance{i, 2} = Mass_Number;
%                            isotopeAbundance{i, 3} = abundance;
%                            (where sum of abundances of all isotopes of an element must be one)   
%
% OUTPUTS:
%    MW:                 Vector of molecular weights
%    Ematrix:            * `m` x 6 matrix of order [C N O H P other] if genericFormula = false
%                        * `m` x `e` matrix if genericFormula = true given `e` elements in the chemical formulae
%    element:            cell array of elements corresponding to the columns of Ematrix
%    (knownWeights and unknownElements are non-empty only if genericFormula = true)
%    knownWeights:       MWs for the part whose MW is computable ofr each of the formulae
%    unknownElements:    cell arrary of elements without known atomic weights that appear in the formulae
%
% .. Author: - Jan Schellenberger (Nov. 5, 2008)

if nargin < 4 || isempty(generalFormula)
    generalFormula = false;
end

if nargin < 5
    isotopeAbundance = false;
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

if ~generalFormula
    % molecular weight of elements in a structure
    elementMwStruct = struct('H', 1, 'C', 12, 'N', 14, 'O', 16, 'Na', 23, 'Mg', 24, 'P', 31, ...
        'S', 32, 'Cl', 35, 'K', 39, 'Ca', 40, 'Mn', 55, 'Fe', 56, 'Ni', 58, 'Co', 59, ...
        'Cu', 63, 'Zn', 65, 'As', 75, 'Se', 80, 'Ag', 107, 'Cd', 114, 'W', 184, 'Hg', 202);
    elementNames = fieldnames(elementMwStruct);  % elements' names
    MW = zeros(size(metIDs));

    for n = 1:length(metIDs)
        i = metIDs(n);
        formula = model.metFormulas(i);
        [compounds, tok] = regexp(formula, '([A-Z][a-z]*)(\d*)', 'match', 'tokens');
        tok = tok{1, 1};
        for j = 1:length(tok)  % go through each token.
            t = tok{1,j};
            comp = t{1,1};
            q = str2double(t{1, 2});
            if isempty(t{1, 2})
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
    [Ematrix, elements] = computeElementalMatrix(model, metList, false);
    [knownWeights, unknownElements] = deal([], {});
else
    % elements' MWs in a vector
    [MW, knownWeights, unknownElements, Ematrix, elements] = getMolecularMass(model.metFormulas(metIDs), isotopeAbundance, 1);
end
