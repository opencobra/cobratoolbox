% The COBRAToolbox: testBuildAtomTransitionNetwork.m
%
% Purpose:
%     - buildAtomTransitionNetwork reads the atom-mapped rxn files of the model reactions that
%       have one (readRXNFile) and builds the atom transition network: one row per atom of the
%       metabolites of those reactions (first instance of a repeated metabolite only) and one
%       column per atom transition, two oppositely directed columns for a reversible reaction.
%       The test builds a small model with createModel and writes hand-made rxn files into a
%       tempname folder; the expected incidence matrix, atom and transition identifiers are
%       derived by hand from those files. It also checks the filtering of the folder (non-rxn
%       files, sub-folders, rxn files without model reaction, the "Case Conflict" rename),
%       the warning for a stoichiometry that differs from S, and the three errors raised by
%       assert.
%
% Function under test:
%     src/dataIntegration/fluxomics/atomTransition/ATN/buildAtomTransitionNetwork.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation on a model built with createModel and hand-written rxn files
%     in a tempname folder; no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testBuildAtomTransitionNetwork'));
cd(fileDir);

% declare the requirements of this test. This test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% model: R1 a -> b, R2 b <=> a (reversible), R3 e -> 2 f (repeated product), R4 2 a -> 2 b
% (its rxn file says a -> b), R5 b -> c (no rxn file)
model = createModel({'R1', 'R2', 'R3', 'R4', 'R5'}, {'R1', 'R2', 'R3', 'R4', 'R5'}, ...
    {'a[c] -> b[c]', 'b[c] <=> a[c]', 'e[c] -> 2 f[c]', '2 a[c] -> 2 b[c]', 'b[c] -> c[c]'});

% writers of MDL rxn files: an atom line holds the element symbol in columns 32-34 and the atom
% mapping number in columns 61-63, the fourth line of a molfile holds the atom count
atomLine = @(element, mapNr) [sprintf('%10.4f%10.4f%10.4f ', 0, 0, 0), sprintf('%-3s', element), ...
    ' 0  0  0  0  0  0  0  0  0', sprintf('%3d', mapNr), '  0  0'];
molBlock = @(metId, elements, mapNrs) strjoin([{metId; '  hand-made'; ''; ...
    sprintf('%3d  0  0  0  0  0            999 V2000', numel(elements))}; ...
    cellfun(atomLine, elements(:), num2cell(mapNrs(:)), 'UniformOutput', false); {'M  END'}], newline);
rxnText = @(rxnId, formula, nReactants, nProducts, blocks) strjoin([{'$RXN'; rxnId; '  hand-made'; ...
    formula; sprintf('%3d%3d', nReactants, nProducts)}; strcat({['$MOL' newline]}, blocks(:))], newline);

% temporary folders of rxn files
tmpDir = tempname;
mkdir(tmpDir);
rxnDir = fullfile(tmpDir, 'atomMapped');
badDir = fullfile(tmpDir, 'badMapping');
emptyDir = fullfile(tmpDir, 'empty');
otherDir = fullfile(tmpDir, 'otherRxns');
mkdir(rxnDir); mkdir(badDir); mkdir(emptyDir); mkdir(otherDir);
mkdir(fullfile(rxnDir, 'subFolder.rxn'));

rxnFiles = struct( ...
    'R1', rxnText('R1', 'a[c] -> b[c]', 1, 1, {molBlock('a', {'C'; 'O'}, [1; 2]); molBlock('b', {'O'; 'C'}, [2; 1])}), ...
    'R2', rxnText('R2', 'b[c] <=> a[c]', 1, 1, {molBlock('b', {'O'; 'C'}, [1; 2]); molBlock('a', {'C'; 'O'}, [2; 1])}), ...
    'R3', rxnText('R3', 'e[c] -> 2 f[c]', 1, 2, {molBlock('e', {'C'; 'C'}, [1; 2]); molBlock('f', {'C'}, 1); molBlock('f', {'C'}, 2)}), ...
    'R4', rxnText('R4', 'a[c] -> b[c]', 1, 1, {molBlock('a', {'C'; 'O'}, [1; 2]); molBlock('b', {'O'; 'C'}, [2; 1])}));
rxnIds = fieldnames(rxnFiles);
for k = 1:numel(rxnIds)
    fid = fopen(fullfile(rxnDir, [rxnIds{k} '.rxn']), 'w');
    fprintf(fid, '%s', rxnFiles.(rxnIds{k}));
    fclose(fid);
end
% files that must be ignored or renamed: a file that is not an rxn file, an rxn file of a
% reaction that is not in the model, and the name the Ubuntu file manager gives to 3AIBTm.rxn
fid = fopen(fullfile(rxnDir, 'notes.txt'), 'w'); fprintf(fid, 'not an rxn file'); fclose(fid);
fid = fopen(fullfile(rxnDir, 'R99.rxn'), 'w'); fprintf(fid, '%s', rxnFiles.R1); fclose(fid);
fid = fopen(fullfile(rxnDir, '3AIBtm (Case Conflict).rxn'), 'w'); fprintf(fid, '%s', rxnFiles.R1); fclose(fid);

