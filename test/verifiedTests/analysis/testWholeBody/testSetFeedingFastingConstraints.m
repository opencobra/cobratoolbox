% The COBRAToolbox: testSetFeedingFastingConstraints.m
%
% Purpose:
%     - setFeedingFastingConstraints sets the bounds of a whole-body model for feeding or fasting:
%       it removes rxnGeneMat, sets the lower bound of every sink reaction not starting with
%       sink_ (organ sinks, except three listed ones and microbe sinks flagged in Microbiota) to
%       0, every reaction containing DM_ to lower bound 0 and every reaction starting with sink_
%       to lower bound -10, rewrites [c] and [r] as (c) and (r) in sink identifiers, opens
%       (feeding) or closes (fasting) the Diet_EX_/Diet_Ex_ exchanges and sets the organ storage
%       reactions to store (feeding: [0, storageValue]) or to release (fasting:
%       [fastingValue, 0]). It records the status in SetupInfo.FeedingStatus.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Models: whole-body models are not distributed. The function reads only the reaction
%       identifiers, the bounds and the optional Microbiota and rxnGeneMat fields, so it is run on
%       Recon3DModel_301 (from which the whole-body organs are built), whose 96 sink_ reactions
%       it changes (its 152 DM_ reactions already have lower bound 0). To reach the organ storage
%       and diet branches, a whole-body-style model is derived from Recon3DModel_301 by adding,
%       with addMultipleReactions, one sink reaction per organ storage list and each single
%       storage reaction, named as in the whole-body models (for example Liver_sink_nad(c) on
%       nad[c]), two diet exchanges, an organ sink that is not a storage reaction, an organ sink
%       of the exception list, a microbe sink and an organ demand reaction, all with bounds
%       [-1000, 1000]. The metabolites are existing Recon3DModel_301 metabolites (the diet
%       exchanges use the [e] metabolite, as Recon3D has no [d] compartment); the function does
%       not read them.
%     - Reference values: the counts of renamed reactions asserted below were recorded from the
%       first run on 2026-11-03 with Recon3DModel_301 (no solver). They were not derived
%       independently, so they guard consistency, not independent correctness (Tier 5). The
%       expected identifiers and bounds are also derived independently from the input model.
%     - The function calls changeRxnBounds for every storage reaction name; on a model without
%       that reaction changeRxnBounds warns (twice per call) that it is not in the model. These
%       warnings, and the storageAA list printed by the AAStorage script (defect below), are
%       not suppressed.
%     - Measuring: the MATLAB R2025a coverage collector reports the function as an invalid file and
%       gives no line data, because it calls the script AAStorage. On 2026-11-04 the coverage was
%       measured on a scratch copy with the script call replaced by its list, on the same line:
%       129 of 129 executable lines.
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/setConstraints/setFeedingFastingConstraints.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; Recon3DModel_301 loaded through
%     getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The list of storable amino acids is printed on every call
%       SEVERITY: cosmetic
%       TRIGGER: any call, for example setFeedingFastingConstraints(model, 'feeding')
%       OBSERVED: the script AAStorage, run at line 52, ends its storageAA assignment (AAStorage.m
%         line 23) without a semicolon, so the 20 x 1 cell array storageAA is displayed
%       EXPECTED: no output
%       LINES: 52
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSetFeedingFastingConstraints'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the model once (10600 reactions, 5835 metabolites; 96 reactions start with sink_, and the
% 152 DM_ reactions all start with DM_ and have lower bound 0)
model = getDistributedModel('Recon3DModel_301.mat');

% the whole-body-style model: Recon3DModel_301 with organ storage, diet, organ, microbe and
% demand reactions named as in the whole-body models (see the header)
storageRxns = {'Liver_sink_nad(c)'; 'Kidney_sink_ascb_L(c)'; 'Muscle_sink_thmpp(c)'; ...
               'Muscle_sink_his_L(c)'; 'Adipocytes_sink_tag_hs(c)'; 'Retina_sink_crvnc(c)'; ...
               'Heart_sink_chol(c)'; 'Brain_sink_crvnc(c)'; 'Brain_sink_chol(c)'; ...
               'RBC_sink_glygn2(c)'; 'Skin_sink_vitd3(c)'};
storageMets = {'nad[c]'; 'ascb_L[c]'; 'thmpp[c]'; 'his_L[c]'; 'tag_hs[c]'; 'crvnc[c]'; ...
               'chol[c]'; 'crvnc[c]'; 'chol[c]'; 'glygn2[c]'; 'vitd3[c]'};
