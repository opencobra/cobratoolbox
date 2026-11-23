% The COBRAToolbox: testFindSExRxnInd.m
%
% Purpose:
%     - findSExRxnInd classifies the reactions of a model as internal (heuristically mass
%       balanced) or external (exchange, demand, sink, biomass) from identifier prefixes,
%       the number of stoichiometric coefficients, the objective or biomassRxnAbbr, HMR-style
%       subsystems and, for whole-body models, organ prefixes, and derives the corresponding
%       metabolite booleans. This test builds a 19-reaction model with one reaction of every
%       kind (every exchange prefix, and the three names of the ATP demand, which is mass
%       balanced and so internal) and checks every boolean against the classification worked
%       out by hand, then the biomass detection (objective, two objectives, no objective, no
%       field c, biomassRxnAbbr with one, several or no match), what is printed at printLevel 0
%       and 1, extra rows of S, the whole-body organ prefixes and the subsystem heuristic.
%
% Function under test:
%     src/reconstruction/modelGeneration/massBalance/findSExRxnInd.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model look-ups without a solver, hand-built models (createModel).
%
% Coverage exemptions:
%     Line 65: unreachable, printLevel is the third input, so when it is given nRealMet is
%         given too and line 61 takes the else branch.
%     Line 282: unreachable, the condition of line 281 compares an expression with itself.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found. (The four defects recorded on 2026-11-16, DM_atp(c) classified as an
%     exchange, a missing c created with one entry per metabolite, the prefix Ex_ never
%     recognised, and the biomass reaction printed at printLevel 0, were fixed by feature
%     20261120-161825-core-blocker-fixes and are tested below.)
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.
%     - Full test after the fix (feature 20261120-161825-core-blocker-fixes), 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindSExRxnInd'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% 19 reactions: an exchange with every prefix (EX_, Exch_, Ex_), two internal conversions, a
% demand, three sinks (all three spellings), ATP maintenance and the ATP demand under both of
% its names (mass balanced), a biomass reaction (objective, two coefficients), five
% single-coefficient reactions without prefix (one with a positive coefficient) and one
% reaction without any coefficient
rxns = {'EX_a'; 'R1'; 'R2'; 'DM_c'; 'sink_d'; 'Sink_e'; 'SINK_f'; 'Exch_g'; 'Ex_hx'; 'ATPM'; ...
    'DM_atp_c_'; 'DM_atp(c)'; 'Biomass_x'; 'R_single'; 'R_o2'; 'R_o3'; 'R_o4'; 'R_pos'; 'R_none'};
formulas = {'a <=> '; 'a -> b'; 'b -> c'; 'c -> '; 'd <=> '; 'e <=> '; 'f <=> '; 'g <=> '; ...
    'hx <=> '; 'atp + h2o -> adp + pi + h'; 'atp2 + h2o -> adp2 + pi'; 'atp3 + h2o -> adp3 + pi'; ...
    'a + b -> '; 'd -> '; 'm5 -> '; 'm10 -> '; 'm13 -> '; ' -> q'; 'q -> '};
model = createModel(rxns, rxns, formulas);
% metabolite names of 1, 5, 10 and 13 characters (the print of missed exchanges formats by
% name length); the compartment suffix of createModel is removed from these four
model.mets(strcmp(model.mets, 'd[c]')) = {'d'};
model.mets(strcmp(model.mets, 'm5[c]')) = {'abcde'};
model.mets(strcmp(model.mets, 'm10[c]')) = {'abcdefghij'};
model.mets(strcmp(model.mets, 'm13[c]')) = {'abcdefghijklm'};
% R_none keeps no coefficient at all
model.S(:, strcmp(model.rxns, 'R_none')) = 0;
model.c = double(strcmp(model.rxns, 'Biomass_x'));
nRxns = numel(model.rxns);
nMets = numel(model.mets);

% the classification worked out by hand
isRxn = @(names) ismember(model.rxns, names);
isMet = @(names) ismember(model.mets, names);
expectedExch = isRxn({'EX_a', 'Exch_g', 'Ex_hx', 'Biomass_x'});
expectedDM = isRxn({'DM_c'});
expectedSink = isRxn({'sink_d', 'Sink_e', 'SINK_f'});
expectedInt = isRxn({'R1', 'R2', 'ATPM', 'DM_atp_c_', 'DM_atp(c)'});
% metabolites of internal reactions, of internal reactions only, of external reactions, of
% external reactions only (q appears only in R_pos)
atpMets = {'atp[c]', 'h2o[c]', 'adp[c]', 'pi[c]', 'h[c]', 'atp2[c]', 'adp2[c]', 'atp3[c]', 'adp3[c]'};
expectedIntMet = isMet([{'a[c]', 'b[c]', 'c[c]'}, atpMets]);
expectedOnlyIntMet = isMet(atpMets);
expectedExMet = isMet({'a[c]', 'b[c]', 'c[c]', 'd', 'e[c]', 'f[c]', 'g[c]', 'hx[c]', 'abcde', ...
    'abcdefghij', 'abcdefghijklm', 'q[c]'});
