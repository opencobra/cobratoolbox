% The COBRAToolbox: testIdentifyAtomEquivalenceClasses.m
%
% Purpose:
%     - Test that identifyAtomEquivalenceClasses detects a metabolite's own
%       symmetry/resonance-equivalence classes of atoms (feature
%       020-canonicalize-symmetric-atom-bonds) correctly and collision-free, computes
%       the unsafe-neighbour set that guards against undercounting genuinely distinct,
%       simultaneously-present bonds, converges without runaway memory growth, and
%       degrades safely (warns, falls back to the identity map, does not halt) on a
%       structurally malformed or inconclusive input.
%
%     Test cases (a)-(d) reconstruct the atoms/bonds of coa[m] and crn[m] from their own
%     RXN-file molblocks (PPACOAATREVm.rxn, shared with testConservedReactingMoieties.m's
%     fixtures) rather than inventing synthetic small graphs, so the expected classes are
%     grounded in the actual defect this feature fixes (research.md R2, R2.3).
%
% Function under test:
%     src/analysis/topology/reactingMoieties/identifyAtomEquivalenceClasses.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - atoms and bonds from a shipped RXN file and hand-built graphs, no model and no solver.
%
% Coverage exemptions:
%     Line 168: unreachable, the number of colours grows at each unconverged round and is at most p, so the loop of p + 1 rounds always converges.
%     Lines 282, 291: unreachable, an atom differs from its representative only in a class of two or more, and such a class always has an unsafe entry from the loop above.
%     Line 306: unreachable, an error raised inside this function always has a stack.
%     Line 333: unreachable, the bonds are checked against atomNumbers at line 91 and the map holds every atom number.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The check for a duplicate bond never fires
%       SEVERITY: limitation
%       TRIGGER: identifyAtomEquivalenceClasses([1; 2], {'C'; 'C'}, [1; 1], [2; 2], [1; 1], 'met') with two bonds between one atom pair
%       OBSERVED: graph keeps parallel edges, so numedges(G) always equals numel(headAtoms); classes are returned without the warning
%       EXPECTED: the input is detected as a duplicate bond and the function falls back to the identity map with a warning
%       LINES: 110
%
% Authors:
%     - COBRA Toolbox, feature 020-canonicalize-symmetric-atom-bonds
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% declare the requirements of this test (a Tier 1 test has none)
prepareTest();

rxnFilesDir = [pwd filesep 'data' filesep 'rxnFiles'];
assert(isfolder(rxnFilesDir), 'Atom-mapped rxnFiles fixture not found.');

[atoms, bonds] = readABRXNFile('PPACOAATREVm', rxnFilesDir);

% ---------------------------------------------------------------------------------------
% (a) known symmetric group: coa[m]'s gem-dimethyl pair (atoms 1 and 3, both C, each its
% own methyl carbon bonded to the same quaternary anchor carbon, atom 2) is detected as
% one equivalence class, and both members canonicalize to the same representative.
% ---------------------------------------------------------------------------------------
coaMAtomBool = strcmp(atoms.mets, 'coa[m]') & atoms.instances == 1;
coaMBondBool = strcmp(bonds.mets, 'coa[m]') & bonds.instances == 1;
[coaMRankMap, coaMClasses, coaMUnsafeMap] = identifyAtomEquivalenceClasses(...
    atoms.metNrs(coaMAtomBool), atoms.elements(coaMAtomBool), ...
    bonds.headAtoms(coaMBondBool), bonds.tailAtoms(coaMBondBool), bonds.bTypes(coaMBondBool), 'coa[m]');

assert(coaMRankMap(1) == coaMRankMap(3), ...
    'coa[m]''s gem-dimethyl pair (atoms 1 and 3) must canonicalize to the same representative atom number.');