dietRxns = {'Diet_EX_glc_D[d]'; 'Diet_Ex_o2[d]'};
organSink = 'Liver_sink_pheme(c)';
exceptionSink = 'Liver_sink_pre_prot(r)';
microbeSink = 'Abiotrophia_defectiva_ATCC_49176_sink_pheme(c)';
organDemand = 'Liver_DM_pheme(c)';
addedRxns = [storageRxns; dietRxns; {organSink; exceptionSink; microbeSink; organDemand}];
addedMets = [storageMets; {'glc_D[e]'; 'o2[e]'; 'pheme[c]'; 'pre_prot[r]'; 'pheme[c]'; 'pheme[c]'}];
[metList, ~, metPos] = unique(addedMets, 'stable');
nAdded = numel(addedRxns);
addedS = full(sparse(metPos, (1:nAdded)', -1, numel(metList), nAdded));
wbModel = addMultipleReactions(model, addedRxns, metList, addedS, ...
                               'lb', -1000 * ones(nAdded, 1), 'ub', 1000 * ones(nAdded, 1));

% the [lb, ub] pair of one reaction, for the assertions
boundsOf = @(m, rxn) [m.lb(strcmp(m.rxns, rxn)), m.ub(strcmp(m.rxns, rxn))];

%% Recon3DModel_301, feeding with the default values: sink and demand bounds, sink identifiers

newModel = setFeedingFastingConstraints(model, 'feeding');

% the reactions starting with sink_ get [c] and [r] rewritten as (c) and (r); no other reaction
% identifier changes (Tier-5 count, first run 2026-11-03: 94 of the 96 sinks, the other two are
% in [l])
isSink = strncmp(model.rxns, 'sink_', 5);
expectedRxns = model.rxns;
expectedRxns(isSink) = regexprep(regexprep(model.rxns(isSink), '\[c\]', '(c)'), '\[r\]', '(r)');
assert(isequal(newModel.rxns, expectedRxns));
assert(nnz(~strcmp(newModel.rxns, model.rxns)) == 94);
assert(nnz(isSink) == 96);
assert(any(strcmp(newModel.rxns, 'sink_pre_prot(r)')));
assert(any(strcmp(newModel.rxns, 'sink_xolest2_hs[l]')));

% the reactions starting with sink_ get lower bound -10 and those containing DM_ lower bound 0;
% every other bound is unchanged
expectedLb = model.lb;
expectedLb(contains(model.rxns, 'DM_')) = 0;
expectedLb(isSink) = -10;
assert(isequal(newModel.lb, expectedLb));
assert(isequal(newModel.ub, model.ub));

% rxnGeneMat is removed, the status is recorded and every other field is copied unchanged
assert(~isfield(newModel, 'rxnGeneMat'));
assert(isequal(newModel.SetupInfo, struct('FeedingStatus', 'feeding')));
assert(isequal(rmfield(newModel, {'rxns', 'lb', 'SetupInfo'}), ...
               rmfield(model, {'rxns', 'lb', 'rxnGeneMat'})));

% the result is structurally consistent: one identifier and two bounds per column of S
nRxns = size(newModel.S, 2);
assert(isequal(size(newModel.rxns), [nRxns, 1]));
assert(isequal(size(newModel.lb), [nRxns, 1]) && isequal(size(newModel.ub), [nRxns, 1]));
assert(numel(unique(newModel.rxns)) == nRxns);

% Recon3DModel_301 has no diet exchange and no organ storage reaction, so fasting gives the same
% model with the other status
fastingModel = setFeedingFastingConstraints(model, 'fasting');
assert(isequal(rmfield(fastingModel, 'SetupInfo'), rmfield(newModel, 'SetupInfo')));
assert(strcmp(fastingModel.SetupInfo.FeedingStatus, 'fasting'));

%% whole-body-style model, feeding with the default values: storage on, diet uptake open

newModel = setFeedingFastingConstraints(wbModel, 'feeding');
[~, storageIdx] = ismember(storageRxns, newModel.rxns);
[~, dietIdx] = ismember(dietRxns, newModel.rxns);
assert(all(storageIdx > 0) && all(dietIdx > 0));

% every storage reaction stores: lower bound 0, upper bound storageValue (default 10)
assert(all(newModel.lb(storageIdx) == 0) && all(newModel.ub(storageIdx) == 10));

% both diet exchanges (Diet_EX_ and Diet_Ex_) take up: lower bound fastingValue (default -10),
% upper bound 0
assert(all(newModel.lb(dietIdx) == -10) && all(newModel.ub(dietIdx) == 0));

% an organ sink that is no storage reaction gets lower bound 0 (no Microbiota field), the listed
% exception keeps its bounds, the organ demand reaction gets lower bound 0
assert(isequal(boundsOf(newModel, organSink), [0, 1000]));
assert(isequal(boundsOf(newModel, exceptionSink), [-1000, 1000]));
assert(newModel.lb(strcmp(newModel.rxns, organDemand)) == 0);

% without a Microbiota field the microbe sink is treated as an organ sink: lower bound 0
assert(newModel.lb(strcmp(newModel.rxns, microbeSink)) == 0);

% the Recon3DModel_301 part is changed exactly as in the first section, and the added
% identifiers are kept
recon3DResult = setFeedingFastingConstraints(model, 'feeding');
nRecon = numel(model.rxns);
assert(isequal(newModel.rxns, [recon3DResult.rxns; addedRxns]));
assert(isequal(newModel.lb(1:nRecon), recon3DResult.lb));
assert(isequal(newModel.ub(1:nRecon), recon3DResult.ub));
assert(~isfield(newModel, 'rxnGeneMat'));
assert(strcmp(newModel.SetupInfo.FeedingStatus, 'feeding'));
assert(isequal(newModel.S, wbModel.S));

%% whole-body-style model, fasting with the default values: storage released, diet closed

newModel = setFeedingFastingConstraints(wbModel, 'fasting');
[~, storageIdx] = ismember(storageRxns, newModel.rxns);
[~, dietIdx] = ismember(dietRxns, newModel.rxns);

% every storage reaction releases: lower bound fastingValue (default -10), upper bound 0
assert(all(newModel.lb(storageIdx) == -10) && all(newModel.ub(storageIdx) == 0));

% the diet exchanges are closed
assert(all(newModel.lb(dietIdx) == 0) && all(newModel.ub(dietIdx) == 0));

% the other reactions are set as under feeding
feedingModel = setFeedingFastingConstraints(wbModel, 'feeding');
isOther = true(numel(newModel.rxns), 1);
isOther([storageIdx; dietIdx]) = false;
assert(isequal(newModel.lb(isOther), feedingModel.lb(isOther)));
assert(isequal(newModel.ub(isOther), feedingModel.ub(isOther)));
assert(isequal(newModel.rxns, feedingModel.rxns));
assert(strcmp(newModel.SetupInfo.FeedingStatus, 'fasting'));

%% explicit fastingValue and storageValue

% feeding: the diet lower bound is fastingValue and the storage upper bound storageValue; the
% reactions starting with sink_ keep the fixed lower bound -10
newModel = setFeedingFastingConstraints(wbModel, 'feeding', -5, 20);
[~, storageIdx] = ismember(storageRxns, newModel.rxns);
[~, dietIdx] = ismember(dietRxns, newModel.rxns);
assert(all(newModel.lb(storageIdx) == 0) && all(newModel.ub(storageIdx) == 20));
assert(all(newModel.lb(dietIdx) == -5) && all(newModel.ub(dietIdx) == 0));
assert(all(newModel.lb(strncmp(newModel.rxns, 'sink_', 5)) == -10));

% fasting: the storage lower bound is fastingValue; storageValue is not used
newModel = setFeedingFastingConstraints(wbModel, 'fasting', -5, 20);
assert(all(newModel.lb(storageIdx) == -5) && all(newModel.ub(storageIdx) == 0));
assert(all(newModel.lb(dietIdx) == 0) && all(newModel.ub(dietIdx) == 0));
assert(isequal(newModel, setFeedingFastingConstraints(wbModel, 'fasting', -5)));

%% Microbiota field: microbe sinks keep their bounds, organ sinks get lower bound 0

flaggedModel = wbModel;
flaggedModel.Microbiota = double(strcmp(wbModel.rxns, microbeSink));
newModel = setFeedingFastingConstraints(flaggedModel, 'feeding');

% the flagged microbe sink keeps its bounds; the organ sink (flag 0) gets lower bound 0
assert(isequal(boundsOf(newModel, microbeSink), [-1000, 1000]));
assert(isequal(boundsOf(newModel, organSink), [0, 1000]));

% the Microbiota field is kept, and apart from the microbe sink the result is the one without
% the field
assert(isequal(newModel.Microbiota, flaggedModel.Microbiota));
withoutFlags = setFeedingFastingConstraints(wbModel, 'feeding');
isMicrobe = strcmp(newModel.rxns, microbeSink);
assert(isequal(newModel.lb(~isMicrobe), withoutFlags.lb(~isMicrobe)));
assert(isequal(newModel.ub, withoutFlags.ub));
assert(isequal(rmfield(newModel, {'lb', 'Microbiota'}), rmfield(withoutFlags, 'lb')));

% change the directory
cd(currentDir)
