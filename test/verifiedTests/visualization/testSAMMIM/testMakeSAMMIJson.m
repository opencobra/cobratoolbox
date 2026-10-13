% The COBRAToolbox: testMakeSAMMIJson.m
%
% Purpose:
%     - makeSAMMIJson converts a model into the JSON text used by the SAMMI viewer: one record per
%     metabolite, and one record per reaction with its fields and its stoichiometry.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/visualization/SAMMIM/makeSAMMIJson.m
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
fileDir = fileparts(which('testMakeSAMMIJson'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% three metabolites and two reactions, so that metabolite and reaction fields can be told apart by size
model.mets = {'a[c]'; 'b[c]'; 'c[c]'};
model.rxns = {'r1'; 'r2'};
model.S = [-1 0; 1 -2; 0 2];
model.metNames = {'A'; 'B'; 'C'};
model.lb = [0; -5];
model.ub = [10; 5];
model.metCharge = [0; -1; 1];
model.rev = [false; true];
model.rxnNames = {'R1'; 'R2'};
jsonText = makeSAMMIJson(model);

%% metabolites and reactions

assert(ischar(jsonText));
% metabolite records hold the fields with one entry per metabolite
assert(contains(jsonText, '{"id":"a[c]","metNames":"A","metCharge":0}'));
assert(contains(jsonText, '{"id":"c[c]","metNames":"C","metCharge":1}'));
% reaction records hold the fields with one entry per reaction and the stoichiometry
assert(contains(jsonText, '{"id":"r1","lb":0,"ub":10,"rev":0,"rxnNames":"R1","metabolites":{'));
assert(contains(jsonText, '"a[c]":-1'));
assert(contains(jsonText, '{"id":"r2","lb":-5,"ub":5,"rev":1,"rxnNames":"R2","metabolites":{'));

%% the text is valid JSON that can be decoded

jsonText = makeSAMMIJson(model);
decoded = jsondecode(jsonText);
assert(numel(decoded.metabolites) == 3 && numel(decoded.reactions) == 2);
assert(strcmp(decoded.metabolites(2).id, 'b[c]') && strcmp(decoded.metabolites(2).metNames, 'B'));
assert(decoded.reactions(2).ub == 5);
% the second reaction involves b[c] with -2 and c[c] with 2
stoichiometry = decoded.reactions(2).metabolites;
names = fieldnames(stoichiometry);
assert(isequal(sort(cellfun(@(n) stoichiometry.(n), names))', [-2 2]));

%% row vectors are accepted and quotation marks and line breaks are removed

rowModel = model;
rowModel.mets = rowModel.mets';
rowModel.rxns = rowModel.rxns';
rowModel.metNames = {'A "x"'; sprintf('B\nB'); 'C'};
jsonText = makeSAMMIJson(rowModel);
assert(contains(jsonText, '"metNames":"A x"') && contains(jsonText, '"metNames":"B B"'));

% change the directory
cd(currentDir)
