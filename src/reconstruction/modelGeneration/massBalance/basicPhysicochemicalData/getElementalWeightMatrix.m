function elementalWeightMatrix = getElementalWeightMatrix(isotopeAbundance)
% Get the symbols for all chemical elements and their atomic weights
%
% USAGE:
%    elementalWeightMatrix = getElementalWeightMatrix(isotopeAbundance)
%
% OPTIONAL INPUT:
%    isotopeAbundance:         * false to return standard atomic weights (default)
%                              * true to return the weights of naturally predominant isotopes for biological 
%                                elements and standard weights for other elements.
%                              * `m` x 3 cell arrray with user defined isotope abundance:
%                                isotopeAbundance{i, 1} = 'Atomic_Symbol';
%                                isotopeAbundance{i, 2} = Mass_Number;
%                                isotopeAbundance{i, 3} = abundance;
%                                (where sum of abundances of all isotopes of an element must be one)
%
% OUTPUT:
%    elementalWeightMatrix:      #elements x 2 cell array, the 1st coloumn being the symbols
%                                of chemial elements and the 2nd their standard atomic weights

if nargin == 0 || isempty(isotopeAbundance)
    isotopeAbundance = false;
end

atomicWeights = parse_Atomic_Weights_and_Isotopic_Compositions_for_All_Elements;
[symbols, ia] = unique([atomicWeights.data.AtomicSymbol]);
% remove Deuterium, Tritium and XYZ (non-existing element) from the symbol list
elementRemove = strcmp(symbols, 'D') | strcmp(symbols, 'T') | strncmp(symbols, 'XYZ', 3);
[symbols, ia] = deal(columnVector(symbols(~elementRemove)), ia(~elementRemove));
% identify elements without standard weight
elementWoMW = arrayfun(@(x) isempty(x.StandardAtomicWeight), atomicWeights.data(ia));
% elements with standard weight come first
symbols = [symbols(~elementWoMW); symbols(elementWoMW)];
elementWeights = [[atomicWeights.data(ia(~elementWoMW)).StandardAtomicWeight], NaN(1, sum(elementWoMW))]';

if ~isscalar(isotopeAbundance) || isotopeAbundance
    % biological elements as defined in getMolecularMass.m
    allBiologicalElements={'C', 'O', 'P', 'N', 'S', 'H', 'Mg', 'Na', 'K', 'Cl', 'Ca', 'Zn', 'Fe', 'Cu', 'Mo', 'I'};
    % get weights of naturally predominant isotopes for biological elements
    bioElementWeights = getMolecularMass(allBiologicalElements, isotopeAbundance);
    [~, id] = ismember(allBiologicalElements, symbols);
    elementWeights(id) = bioElementWeights;
end

elementalWeightMatrix = [symbols, num2cell(elementWeights)];