% expected network, derived by hand from the files above. Atom rows, in the order of first
% appearance (first instance of a repeated metabolite only): a#1 C, a#2 O, b#1 O, b#2 C (R1),
% e#1 C, e#2 C, f#1 C (R3); R2 and R4 add no metabolite
expectedMets = {'a[c]'; 'a[c]'; 'b[c]'; 'b[c]'; 'e[c]'; 'e[c]'; 'f[c]'};
expectedAtns = [1; 2; 1; 2; 1; 2; 1];
expectedElements = {'C'; 'O'; 'O'; 'C'; 'C'; 'C'; 'C'};
expectedAtoms = {'a[c]#1#C'; 'a[c]#2#O'; 'b[c]#1#O'; 'b[c]#2#C'; 'e[c]#1#C'; 'e[c]#2#C'; 'f[c]#1#C'};
% columns: R1 maps a#1 -> b#2 and a#2 -> b#1; R2 (reversible) maps b#1 -> a#2 and b#2 -> a#1,
% each as a forward and a backward column; R3 maps e#1 -> f#1 and e#2 -> f#1 (second instance
% of f collapses onto the row of f#1); R4 repeats R1
heads = [1 2 3 2 4 1 5 6 1 2];
tails = [4 3 2 3 1 4 7 7 4 3];
expectedA = sparse([heads tails], [1:10 1:10], [-ones(1, 10) ones(1, 10)], 7, 10);
expectedRxns = {'R1'; 'R1'; 'R2'; 'R2'; 'R2'; 'R2'; 'R3'; 'R3'; 'R4'; 'R4'};
expectedAtrans = strcat(expectedRxns, '#', expectedAtoms(heads), '#', expectedAtoms(tails));

%% network of the model reactions with an rxn file

% R4 has stoichiometry 2 a -> 2 b in S but a -> b in its file: a warning, the file is used
lastwarn('');
ATN = buildAtomTransitionNetwork(model, rxnDir);
[warnMsg, ~] = lastwarn();
assert(contains(warnMsg, 'The stoichiometry of reaction R4 in the rxnfile does not match that in S.'));

% exact incidence matrix and identifiers (integers and strings: exact comparison)
assert(issparse(ATN.A));
assert(isequal(full(ATN.A), full(expectedA)));
assert(isequal(ATN.mets, expectedMets));
assert(isequal(ATN.atns, expectedAtns));
assert(isequal(ATN.elements, expectedElements));
assert(isequal(ATN.rxns, expectedRxns));
assert(isequal(ATN.atoms, expectedAtoms));
assert(isequal(ATN.atrans, expectedAtrans));

% structural consistency: one head and one tail per transition, sizes agree, R5 (no rxn file),
% c[c] (only in R5), R99 and 3AIBTm (not in the model) are left out
assert(all(sum(ATN.A == -1, 1) == 1) && all(sum(ATN.A == 1, 1) == 1));
assert(isequal(size(ATN.A), [numel(ATN.mets), numel(ATN.rxns)]));
assert(~any(ismember({'R5', 'R99', '3AIBTm'}, ATN.rxns)) && ~any(strcmp(ATN.mets, 'c[c]')));
% every transition maps atoms of the same element (elemental balance of the mapping)
[headRows, ~] = find(ATN.A == -1);
[tailRows, ~] = find(ATN.A == 1);
assert(isequal(ATN.elements(headRows), ATN.elements(tailRows)));

%% a folder path that ends with a file separator gives the same network

ATN2 = buildAtomTransitionNetwork(model, [rxnDir filesep]);
assert(isequal(ATN2, ATN));

%% a transition between atoms of different elements is an error

% R1 file that maps the carbon of a onto the oxygen of b and vice versa
fid = fopen(fullfile(badDir, 'R1.rxn'), 'w');
fprintf(fid, '%s', rxnText('R1', 'a[c] -> b[c]', 1, 1, {molBlock('a', {'C'; 'O'}, [1; 2]); molBlock('b', {'O'; 'C'}, [1; 2])}));
fclose(fid);
assert(verifyCobraFunctionError('buildAtomTransitionNetwork', 'inputs', {model, badDir}, ...
    'testMessage', 'Transition 1 in reaction 1 maps between atoms of different elements'));

%% a folder without rxn files, or with none for a model reaction, is an error

% assert with a message and no further argument does not expand \n, so the message holds the
% two characters backslash and n
assert(verifyCobraFunctionError('buildAtomTransitionNetwork', 'inputs', {model, emptyDir}, ...
    'testMessage', 'Rxnfile directory is empty or nonexistent.'));
fid = fopen(fullfile(otherDir, 'R99.rxn'), 'w'); fprintf(fid, '%s', rxnFiles.R1); fclose(fid);
assert(verifyCobraFunctionError('buildAtomTransitionNetwork', 'inputs', {model, otherDir}, ...
    'testMessage', 'No atom mappings found for model reactions.\nCheck that rxnfile names match reaction identifiers in rxns.'));

% remove the temporary files
rmdir(tmpDir, 's');

% change the directory
cd(currentDir)
