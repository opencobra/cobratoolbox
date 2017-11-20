% test getElementalWeightMatrix

% default standard atomic mass
elementalWeightMatrix = getElementalWeightMatrix();
data = load('testGetMolecularMass_refData.mat');
assert(isequal(size(elementalWeightMatrix), size(data.elementalWeightMatrix)))
[yn, id] = ismember(elementalWeightMatrix(:, 1), data.elementalWeightMatrix(:, 1));
assert(all(yn))
assert(isequal(elementalWeightMatrix(~isnan(cell2mat(elementalWeightMatrix(:, 2))), 2), ...
    data.elementalWeightMatrix(id(~isnan(cell2mat(elementalWeightMatrix(:, 2)))), 2)))

% use the naturally occuring isotopes only as defined in the function
elementalWeightMatrix2 = getElementalWeightMatrix(true);
assert(isequal(size(elementalWeightMatrix2), size(data.elementalWeightMatrix2)))
[yn, id] = ismember(elementalWeightMatrix2(:, 1), data.elementalWeightMatrix2(:, 1));
assert(all(yn))
assert(isequal(elementalWeightMatrix2(~isnan(cell2mat(elementalWeightMatrix2(:, 2))), 2), ...
    data.elementalWeightMatrix2(id(~isnan(cell2mat(elementalWeightMatrix2(:, 2)))), 2)))

% user-supplied isotope abundance profile
elementalWeightMatrix3 = getElementalWeightMatrix({'H', 1, 0.1; 'H', 2, 0.3; 'H', 3, 0.6});
id = strcmp(elementalWeightMatrix3, 'H');
assert(abs(elementalWeightMatrix3{id, 2} - 2.5146) < 1e-3)
[yn, id] = ismember(elementalWeightMatrix(:, 1), elementalWeightMatrix3(:, 1));
assert(all(yn))
yn(strcmp(elementalWeightMatrix(:, 1), 'H')) = false;
assert(isequal(elementalWeightMatrix(~isnan(cell2mat(elementalWeightMatrix(:, 2))) & yn, 2), ...
    elementalWeightMatrix3(id(~isnan(cell2mat(elementalWeightMatrix(:, 2))) & yn), 2)))

% treat 'D', 'T' as isotopes of 'H'
elementalWeightMatrix4 = getElementalWeightMatrix({'H', 1, 0.1; 'D', 2, 0.3; 'T', 3, 0.6});
assert(isequal(size(elementalWeightMatrix3), size(elementalWeightMatrix4)))
[yn, id] = ismember(elementalWeightMatrix3(:, 1), elementalWeightMatrix4(:, 1));
assert(all(yn))
assert(isequal(elementalWeightMatrix3(~isnan(cell2mat(elementalWeightMatrix3(:, 2))), 2), ...
    elementalWeightMatrix4(id(~isnan(cell2mat(elementalWeightMatrix3(:, 2)))), 2)))

% error messages
try
    getElementalWeightMatrix({'H', 0.1});
    error('Should not finish!')
catch ME
end
assert(strcmp(ME.message, 'Incorrect size. IsotopeAbundance must be a n-by-3 cell array.'))

try
    getElementalWeightMatrix({'Abc', 4, 0.1});
    error('Should not finish!')
catch ME
end
assert(strcmp(ME.message, 'Abc in the supplied isotope abundance profile is/are not standard chemical elements.'))

try
    getElementalWeightMatrix({'H', 4, 0.1});
    error('Should not finish!')
catch ME
end
assert(strcmp(ME.message, sprintf('The following isotopes could not be identified:\n#1\tH\t4')))

try
    getElementalWeightMatrix({'H', 1, 0.8});
    error('Should not finish!')
catch ME
end
assert(strcmp(ME.message, sprintf('Invalid isotope abundances for element(s) H. The sum of isotope abundances for each element must be equal to 1.')))

% test the function getMolecularMass