assert(coaMRankMap(1) == 1, 'The gem-dimethyl pair''s canonical representative must be the lower raw atom number (1).');
gemDimethylClass = coaMClasses(cellfun(@(c) isequal(sort(c(:)'), [1 3]), coaMClasses));
assert(numel(gemDimethylClass) == 1, 'coa[m]''s gem-dimethyl pair must form exactly one equivalence class {1, 3}.');

% ---------------------------------------------------------------------------------------
% (b) collision-free: two atoms sharing an element (both C) but distinguishable elsewhere
% in the molecular graph (atom 2, the shared quaternary anchor carbon, vs. atom 1, one of
% the two gem-dimethyl methyls it anchors) are NOT merged into the same class (FR-004).
% ---------------------------------------------------------------------------------------
assert(coaMRankMap(2) ~= coaMRankMap(1), ...
    'Atom 2 (the gem-dimethyl pair''s anchor carbon) must not be merged with atom 1 (one of the methyls) merely because both are carbon.');

% unsafe-neighbour guard (FR-002): atom 2 is bonded to BOTH class {1,3} members
% simultaneously, so it must be named unsafe for that class -- substituting the canonical
% representative (1) for atom 3 in the "3-2" bond would otherwise collapse the genuinely
% distinct "1-2" and "3-2" bonds onto one identity, undercounting coa[m]'s true bond count.
assert(isKey(coaMUnsafeMap, 1), 'coa[m]''s gem-dimethyl class (canonical rep 1) must have an unsafe-neighbour entry.');
assert(ismember(2, coaMUnsafeMap(1)), ...
    'Atom 2, bonded to both gem-dimethyl methyls simultaneously, must be named unsafe for class {1, 3}.');
% each methyl's own three hydrogens (49-51 for atom 1, 52-54 for atom 3), by contrast, are
% each bonded to only ONE class member, so substitution for THOSE bonds is safe -- unaffected.
assert(~ismember(49, coaMUnsafeMap(1)), 'Atom 49 (bonded only to atom 1, not atom 3) must not be flagged unsafe.');

% ---------------------------------------------------------------------------------------
% (c) a metabolite with two independent, simultaneously-detected equivalence classes
% (FR-005): crn[m]'s trimethylammonium methyls (atoms 4, 9, 11 -- the three symmetric
% N-methyl carbons; the fourth carbon on the same nitrogen, atom 1, is the backbone CH2
% and is correctly excluded since its further connectivity differs) and, independently,
% one of its diastereotopic CH2 hydrogen pairs (atoms 12, 13).
% ---------------------------------------------------------------------------------------
crnMAtomBool = strcmp(atoms.mets, 'crn[m]') & atoms.instances == 1;
crnMBondBool = strcmp(bonds.mets, 'crn[m]') & bonds.instances == 1;
[crnMRankMap, crnMClasses, crnMUnsafeMap] = identifyAtomEquivalenceClasses(...
    atoms.metNrs(crnMAtomBool), atoms.elements(crnMAtomBool), ...
    bonds.headAtoms(crnMBondBool), bonds.tailAtoms(crnMBondBool), bonds.bTypes(crnMBondBool), 'crn[m]');

methylClass = crnMClasses(cellfun(@(c) isequal(sort(c(:)'), [4 9 11]), crnMClasses));
assert(numel(methylClass) == 1, 'crn[m]''s three symmetric N-methyl carbons {4, 9, 11} must form exactly one equivalence class.');
assert(crnMRankMap(4) == 4 && crnMRankMap(9) == 4 && crnMRankMap(11) == 4, ...
    'All three N-methyl carbons must canonicalize to representative atom 4 (the lowest raw atom number).');
assert(isKey(crnMUnsafeMap, 4) && ismember(10, crnMUnsafeMap(4)), ...
    'The shared nitrogen (atom 10), bonded to all three N-methyl class members simultaneously, must be named unsafe for class {4, 9, 11}.');

ch2PairClass = crnMClasses(cellfun(@(c) isequal(sort(c(:)'), [12 13]), crnMClasses));
assert(numel(ch2PairClass) == 1, 'crn[m]''s diastereotopic CH2 hydrogen pair {12, 13} must form its own, independent equivalence class.');
assert(crnMRankMap(12) == crnMRankMap(13), 'The {12, 13} hydrogen pair must canonicalize to the same representative.');
% the two classes are independent -- neither absorbs the other's members
assert(crnMRankMap(12) ~= crnMRankMap(4), ...
    'The {12, 13} hydrogen-pair class and the {4, 9, 11} methyl-carbon class must remain independent (not merged).');

% ---------------------------------------------------------------------------------------
% (d) unsafe-neighbour precision (FR-002, the CoA H49/H52-anchor edge case): substitution
% must be blocked ONLY for the specific bond whose other endpoint is itself simultaneously
% bonded to more than one class member -- not for every bond of every class member. Reusing
% (a)'s gem-dimethyl class: atom 2 (the shared anchor) is correctly unsafe, but a bond from
% atom 1 to one of ITS OWN hydrogens (49, 50, or 51 -- each bonded to atom 1 alone, not to
% atom 3) is safe to canonicalize, i.e. only a SUBSET of the class's bonds are blocked, not
% a full-class rotation/swap.
% ---------------------------------------------------------------------------------------
assert(~ismember(50, coaMUnsafeMap(1)) && ~ismember(51, coaMUnsafeMap(1)), ...
    'Atoms 50 and 51 (each bonded only to atom 1) must not be flagged unsafe for class {1, 3}.');
assert(~ismember(52, coaMUnsafeMap(1)) && ~ismember(53, coaMUnsafeMap(1)) && ~ismember(54, coaMUnsafeMap(1)), ...
    'Atoms 52-54 (each bonded only to atom 3) must not be flagged unsafe for class {1, 3}.');

% ---------------------------------------------------------------------------------------
% Regression (feature 020, T011a): a metabolite requiring several colour-refinement rounds
% to converge must stay fast and memory-bounded, not balloon per round. A synthetic
% unbranched chain of 20 identical-element carbons (average degree ~2, needing several
% rounds for the refined colour to propagate from each chain end) is the pathological case
% that, pre-fix, made a node's colour string grow multiplicatively per round and OOM-killed
% MATLAB during implementation (two kernel OOM kills, anon-rss 17.9GB and 25.3GB observed
% 2026-08-18). Elapsed time is used as the practical bound here (the per-round compact-label
% mechanism itself is an internal implementation detail, not part of the function's public
% contract) -- a multiplicative-growth regression would make this take vastly longer, not
% merely somewhat longer.
% ---------------------------------------------------------------------------------------
n = 20;
chainElements = repmat({'C'}, n, 1);
t0 = tic;
[chainRankMap, chainClasses] = identifyAtomEquivalenceClasses(...
    (1:n)', chainElements, (1:n-1)', (2:n)', ones(n-1, 1), 'syntheticChain20[c]');
chainElapsed = toc(t0);
assert(chainElapsed < 10, ...
    sprintf('Colour refinement on a 20-atom chain took %.2fs -- expected a few hundred ms; possible regression of the per-round memory/growth fix.', chainElapsed));
% a plain (unbranched, non-cyclic) chain has no symmetry beyond a possible whole-chain
% mirror reflection, which colour refinement alone cannot break (no root anchor) -- so
% every class must have size <= 2 (a mirrored pair), never larger.
maxChainClassSize = max(cellfun(@numel, chainClasses));
assert(maxChainClassSize <= 2, ...
    sprintf('Max equivalence-class size %d on a plain chain exceeds 2 -- possible false collapsing.', maxChainClassSize));
assert(chainRankMap(1) == chainRankMap(n), ...
    'The two chain endpoints (mirror images of each other) must canonicalize to the same representative.');

% ---------------------------------------------------------------------------------------
% Fault injection (FR-011, spec SC- / feature 020 US2): a structurally malformed input (a
% bond referencing an atom number absent from atomNumbers) must not halt the run -- it
% must emit a visible warning naming the metabolite and return the identity canonical-rank
% map (every atom number maps to itself), i.e. feature 019's pre-existing plain
% atom-number-canonicalization behaviour, for that metabolite only.
% ---------------------------------------------------------------------------------------
lastwarn('');
[faultRankMap, faultClasses, faultUnsafeMap] = identifyAtomEquivalenceClasses(...
    [1; 2; 3], {'C'; 'C'; 'O'}, [1], [99], [1], 'malformedMet[c]'); %#ok<NBRAK>
[faultWarnMsg, ~] = lastwarn();
assert(~isempty(strfind(faultWarnMsg, 'malformedMet[c]')), ...
    'A structurally malformed input must emit a warning naming the affected metabolite.');
assert(faultRankMap(1) == 1 && faultRankMap(2) == 2 && faultRankMap(3) == 3, ...
    'On a malformed/inconclusive input, the fallback canonical-rank map must be the identity map (every atom number maps to itself).');
assert(isempty(faultUnsafeMap.keys()), ...
    'On a malformed/inconclusive input, the fallback unsafe-neighbours map must be empty (no equivalence classes detected).');
% execution continues past the warning (non-fatal) -- reaching this line proves it did not halt.

%% Other malformed inputs fall back in the same way, each naming the reason
% (input, reason) pairs: no atom, atoms without elements, bonds of different lengths
malformedInputs = { ...
    {zeros(0, 1), cell(0, 1), [], [], []}, 'No atoms provided'; ...
    {[1; 2], {'C'}, [], [], []}, 'atomNumbers and elements must be the same length'; ...
    {[1; 2], {'C'; 'C'}, 1, [2; 2], 1}, 'headAtoms, tailAtoms, and bTypes must be the same length'};
for k = 1:size(malformedInputs, 1)
    lastwarn('');
    [fallbackMap, fallbackClasses, fallbackUnsafe] = identifyAtomEquivalenceClasses(malformedInputs{k, 1}{:}, 'badInput[c]');
    assert(contains(lastwarn, malformedInputs{k, 2}) && contains(lastwarn, 'badInput[c]'), ...
        sprintf('The warning must name the metabolite and the reason: %s.', malformedInputs{k, 2}));
    atomList = malformedInputs{k, 1}{1};
    assert(fallbackMap.Count == numel(atomList) && numel(fallbackClasses) == numel(atomList) && ...
        fallbackUnsafe.Count == 0, 'Each atom must be alone in its class after the fallback.');
end

%% Atoms without bonds: equal elements are equivalent, and nothing is unsafe
lastwarn('');
[isolatedMap, isolatedClasses, isolatedUnsafe] = identifyAtomEquivalenceClasses( ...
    [1; 2; 3], {'C'; 'C'; 'O'}, zeros(0, 1), zeros(0, 1), zeros(0, 1), 'isolatedAtoms[c]');
assert(isempty(lastwarn), 'Atoms without bonds are a valid input.');
assert(isolatedMap(2) == 1 && isolatedMap(3) == 3, 'Only the two carbon atoms are equivalent.');
assert(isequal(isolatedClasses, {[1; 2]; 3}) && isequal(isolatedUnsafe(1), []), ...
    'The two classes hold the carbons and the oxygen, with no unsafe neighbour.');

%% A colour refinement false positive is caught by the automorphism check
% a hexagon and two triangles: every atom has two neighbours, so refinement gives one class,
% but no automorphism maps a hexagon atom to a triangle atom
hexagonAndTriangles = (1:12)';
ringHeads = (1:12)';
ringTails = [2 3 4 5 6 1 8 9 7 11 12 10]';
lastwarn('');
[ringMap, ringClasses, ringUnsafe] = identifyAtomEquivalenceClasses(hexagonAndTriangles, ...
    repmat({'C'}, 12, 1), ringHeads, ringTails, ones(12, 1), 'rings[c]');
assert(contains(lastwarn, 'failed the isisomorphic collision check') && contains(lastwarn, 'rings[c]'), ...
    'A false positive of the colour refinement must fall back with a warning.');
assert(numel(ringClasses) == 12 && ringMap(12) == 12 && ringUnsafe.Count == 0, ...
    'After the fallback each atom must be alone in its class.');

% return to the original directory
cd(currentDir);
