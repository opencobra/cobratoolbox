% The COBRAToolbox: testResolveAtomNodeIndex.m
%
% Purpose:
%     - Test that resolveAtomNodeIndex resolves a unique (mets, AtomNumber,
%       Element) composite key to the correct Atom/AtomIndex pair, and raises
%       an explicit, identifiable error -- rather than silently selecting a
%       match or silently returning an empty/default value -- when the key
%       is absent or resolves to more than one row (feature
%       20260902-150020-eliminate-bond-transition-ismember-scans, US2,
%       FR-005, SC-006).
%
% Authors:
%     - COBRA Toolbox, feature 20260902-150020-eliminate-bond-transition-ismember-scans

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% synthetic node table matching dATM.Nodes's relevant column shape
nodeTable = table({'A1'; 'A2'; 'A3'}, [1; 2; 3], {'met1[c]'; 'met1[c]'; 'met2[c]'}, ...
    [1; 2; 1], {'C'; 'N'; 'O'}, ...
    'VariableNames', {'Atom', 'AtomIndex', 'mets', 'AtomNumber', 'Element'});

% build the node-identity index exactly as buildAtomAndBondTransitionMultigraph does
nodeIndexMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
for r = 1:height(nodeTable)
    key = sprintf('%s\x1f%d\x1f%s', nodeTable.mets{r}, nodeTable.AtomNumber(r), nodeTable.Element{r});
    if isKey(nodeIndexMap, key)
        nodeIndexMap(key) = [nodeIndexMap(key), r];
    else
        nodeIndexMap(key) = r;
    end
end

% (a) a key present exactly once returns the expected atom/atomIndex pair
[atom, atomIndex] = resolveAtomNodeIndex(nodeTable, nodeIndexMap, 'met1[c]', 1, 'C');
assert(isequal(atom, {'A1'}), 'resolveAtomNodeIndex must return the Atom value of the uniquely-matching row.');
assert(isequal(atomIndex, nodeTable.AtomIndex(1)), 'resolveAtomNodeIndex must return the AtomIndex value of the uniquely-matching row.');

[atom2, atomIndex2] = resolveAtomNodeIndex(nodeTable, nodeIndexMap, 'met2[c]', 1, 'O');
assert(isequal(atom2, {'A3'}), 'resolveAtomNodeIndex must resolve a distinct metabolite/atom-number/element key to its own row.');
assert(isequal(atomIndex2, nodeTable.AtomIndex(3)), 'resolveAtomNodeIndex must return the AtomIndex value of the uniquely-matching row.');

% (b) a key absent from nodeIndexMap raises resolveAtomNodeIndex:missingNodeIdentity
% (Acceptance Scenario US2-2)
missingKeyRaised = false;
try
    resolveAtomNodeIndex(nodeTable, nodeIndexMap, 'met1[c]', 99, 'C');
catch ME
    missingKeyRaised = true;
    assert(strcmp(ME.identifier, 'resolveAtomNodeIndex:missingNodeIdentity'), ...
        'A missing composite key must raise resolveAtomNodeIndex:missingNodeIdentity, got %s.', ME.identifier);
end
assert(missingKeyRaised, 'resolveAtomNodeIndex must raise an error for a missing composite key, not return an empty or default value.');

% (c) a key present for two synthetic rows raises resolveAtomNodeIndex:ambiguousNodeIdentity
% (Acceptance Scenario US2-1)
duplicateNodeTable = table({'A1'; 'A2'; 'A3'}, [1; 2; 3], {'met1[c]'; 'met1[c]'; 'met1[c]'}, ...
    [1; 1; 3], {'C'; 'C'; 'O'}, ...
    'VariableNames', {'Atom', 'AtomIndex', 'mets', 'AtomNumber', 'Element'});
duplicateNodeIndexMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
for r = 1:height(duplicateNodeTable)
    key = sprintf('%s\x1f%d\x1f%s', duplicateNodeTable.mets{r}, duplicateNodeTable.AtomNumber(r), duplicateNodeTable.Element{r});
    if isKey(duplicateNodeIndexMap, key)
        duplicateNodeIndexMap(key) = [duplicateNodeIndexMap(key), r];
    else
        duplicateNodeIndexMap(key) = r;
    end
end

ambiguousKeyRaised = false;
try
    resolveAtomNodeIndex(duplicateNodeTable, duplicateNodeIndexMap, 'met1[c]', 1, 'C');
catch ME
    ambiguousKeyRaised = true;
    assert(strcmp(ME.identifier, 'resolveAtomNodeIndex:ambiguousNodeIdentity'), ...
        'A duplicated composite key must raise resolveAtomNodeIndex:ambiguousNodeIdentity, got %s.', ME.identifier);
end
assert(ambiguousKeyRaised, 'resolveAtomNodeIndex must raise an error for an ambiguous composite key, not silently pick one match.');

% the non-duplicated key in the same table still resolves normally
[atom3, atomIndex3] = resolveAtomNodeIndex(duplicateNodeTable, duplicateNodeIndexMap, 'met1[c]', 3, 'O');
assert(isequal(atom3, {'A3'}), 'A non-duplicated key must still resolve normally even when other keys in the same table are ambiguous.');
assert(isequal(atomIndex3, duplicateNodeTable.AtomIndex(3)), 'A non-duplicated key must still resolve normally even when other keys in the same table are ambiguous.');

% return to the original directory
cd(currentDir);