expectedOnlyExMet = isMet({'d', 'e[c]', 'f[c]', 'g[c]', 'hx[c]', 'abcde', 'abcdefghij', ...
    'abcdefghijklm', 'q[c]'});

% printed output is read from a diary file in a temporary folder
diaryFolder = tempname;
mkdir(diaryFolder);
diaryFile = fullfile(diaryFolder, 'findSExRxnInd.txt');

%% default call: every boolean, the biomass reaction taken from the objective

out = findSExRxnInd(model);
assert(strcmp(out.biomassRxnAbbr, 'Biomass_x') && isequal(out.biomassBool, isRxn({'Biomass_x'})));
assert(isequal(out.ExchRxnBool, expectedExch) && isequal(out.DMRxnBool, expectedDM));
assert(isequal(out.SinkRxnBool, expectedSink) && isequal(out.SIntRxnBool, expectedInt));
assert(isequal(out.SIntMetBool, expectedIntMet) && isequal(out.SOnlyIntMetBool, expectedOnlyIntMet));
assert(isequal(out.SExMetBool, expectedExMet) && isequal(out.SOnlyExMetBool, expectedOnlyExMet));
% sizes and mutual agreement: n x 1 and m x 1 logicals, the exclusive sets inside the
% inclusive ones, every metabolite of a reaction accounted for, the model otherwise unchanged
assert(isequal(size(out.SIntRxnBool), [nRxns 1]) && isequal(size(out.SIntMetBool), [nMets 1]));
assert(all(out.SOnlyIntMetBool <= out.SIntMetBool) && all(out.SOnlyExMetBool <= out.SExMetBool));
assert(isequal(out.SIntMetBool | out.SExMetBool, any(model.S ~= 0, 2)));
assert(isequal(out.S, model.S) && isequal(out.c, model.c) && isequal(out.rxns, model.rxns));

%% the ATP demand is internal under each of its names, also with a single other ATP name

for atpName = {'ATPM', 'DM_atp_c_', 'DM_atp(c)'}
    atpModel = createModel({'R1'; atpName{1}; 'EX_a'}, {'r1'; 'atp'; 'ex'}, ...
        {'a -> b'; 'atp + h2o -> adp + pi'; 'a <=> '});
    out = findSExRxnInd(atpModel);
    assert(isequal(out.SIntRxnBool, [true; true; false]) && isequal(out.DMRxnBool, false(3, 1)));
end

%% a model without the field c: c is created as n zeros, and the name Biomass_x is recognised

out = findSExRxnInd(rmfield(model, 'c'));
assert(isequal(out.c, zeros(nRxns, 1)) && ~isfield(out, 'biomassRxnAbbr'));
assert(isequal(out.biomassBool, isRxn({'Biomass_x'})) && isequal(out.SIntRxnBool, expectedInt));

%% printLevel 0 prints nothing, also when the biomass reaction is found from biomassRxnAbbr;
%% printLevel 1 prints the messages

modelAbbr = model;
modelAbbr.biomassRxnAbbr = 'Biomass_x';
diary(diaryFile);
findSExRxnInd(model);
findSExRxnInd(modelAbbr, [], 0);
diary('off');
printed = '';
if exist(diaryFile, 'file')
    printed = fileread(diaryFile);
    delete(diaryFile);
end
assert(isempty(strtrim(printed)));
diary(diaryFile);
out = findSExRxnInd(modelAbbr, [], 1);
diary('off');
printed = fileread(diaryFile);
delete(diaryFile);
assert(contains(printed, 'Found biomass reaction: Biomass_x'));
assert(contains(printed, 'ATP demand reaction is not considered an exchange reaction by default'));
assert(isequal(out.SIntRxnBool, expectedInt));

%% printLevel 1 with an empty nRealMet: the same classification, with the messages printed

out = findSExRxnInd(model, [], 1);
assert(isequal(out.SIntRxnBool, expectedInt) && isequal(out.DMRxnBool, expectedDM));
assert(isequal(out.SOnlyExMetBool, expectedOnlyExMet));

%% extra rows of S without metabolites: detected (printLevel 1) or given as nRealMet

modelExtra = model;
modelExtra.S = [model.S; sparse(2, nRxns)];
out = findSExRxnInd(modelExtra, [], 1);
assert(isequal(out.SIntRxnBool, expectedInt) && isequal(out.ExchRxnBool, expectedExch));
% the two extra rows belong to no reaction
assert(isequal(out.SIntMetBool, [expectedIntMet; false; false]));
assert(isequal(out.SExMetBool, [expectedExMet; false; false]));
% without nRealMet the extra rows are detected silently; without subSystems only the prefixes
% and the biomass reaction mark exchanges (same classification here)
out = findSExRxnInd(rmfield(modelExtra, 'subSystems'));
assert(isequal(out.SIntRxnBool, expectedInt) && isequal(out.ExchRxnBool, expectedExch));
assert(isequal(out.SIntMetBool, [expectedIntMet; false; false]));
out = findSExRxnInd(modelExtra, nMets, 0);
assert(isequal(out.SIntRxnBool, expectedInt) && isequal(out.SOnlyIntMetBool, [expectedOnlyIntMet; false; false]));

