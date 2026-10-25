% The COBRAToolbox: testGetRxnsFromGene.m
%
% Purpose:
%     - getRxnsFromGene lists the reactions whose gene rule contains a gene, taking alternative
%     splice forms (suffix after a dot) and the and/or structure of the rule into account.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/getRxnsFromGene.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetRxnsFromGene'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.rxns = {'r1'; 'r2'; 'r3'; 'r4'; 'r5'};
model.genes = {'g1'; 'g2'; 'g3'; 'g4'};
model.grRules = {'g1'; 'g1 and g2'; 'g1.1 or g1.2'; '(g2 and g3) or g4'; 'g3 or g3.2'};

%% a gene alone, in an and-rule and in an or-rule of splice forms

[rxns, grRules] = getRxnsFromGene(model, 'g1');
assert(isequal(rxns, {'r1'; 'r2'; 'r3'}));
assert(isequal(grRules, {'g1'; 'g1 and g2'; 'g1.1 or g1.2'}));

%% a gene that is the second member of an and-rule or part of a mixed rule

[rxns, grRules] = getRxnsFromGene(model, 'g2');
assert(isequal(rxns, {'r2'; 'r4'}));
assert(isequal(grRules, {'g1 and g2'; '(g2 and g3) or g4'}));

[rxns, ~] = getRxnsFromGene(model, 'g3');
assert(isequal(rxns, {'r4'; 'r5'}));

[rxns, ~] = getRxnsFromGene(model, 'g4');
assert(isequal(rxns, {'r4'}));

%% a splice form

[rxns, grRules] = getRxnsFromGene(model, 'g1.1');
assert(isequal(rxns, {'r3'}) && isequal(grRules, {'g1.1 or g1.2'}));

%% causal mode: all members of an or-rule must be splice forms of the gene

[rxns, ~] = getRxnsFromGene(model, 'g1', 1);
assert(isequal(rxns, {'r1'; 'r2'; 'r3'}));
% g3 appears with an unrelated gene in r4, so only r5 (g3 or g3.2) qualifies
[rxns, ~] = getRxnsFromGene(model, 'g3', 1);
assert(isequal(rxns, {'r5'}));

%% causal mode with and-rules: every part of the or-rule must contain the gene

alt.rxns = {'x'};
alt.genes = {'g1'; 'g2'};
alt.grRules = {'(g1 and g2) or (g1.2 and g2)'};
[rxns, ~] = getRxnsFromGene(alt, 'g2', 1);
assert(isequal(rxns, {'x'}));
[rxns, ~] = getRxnsFromGene(alt, 'g1');
assert(isequal(rxns, {'x'}));

%% a gene that does not occur

[rxns, grRules] = getRxnsFromGene(model, 'g9');
assert(isempty(rxns) && isempty(grRules));

% change the directory
cd(currentDir)
