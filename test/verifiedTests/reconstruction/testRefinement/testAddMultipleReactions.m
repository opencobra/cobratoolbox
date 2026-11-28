% The COBRAToolbox: testAddMultipleReactions.m
%
% Purpose:
%     - addMultipleReactions appends several reactions at once to a model whose metabolites
%       already exist: the columns of S come from metList and Stoichiometries, reaction fields
%       given as name/value pairs are appended (new defined fields are created), the other
%       reaction fields are extended with their defaults, and the gene rules are set from
%       grRules, from rules, or from rules with their own gene list. The function is
%       quarantined for the defects below (a rules input leaves the new reactions without
%       grRules and rxnGeneMat entries; reaction IDs already in the model are added a second
%       time). This file only opens the test; it asserts nothing about the function.
%
% Function under test:
%     src/reconstruction/refinement/addMultipleReactions.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation on a hand-built model (createModel); no solver.
%
% Coverage exemptions:
%     every line - addMultipleReactions is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A rules input leaves the grRules and rxnGeneMat entries of the new reactions empty
%       SEVERITY: wrong-result
%       TRIGGER: m = createModel({'R1','R2'}, {'',''}, {'a[c] -> b[c]', 'b[c] -> '},
%         'grRuleList', {'g1',''}, 'printLevel', 0); m2 = addMultipleReactions(m, {'N1','N2'},
%         {'a[c]','b[c]'}, [1 0; -1 1], 'rules', {'x(1)', ''}) (also with 'genes', {'g9';'g1'}
%         and rules {'x(1) | x(2)', ''})
%       OBSERVED: (R2025a, 2026-11-25) m2.rules = {'x(1)'; ''; 'x(1)'; ''} but
%         m2.grRules = {'g1'; ''; ''; ''} and full(m2.rxnGeneMat) = [1; 0; 0; 0]: the rule of N1
%         refers to g1 while its grRule is empty and its rxnGeneMat row marks no gene. Line 186
%         empties the new grRules and line 222 looks for new rules in model.rules, the input
%         model whose rules field was never extended, so the update of lines 224-244 is never
%         reached (line 228 would also read the genes of the input model)
%       EXPECTED: the grRules and rxnGeneMat rows of the new reactions agree with the given
%         rules, as the comment of line 220 states and as the grRules input gives
%       LINES: 186, 222-246
%     - DEFECT: Reaction IDs already in the model, or repeated in rxnIDs, are added a second time
%       SEVERITY: wrong-result
%       TRIGGER: the model above; m4 = addMultipleReactions(m, {'R1','N2'}, {'a[c]','b[c]'},
%         [1 0; -1 1]) and m5 = addMultipleReactions(m, {'N1','N1'}, {'a[c]','b[c]'}, [1 0; -1 1])
%       OBSERVED: (R2025a, 2026-11-25) m4 warns "The following reaction IDs are already IDs of
%         variables in the model: R1" and returns rxns {'R1','R2','R1','N2'}; m5 returns
%         {'R1','R2','N1','N1'} without a warning. Line 97 tests exist('varargin','var'), which
%         is always true in a function with varargin, so the recovery of lines 100-115 (drop
%         the existing IDs) is unreachable; the error for duplicate reaction IDs was replaced
%         by this warning in 2020 (commit 9fd8de21ea) and nothing checks repeats within rxnIDs,
%         whereas repeated metabolites raise an error (line 120)
%       EXPECTED: reaction IDs stay unique: existing IDs are rejected or skipped (the intent of
%         lines 100-115), repeated IDs in rxnIDs are rejected as repeated metabolites are
%       LINES: 94-117
%     - DEFECT: A rules input without genes stops on a model without a rules field
%       SEVERITY: error
%       TRIGGER: the model above; mm = rmfield(m, 'rules'); addMultipleReactions(mm,
%         {'N1','N2'}, {'a[c]','b[c]'}, [1 0; -1 1], 'rules', {'x(1)', ''})
%       OBSERVED: (R2025a, 2026-11-25) error "Unrecognized field name "rules"." at line 222:
%         lines 211-212 create the rules of newmodel, but line 222 reads model.rules
%       EXPECTED: the rules created at lines 211-212 are used and the reactions are added
%       LINES: 211-212, 222
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddMultipleReactions'));
cd(fileDir);

% declare the requirements of this test. This test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
