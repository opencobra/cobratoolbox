% The COBRAToolbox: testVerifyModel.m
%
% Purpose:
%     - Tests the Model Verification function
%

model = getDistributedModel('ecoli_core_model.mat');

% test whether the correct "invalid" subSystem is found
modelSub = model;
modelSub.subSystems(20) = {'blubb'};

res = verifyModel(modelSub,'silentCheck',true);

assert(~isempty(res))
if isfield(res,'Errors')
    assert(isequal(res.Errors.propertiesNotMatched.subSystems, sprintf('Field does not match the required properties at the following positions: \n            20')));
end

% test whether rules are checked crrectly
modelRule = model;
modelRule.rules(3) = {'x(17) )'};
res = verifyModel(modelRule,'silentCheck',true);

assert(~isempty(res))
assert(isequal(res.Errors.propertiesNotMatched.rules, sprintf('Field does not match the required properties at the following positions: \n       3')));
