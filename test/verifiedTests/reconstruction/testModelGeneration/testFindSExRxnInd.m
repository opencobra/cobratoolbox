% The COBRAToolbox: testFindSExRxnInd.m
%
% Purpose:
%     - findSExRxnInd classifies the reactions of a model as internal (heuristically mass
%       balanced) or external (exchange, demand, sink, biomass) from identifier prefixes,
%       the number of stoichiometric coefficients, the objective or biomassRxnAbbr, HMR-style
%       subsystems and, for whole-body models, organ prefixes, and derives the corresponding
%       metabolite booleans. This test builds a 17-reaction model with one reaction of every
%       kind and checks every boolean against the classification worked out by hand, then the
%       biomass detection (objective, two objectives, biomassRxnAbbr with one, several or no
%       match), extra rows of S, the print levels, the whole-body organ prefixes and the
%       subsystem heuristic.
%     - Quarantined: the body asserts nothing about the function (the checks above describe
%       the test written before the quarantine, kept for the lead).
%
% Function under test:
%     src/reconstruction/modelGeneration/massBalance/findSExRxnInd.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model look-ups without a solver, hand-built models (createModel).
%
% Coverage exemptions:
%     every line - findSExRxnInd is quarantined for the wrong-result defect(s)
%     below (feature 20261113-142115-test-backfill-tiers).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: a mass-balanced reaction named DM_atp(c) is classified as an exchange
%       SEVERITY: wrong-result
%       TRIGGER: model = createModel({'R1'; 'DM_atp(c)'; 'EX_a'; 'DM_atp_c_'}, {'r1'; 'dm'; 'ex'; 'dm2'},
%                {'a -> b'; 'atp + h2o -> adp + pi'; 'a <=> '; 'atp2 + h2o -> adp2 + pi'});
%                out = findSExRxnInd(model)
%       OBSERVED: MATLAB R2025a: out.DMRxnBool(2) = 0 but out.SIntRxnBool(2) = 0, while
%                 out.SIntRxnBool(4) = 1 for the same reaction named DM_atp_c_. The variable
%                 bool used at line 198 to remove the ATP demand from the heuristic exchange
%                 set is the one computed for DM_atp_c_ at line 189, so DM_atp(c) (and ATPM)
%                 are only removed from DMRxnBool (lines 179, 187) and stay in
%                 SExRxnBoolHeuristic, computed at line 170 before the removal
%       EXPECTED: SIntRxnBool true for DM_atp(c), as for DM_atp_c_ and as the message of line
%                 184 announces ("not considered an exchange reaction by default")
%       LINES: 189, 198
%     - DEFECT: a model without c gets a c with one entry per metabolite
%       SEVERITY: wrong-result
%       TRIGGER: findSExRxnInd(rmfield(model, 'c')) with the model of defect 1 (S is 8 x 4)
%       OBSERVED: MATLAB R2025a: the returned model.c is 8 x 1 (zeros(nMet, 1), line 68)
%       EXPECTED: an n x 1 vector (4 x 1), as documented for .c ("created as zeros if absent")
%       LINES: 68
%     - DEFECT: the exchange prefix Ex_ is never recognised
%       SEVERITY: wrong-result
%       TRIGGER: model = createModel({'Ex_h'; 'R1'}, {'1'; '2'}, {'h <=> '; 'h -> g'});
%                out = findSExRxnInd(model)
%       OBSERVED: MATLAB R2025a: out.ExchRxnBool(1) = 0 (SIntRxnBool is still false through
%                 the one-coefficient heuristic); strncmp('Ex_', rxns, 5) at lines 159 and 162
%                 compares five characters of a three-character prefix and is always false
%       EXPECTED: ExchRxnBool true (documented: "Prefix EX_ or Exch_ or Ex_")
%       LINES: 159, 162
%     - DEFECT: the biomass reaction found from biomassRxnAbbr is printed at every printLevel
%       SEVERITY: cosmetic
%       TRIGGER: model.biomassRxnAbbr = 'Biomass_x'; findSExRxnInd(model, [], 0)
%       OBSERVED: MATLAB R2025a: "Found biomass reaction: Biomass_x" is printed at printLevel 0
%       EXPECTED: no output at printLevel 0, as for the other messages of the function
%       LINES: 98
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindSExRxnInd'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
