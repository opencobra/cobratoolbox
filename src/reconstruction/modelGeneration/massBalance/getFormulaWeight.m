function [weights, knownWeights, unknownElements, Ematrix, elements] = getFormulaWeight(formulae, isotopeAbundance)
% Calculate the molecular weights (MWs) of a set of chemical formulae
%
% USAGE:
%    [weights, knownWeights, unknownElements] = getFormulaWeight(formulae, isotopeAbundance)
%
% INPUT:
%    formulae:           cell array of strings of chemical formulae. Can contain any generic elements starting 
%                        with a capital letter followed by lowercase letters or '_', followed by a non-negative number. 
%                        Also support '()', '[]', '{}'. E.g. {'H2O'; '[H2O]2(CuSO4)Generic_element0.5'}
%
% OPTIONAL INPUT:
%    isotopeAbundance:   * false to use standard atomic weights (default)
%                        * true to use the weights of naturally predominant isotopes for biological 
%                            elements and standard weights for other elements.
%                        * `m` x 3 cell arrray with user defined isotope abundance:
%                            isotopeAbundance{i, 1} = 'Atomic_Symbol';
%                            isotopeAbundance{i, 2} = Mass_Number;
%                            isotopeAbundance{i, 3} = abundance;
%                            (where sum of abundances of all isotopes of an element must be one)
%
% OUTPUTS:
%    weights:            vector of MWs. Formulae containing elements with unknown atomic weights will have MW = NaN
%    knownWeights:       MWs for the part whose MW is computable ofr each of the formulae
%    unknownElements:    cell arrary of elements without known atomic weights that appear in the formulae
%    Ematrix:         elemental composition matrix (#formulae x #elements)
%    element:         cell array of elements corresponding to the columns of Ematrix

if nargin < 2
    isotopeAbundance = false;
end

persistent elementalWeightMatrix
if isempty(elementalWeightMatrix)
    % get the list of true chemical elements and their atomic weights
    elementalWeightMatrix = getElementalWeightMatrix(isotopeAbundance);
end

% get the elemental composition matrix
[Ematrix, elements] = getElementalComposition(formulae, [], true);
eleMW = nan(numel(elements), 1);
[yn, id] = ismember(elements, elementalWeightMatrix(:, 1));
eleMW(yn) = cell2mat(elementalWeightMatrix(id(yn), 2));

eleWoWeight = isnan(eleMW);
unknownElements = elements(eleWoWeight);
knownWeights = Ematrix(:, ~eleWoWeight) * eleMW(~eleWoWeight);
weights = knownWeights;
weights(any(Ematrix(:, eleWoWeight), 2)) = NaN;