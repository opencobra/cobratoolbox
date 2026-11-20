% The COBRAToolbox: testConvertCarbonInput.m
%
% Purpose:
%     - convertCarbonInput turns the label input of glucose, given as the cumomer distribution
%       vector (64 entries) that the cumomer solver slvrCumomer_fast takes, into the mass
%       distribution vectors (MDVs) of the 16 glucose fragments that the EMU solver
%       slvrEMU_fast takes. Field x<c1...c6> holds the MDV of the fragment made of the carbons
%       marked 1 (carbon k = character k). The test checks the 16 field names (not their
%       order) and, for glucose made of one isotopomer, that each fragment MDV is the unit
%       vector at M + (number of labelled carbons in the fragment) - an independent
%       derivation - for unlabelled,
%       [1-13C], [1,2-13C], [6-13C] and uniformly labelled glucose, and the linearity of the
%       conversion for a mixture. The isotopomer distribution vector is indexed by
%       1 + sum of 2^(k-1) over the labelled carbons k (getBinsOfFluxes uses the same
%       numbering) and converted to cumomers with idv2cdv (tested separately).
%
% Function under test:
%     src/dataIntegration/fluxomics/c13solver/convertCarbonInput.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - the function under test is written in the test by generateIsotopomerSolver, whose
%     flux variability step needs an LP solver and whose scripts need Perl (declared with
%     prepareTest). The function itself needs no model and no solver; the label inputs are built
%     by hand.
%
% Coverage exemptions:
%     None. Every executable line is reached below (the function is straight-line code).
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Generates the solver files it tests itself, as the CI run has none (T035), 2026-11-20.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConvertCarbonInput'));
cd(fileDir);

% declare the requirements of this test: an LP solver and Perl, both used only to generate
% the solver files below
solvers = prepareTest('needsLP', true, 'requiredSoftwares', {'perl'});

% the solver files (slvr*.m, convertCarbonInput.m) are written by generateIsotopomerSolver for
% a given model and are not kept in the repository (.gitignore); generate them here for
% model.mat of this folder, as testFitC13Data does. Solver files present now (perhaps generated
% for another model) are copied to a temporary folder and put back at the end
c13Dir = fileparts(which('generateIsotopomerSolver'));
c13Files = {'IsotopomerModel.txt'; 'convertCarbonInput.m'; 'slvrCumomer.m'; 'slvrCumomer_fast.m'; ...
    'slvrEMU.m'; 'slvrEMU_fast.m'};
c13Existed = cellfun(@(f) exist(fullfile(c13Dir, f), 'file') == 2, c13Files);
c13Backup = tempname;
mkdir(c13Backup);
for k = find(c13Existed)'
    copyfile(fullfile(c13Dir, c13Files{k}), c13Backup);
end
changeCobraSolver(solvers.LP{1}, 'LP', 0);
c13Fixtures = load('model.mat', 'model');
c13Fixtures.expdata = getfield(load('expdata.mat', 'expdata'), 'expdata');
% true: leave out the reactions that carry no flux in any steady state (flux variability), as
% testFitC13Data does
generateIsotopomerSolver(c13Fixtures.model, 'xglcDe', c13Fixtures.expdata, true);
clear c13Fixtures
% make MATLAB read the new files, not versions of them it may hold in memory
rehash;
clear convertCarbonInput slvrCumomer slvrCumomer_fast slvrEMU slvrEMU_fast

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
    % Perl writes the fields in hash order, which changes each time the file is generated;
    % compare the names, not their order
    assert(isequal(sort(fieldnames(fragmentMdvs)), sort(expectedNames)));
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

% put back the solver files present before the test and remove the ones it generated
for k = 1:numel(c13Files)
    if c13Existed(k)
        copyfile(fullfile(c13Backup, c13Files{k}), c13Dir);
    elseif exist(fullfile(c13Dir, c13Files{k}), 'file') == 2
        delete(fullfile(c13Dir, c13Files{k}));
    end
end
rmdir(c13Backup, 's');
rehash;
clear convertCarbonInput slvrCumomer slvrCumomer_fast slvrEMU slvrEMU_fast

% change the directory
cd(currentDir)
