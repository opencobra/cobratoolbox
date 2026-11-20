% The COBRAToolbox: testRepresentativeMolecule.m
%
% Purpose:
%     - representativeMolecule(L, moietyFormulae, mets) computes the moiety masses with
%       getMolecularMass (monoisotopic), approximates each metabolite's mass as L' * moiety
%       masses and, for each moiety, returns the first metabolite of minimal approximate mass
%       among those that contain it, the number of metabolites sharing that mass and the ratio
%       moiety mass / minimal metabolite mass. Expected values are derived by hand from the
%       NIST monoisotopic masses of C, H and O (12, 1.00782503207, 15.99491461956); the test
%       covers ties, a fraction below 1, a sparse L and a moiety found in no metabolite (the
%       warning branch).
%
% Function under test:
%     src/analysis/topology/conservedMoieties/representativeMolecule.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built moiety matrix and formulae.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRepresentativeMolecule'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% NIST monoisotopic masses (relative atomic mass of the most abundant isotope)
massC = 12;
massH = 1.00782503207;
massO = 15.99491461956;
massCH4 = massC + 4 * massH;

% moiety 1 = CH4 in metabolites a, b, d; moiety 2 = O in metabolite b only
% approximate metabolite masses: a = d = CH4, b = CH4 + O, c = 0 (no moiety)
moietyMatrix = [1 1 0 1; 0 1 0 0];
moietyFormulae = {'CH4'; 'O'};
mets = {'a'; 'b'; 'c'; 'd'};

%% minimal-mass metabolite, ties and the mass fraction

[minimalMassMetabolite, minimalMassFraction, numMinimalMassMetabolites] = ...
    representativeMolecule(moietyMatrix, moietyFormulae, mets);
% a and d both have the minimal mass of moiety 1: the first one is returned, and two are
% counted; b is the only metabolite with moiety 2
assert(isequal(minimalMassMetabolite, {'a'; 'b'}));
assert(isequal(numMinimalMassMetabolites, [2; 1]));
% the fraction is a ratio of sums of a few atomic masses (about 16 and 32 Da); a difference
% of up to 1e-5 Da between the tabulated and the NIST masses moves it by less than 1e-6
expectedFraction = [1; massO / (massCH4 + massO)];
assert(all(abs(minimalMassFraction - expectedFraction) < 1e-6));
assert(isequal(size(minimalMassFraction), [2 1]));

%% a sparse moiety matrix gives the same result

[sparseMetabolite, sparseFraction, sparseNumber] = ...
    representativeMolecule(sparse(moietyMatrix), moietyFormulae, mets);
assert(isequal(sparseMetabolite, minimalMassMetabolite));
assert(isequal(sparseNumber, numMinimalMassMetabolites));
% same sums of the same masses: equal up to the order of floating-point additions
assert(all(abs(sparseFraction - minimalMassFraction) < 1e-12));

%% a moiety found in no metabolite: warning, outputs keep their defaults

% the minimum over an empty set is empty, which the function treats like an undefined (NaN)
% mass: it warns, naming the moiety, and leaves the metabolite empty and the counts at 0
lastwarn('');
[minimalMassMetabolite, minimalMassFraction, numMinimalMassMetabolites] = ...
    representativeMolecule([moietyMatrix; 0 0 0 0], [moietyFormulae; {'C'}], mets);
warningText = lastwarn;
assert(contains(warningText, 'moiety C'));
assert(isequal(minimalMassMetabolite(1:2), {'a'; 'b'}) && isempty(minimalMassMetabolite{3}));
assert(isequal(numMinimalMassMetabolites, [2; 1; 0]));
assert(minimalMassFraction(3) == 0 && all(abs(minimalMassFraction(1:2) - expectedFraction) < 1e-6));

% change the directory
cd(currentDir)
