% The COBRAToolbox: testReadRXNFile.m
%
% Purpose:
%     - readRXNFile reads an atom-mapped MDL rxn file and returns one entry per atom: the
%       metabolite, the element, the atom number inside its molfile, the atom transition number,
%       whether the atom belongs to a substrate, and the instance of a repeated metabolite. The
%       file name may be given with or without the .rxn ending; the directory defaults to the
%       current directory. A reaction identifier inside the file that differs from the file name
%       gives a warning.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Expected values are read by hand from the rxn files that ship with the test suite
%       (test/verifiedTests/analysis/testBiomassPrecursorCheck/data/atomMapped/R3.rxn and
%       test/verifiedTests/analysis/testReactingMoieties/data/rxnFiles/rh_14817.rxn); the test
%       creates no file.
%
% Function under test:
%     src/dataIntegration/chemoInformatics/RXN/readRXNFile.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver; inputs are rxn files shipped with the test suite.
%
% Coverage exemptions:
%     Every rxn file shipped in the repository (the 23 files under test/verifiedTests) has a
%     correct, balanced and fully mapped reaction, so the branches for malformed files are
%     not reached, and the test creates no file:
%     - Lines 64-65 and 74-75: a stoichiometric coefficient in the reaction formula (no shipped
%       file has one).
%     - Lines 82-84: hydrogen omitted from the reactant/product counts line (no shipped file
%       omits it).
%     - Line 88: a formula that does not match the counts line.
%     - Line 130: an odd total number of atoms.
%     - Lines 137, 140, 143 and 154: atom transition numbers that are not ordered 1:q, do not
%       match between substrates and products, or map different elements.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReadRXNFile'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% folders of the shipped rxn files (read only)
atomMappedDir = fullfile(fileDir, '..', '..', 'analysis', 'testBiomassPrecursorCheck', 'data', 'atomMapped');
rxnFilesDir = fullfile(fileDir, '..', '..', 'analysis', 'testReactingMoieties', 'data', 'rxnFiles');

% R3.rxn holds 34dhphe[c] -> dopa[c] + co2[c]: molfiles of 14, 11 and 3 atoms. The values below
% are copied from its atom blocks (element symbol in columns 31-33, atom mapping number at
% column 61)
expectedMets = [repmat({'34dhphe[c]'}, 14, 1); repmat({'dopa[c]'}, 11, 1); repmat({'co2[c]'}, 3, 1)];
expectedElements = {'N'; 'C'; 'C'; 'C'; 'C'; 'C'; 'C'; 'O'; 'C'; 'O'; 'C'; 'C'; 'O'; 'O'; ...
                    'N'; 'C'; 'C'; 'C'; 'C'; 'C'; 'C'; 'O'; 'C'; 'O'; 'C'; ...
                    'O'; 'C'; 'O'};
expectedMetNrs = [(1:14)'; (1:11)'; (1:3)'];
expectedTransitionNrs = [(1:14)'; (1:11)'; 14; 12; 13];
expectedIsSubstrate = [true(14, 1); false(14, 1)];

%% file name with the .rxn ending and an explicit directory

[mets, elements, metNrs, atomTransitionNrs, isSubstrate, instances] = readRXNFile('R3.rxn', atomMappedDir);

% one entry per atom, in molfile order: substrate first, then the products
assert(isequal(mets, expectedMets));
assert(isequal(elements, expectedElements));
assert(isequal(metNrs, expectedMetNrs));
assert(isequal(atomTransitionNrs, expectedTransitionNrs));
assert(islogical(isSubstrate) && isequal(isSubstrate, expectedIsSubstrate));
% no metabolite is repeated, so every atom belongs to the first instance
assert(isequal(instances, ones(28, 1)));

% the atom mapping conserves elements: each transition number maps a substrate atom onto a
% product atom of the same element
substrateElements = elements(isSubstrate);
productElements = elements(~isSubstrate);
[~, substrateOrder] = sort(atomTransitionNrs(isSubstrate));
[~, productOrder] = sort(atomTransitionNrs(~isSubstrate));
assert(isequal(substrateElements(substrateOrder), productElements(productOrder)));

%% file name without the ending and a directory with a trailing separator give the same result

[mets, elements, metNrs, atomTransitionNrs, isSubstrate, instances] = readRXNFile('R3', [atomMappedDir filesep]);
assert(isequal(mets, expectedMets));
assert(isequal(elements, expectedElements));
assert(isequal(metNrs, expectedMetNrs));
assert(isequal(atomTransitionNrs, expectedTransitionNrs));
assert(isequal(isSubstrate, expectedIsSubstrate));
assert(isequal(instances, ones(28, 1)));

%% the directory defaults to the current directory

cd(atomMappedDir);
[mets, elements, ~, atomTransitionNrs, isSubstrate] = readRXNFile('R3');
cd(fileDir);
assert(isequal(mets, expectedMets));
assert(isequal(elements, expectedElements));
assert(isequal(atomTransitionNrs, expectedTransitionNrs));
assert(isequal(isSubstrate, expectedIsSubstrate));

%% a reaction identifier that differs from the file name gives a warning

% rh_14817.rxn holds the identifier rh:14817 and CHEBI_17105[c] -> CHEBI_18034[c], two
% molfiles of 20 atoms each with 16 C, 12 H and 12 O in total
lastwarn('');
[mets, elements, metNrs, atomTransitionNrs, isSubstrate, instances] = readRXNFile('rh_14817', rxnFilesDir);
assert(strcmp(lastwarn(), 'Reaction identifier in the rxnfile rh_14817.rxn does not match file name.'));

% the file is read all the same
assert(isequal(mets, [repmat({'CHEBI_17105[c]'}, 20, 1); repmat({'CHEBI_18034[c]'}, 20, 1)]));
assert(isequal(isSubstrate, [true(20, 1); false(20, 1)]));
assert(isequal(metNrs, [(1:20)'; (1:20)']));
assert(isequal(instances, ones(40, 1)));
assert(isequal([nnz(strcmp(elements, 'C')), nnz(strcmp(elements, 'H')), nnz(strcmp(elements, 'O'))], [16 12 12]));
% the transition numbers of substrates and of products are each a permutation of 1:20
assert(isequal(sort(atomTransitionNrs(isSubstrate)), (1:20)'));
assert(isequal(sort(atomTransitionNrs(~isSubstrate)), (1:20)'));

% change the directory
cd(currentDir)
