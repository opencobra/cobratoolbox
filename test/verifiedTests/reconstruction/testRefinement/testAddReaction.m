% The COBRAToolbox: testAddReaction.m
%
% Purpose:
%     - addReaction adds one reaction to a model, or changes a reaction whose ID is already
%       in the model, from a formula string or from a metabolite list with coefficients
%       (name/value pairs, or the deprecated positional signature): it sets the column of S,
%       the bounds, the objective coefficient, the name, the subsystem and the gene rule,
%       adds the metabolites and genes that are new, and optionally refuses a reaction whose
%       column of S is already in the model. The function is quarantined for the defects
%       below (the documented default coefficients stop the call; changing an existing
%       reaction erases its subsystem). This file only opens the test; it asserts nothing
%       about the function.
%
% Function under test:
%     src/reconstruction/refinement/addReaction.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation on a hand-built model (createModel); no solver.
%
% Coverage exemptions:
%     every line - addReaction is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A metaboliteList without stoichCoeffList stops instead of using coefficients -1
%       SEVERITY: error
%       TRIGGER: m = createModel({'R1','R2','R3'}, {'','',''}, {'a[c] -> b[c]', 'b[c] -> ',
%         'c[c] -> '}, 'grRuleList', {'g1','',''}, 'printLevel', 0); addReaction(m, 'N1',
%         'metaboliteList', {'a[c]','b[c]'})
%       OBSERVED: (R2025a, 2026-11-25) error "Index exceeds array bounds." at line 341: the
%         default of stoichCoeffList is [] (lines 173, 203) and line 341 indexes it for every
%         metabolite
%       EXPECTED: every coefficient -1, as the help of stoichCoeffList states ("if not
%         provided, all stoichiometries are assumed to be -1")
%       LINES: 173, 203, 341, 347
%     - DEFECT: Changing an existing reaction erases its subsystem
%       SEVERITY: wrong-result
%       TRIGGER: the model above; m.subSystems{1} = {'Glyc'}; r = addReaction(m, 'R1',
%         'lowerBound', -5) (also r = addReaction(m, 'R2', 'reactionFormula', 'b[c] -> 2 c[c]')
%         after m.subSystems{2} = {'Glyc'})
%       OBSERVED: (R2025a, 2026-11-25) r.subSystems{1} is {''} while the bound, the gene rule
%         and the metabolites of R1 are kept. When an existing reaction is changed, the
%         defaults are taken from the reaction (lines 178-196), but the subsystem default is
%         read from the legacy field subSystem (lines 183-185); a model with subSystems keeps
%         the default {''} (line 170), which line 307 writes over the reaction's subsystem
%       EXPECTED: an existing reaction keeps its subsystem unless subSystem is given, as it
%         keeps its bounds, objective coefficient, name, gene rule and metabolites
%       LINES: 170, 183-185, 306-307
%     - DEFECT: rxnIDexists holds the position of the identical reaction, not its ID
%       SEVERITY: cosmetic
%       TRIGGER: the model above; [r, ex] = addReaction(m, 'N1', 'reactionFormula',
%         'a[c] -> b[c]', 'checkDuplicate', true)
%       OBSERVED: (R2025a, 2026-11-25) ex = 1 (class double), the index of R1; the warning
%         "Model already has the same reaction you tried to add: R1" is raised and the model
%         is returned unchanged
%       EXPECTED: the ID of the identical reaction ('R1'), as the OUTPUTS help states, or a
%         help that describes the index
%       LINES: 68-70, 370-373
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddReaction'));
cd(fileDir);

% declare the requirements of this test. This test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
