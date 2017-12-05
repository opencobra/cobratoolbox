function elementalWeightMatrix = getElementalWeightMatrix(isotopeAbundance)
% Get the symbols for all chemical elements and their atomic weights
%
% USAGE:
%    elementalWeightMatrix = getElementalWeightMatrix(isotopeAbundance)
%
% OPTIONAL INPUTS:
%    isotopeAbundance:         * false to return standard atomic weights (default)
%                              * true to return the weights of naturally predominant isotopes for biological 
%                                elements and standard weights for other elements.
%                              * `m` x 3 cell arrray with user defined isotope abundance:
%                                isotopeAbundance{i, 1} = 'Atomic_Symbol';
%                                isotopeAbundance{i, 2} = Mass_Number;
%                                isotopeAbundance{i, 3} = abundance;
%                                (where sum of abundances of all isotopes of an element must be one)
%    printWarning:             true to print warning if there are unknown elements in isotopeAbundance
%
% OUTPUT:
%    elementalWeightMatrix:    #elements x 2 cell array, the 1st coloumn being the symbols
%                              of chemial elements and the 2nd their standard atomic weights

if nargin == 0 || isempty(isotopeAbundance)
    isotopeAbundance = false;
end

atomicWeights = parse_Atomic_Weights_and_Isotopic_Compositions_for_All_Elements;
[symbols, ia] = unique([atomicWeights.data.AtomicSymbol]);
% remove XYZ (non-existing element) from the symbol list
elementRemove = strcmp(symbols, 'D') | strcmp(symbols, 'T') | strncmp(symbols, 'XYZ', 3);
[symbols, ia] = deal(columnVector(symbols(~elementRemove)), ia(~elementRemove));
% identify elements without standard weight
elementWoMW = arrayfun(@(x) isempty(x.StandardAtomicWeight), atomicWeights.data(ia));
% elements with standard weight come first
symbols = [symbols(~elementWoMW); symbols(elementWoMW)];
elementWeights = [[atomicWeights.data(ia(~elementWoMW)).StandardAtomicWeight], NaN(1, sum(elementWoMW))]';

if ~isscalar(isotopeAbundance) || isotopeAbundance
    
    % biological elements as defined in getMolecularMass.m
    %allBiologicalElements = {'C', 'O', 'P', 'N', 'S', 'H', 'Mg', 'Na', 'K', 'Cl', 'Ca', 'Zn', 'Fe', 'Cu', 'Mo', 'I'};
    if isscalar(isotopeAbundance)
        % use the defaulted most naturally predominant isotope of each biological element
        isotopeAbundance = {...
            'C', 12, 1; ...  % Carbon, all as C12
            'H', 1, 1; ...  % Hydrogen, all as H1
            'O', 16, 1; ...  % Oxygen, all as O16
            'N', 14, 1; ...  % Nitrogen, all as N14
            'S', 32, 1; ...  % Sulphur, all as S32 (94% naturally S32)
            'Mg', 24, 1; ...  % Magnesium, all as Mg24, (79 % naturally Mg24)
            'K', 39, 1; ...  % Potassium, all as K39, (93% naturally K39)
            'Cl', 35, 1; ...  % Chlorine, all as Cl35 (75.78% naturally Cl35)
            'Ca', 40, 1; ...  % Calcium, all as Ca40 (96% naturally Ca40)
            'Zn', 64, 1; ...  % Zinc, all as Zn64 (48% naturally Zn64)
            'Cu', 63, 1; ...  % Copper, all as Cu63 (69% naturally Cu63)
            'Mo', 98, 1; ...  % Molybdenum, all as Mo98 (24% naturally Mo98)
            'P', 31, 1; ...  % Phosphorus, all as P31
            'Na', 23, 1; ...  % Sodium, all as Na23
            'Fe', 56, 1; ...  % Iron, all as Fe56
            'I', 127, 1; ...  % Iodine, all as I127
            };
    end
    
    % get the list of all isotopes
    [isotopes, isoMassNums, isoWeights] = deal([atomicWeights.data.AtomicSymbol], ...
        [atomicWeights.data.MassNumber], [atomicWeights.data.RelativeAtomicMass]);
    % treat 'D' and 'T' as the same element as 'H'
    isotopes(strcmp(isotopes, 'D') | strcmp(isotopes, 'T')) = {'H'};
    isotopeAbundance(strcmp(isotopeAbundance(:, 1), 'D') | ...
        strcmp(isotopeAbundance(:, 1), 'T')) = {'H'};
    
    [eleWtIsoAb, ~, ib] = unique(isotopeAbundance(:, 1));
    [ynE, idE] = ismember(eleWtIsoAb, symbols);
    
    % sanity check
    if size(isotopeAbundance, 2) ~= 3
        error('Incorrect size. IsotopeAbundance must be a n-by-3 cell array.')
    elseif ~all(ynE)
        % unknown elements in isotope abundance profile
        error('%s in the supplied isotope abundance profile is/are not standard chemical elements.', strjoin(eleWtIsoAb(~ynE), ', '))
    end
    
    massNumbers = cell2mat(isotopeAbundance(:, 2));
    abundances = cell2mat(isotopeAbundance(:, 3));
    if any(massNumbers <= 0)  % positive masses
        error('Non-positive isotope mass in row(s) %s.', strjoin(cellstr(num2str(find(massNumbers <= 0))), ', '))
    elseif any(abundances < 0 | abundances > 1)  % 0 <= abundnace <= 1
        error('Invalid isotope abundance in row(s) %s. Must lie between 0 and 1.', ...
            strjoin(cellstr(num2str(find(abundances < 0 | abundances > 1))), ', '))
    end
    
    % get the order of the supplied isotopeAbundance in the atomic weight data
    eleWtIsoAbIDs = zeros(size(isotopeAbundance, 1), 1);
    for j = 1:size(isotopeAbundance, 1)
        f = strcmp(isotopeAbundance{j, 1}, isotopes(:)) & isoMassNums(:) == isotopeAbundance{j, 2};
        if sum(f) == 1
            eleWtIsoAbIDs(j) = find(f);
        end
    end
    % error if the isotopes cannot be matched
    if ~all(eleWtIsoAbIDs)
        notMatched = find(eleWtIsoAbIDs == 0);
        errMsg = '';
        for j = 1:numel(notMatched)
            errMsg = [errMsg, ['\n#' num2str(notMatched(j)) '\t' ...
                isotopeAbundance{notMatched(j), 1} '\t' num2str(isotopeAbundance{notMatched(j), 2})]];
        end
        error(['%s', errMsg], 'The following isotopes could not be identified:')
    end
    
    % get the corresponding relative atomic mass
    relativeMasses = columnVector(isoWeights(eleWtIsoAbIDs));
    
    % get the user-defined atomic masses
    sumIsoEq1 = false(numel(eleWtIsoAb), 1);
    averageWeight = zeros(numel(eleWtIsoAb), 1);
    for j = 1:numel(eleWtIsoAb)
        sumIsoEq1(j) = abs(sum(abundances(ib == j)) - 1) < 1e-7;
        averageWeight(j) = relativeMasses(ib == j)' * abundances(ib == j);
    end
    if any(~sumIsoEq1)  % sum(abundance) = 1
        error('Invalid isotope abundances for element(s) %s. The sum of isotope abundances for each element must be equal to 1.', ...
            strjoin(eleWtIsoAb(~sumIsoEq1), ', '))
    end

    % update the list of weights
    elementWeights(idE) = averageWeight;
end

elementalWeightMatrix = [symbols, num2cell(elementWeights)];