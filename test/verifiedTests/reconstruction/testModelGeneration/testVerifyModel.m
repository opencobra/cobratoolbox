% The COBRAToolbox: testVerifyModel.m
%
% Purpose:
%     - Tests the Model Verification function
%

model = getDistributedModel('ecoli_core_model.mat');

% test whether the correct "invalid" subSystem is found. Note:
% modelSub.subSystems(20) = {'blubb'} (paren-indexing) previously used here
% keeps position 20 as the plain char 'blubb', which is a VALID legacy
% entry -- it never actually exercised the malformed-content path; use
% curly-brace assignment of a non-char, non-cell value instead (FR-006,
% research.md R2).
modelSub = model;
modelSub.subSystems{20} = 5;
subSystemsBefore = modelSub.subSystems;

res = verifyModel(modelSub,'silentCheck',true);

assert(~isempty(res))
assert(isfield(res,'Errors') && isfield(res.Errors,'propertiesNotMatched') && ...
    isfield(res.Errors.propertiesNotMatched,'subSystems'), ...
    'verifyModel did not report the malformed subSystems entry.');
assert(isequal(res.Errors.propertiesNotMatched.subSystems, sprintf('Field does not match the required properties at the following positions: \n            20')));
assert(isequal(modelSub.subSystems, subSystemsBefore), 'verifyModel mutated model.subSystems.');

% test that a validly flat-char subSystems field reports no error (FR-006, SC-004)
subSystemsBefore = model.subSystems;
resFlat = verifyModel(model,'silentCheck',true);
assert(~(isfield(resFlat,'Errors') && isfield(resFlat.Errors,'propertiesNotMatched') && ...
    isfield(resFlat.Errors.propertiesNotMatched,'subSystems')), ...
    'verifyModel false-flagged a validly flat-char subSystems field.');
assert(isequal(model.subSystems, subSystemsBefore), 'verifyModel mutated model.subSystems.');

% test that a validly nested-cell subSystems field (multi-subsystem
% reactions) reports no error (FR-006, SC-004)
modelNested = model;
modelNested.subSystems = cellfun(@(x) {x}, model.subSystems, 'UniformOutput', false);
modelNested.subSystems{1} = {'Glycolysis','Pentose Phosphate'};
subSystemsBefore = modelNested.subSystems;
resNested = verifyModel(modelNested,'silentCheck',true);
assert(~(isfield(resNested,'Errors') && isfield(resNested.Errors,'propertiesNotMatched') && ...
    isfield(resNested.Errors.propertiesNotMatched,'subSystems')), ...
    'verifyModel false-flagged a validly nested-cell subSystems field.');
assert(isequal(modelNested.subSystems, subSystemsBefore), 'verifyModel mutated model.subSystems.');

% test that a valid rxn2subSystem/subSystemNames pair reports no error (FR-005)
modelMat = model;
[~, modelMat.rxn2subSystem, modelMat.subSystemNames] = buildRxn2subSystem(model, false);
resMat = verifyModel(modelMat,'silentCheck',true);
assert(~(isfield(resMat,'Errors') && isfield(resMat.Errors,'propertiesNotMatched') && ...
    (isfield(resMat.Errors.propertiesNotMatched,'rxn2subSystem') || ...
     isfield(resMat.Errors.propertiesNotMatched,'subSystemNames'))), ...
    'verifyModel false-flagged a valid rxn2subSystem/subSystemNames pair.');

% test that a malformed rxn2subSystem (wrong column count) reports an error (FR-005)
modelBadMat = modelMat;
modelBadMat.rxn2subSystem = modelBadMat.rxn2subSystem(:,1:end-1);
resBadMat = verifyModel(modelBadMat,'silentCheck',true);
assert(isfield(resBadMat,'Errors') && isfield(resBadMat.Errors,'inconsistentFields') && ...
    isfield(resBadMat.Errors.inconsistentFields,'rxn2subSystem'), ...
    'verifyModel did not report a dimension-mismatched rxn2subSystem.');

% test whether rules are checked crrectly
modelRule = model;
modelRule.rules(3) = {'x(17) )'};
res = verifyModel(modelRule,'silentCheck',true);

assert(~isempty(res))
assert(isequal(res.Errors.propertiesNotMatched.rules, sprintf('Field does not match the required properties at the following positions: \n       3')));
