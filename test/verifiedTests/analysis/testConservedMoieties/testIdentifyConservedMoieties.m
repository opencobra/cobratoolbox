% The COBRAToolbox: testIdentifyConservedMoieties.m
%
% Purpose:
%     - identifyConservedMoieties(model, dATM, options) decomposes the stoichiometric matrix of
%       the atom-mapped part of a model into moiety transitions, from the connected components
%       of the atom transition graph grouped into isomorphism classes, and returns the
%       atomically resolved model arm (L, M2M, M2R, ATG, MTG, ...) and the moiety formulae.
%       The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): with its default options it stops when two atom transition instances
%       share one atom transition, and the moiety index of the atoms of a non-canonical
%       component depends on the order of its atoms; no assertion about the function is made.
%
% Function under test:
%     src/analysis/topology/conservedMoieties/identifyConservedMoieties.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - no solver; a test would hand-build a directed atom transition multigraph (a
%     digraph with the tables of buildAtomTransitionMultigraph) for a five-metabolite model.
%
% Coverage exemptions:
%     every line - identifyConservedMoieties is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: the default sanity checks stop when an atom transition has two instances
%       SEVERITY: error
%       TRIGGER: model with mets {A, B, C, D, E}, rxns {R1, R2, R3, R4}, S = [-1 1 0 0; 1 -1 0 0;
%         0 0 -1 0; 0 0 1 0; 0 0 0 -1]; dATM = digraph with atoms A#1#C, A#2#C, B#1#C, B#2#C,
%         C#1#O, D#1#O (AtomIndex 1-6) and edges R1: 1->3, 2->4, R2: 3->1, 4->2, R3: 5->6 (the
%         tables of buildAtomTransitionMultigraph); identifyConservedMoieties(model, dATM)
%       OBSERVED: "Error using strcmp / Too many input arguments." at line 442 (R2025a,
%         2026-11-16): dATM.Edges.HeadAtom{A2Ti(i,:)~=0} expands to two arguments when the
%         atom transition A#1#C-B#1#C has the instances of R1 and R2; the default is
%         sanityChecks = 1 (line 169) although the header documents (0); with sanityChecks = 0
%         the same call returns L = [1 1 0 0; 0 0 1 1] and the formulae {'C2', 'O'}
%       EXPECTED: the sanity check compares every instance of the atom transition and passes
%       LINES: 169, 442-446
%     - DEFECT: the moiety index of a non-canonical component follows its atom order
%       SEVERITY: wrong-result
%       TRIGGER: the model above without R2 (rxns {R1, R3, R4}) and a dATM whose atoms are
%         A#1#C, B#2#C, B#1#C, A#2#C, C#1#O, D#1#O with edges R1: 1->3, 4->2, R3: 5->6;
%         identifyConservedMoieties(model, dATM, struct('sanityChecks', 0))
%       OBSERVED: arm.ATG.Nodes.MoietyIndex = [1; 1; 2; 2; 3; 4] (R2025a, 2026-11-16): atom 2
%         (in B) gets moiety 1, which is the moiety of A, because lines 883-889 copy the moiety
%         indices of the first component position by position to the isomorphic component,
%         whose atoms are listed in the order B, A; with sanityChecks = 1 the call stops with
%         "Matrix mapping metabolites to moieties is incorrect" (line 961) after the warning
%         "single moiety incident in more than one metabolite"
%       EXPECTED: MoietyIndex = [1; 2; 2; 1; 3; 4] (each atom takes the moiety of the
%         metabolite it belongs to), as for the same network with the atoms in the order A, B
%       LINES: 883-890
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testIdentifyConservedMoieties'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so nothing is run;
% the call is the standard opening of a COBRA test
prepareTest();

% change the directory
cd(currentDir)
