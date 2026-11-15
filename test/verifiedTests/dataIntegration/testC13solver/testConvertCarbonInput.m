% The COBRAToolbox: testConvertCarbonInput.m
%
% Purpose:
%     - convertCarbonInput turns the label input of glucose, given as the cumomer distribution
%       vector (64 entries) that the cumomer solver slvrCumomer_fast takes, into the mass
%       distribution vectors (MDVs) of the 16 glucose fragments that the EMU solver
%       slvrEMU_fast takes. Field x<c1...c6> holds the MDV of the fragment made of the carbons
%       marked 1 (carbon k = character k). The test checks the 16 field names and, for glucose
%       made of one isotopomer, that each fragment MDV is the unit vector at M + (number of
%       labelled carbons in the fragment) - an independent derivation - for unlabelled,
%       [1-13C], [1,2-13C], [6-13C] and uniformly labelled glucose, and the linearity of the
%       conversion for a mixture. The isotopomer distribution vector is indexed by
%       1 + sum of 2^(k-1) over the labelled carbons k (getBinsOfFluxes uses the same
%       numbering) and converted to cumomers with idv2cdv (tested separately).
%
% Function under test:
%     src/dataIntegration/fluxomics/c13solver/convertCarbonInput.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built label inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below (the function is straight-line code).
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConvertCarbonInput'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% cdv2idv and idv2mdv (called by the function) cache matrices in global variables; note the
% globals that exist now to remove the new ones at the end
globalsBefore = who('global');

% the conversion multiplies 0/1 matrices with +-1 entries by the input; the results are exact
% integers for single isotopomers and sums of two terms for the mixture, so 1e-12 is ample
tol = 1e-12;

expectedNames = {'x111000'; 'x001110'; 'x011110'; 'x000111'; 'x010000'; 'x000010'; 'x011111'; ...
    'x001000'; 'x011000'; 'x001111'; 'x000001'; 'x000110'; 'x000100'; 'x100000'; 'x110000'; ...
    'x000011'};
% cumomer vector of glucose made of the single isotopomer with the given labelled carbons
cumomerOfIsotopomer = @(labelledCarbons) idv2cdv(6) * ((1:64)' == 1 + sum(2 .^ (labelledCarbons - 1)));

%% glucose made of one isotopomer: each fragment MDV is a unit vector

labelPatterns = {[], 1, [1 2], 6, 1:6};
for p = 1:numel(labelPatterns)
    labelledCarbons = labelPatterns{p};
    fragmentMdvs = convertCarbonInput(cumomerOfIsotopomer(labelledCarbons));
    assert(isequal(fieldnames(fragmentMdvs), expectedNames));
    for k = 1:numel(expectedNames)
        % carbon c belongs to the fragment when character c + 1 of the name is '1'
        fragmentCarbons = find(expectedNames{k}(2:end) == '1');
        mdv = fragmentMdvs.(expectedNames{k});
        expectedMdv = zeros(numel(fragmentCarbons) + 1, 1);
        expectedMdv(1 + numel(intersect(fragmentCarbons, labelledCarbons))) = 1;
        assert(isequal(size(mdv), size(expectedMdv)));
        assert(max(abs(mdv - expectedMdv)) < tol);
    end
end

%% a mixture of isotopomers gives the same mixture of fragment MDVs

% 30 % [1-13C] glucose and 70 % uniformly labelled glucose
mixtureMdvs = convertCarbonInput(0.3 * cumomerOfIsotopomer(1) + 0.7 * cumomerOfIsotopomer(1:6));
firstCarbonMdvs = convertCarbonInput(cumomerOfIsotopomer(1));
uniformMdvs = convertCarbonInput(cumomerOfIsotopomer(1:6));
for k = 1:numel(expectedNames)
    fragmentName = expectedNames{k};
    expectedMdv = 0.3 * firstCarbonMdvs.(fragmentName) + 0.7 * uniformMdvs.(fragmentName);
    assert(max(abs(mixtureMdvs.(fragmentName) - expectedMdv)) < tol);
    assert(abs(sum(mixtureMdvs.(fragmentName)) - 1) < tol);
end
% for example, fragment C1-C3 is M+1 for 30 % and M+3 for 70 %
assert(max(abs(mixtureMdvs.x111000 - [0; 0.3; 0; 0.7])) < tol);

% remove the global caches created by cdv2idv and idv2mdv
newGlobals = setdiff(who('global'), globalsBefore);
for k = 1:numel(newGlobals)
    clearvars('-global', newGlobals{k});
end

% change the directory
cd(currentDir)
