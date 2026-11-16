% The COBRAToolbox: testReactionChecks.m
%
% Purpose:
%     - ReactionChecks(rxn, metab, meta_compartment, newrxns, data) checks the new reactions
%       newrxns (rows: abbreviation, description, formula, ...) before rBioNet adds them to
%       the reaction database rxn: abbreviations must be given and distinct, every reaction
%       must be mass and charge balanced with the metabolites of metab (columns abbreviation,
%       description, neutral formula, charged formula, charge) in the compartments of
%       meta_compartment, and each new reaction is compared with the database. A new reaction
%       with the same metabolites as a database reaction (any compartment, any coefficient)
%       is listed in data as {abbreviation, database row, database row, ...}; one identical to
%       a database reaction (same metabolites, compartments, coefficients and reversibility)
%       is removed with a warning box. The output is {newrxns, data, 1}, or [] after an error
%       box. The test uses a hand-built database of glycolysis reactions; the expected
%       outputs follow from the documentation and from the formulae (balance checked by
%       hand in the comments). Message boxes are closed by the test.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the severity audit T009a raised the second and third defects below
%       (intended inputs that fail with an index error instead of the intended message box),
%       so this file makes no assertion about the function. The checks described above are
%       those of the wave 12 version of this test (git history), to be restored once the
%       defects are fixed.
%
% Function under test:
%     src/reconstruction/rBioNet/ReactionChecks.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built rBioNet reaction and metabolite tables.
%
% Coverage exemptions:
%     every line - ReactionChecks is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers, severity audit T009a). Before the quarantine the
%     test exempted the GUI branches: lines 59-60, 70-112 (an abbreviation already in the
%     database opens a modal question dialog, questdlg), 145-147, 187-217 (a metabolite not in
%     metab leads to the modal question dialog of line 196), 156, 174-181 (a charged formula
%     containing FULLRCO opens a modal question dialog), 161-168, 223-225 (an unbalanced
%     reaction opens the unbalanced window, which waits with uiwait for the user; line 162 is
%     moreover unreachable: balancecheck with output 1 never returns []); and lines 118-122 as
%     unreachable (second defect below).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The balance check prints ans = [] for every new reaction
%       SEVERITY: cosmetic
%       TRIGGER: any call that reaches the balance check, for example a balanced new reaction
%         {'GLCt', 'glucose transport', 'glc-D[e] <=> glc-D[c]', 1, 0} with glc-D in metab
%       OBSERVED: (R2025a, 2026-11-15) "ans =" and "[]" printed once per new reaction, because
%         the call showprogress(i/S_nrxns(1)) has no semicolon and showprogress returns []
%       EXPECTED: only the progress bar printed
%       LINES: 142
%     - DEFECT: The missing-formula message is never shown; an empty formula raises an index error
%       SEVERITY: error
%       TRIGGER: ReactionChecks(rxn, metab, compartments, {'NOF', 'no formula', '', 1, 0}, [])
%         with any reaction database rxn, metabolite table metab and compartment list, for
%         example those of the wave 12 version of this test
%       OBSERVED: (R2025a, 2026-11-15) error 'Index exceeds array bounds.' at line 144:
%         isempty(newrxns(i,3)) on line 117 tests a 1 x 1 cell, which is never empty, so the
%         box 'is missing the formula' is never opened and LoadReaction returns an empty
%         0 x 6 cell for the empty formula
%       EXPECTED: the box of line 118 and the output []; the branch of lines 117-122 (message
%         box "is missing the formula" and return) shows that an empty formula is an intended
%         input, which fails when used (severity audit T009a, borderline)
%       LINES: 117-122
%     - DEFECT: A metabolite without charged formula raises an error after BalancePrep's message
%       SEVERITY: error
%       TRIGGER: a metab row {'nochg', 'no charged formula', 'H', '', '0'} (metab also holding
%         {'h', 'Proton', 'H', 'H', '1'}) and
%         ReactionChecks(rxn, metab, compartments, {'NOC', 'x', 'nochg[c] -> h[c]', 1, 0}, [])
%       OBSERVED: (R2025a, 2026-11-15) BalancePrep opens the box 'Reaction cannot be created
%         with metabolites that are missing the charged formula.' and returns [], then
%         ReactionChecks fails with 'Brace indexing is not supported for variables of this
%         type.' at line 150
%       EXPECTED: the output [] after the box; BalancePrep returns [] after its message box by
%         design (header of ReactionChecks, line 22: "If we return, empty is a good choice"),
%         so a metabolite without charged formula is an intended input, which fails when used
%         (severity audit T009a, borderline)
%       LINES: 149-150
%     - DEFECT: A new reaction identical to a database reaction leaves an empty row in data
%       SEVERITY: cosmetic
%       TRIGGER: newrxns {'ENO2', 'x', '2pg[c] -> h2o[c] + pep[c]', 0, 0; 'ENO_DUP', 'x',
%         '2pg[c] <=> h2o[c] + pep[c]', 1, 0; 'GLCt', 'x', 'glc-D[e] <=> glc-D[c]', 1, 0;
%         'PGIe', 'x', 'g6p[c] <=> f6p[e]', 1, 0} with the database rows {'ENO', 'enolase',
%         '2pg[c] <=> h2o[c] + pep[c]', 1, 0} and {'PGI', 'glucose-6-phosphate isomerase',
%         'g6p[c] <=> f6p[c]', 1, 0}
%       OBSERVED: (R2025a, 2026-11-15) data = {'ENO2', ENO row; [], []; 'PGIe', PGI row}: the
%         rows of data follow the rows of the similarity list, and the row of the removed
%         reaction ENO_DUP stays empty when a later new reaction has similar reactions
%       EXPECTED: one row of data per remaining new reaction with similar reactions
%       LINES: 318-319
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Converted to the quarantine layout after the severity audit 2026-11-15 (T009a).

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReactionChecks'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
