% The COBRAToolbox: testAddBondMappingsRXNFile.m
%
% Purpose:
%     - Test that addBondMappingsRXNFile returns, for every shipped RXN file,
%       the bondMappings table captured from the function before feature
%       20260921-160105-build-function-runtime (FR-003, FR-013).
%     - Test that passing the atoms and bonds tables already returned by
%       readABRXNFile gives the same table as letting the function read the
%       file itself, and that empty atoms/bonds fall back to reading (FR-005).
%     - Test that a missing or unparsable RXN file raises an error in both
%       call forms.
%
% Function under test:
%     src/analysis/topology/reactingMoieties/addBondMappingsRXNFile.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - shipped and hand-written RXN files, no model and no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - COBRA Toolbox, feature 20260921-160105-build-function-runtime
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

% no solver is needed; declared for the harness convention
prepareTest();

% save the current path and initialize the test
currentDir = pwd;
fileDir = fileparts(which('testAddBondMappingsRXNFile'));
cd(fileDir);
restoreDir = onCleanup(@() cd(currentDir));

% atom-mapped reaction files shipped beside the reacting-moiety tests
rxnFilesDir = [fileDir filesep 'data' filesep 'rxnFiles'];
assert(isfolder(rxnFilesDir), 'Atom-mapped rxnFiles fixture not found.');

% expected tables, captured from the unmodified function (research R8)
expected = load([fileDir filesep 'data' filesep 'addBondMappingsRXNFileExpected.mat']);
assert(numel(expected.rxnIds) == numel(dir([rxnFilesDir filesep '*.rxn'])), ...
    'The expected-value file does not cover every shipped RXN file.');

for k = 1:numel(expected.rxnIds)
    rxnId = expected.rxnIds{k};
    expectedTable = expected.bondMappings{k};

    % two-input call form: the function reads the file itself
    bondMappingsRead = addBondMappingsRXNFile(rxnId, rxnFilesDir);
    assert(isequaln(bondMappingsRead, expectedTable), ...
        sprintf('%s: two-input call differs from the captured table.', rxnId));
    assert(isequal(bondMappingsRead.Properties.VariableNames, expectedTable.Properties.VariableNames), ...
        sprintf('%s: two-input call changes the variable names or order.', rxnId));

    % four-input call form: the atoms and bonds tables are handed in
    [atoms, bonds] = readABRXNFile(rxnId, rxnFilesDir);
    bondMappingsHanded = addBondMappingsRXNFile(rxnId, rxnFilesDir, atoms, bonds);
    assert(isequaln(bondMappingsHanded, expectedTable), ...
        sprintf('%s: four-input call differs from the captured table.', rxnId));
    assert(isequal(bondMappingsHanded.Properties.VariableNames, expectedTable.Properties.VariableNames), ...
        sprintf('%s: four-input call changes the variable names or order.', rxnId));
    assert(isequaln(bondMappingsHanded, bondMappingsRead), ...
        sprintf('%s: the two call forms disagree.', rxnId));

    % the caller's bonds table is not modified by the call (tables are values)
    [~, bondsAgain] = readABRXNFile(rxnId, rxnFilesDir);
    assert(isequaln(bonds, bondsAgain), sprintf('%s: the handed-in bonds table was modified.', rxnId));
end

% empty atoms/bonds fall back to reading the file
rxnId = expected.rxnIds{1};
assert(isequaln(addBondMappingsRXNFile(rxnId, rxnFilesDir, [], []), expected.bondMappings{1}), ...
    'Empty atoms/bonds must fall back to reading the file.');

% a missing file raises an error in both call forms
assert(verifyCobraFunctionError('addBondMappingsRXNFile', 'inputs', {'noSuchReaction', rxnFilesDir}), ...
    'A missing RXN file must raise an error.');
assert(verifyCobraFunctionError('addBondMappingsRXNFile', 'inputs', {'noSuchReaction', rxnFilesDir, [], []}), ...
    'A missing RXN file must raise an error when empty atoms/bonds are passed.');

