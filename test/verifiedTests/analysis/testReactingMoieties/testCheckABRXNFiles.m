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
%     - Test that a reaction with no bonds adds no bond transitions to the total
%       (feature 20261012-093525-symmetric-iso-zero-bond).
%
% Function under test:
%     src/analysis/topology/reactingMoieties/checkABRXNFiles.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no solver; RXN files shipped or written to a temporary folder, with a three-reaction
%     extract of Recon3D and toy models. checkABRXNFiles only prints and returns its findings.
%
% Coverage exemptions:
%     None apart from the lines of the defects below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Decompartmentalising the model keeps the opening bracket
%       SEVERITY: wrong-result
%       TRIGGER: model.mets with compartments, as in 'a[c]', and RXN files without, as in 'a'
%       OBSERVED: model.mets{j}(1:end-2) turns 'a[c]' into 'a[', which matches no atom, so every reaction fails the stoichiometry check and modelOut.mets is corrupted
%       EXPECTED: 'a[c]' becomes 'a', the three characters of the compartment removed, as for the atoms at line 182
%       LINES: 140, 141
%     - DEFECT: The duplicates that stop the check are not shown
%       SEVERITY: cosmetic
%       TRIGGER: a model with a repeated metabolite or reaction identifier
%       OBSERVED: setdiff(model.mets, unique(model.mets)) is always empty, so nothing is displayed before the error
%       EXPECTED: the repeated identifiers are displayed
%       LINES: 65, 69
%
% Authors:
%     - COBRA Toolbox, feature 20260921-160105-build-function-runtime
%     - COBRA Toolbox, feature 20261012-093525-symmetric-iso-zero-bond (zero-bond reaction)
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

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

% a reaction with no bonds (implicit-hydrogen water transport) adds no bond transitions; the
% implicit-hydrogen ethanol transport has two (feature 20261012-093525-symmetric-iso-zero-bond)
zeroBondModel = struct();
zeroBondModel.mets = {'etoh[e]'; 'etoh[c]'; 'h2o[c]'; 'h2o[e]'};
zeroBondModel.rxns = {'ETOHt_implicitH'; 'H2Ot_implicitH'};
zeroBondModel.S = sparse([-1, 0; 1, 0; 0, -1; 0, 1]);
zeroBondModel.lb = [-1000; -1000];
zeroBondModel.ub = [1000; 1000];
[~, nTotalAtomTransitions, nTotalBondTransitions] = checkABRXNFiles(zeroBondModel, ...
    [fileDir filesep 'data' filesep 'rxn']);
assert(isequal(nTotalAtomTransitions, 4) && isequal(nTotalBondTransitions, 2), ...
    'A reaction with no bonds must add no bond transitions to the total.');

% small RXN files written for the branches below go to temporary folders
toyDir = tempname;
mkdir(toyDir);
removeToyDir = onCleanup(@() rmdir(toyDir, 's'));
noBonds = zeros(0, 3);
carbonOxide = @(name) makeMolecule(name, {'C', 'O'}, [1 2], [1 2 1]);
carbonOxides = @(a, b) {carbonOxide(a), carbonOxide(b)};
twoCarbons = @(name, mapping) makeMolecule(name, {'C', 'C'}, mapping, noBonds);
% a -> b -> c, all with compartments
toyModel = struct('mets', {{'a[c]'; 'b[c]'; 'c[c]'}}, 'rxns', {{'R1'; 'R2'}}, ...
    'S', sparse([-1 0; 1 -1; 0 1]), 'lb', [-1000; -1000], 'ub', [1000; 1000]);
writeRxnFile(toyDir, 'R1', 'a[c] -> b[c]', 1, 1, carbonOxides('a[c]', 'b[c]'));

%% Repeated metabolites or reactions are refused
repeatedMet = toyModel;
repeatedMet.mets{2} = 'a[c]';
assert(verifyCobraFunctionError('checkABRXNFiles', 'inputs', {repeatedMet, toyDir}, ...
    'testMessage', 'duplicate metabolites'));
repeatedRxn = toyModel;
repeatedRxn.rxns{2} = 'R1';
assert(verifyCobraFunctionError('checkABRXNFiles', 'inputs', {repeatedRxn, toyDir}, ...
    'testMessage', 'duplicate reactions'));

%% The directory defaults to the current folder
writeRxnFile(toyDir, 'R2', 'b[c] -> c[c]', 1, 1, carbonOxides('b[c]', 'c[c]'));
cd(toyDir);
[modelOut, nTotalAtomTransitions, nTotalBondTransitions] = checkABRXNFiles(toyModel);
cd(fileDir);
assert(all(modelOut.RXNBool) && all(modelOut.RXNStoichiometryMatchBool == 1), ...
    'Without a directory the RXN files must be found in the current folder.');
assert(nTotalAtomTransitions == 4 && nTotalBondTransitions == 2, ...
    'Two reactions of two atoms and one bond have four atom and two bond transitions.');

%% An RXN file without an atom mapping: nothing is counted, and the plain summary is printed
unmappedDir = tempname;
mkdir(unmappedDir);
removeUnmappedDir = onCleanup(@() rmdir(unmappedDir, 's'));
writeRxnFile(unmappedDir, 'R1', 'a[c] -> b[c]', 1, 1, {makeMolecule('a[c]', {'C', 'O'}, [0 0], noBonds), ...
    makeMolecule('b[c]', {'C', 'O'}, [0 0], noBonds)});
