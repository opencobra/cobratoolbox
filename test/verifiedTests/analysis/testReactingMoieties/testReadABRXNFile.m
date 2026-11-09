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
% Function under test:
%     src/analysis/topology/reactingMoieties/readABRXNFile.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - shipped RXN files and small RXN files written to a temporary folder, no model and no solver.
%
% Coverage exemptions:
%     None apart from the lines of the defects below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: options.readBonds = 0 cannot be used
%       SEVERITY: unusable-option
%       TRIGGER: readABRXNFile(rxnfileName, rxnfileDirectory, struct('readBonds', 0)) with any RXN file
%       OBSERVED: error 'Unrecognized field name "Properties"': the code after the branch that sets bonds to [] builds a structure and then reads bonds.Properties
%       EXPECTED: the atom table is returned and the bond table is not read, as the help text states
%       LINES: 260
%     - DEFECT: The two warnings about transition numbers print a literal backslash n
%       SEVERITY: cosmetic
%       TRIGGER: an RXN file whose substrate or product transition numbers are not 1:q
%       OBSERVED: warning text ending in the two characters \n, because a one-argument warning does not process escapes
%       EXPECTED: a warning ending at the full stop
%       LINES: 231, 234
%
% Authors:
%     - COBRA Toolbox, feature 20261012-093525-symmetric-iso-zero-bond
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

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

% small RXN files written for the branches below go to a temporary folder
fixtureDir = tempname;
mkdir(fixtureDir);
removeFixtureDir = onCleanup(@() rmdir(fixtureDir, 's'));
noBonds = zeros(0, 3);
% warnings captured from the console are wrapped at its width
oneLine = @(text) regexprep(text, '\s+', ' ');

%% The directory defaults to the current folder
cd(implicitHDir);
[atomsHere, bondsHere] = readABRXNFile('ETOHt_implicitH.rxn');
cd(fileDir);
[atomsThere, bondsThere] = readABRXNFile('ETOHt_implicitH', implicitHDir);
assert(isequaln(atomsHere, atomsThere) && isequaln(bondsHere, bondsThere), ...
    'Without a directory the file must be read from the current folder, with or without its ending.');

%% A file named differently from the identifier inside it raises a warning
copyfile(fullfile(implicitHDir, 'H2Ot_implicitH.rxn'), fullfile(fixtureDir, 'renamed.rxn'));
lastwarn('');
atomsRenamed = readABRXNFile('renamed', fixtureDir);
assert(contains(lastwarn, 'renamed.rxn does not match file name'), ...
    'A file name differing from the identifier inside must raise a warning.');
assert(height(atomsRenamed) == 2, 'The atoms of the renamed file must still be read.');

%% Stoichiometric coefficients on both sides repeat the molecule block
writeRxnFile(fixtureDir, 'coefficients', '2 a -> 2 b', 2, 2, { ...
    makeMolecule('a', {'C'}, 1, noBonds), makeMolecule('a', {'C'}, 2, noBonds), ...
    makeMolecule('b', {'C'}, 1, noBonds), makeMolecule('b', {'C'}, 2, noBonds)});
atoms = readABRXNFile('coefficients', fixtureDir);
assert(isequal(atoms.mets, {'a'; 'a'; 'b'; 'b'}) && isequal(atoms.instances, [1; 2; 1; 2]) ...
    && isequal(atoms.isSubstrate, [true; true; false; false]), ...
    'A coefficient of 2 must give two instances of the molecule.');

%% Protons in the formula are dropped when the atom mapping does not hold them
molecules = {makeMolecule('a', {'C', 'O'}, [1 2], [1 2 1]), makeMolecule('b', {'C', 'O'}, [1 2], [1 2 1])};
writeRxnFile(fixtureDir, 'protonated', 'a + h[c] -> b', 1, 1, molecules);
writeRxnFile(fixtureDir, 'plainProton', 'a -> b + h', 1, 1, molecules);
for rxnId = {'protonated', 'plainProton'}
    lastwarn('');
    atoms = readABRXNFile(rxnId{1}, fixtureDir);
    assert(isequal(unique(atoms.mets), {'a'; 'b'}) && isempty(lastwarn), ...
        'A proton in the formula that has no molecule block must be dropped without a warning.');
end

%% A formula that disagrees with the counts line raises a warning
% the formula holds three molecules, the counts line two: the blocks of all three are still read
writeRxnFile(fixtureDir, 'wrongCounts', 'a + c -> b', 1, 1, {makeMolecule('a', {'C'}, 1, noBonds), ...
    makeMolecule('c', {'O'}, 2, noBonds), makeMolecule('b', {'C', 'O'}, [1 2], [1 2 1])});
lastwarn('');
atoms = readABRXNFile('wrongCounts', fixtureDir);
assert(contains(lastwarn, 'Incorrect reaction formula in the rxnfile wrongCounts'), ...
    'A formula disagreeing with the counts line must raise a warning.');
