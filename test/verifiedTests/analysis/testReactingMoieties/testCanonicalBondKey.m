% The COBRAToolbox: testCanonicalBondKey.m
%
% Purpose:
%     - Test that canonicalBondKey produces an order-independent, collision-free
%       identity string for a bond's two (metabolite, atomNumber, element) atoms,
%       regardless of which atom is supplied first, so the same physical bond
%       always collapses onto the same dBTM.Nodes row (feature 019-canonicalize-bond-node-keys).
%
% Authors:
%     - COBRA Toolbox, feature 019-canonicalize-bond-node-keys

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% (a) same physical bond supplied in both atom orders produces an identical key
[keyForward, m1f, n1f, e1f, m2f, n2f, e2f] = canonicalBondKey('crn[c]', 7, 'C', 'crn[c]', 2, 'O');
[keyReverse, m1r, n1r, e1r, m2r, n2r, e2r] = canonicalBondKey('crn[c]', 2, 'O', 'crn[c]', 7, 'C');
assert(strcmp(keyForward, keyReverse), 'canonicalBondKey must be order-independent for the same physical bond.');
assert(isequal(m1f, m1r) && isequal(n1f, n1r) && isequal(e1f, e1r), 'canonicalBondKey must return the same canonically-first atom regardless of input order.');
assert(isequal(m2f, m2r) && isequal(n2f, n2r) && isequal(e2f, e2r), 'canonicalBondKey must return the same canonically-second atom regardless of input order.');
% lower atom number sorts first within one metabolite
assert(n1f == 2 && strcmp(e1f, 'O'), 'canonicalBondKey must order atoms of the same metabolite by ascending atom number.');
assert(n2f == 7 && strcmp(e2f, 'C'), 'canonicalBondKey must order atoms of the same metabolite by ascending atom number.');

% (b) two distinct bonds of one metabolite (sharing an atom) produce distinct keys
keyC1C7 = canonicalBondKey('crn[c]', 1, 'C', 'crn[c]', 7, 'C');
keyC1N10 = canonicalBondKey('crn[c]', 1, 'C', 'crn[c]', 10, 'N');
assert(~strcmp(keyC1C7, keyC1N10), 'canonicalBondKey must not collide two genuinely distinct bonds sharing an atom.');

% two distinct bonds with no shared atom must also remain distinct
keyC2O3 = canonicalBondKey('crn[c]', 2, 'C', 'crn[c]', 3, 'O');
keyC4O5 = canonicalBondKey('crn[c]', 4, 'C', 'crn[c]', 5, 'O');
assert(~strcmp(keyC2O3, keyC4O5), 'canonicalBondKey must not collide two bonds of the same metabolite with different atom numbers.');

% (c) a bond between a real atom and a reaction's energy node (AtomNumber hardcoded to 1)
% canonicalises correctly via metabolite identity, not atom number, even when the real
% atom also happens to be numbered 1
[keyEnergyForward, em1f, en1f, ee1f, em2f, en2f, ee2f] = canonicalBondKey('crn[c]', 1, 'C', 'HMR_2634', 1, 'E');
[keyEnergyReverse, em1r, en1r, ee1r, em2r, en2r, ee2r] = canonicalBondKey('HMR_2634', 1, 'E', 'crn[c]', 1, 'C');
assert(strcmp(keyEnergyForward, keyEnergyReverse), 'canonicalBondKey must be order-independent for a bond to the reaction energy node even when atom numbers collide.');
assert(isequal(em1f, em1r) && isequal(en1f, en1r) && isequal(ee1f, ee1r), 'canonicalBondKey must resolve the energy-node case identically regardless of input order.');
% metabolite identity (not atom number) breaks the tie: 'HMR_2634' < 'crn[c]' lexicographically
assert(strcmp(em1f, 'HMR_2634') && strcmp(ee1f, 'E'), 'canonicalBondKey must order a cross-metabolite bond by metabolite identity when atom numbers coincide.');

% return to the original directory
cd(currentDir);