% an unparsable file (header lines only) raises an error in both call forms
unparsableDir = tempname;
mkdir(unparsableDir);
removeUnparsableDir = onCleanup(@() rmdir(unparsableDir, 's'));
headerLines = regexp(fileread([rxnFilesDir filesep rxnId '.rxn']), '\r?\n', 'split');
fid = fopen([unparsableDir filesep rxnId '.rxn'], 'w');
fprintf(fid, '%s\n', headerLines{1:4});
fclose(fid);
assert(verifyCobraFunctionError('addBondMappingsRXNFile', 'inputs', {rxnId, unparsableDir}), ...
    'An unparsable RXN file must raise an error.');
assert(verifyCobraFunctionError('addBondMappingsRXNFile', 'inputs', {rxnId, unparsableDir, [], []}), ...
    'An unparsable RXN file must raise an error when empty atoms/bonds are passed.');

%% The directory defaults to the current folder
cd(rxnFilesDir);
assert(isequaln(addBondMappingsRXNFile(rxnId), expected.bondMappings{1}), ...
    'Without a directory the RXN file must be read from the current folder.');
cd(fileDir);

%% An unbalanced reaction raises a warning and maps the bond that is broken
% a two-atom substrate gives a one-atom product: the C-C bond breaks
unbalancedDir = tempname;
mkdir(unbalancedDir);
removeUnbalancedDir = onCleanup(@() rmdir(unbalancedDir, 's'));
writeRxnFile(unbalancedDir, 'unbalanced', 'a -> b', 1, 1, { ...
    makeMolecule('a', {'C', 'C'}, [1 2], [1 2 1]), makeMolecule('b', {'C'}, 1, zeros(0, 3))});
lastwarn('');
unbalancedMappings = addBondMappingsRXNFile('unbalanced', unbalancedDir);
assert(contains(lastwarn, 'do not have the same dimensions in reaction "unbalanced"'), ...
    'An unbalanced reaction must raise a warning naming it.');
assert(isequal(unbalancedMappings.mets, {'a'; 'unbalanced'}) && isequal(unbalancedMappings.isReacting, [-1; -1]), ...
    'The broken bond must be mapped to the energy node of the reaction.');
assert(isequal(unbalancedMappings.bondTransitionNrs, [1; 1]), ...
    'A broken bond and its energy node must share a bond transition number.');

fprintf('testAddBondMappingsRXNFile: done\n');

function writeRxnFile(folder, rxnId, formula, nSubstrates, nProducts, molecules)
% Write an MDL RXN file. molecules is a cell array of structs with fields name, elements,
% mapping (the atom transition numbers) and bonds (rows [head tail type]).
fid = fopen(fullfile(folder, [rxnId '.rxn']), 'w');
fprintf(fid, '$RXN\n%s\nTest fixture\n%s\n%3d%3d\n', rxnId, formula, nSubstrates, nProducts);
for i = 1:numel(molecules)
    molecule = molecules{i};
    fprintf(fid, '$MOL\n%s\n  fixture\n\n%3d%3d  0  0  0  0  0  0  0  0999 V2000\n', ...
        molecule.name, numel(molecule.elements), size(molecule.bonds, 1));
    for a = 1:numel(molecule.elements)
        fprintf(fid, '%10.4f%10.4f%10.4f %-3s 0  0  0  0  0  0  0  0  0%3d  0  0\n', 0, 0, 0, ...
            molecule.elements{a}, molecule.mapping(a));
    end
    for b = 1:size(molecule.bonds, 1)
        fprintf(fid, '%3d%3d%3d  0\n', molecule.bonds(b, :));
    end
    fprintf(fid, 'M  END\n');
end
fclose(fid);
end

function molecule = makeMolecule(name, elements, mapping, bonds)
% One molecule of a writeRxnFile fixture.
molecule = struct('name', name, 'elements', {elements}, 'mapping', mapping, 'bonds', bonds);
end
