% The COBRAToolbox: testSortAtomMappingIdx.m
%
% Purpose:
%     - sortAtomMappingIdx renumbers the atom-atom mapping numbers in a reaction (rxn) file so that
%     the substrate atoms are numbered 1, 2, 3, ... in order and each product atom gets the number
%     of its mapped substrate atom.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/chemoInformatics/reactions/sortAtomMappingIdx.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The flag for a non-ascending file is overwritten and the function always returns the
%         file text
%       SEVERITY: cosmetic
%       TRIGGER: any call, including product atoms whose mapping number has no substrate partner
%       OBSERVED: the output ascendingRxnFile is set to false for unmapped product atoms and
%         non-zero sums, but the last statement replaces it by the renumbered file text, so the
%         false value is never returned
%       EXPECTED: the documented flag or text, not a mix of both
%       LINES: 36-45
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSortAtomMappingIdx'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a helper builds the file text: line 5 holds the number of substrates and products, and each
% molecule block has a counts line (number of atoms in the first three characters) four lines
% after its $MOL line; the atom lines hold the mapping number in characters 61 to 63
atomLine = @(map) [repmat(' ', 1, 60) sprintf('%3d', map) '  0  0'];
countsLine = @(nAtoms) sprintf('%3d  0  0  0  0  0  0  0  0  0999 V2000', nAtoms);
molBlock = @(maps) [{'$MOL'; ''; ''; ''; countsLine(numel(maps))}; arrayfun(atomLine, maps(:), 'UniformOutput', false); {'M  END'}];
header = {'$RXN'; ''; ''; ''};
mapsOf = @(file, start, n) arrayfun(@(j) str2double(file{start + j}(61:63)), 1:n);

%% substrate atoms are numbered in order and product atoms follow their partners

% one substrate with atoms mapped 3 and 5, one product with the same atoms in the other order
rxnFile = [header; {'  1  1'}; molBlock([3 5]); molBlock([5 3])];
sorted = sortAtomMappingIdx(rxnFile);
% substrate block starts at line 6: atoms at lines 11, 12; product block starts at line 14: atoms at 19, 20
substrateMaps = mapsOf(sorted, 10, 2);
productMaps = mapsOf(sorted, 18, 2);
assert(isequal(substrateMaps, [1 2]));
% the product atom mapped 5 (second substrate atom) gets 2 and the one mapped 3 gets 1
assert(isequal(productMaps, [2 1]));

%% atoms without a mapping number are left alone

rxnFile = [header; {'  1  1'}; molBlock([0 4]); molBlock([4 0])];
sorted = sortAtomMappingIdx(rxnFile);
% an unmapped atom still uses up a number, so the mapped substrate atom becomes 2
assert(isequal(mapsOf(sorted, 10, 2), [0 2]));
assert(isequal(mapsOf(sorted, 18, 2), [2 0]));

%% a product atom without a substrate partner gets the next free number

rxnFile = [header; {'  1  1'}; molBlock(7); molBlock(9)];
sorted = sortAtomMappingIdx(rxnFile);
assert(isequal(mapsOf(sorted, 10, 1), 1));
assert(isequal(mapsOf(sorted, 17, 1), 2));

%% two substrates

rxnFile = [header; {'  2  1'}; molBlock(8); molBlock(6); molBlock([6 8])];
sorted = sortAtomMappingIdx(rxnFile);
assert(isequal(mapsOf(sorted, 10, 1), 1) && isequal(mapsOf(sorted, 17, 1), 2));
% the product atoms follow their partners: 6 became 2 and 8 became 1
assert(isequal(mapsOf(sorted, 24, 2), [2 1]));

% change the directory
cd(currentDir)
