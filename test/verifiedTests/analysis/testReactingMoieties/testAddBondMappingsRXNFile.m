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
% Authors:
%     - COBRA Toolbox, feature 20260921-160105-build-function-runtime

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

fprintf('testAddBondMappingsRXNFile: done\n');