assert(height(atoms) == 4, 'All the molecule blocks of the formula must be read.');

%% Molecule blocks in another order than the formula are refused, by their numeric identifiers
writeRxnFile(fixtureDir, 'blockOrder', 'M_1[c] -> M_2[c]', 1, 1, { ...
    makeMolecule('CHEBI_2', {'C'}, 1, noBonds), makeMolecule('CHEBI_1', {'C'}, 1, noBonds)});
blockOrderId = '';
try
    readABRXNFile('blockOrder', fixtureDir);
catch ME
    blockOrderId = ME.identifier;
    blockOrderMessage = ME.message;
end
assert(strcmp(blockOrderId, 'readABRXNFile:blockOrderMismatch'), 'Blocks out of order must raise an error.');
assert(contains(blockOrderMessage, 'Expected metabolite "M_1[c]"') && contains(blockOrderMessage, 'CHEBI_2'), ...
    'The error must name the expected metabolite and the block found.');

%% An odd number of atoms is reported as elementally unbalanced
writeRxnFile(fixtureDir, 'oddAtoms', 'a -> b', 1, 1, { ...
    makeMolecule('a', {'C', 'O'}, [1 2], noBonds), makeMolecule('b', {'C'}, 1, noBonds)});
consoleText = evalc('atoms = readABRXNFile(''oddAtoms'', fixtureDir);');
assert(contains(consoleText, 'oddAtoms a -> b is elementally unbalanced.'), ...
    'An odd number of atoms must be reported.');
assert(height(atoms) == 3, 'The atoms of an unbalanced reaction must still be read.');

%% Atom transitions between different elements are reported
writeRxnFile(fixtureDir, 'elements', 'a -> b', 1, 1, { ...
    makeMolecule('a', {'C', 'O'}, [1 2], noBonds), makeMolecule('b', {'O', 'C'}, [1 2], noBonds)});
consoleText = evalc('readABRXNFile(''elements'', fixtureDir);');
assert(contains(consoleText, 'contains 2 atom transitions violating elemental conservation.'), ...
    'Atom transitions between different elements must be reported.');

%% Transition numbers that are not 1:q, or that do not match across the reaction, raise warnings
writeRxnFile(fixtureDir, 'substrateOrder', 'a -> b', 1, 1, { ...
    makeMolecule('a', {'C', 'C'}, [1 3], noBonds), makeMolecule('b', {'C', 'C'}, [1 2], noBonds)});
consoleText = evalc('readABRXNFile(''substrateOrder'', fixtureDir);');
consoleText = oneLine(consoleText);
assert(contains(consoleText, 'substrateOrder.rxn, Substrate transition numbers not ordered 1:q.'), ...
    'Substrate transition numbers that are not 1:q must raise a warning.');
assert(contains(consoleText, 'Reaction file: substrateOrder.rxn, Substrate and product transition numbers not matching'), ...
    'Transition numbers that do not match across the reaction must raise a warning.');
writeRxnFile(fixtureDir, 'productOrder', 'a -> b', 1, 1, { ...
    makeMolecule('a', {'C', 'C'}, [1 2], noBonds), makeMolecule('b', {'C', 'C'}, [1 3], noBonds)});
consoleText = evalc('readABRXNFile(''productOrder'', fixtureDir);');
assert(contains(oneLine(consoleText), 'productOrder.rxn, Product transition numbers not ordered 1:q.'), ...
    'Product transition numbers that are not 1:q must raise a warning.');

%% One metabolite written twice in a formula gives two atoms with one identity
% (met, metNr, instance) is then not unique: harmless without bonds, an error for a bond
writeRxnFile(fixtureDir, 'repeatedMet', 'a + a -> b + c', 2, 2, { ...
    makeMolecule('a', {'C'}, 1, noBonds), makeMolecule('a', {'C'}, 2, noBonds), ...
    makeMolecule('b', {'C'}, 1, noBonds), makeMolecule('c', {'C'}, 2, noBonds)});
atoms = readABRXNFile('repeatedMet', fixtureDir);
assert(isequal(atoms.instances, ones(4, 1)) && nnz(strcmp(atoms.mets, 'a')) == 2, ...
    'Both atoms of the repeated metabolite must be read, each as instance 1.');
carbonOxide = @(name, mapping) makeMolecule(name, {'C', 'O'}, mapping, [1 2 1]);
writeRxnFile(fixtureDir, 'repeatedBonded', 'a + a -> b + c', 2, 2, {carbonOxide('a', [1 2]), ...
    carbonOxide('a', [3 4]), carbonOxide('b', [1 2]), carbonOxide('c', [3 4])});
assert(verifyCobraFunctionError('readABRXNFile', 'inputs', {'repeatedBonded', fixtureDir}), ...
    'A bond of an atom whose identity is not unique must raise an error.');

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
