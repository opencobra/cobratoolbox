% The COBRAToolbox: testCheckABRXNFiles.m
%
% Purpose:
%     - Test that checkABRXNFiles returns the quality-check fields and the
%       total atom and bond transition counts captured from the function
%       before feature 20260921-160105-build-function-runtime (FR-007, FR-013),
%       on the shipped RXN files and on two derived directories: one with the
%       last mapped reaction's RXN file missing, and one with it cut to its
%       header lines (unparsable).
%     - Test that an unparsable RXN file for the first mapped reaction still
%       raises an error, as before.
%
% Authors:
%     - COBRA Toolbox, feature 20260921-160105-build-function-runtime

global CBTDIR

% no solver is needed; declared for the harness convention
prepareTest();

% save the current path and initialize the test
currentDir = pwd;
fileDir = fileparts(which('testCheckABRXNFiles'));
cd(fileDir);
restoreDir = onCleanup(@() cd(currentDir));

% atom-mapped reaction files shipped beside the reacting-moiety tests
rxnFilesDir = [fileDir filesep 'data' filesep 'rxnFiles'];
assert(isfolder(rxnFilesDir), 'Atom-mapped rxnFiles fixture not found.');

% the r0317/ACONTm/r0426 Recon3D subnetwork used by testConservedReactingMoieties.m
model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'mat' filesep 'Recon3D_301.mat']);
subModel = extractSubNetwork(model, {'r0317'; 'ACONTm'; 'r0426'});

% expected values, captured from the unmodified function (research R8)
expected = load([fileDir filesep 'data' filesep 'checkABRXNFilesExpected.mat']);

% shipped directory
[modelOut, nTotalAtomTransitions, nTotalBondTransitions] = checkABRXNFiles(subModel, rxnFilesDir);
assertCheckOutputs(modelOut, nTotalAtomTransitions, nTotalBondTransitions, expected.base, 'base');

% last mapped reaction's RXN file missing
[missingDir, missingRxn] = makeDerivedRxnDir('missing', subModel, rxnFilesDir);
removeMissingDir = onCleanup(@() rmdir(missingDir, 's'));
assert(strcmp(missingRxn, expected.missing.alteredRxn), 'The derived missing fixture changed.');
[modelOut, nTotalAtomTransitions, nTotalBondTransitions] = checkABRXNFiles(subModel, missingDir);
assertCheckOutputs(modelOut, nTotalAtomTransitions, nTotalBondTransitions, expected.missing, 'missing');
assert(~modelOut.RXNBool(strcmp(subModel.rxns, missingRxn)), 'A missing RXN file must give RXNBool false.');

% last mapped reaction's RXN file unparsable
[unparsableDir, unparsableRxn] = makeDerivedRxnDir('unparsable', subModel, rxnFilesDir);
removeUnparsableDir = onCleanup(@() rmdir(unparsableDir, 's'));
assert(strcmp(unparsableRxn, expected.unparsable.alteredRxn), 'The derived unparsable fixture changed.');
[modelOut, nTotalAtomTransitions, nTotalBondTransitions] = checkABRXNFiles(subModel, unparsableDir);
assertCheckOutputs(modelOut, nTotalAtomTransitions, nTotalBondTransitions, expected.unparsable, 'unparsable');
assert(modelOut.RXNParsedBool(strcmp(subModel.rxns, unparsableRxn)) == 0, ...
    'An unparsable RXN file must give RXNParsedBool 0.');

% first mapped reaction's RXN file unparsable: the decompartmentalisation read rethrows
[firstBrokenDir, ~] = makeDerivedRxnDir('firstBroken', subModel, rxnFilesDir);
removeFirstBrokenDir = onCleanup(@() rmdir(firstBrokenDir, 's'));
assert(verifyCobraFunctionError('checkABRXNFiles', 'inputs', {subModel, firstBrokenDir}), ...
    'An unparsable RXN file for the first mapped reaction must raise an error.');

fprintf('testCheckABRXNFiles: done\n');

function assertCheckOutputs(modelOut, nTotalAtomTransitions, nTotalBondTransitions, expectedCase, caseName)
fieldList = {'metRXNBool', 'RXNBool', 'RXNParsedBool', 'RXNAtomsConservedBool', ...
    'RXNStoichiometryMatchBool', 'RXNStoichiometryMatchUptoProtonsBool', ...
    'RXNSubstrateTransitionNumbersOrdered', 'RXNProductTransitionNumbersOrdered', ...
    'RXNTransitionNumbersMatching', 'RXNMatchingElementBool'};
for k = 1:numel(fieldList)
    assert(isequaln(modelOut.(fieldList{k}), expectedCase.(fieldList{k})), ...
        sprintf('%s: modelOut.%s differs from the captured value.', caseName, fieldList{k}));
end
assert(isequal(nTotalAtomTransitions, expectedCase.nTotalAtomTransitions), ...
    sprintf('%s: nTotalAtomTransitions differs from the captured value.', caseName));
assert(isequal(nTotalBondTransitions, expectedCase.nTotalBondTransitions), ...
    sprintf('%s: nTotalBondTransitions differs from the captured value.', caseName));
end

function [derivedDir, alteredRxn] = makeDerivedRxnDir(kind, subModel, rxnFilesDir)
% Derived fixture (tasks T004): a copy of the RXN directory with one reaction's file
% deleted ('missing') or cut to its first 4 header lines ('unparsable' for the last
% mapped reaction, 'firstBroken' for the first). The caller removes derivedDir.
% The body of this function is copied verbatim into testCheckABRXNFiles.m.
derivedDir = tempname;
mkdir(derivedDir);
copyfile(fullfile(rxnFilesDir, '*.rxn'), derivedDir);
mappedBool = cellfun(@(r) isfile(fullfile(rxnFilesDir, [r '.rxn'])), subModel.rxns);
mappedRxns = subModel.rxns(mappedBool);
switch kind
    case 'missing'
        alteredRxn = mappedRxns{end};
        delete(fullfile(derivedDir, [alteredRxn '.rxn']));
    case {'unparsable', 'firstBroken'}
        if strcmp(kind, 'unparsable')
            alteredRxn = mappedRxns{end};
        else
            alteredRxn = mappedRxns{1};
        end
        alteredPath = fullfile(derivedDir, [alteredRxn '.rxn']);
        fileLines = regexp(fileread(alteredPath), '\r?\n', 'split');
        fid = fopen(alteredPath, 'w');
        fprintf(fid, '%s\n', fileLines{1:4});
        fclose(fid);
    otherwise
        error('makeDerivedRxnDir:badKind', 'Unknown derived fixture kind "%s".', kind);
end
end
