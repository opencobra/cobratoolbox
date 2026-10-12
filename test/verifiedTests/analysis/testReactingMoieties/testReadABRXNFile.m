% The COBRAToolbox: testReadABRXNFile.m
%
% Purpose:
%     - Test that readABRXNFile reads a reaction in which no molecule has a bond (implicit-hydrogen
%       water transport and potassium chloride transport fixtures): the atom table holds the
%       atoms and their mappings, and the bond table is empty with the same variables, in the
%       same order and of the same types, as a non-empty bond table (feature
%       20261012-093525-symmetric-iso-zero-bond, spec FR-004, SC-004).
%     - Test that the bonded implicit-hydrogen fixture ETOHt_implicitH and three explicit-hydrogen
%       fixtures (r0317, ACONTm, r0426) give the atom and bond tables captured from readABRXNFile
%       before this feature (data/readABRXNFileReference.mat; spec FR-006).
%
% Authors:
%     - COBRA Toolbox, feature 20261012-093525-symmetric-iso-zero-bond

% no solver is needed; declared for the harness convention
prepareTest();

% save the current path and initialize the test
currentDir = pwd;
fileDir = fileparts(which('testReadABRXNFile'));
cd(fileDir);
restoreDir = onCleanup(@() cd(currentDir));

implicitHDir = [fileDir filesep 'data' filesep 'rxn'];
rxnFilesDir = [fileDir filesep 'data' filesep 'rxnFiles'];
assert(isfolder(implicitHDir) && isfolder(rxnFilesDir), 'RXN file fixtures not found.');

bondVariables = {'mets', 'headAtoms', 'tailAtoms', 'bTypes', 'headAtomElements', ...
    'tailAtomElements', 'headAtomTransitionNrs', 'tailAtomTransitionNrs', 'isSubstrate', 'instances'};

% a non-empty bond table, for the variable types
[~, bondedBonds] = readABRXNFile('ETOHt_implicitH', implicitHDir);
assert(isequal(bondedBonds.Properties.VariableNames, bondVariables));

% reactions with no bond: expected atom mets, elements and atom transition numbers
zeroBondCases = {'H2Ot_implicitH', {'h2o[c]'; 'h2o[e]'}, {'O'; 'O'}, [1; 1], [true; false]; ...
    'KCLt_implicitH', {'k[e]'; 'cl[e]'; 'k[c]'; 'cl[c]'}, {'K'; 'Cl'; 'K'; 'Cl'}, [1; 2; 1; 2], ...
    [true; true; false; false]};
for k = 1:size(zeroBondCases, 1)
    rxnId = zeroBondCases{k, 1};
    [atoms, bonds] = readABRXNFile(rxnId, implicitHDir);
    assert(isequal(atoms.mets, zeroBondCases{k, 2}) && isequal(atoms.elements, zeroBondCases{k, 3}) ...
        && isequal(atoms.atomTransitionNrs, zeroBondCases{k, 4}) ...
        && isequal(atoms.isSubstrate, zeroBondCases{k, 5}) && isequal(atoms.metNrs, ones(height(atoms), 1)) ...
        && isequal(atoms.instances, ones(height(atoms), 1)), ...
        sprintf('%s: atom table differs from the RXN file.', rxnId));
    assert(istable(bonds) && height(bonds) == 0, sprintf('%s: the bond table must be empty.', rxnId));
    assert(isequal(bonds.Properties.VariableNames, bondVariables), ...
        sprintf('%s: the empty bond table must have the documented variables.', rxnId));
    for v = 1:numel(bondVariables)
        assert(strcmp(class(bonds.(bondVariables{v})), class(bondedBonds.(bondVariables{v}))) && ...
            size(bonds.(bondVariables{v}), 2) == size(bondedBonds.(bondVariables{v}), 2), ...
            sprintf('%s: bond variable %s has a different type or width from a non-empty table.', ...
            rxnId, bondVariables{v}));
    end
end

% bonded fixtures: identical to readABRXNFile before this feature
reference = load([fileDir filesep 'data' filesep 'readABRXNFileReference.mat']);
for k = 1:numel(reference.readABRXNFileReference)
    rxnId = reference.readABRXNFileReference(k).rxnfileName;
    if strcmp(rxnId, 'ETOHt_implicitH')
        rxnDir = implicitHDir;
    else
        rxnDir = rxnFilesDir;
    end
    [atoms, bonds] = readABRXNFile(rxnId, rxnDir);
    assert(isequaln(atoms, reference.readABRXNFileReference(k).atoms), ...
        sprintf('%s: atom table differs from the pre-change reference.', rxnId));
    assert(isequaln(bonds, reference.readABRXNFileReference(k).bonds), ...
        sprintf('%s: bond table differs from the pre-change reference.', rxnId));
end