%% the objective: two non-zero coefficients give a warning, none gives a message; the name
%% Biomass_x is recognised in both cases

modelTwo = model;
modelTwo.c(strcmp(model.rxns, 'R1')) = 1;
lastwarn('');
out = findSExRxnInd(modelTwo);
assert(strcmp(lastwarn, 'More than one biomass reaction?'));
assert(~isfield(out, 'biomassRxnAbbr') && isequal(out.biomassBool, isRxn({'Biomass_x'})));
assert(isequal(out.SIntRxnBool, expectedInt));
modelNoObj = model;
modelNoObj.c(:) = 0;
out = findSExRxnInd(modelNoObj, [], 1);
assert(~isfield(out, 'biomassRxnAbbr') && isequal(out.biomassBool, isRxn({'Biomass_x'})));
assert(isequal(out.SIntRxnBool, expectedInt));

%% biomassRxnAbbr given: one match, several matches (every reaction containing it counts as
%% biomass, hence as external), no match

out = findSExRxnInd(modelAbbr, [], 0);
assert(isequal(out.biomassBool, isRxn({'Biomass_x'})) && isequal(out.SIntRxnBool, expectedInt));
modelAbbr.biomassRxnAbbr = 'R';
for printLevel = [0 1]
    out = findSExRxnInd(modelAbbr, [], printLevel);
    assert(isequal(out.biomassBool, contains(model.rxns, 'R') | isRxn({'Biomass_x'})));
    assert(isequal(out.SIntRxnBool, isRxn({'ATPM', 'DM_atp_c_', 'DM_atp(c)'})));
end
modelAbbr.biomassRxnAbbr = 'zz';
for printLevel = [0 1]
    out = findSExRxnInd(modelAbbr, [], printLevel);
    assert(isequal(out.biomassBool, isRxn({'Biomass_x'})) && isequal(out.SIntRxnBool, expectedInt));
end

%% printLevel 3 reports the sign of every single coefficient

out = findSExRxnInd(model, [], 3);
assert(isequal(out.SIntRxnBool, expectedInt));

%% whole-body models: organ prefixes are removed before the prefix heuristics (both sexes)

wbm = createModel({'Liver_EX_a'; 'Muscle_R1'; 'Brain_DM_atp_c_'; 'Excretion_EX_b'; 'Diet_EX_c'; ...
    'Kidney_sink_d'; 'BBB_R2'; 'Liver_Ex_e'; 'Muscle_DM_atp(c)'}, {'1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'; '9'}, ...
    {'a <=> '; 'a -> b'; 'atp + h2o -> adp + pi'; 'b <=> '; 'c <=> '; 'd <=> '; 'b -> c'; 'e + b -> '; ...
    'atp + h2o -> adp + pi'});
for sex = {'male', 'female'}
    wbm.sex = sex{1};
    out = findSExRxnInd(wbm);
    assert(isequal(out.ExchRxnBool, logical([1 0 0 1 1 0 0 1 0]')));
    assert(isequal(out.DMRxnBool, false(9, 1)) && isequal(out.SinkRxnBool, logical([0 0 0 0 0 1 0 0 0]')));
    assert(isequal(out.SIntRxnBool, logical([0 1 1 0 0 0 1 0 1]')));
end

%% HMR-style subsystems and the reaction compartment x mark exchanges; the ATP demand stays
%% internal whatever its subsystem

modelSub = model;
modelSub.subSystems = repmat({{'Metabolism'}}, nRxns, 1);
modelSub.subSystems{strcmp(model.rxns, 'R1')} = {'Artificial reactions'};
modelSub.subSystems{strcmp(model.rxns, 'DM_atp_c_')} = 'Pool reactions';
modelSub.subSystems{strcmp(model.rxns, 'DM_atp(c)')} = 'Pool reactions';
modelSub.subSystems{strcmp(model.rxns, 'ATPM')} = {'Exchange reactions'};
out = findSExRxnInd(modelSub);
assert(isequal(out.ExchRxnBool, expectedExch | isRxn({'R1', 'DM_atp_c_', 'DM_atp(c)', 'ATPM'})));
assert(isequal(out.SIntRxnBool, isRxn({'R2', 'ATPM', 'DM_atp_c_', 'DM_atp(c)'})));
modelSub.rxnComps = repmat({'c'}, nRxns, 1);
modelSub.rxnComps{strcmp(model.rxns, 'R2')} = 'x';
out = findSExRxnInd(modelSub);
assert(isequal(out.ExchRxnBool, expectedExch | isRxn({'R1', 'R2', 'DM_atp_c_', 'DM_atp(c)', 'ATPM'})));
assert(isequal(out.SIntRxnBool, isRxn({'ATPM', 'DM_atp_c_', 'DM_atp(c)'})));

% remove the temporary folder
rmdir(diaryFolder, 's');

% change the directory
cd(currentDir)