% MW for elements defined in the function
allBiologicalElements = {'C', 'O', 'P', 'N', 'S', 'H', 'Mg', 'Na', 'K', 'Cl', 'Ca', 'Zn', 'Fe', 'Cu', 'Mo', 'I'};
% default using naturally occuring isotopes
mw1 = getMolecularMass(allBiologicalElements);
assert(max([12; 15.9949146221000; 30.9737615100000; 14.0030740052000; ...
    31.9720706900000; 1.00782503210000; 23.9850419000000; 22.9897696700000; ...
    38.9637069000000; 34.9688527100000; 39.9625912000000; 63.9291466000000; ...
    55.9349421000000; 62.9296011000000; 97.9054078000000;126.904468000000] - mw1) < 1e-3);
% use standard atomic mass (there are slight differences)
mw2 = getMolecularMass(allBiologicalElements, 0);
assert(max([12.0107000000000;15.9994000000000;30.9737610000000;14.0067000000000;....
    32.0650000000000;1.00794000000000;24.3050000000000;22.9897700000000;...
    39.0983000000000;35.4530000000000;40.0780000000000;65.4090000000000;...
    55.8450000000000;63.5460000000000;95.9400000000000;126.904470000000] - mw2) < 1e-3);

% user-supplied isotope abundances
mw = getMolecularMass('C', {'C', 12, 0.2; 'C', 13, 0.4; 'C', 14, 0.4});
assert(abs(mw == 13.2026) < 1e-3)

% MW for other elements not listed in 'allBiologicalElements'
mw = getMolecularMass('Se');
assert(mw == 0)

% generic fomrula
mw = getMolecularMass('(H2O)2CuSO4Element2');
assert(abs(mw - 176.8919) < 1e-3)

% test with the general flag switched on

% same masses for biological elements
mw1b = getMolecularMass(allBiologicalElements, [], 1);
assert(isequal(mw1, mw1b))
mw2b = getMolecularMass(allBiologicalElements, 0, 1);
assert(isequal(mw2, mw2b))
mw = getMolecularMass('C', {'C', 12, 0.2; 'C', 13, 0.4; 'C', 14, 0.4}, 1);
assert(abs(mw == 13.2026) < 1e-3)

% MW for other elements not listed in 'allBiologicalElements'
[mw, kMw, uE, Ematrix, ele] = getMolecularMass('Se', [], 1);
assert(abs(mw - 78.96) < 1e-3)
assert(mw == kMw)
assert(isempty(uE))
assert(isequal(Ematrix, 1))
assert(isequal(ele, {'Se'}))
[mw, kMw, uE, Ematrix, ele] = getMolecularMass('H2Se', [], 1);
assert(abs(mw - 80.9757) < 1e-3)
assert(mw == kMw)
assert(isempty(uE))
[yn, id] = ismember({'H', 'Se'}, ele);
assert(all(yn))
assert(isequal(Ematrix(:, id), [2, 1]))

% generic fomrula
[mw, kMw, uE, Ematrix, ele] = getMolecularMass('(H2O)2CuSO4Element2', [], 1);
assert(isnan(mw) & abs(kMw == 194.9025) < 1e-3)
assert(isequal(uE, {'Element'}))
[yn, id] = ismember({'H', 'O', 'Cu', 'S', 'Element'}, ele);
assert(all(yn) & numel(ele) == 5)
assert(isequal(Ematrix(:, id), [4, 6, 1, 1, 2]))

% 'Mass0' as a keyword for massless metabolites (e.g., photon)
[mw, kMw, uE, Ematrix, ele] = getMolecularMass('Mass0', [], 1);
assert(mw == 0 & kMw == 0 & isequal(uE, {'Mass'}) & isequal(Ematrix, 0) & isequal(ele, {'Mass'}))
% NaN is returned for all undefined elements, defined elements with only zero
% coefficients, and empty formula
[mw, kMw] = getMolecularMass({''; 'Mass1'; 'E2'; 'C0H0'}, [], 1);
assert(all(isnan(mw)) & ~any(kMw))