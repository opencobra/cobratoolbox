% The COBRAToolbox: testConstrainModelOnMedium.m
%
% Purpose:
%     - constrainModelOnMedium(model, mediumMets, notMediumConstrained, biomassReaction,
%       functionToKeep) closes the uptake of the organic exchange reactions found by
%       findOrganicExRxns (lb = 0 for an exchange written "met ->", ub = 0 for one written
%       "-> met"), then gives back their original bounds to the reactions listed in
%       notMediumConstrained and to the exchange reactions of the medium metabolites. The
%       biomass reaction, the reactions of functionToKeep and inorganic exchanges keep their
%       bounds. The test checks every bound on a hand-built model, where the expected bounds
%       follow from these rules, with and without reactions to keep unconstrained and with a
%       medium that has no exchange reaction.
%
% Function under test:
%     src/dataIntegration/transcriptomics/rFASTCORMICS/constrainModelOnMedium.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs (the ledger lists Tier 3;
%     the function changes bounds only and calls no solver).
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConstrainModelOnMedium'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% Model: 7 single-metabolite reactions and one internal reaction
%   EX_glc  glc <=>       organic, medium metabolite          -> keeps its bounds
%   EX_lac  lac <=>       organic, written "met ->"           -> lb set to 0
%   EX_ac   -> ac         organic, written "-> met"           -> ub set to 0
%   EX_o2   o2 <=>        inorganic                           -> keeps its bounds
%   EX_pyr  pyr <=>       organic, in notMediumConstrained    -> keeps its bounds
%   bio     a ->          biomass reaction                    -> keeps its bounds
%   EX_cit  cit <=>       organic, in functionToKeep          -> keeps its bounds
%   R       glc + lac + ac + o2 + pyr + cit -> a (internal)   -> keeps its bounds
model.rxns = {'EX_glc'; 'EX_lac'; 'EX_ac'; 'EX_o2'; 'EX_pyr'; 'bio'; 'EX_cit'; 'R'};
model.mets = {'glc'; 'lac'; 'ac'; 'o2'; 'pyr'; 'a'; 'cit'};
model.metFormulas = {'C6H12O6'; 'C3H5O3'; 'C2H3O2'; 'O2'; 'C3H3O3'; 'C'; 'C6H5O7'};
model.S = sparse([-1  0  0  0  0  0  0 -1; ...
                   0 -1  0  0  0  0  0 -1; ...
                   0  0  1  0  0  0  0 -1; ...
                   0  0  0 -1  0  0  0 -1; ...
                   0  0  0  0 -1  0  0 -1; ...
                   0  0  0  0  0 -1  0  1; ...
                   0  0  0  0  0  0 -1 -1]);
model.lb = [-10; -10; -5; -20; -5; -3; -7; -1000];
model.ub = [1000; 1000; 10; 1000; 1000; 1000; 1000; 1000];

%% reactions kept unconstrained and a medium metabolite with an exchange reaction
% only EX_lac (lb) and EX_ac (ub) are closed; every other bound is the original one
constrained = constrainModelOnMedium(model, {'glc'}, {'EX_pyr'}, 'bio', {'EX_cit'});
expectedLb = model.lb;
expectedLb(2) = 0;
expectedUb = model.ub;
expectedUb(3) = 0;
assert(isequal(constrained.lb, expectedLb));
assert(isequal(constrained.ub, expectedUb));
% the stoichiometry is not changed (findOrganicExRxns changes only its own copy of S)
assert(isequal(constrained.S, model.S));
assert(isequal(constrained.rxns, model.rxns));

%% no reaction kept unconstrained: the organic exchange EX_pyr is closed too
constrained = constrainModelOnMedium(model, {'glc'}, {}, 'bio', {'EX_cit'});
expectedLb(5) = 0;
assert(isequal(constrained.lb, expectedLb));
assert(isequal(constrained.ub, expectedUb));

%% a medium without exchange reaction: the medium metabolite glc is not reopened
% the medium metabolite a occurs only in bio and R, which are not candidate exchanges
constrained = constrainModelOnMedium(model, {'a'}, {}, 'bio', {'EX_cit'});
expectedLb(1) = 0;
assert(isequal(constrained.lb, expectedLb));
assert(isequal(constrained.ub, expectedUb));

%% an inorganic medium metabolite and no reaction to keep: EX_cit is closed as well
% EX_o2 is restored to its own (unchanged) bounds; EX_cit is now a candidate organic exchange
constrained = constrainModelOnMedium(model, {'o2'}, {}, 'bio', {});
expectedLb(7) = 0;
assert(isequal(constrained.lb, expectedLb));
assert(isequal(constrained.ub, expectedUb));

% change the directory
cd(currentDir)
