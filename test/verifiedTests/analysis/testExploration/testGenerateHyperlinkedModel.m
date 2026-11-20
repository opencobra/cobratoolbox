% The COBRAToolbox: testGenerateHyperlinkedModel.m
%
% Purpose:
%     - generateHyperlinkedModel is documented to return a copy of a model whose gene-reaction
%       rules, metabolites, reactions and genes carry clickable MATLAB hyperlinks (fields
%       grRules, grRulesLinked, metsLinked, rxnsLinked, genesLinked). Quarantined: no behaviour
%       of generateHyperlinkedModel is asserted until the defects below are fixed; every call
%       stops before producing an output. The opening below still calls prepareTest() because
%       it is the standard opening of every COBRA test.
%
% Function under test:
%     src/analysis/exploration/generateHyperlinkedModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; a test would use a two-reaction model with rules,
%     genes, mets, rxns and metNames (the smallest model that reaches every branch).
%
% Coverage exemptions:
%     every line - generateHyperlinkedModel is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Every call stops at the undefined variable addGrRulesLinked
%       SEVERITY: error
%       TRIGGER: any call, for example generateHyperlinkedModel(model) with model =
%         getDistributedModel('ecoli_core_model.mat'), or with a two-reaction model with fields
%         rxns, mets, genes and rules (with or without metNameFlag and hyperlinkCommand, with
%         grRules instead of rules)
%       OBSERVED: MATLAB R2025a: "Unrecognized function or variable 'addGrRulesLinked'." at
%         line 57 for every one of these calls; which('addGrRulesLinked') is empty. The name is
%         defined only in generateGrRules (src/analysis/exploration/surfNetSubfunctions), from
%         which this function was derived, as ~isempty(hyperlinkCommand)
%       EXPECTED: the model with the fields grRules, grRulesLinked, metsLinked, rxnsLinked and
%         genesLinked listed under OUTPUT
%       LINES: 57, 72
%     - DEFECT: The hyperlink format string is read from the undefined variable command
%       SEVERITY: error
%       TRIGGER: any call that passes line 57 (none can while the first defect stands)
%       OBSERVED: lines 92, 95, 98 and 100 use command, which the function never assigns and
%         which is not on the path (MATLAB R2025a after initCobraToolbox: which('command') is
%         empty, exist('command') is 0); the documented input hyperlinkCommand is used only at
%         line 73. Not observed at run time because every call stops at line 57
%       EXPECTED: the hyperlinks built with the documented hyperlinkCommand format string
%       LINES: 92, 95, 98, 100
%     - DEFECT: A model without rules and without grRules stops at a reference to the missing field rules
%       SEVERITY: error
%       TRIGGER: generateHyperlinkedModel(model) with a model that has rxns, mets and genes but
%         neither rules nor grRules
%       OBSERVED: MATLAB R2025a: "Unrecognized field name "rules"." at line 48, where
%         numel(model.rules) sizes the empty rules from the very field that was just found
%         missing
%       EXPECTED: one empty rule per reaction (numel(model.rxns), as generateGrRules line 36
%         does), then the hyperlinked fields
%       LINES: 48
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGenerateHyperlinkedModel'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
