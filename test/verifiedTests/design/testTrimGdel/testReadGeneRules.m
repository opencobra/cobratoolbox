% The COBRAToolbox: testReadGeneRules.m
%
% Purpose:
%     - readGeneRules parses the gene-protein-reaction rules (model.grRules) into Boolean
%       terms (and, or, equal) with internal terms term_<n> and one reactionKO_<i> term per
%       reaction with a rule, and returns the numbers of genes, internal terms, reactions and
%       repressible reactions. Quarantined: no behaviour of readGeneRules is asserted until
%       the defects below are fixed.
%
% Function under test:
%     src/design/TrimGdel/readGeneRules.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - gene rules of hand-built and distributed models, no solver.
%
% Coverage exemptions:
%     every line - readGeneRules is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A rule enclosed in parentheses stops with an error
%       SEVERITY: error
%       TRIGGER: readGeneRules(model) with model.rxns = {'r1'}, model.genes = {'g1'; 'g2'} and
%         model.grRules = {'(g1 or g2)'} (also '(g1)', a single gene whose name contains "or"
%         or "and" such as 'gor', and ecoli_core_model from getDistributedModel, many of whose
%         rules, e.g. "(b3925 or b4232)" of FBP, are enclosed in parentheses)
%       OBSERVED: error "Index exceeds the number of array elements. Index must not exceed 1."
%         at line 83: after the inner term is replaced, "(term_1)" (or "(g1)") is left, whose
%         single word has no operator unit(2)
%       EXPECTED: parentheses around a whole rule or a single gene accepted, as in the
%         grRules of the distributed models
%       LINES: 41-42, 75-89
%     - DEFECT: reactionKO2term points into the term list before it is reordered
%       SEVERITY: wrong-result
%       TRIGGER: model.rxns = {'r1';'r2';'r3';'r4';'r5'}, model.genes = {'g1';'g2';'g3';'g4'},
%         model.grRules = {'g1'; 'g1 and g2'; ''; '(g1 and g2) or g3'; 'g3 or g4'}
%       OBSERVED: reactionKO2term = [1 2 0 4 5] but the returned term lists term_2 first, so
%         term(1).output is 'term_2', not 'reactionKO_1', and term(2) is reactionKO_1; lines
%         103-115 reorder term (internal terms first) after lines 48 and 93 set the map
%       EXPECTED: term(reactionKO2term(i)).output equal to reactionKO_<i> for every reaction i
%         with a rule, as the help text documents
%       LINES: 48, 93, 103-115
%     - DEFECT: A model without any gene rule stops with an error
%       SEVERITY: error
%       TRIGGER: readGeneRules(model) with every model.grRules entry empty
%       OBSERVED: error "Unrecognized function or variable 'term2'." at line 115
%       EXPECTED: empty term and zero counts
%       LINES: 115
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReadGeneRules'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