consoleText = evalc('[modelOut, nTotalAtomTransitions] = checkABRXNFiles(toyModel, unmappedDir);');
assert(isequal(modelOut.RXNBool, [true; false]) && nTotalAtomTransitions == 0, ...
    'A file without an atom mapping must count no atom transition.');
assert(contains(consoleText, 'RXN file summary:') && ~contains(consoleText, 'atom mapping summary'), ...
    'Without an atom mapping the plain summary must be printed.');

%% RXN files with compartments and a model without: the atoms lose their compartment
plainModel = toyModel;
plainModel.mets = {'a'; 'b'; 'c'};
modelOut = checkABRXNFiles(plainModel, toyDir);
assert(all(modelOut.RXNStoichiometryMatchBool == 1), ...
    'The atoms must match the metabolites once their compartments are removed.');

%% Different names without compartments, here R1 starts with b, are left as they are
reversedDir = tempname;
mkdir(reversedDir);
removeReversedDir = onCleanup(@() rmdir(reversedDir, 's'));
writeRxnFile(reversedDir, 'R1', 'b -> a', 1, 1, carbonOxides('b', 'a'));
reversedModel = struct('mets', {{'a'; 'b'}}, 'rxns', {{'R1'}}, 'S', sparse([1; -1]), 'lb', -1000, 'ub', 1000);
modelOut = checkABRXNFiles(reversedModel, reversedDir);
assert(isequal(modelOut.mets, {'a'; 'b'}) && modelOut.RXNStoichiometryMatchBool == 1, ...
    'Metabolites without compartments must not be changed.');

%% A proton in the model and not in the RXN file matches up to protons
protonModel = toyModel;
protonModel.mets{3} = 'h[c]';
protonModel.S = sparse([-1; 1; 1]);
protonModel.rxns = {'R1'};
protonModel.lb = -1000;
protonModel.ub = 1000;
modelOut = checkABRXNFiles(protonModel, toyDir);
assert(modelOut.RXNStoichiometryMatchBool == 0 && modelOut.RXNStoichiometryMatchUptoProtonsBool == 1, ...
    'A reaction differing by a proton must match up to protons only.');

%% An odd number of atoms does not conserve atoms
oddDir = tempname;
mkdir(oddDir);
removeOddDir = onCleanup(@() rmdir(oddDir, 's'));
writeRxnFile(oddDir, 'R1', 'a[c] -> b[c]', 1, 1, carbonOxides('a[c]', 'b[c]'));
writeRxnFile(oddDir, 'R2', 'b[c] -> c[c]', 1, 1, {carbonOxide('b[c]'), makeMolecule('c[c]', {'C'}, 1, noBonds)});
consoleText = evalc('modelOut = checkABRXNFiles(toyModel, oddDir);');
assert(isequal(modelOut.RXNAtomsConservedBool, [1; 0]), 'The odd reaction must fail the atom count.');
assert(contains(consoleText, 'does not conserve atoms.'), 'The odd reaction must be reported.');

%% Transition numbers that are not 1:q, or that do not match across the reaction, are recorded
orderDir = tempname;
mkdir(orderDir);
removeOrderDir = onCleanup(@() rmdir(orderDir, 's'));
writeRxnFile(orderDir, 'R1', 'a[c] -> b[c]', 1, 1, {twoCarbons('a[c]', [1 3]), twoCarbons('b[c]', [1 2])});
writeRxnFile(orderDir, 'R2', 'b[c] -> c[c]', 1, 1, {twoCarbons('b[c]', [1 2]), twoCarbons('c[c]', [1 3])});
consoleText = evalc('modelOut = checkABRXNFiles(toyModel, orderDir);');
assert(isequal(modelOut.RXNSubstrateTransitionNumbersOrdered, [0; 1]), 'R1 has disordered substrate numbers.');
assert(isequal(modelOut.RXNProductTransitionNumbersOrdered, [1; 0]), 'R2 has disordered product numbers.');
assert(isequal(modelOut.RXNTransitionNumbersMatching, [0; 0]), 'Neither reaction has matching numbers.');
assert(contains(consoleText, 'R1.rxn, Substrate transition numbers not ordered 1:q.') && ...
    contains(consoleText, 'R2.rxn, Product transition numbers not ordered 1:q.') && ...
    contains(consoleText, 'R1.rxn, Substrate and product transition numbers not matching order 1:q.'), ...
    'Each finding must be reported.');

%% An atom transition between different elements is recorded
elementDir = tempname;
mkdir(elementDir);
removeElementDir = onCleanup(@() rmdir(elementDir, 's'));
writeRxnFile(elementDir, 'R1', 'a[c] -> b[c]', 1, 1, {makeMolecule('a[c]', {'C', 'O'}, [1 2], noBonds), ...
    makeMolecule('b[c]', {'O', 'C'}, [1 2], noBonds)});
consoleText = evalc('modelOut = checkABRXNFiles(toyModel, elementDir);');
assert(isequal(modelOut.RXNMatchingElementBool(1), 0), 'Transitions from C to O and O to C must fail.');
assert(contains(consoleText, 'R1 a[c]  <=> b[c]  contains 2 atom transitions violating elemental conservation.'), ...
    'The violation must be reported with the formula of the reaction.');

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
