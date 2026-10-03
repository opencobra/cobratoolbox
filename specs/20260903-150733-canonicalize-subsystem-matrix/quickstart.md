# Quickstart: Validating Subsystem Matrix Canonicalization

Prerequisites: a working COBRA Toolbox checkout on this branch, headless MATLAB (`matlab -batch`), no solver required — every check below is a pure data-structure operation (spec FR-010).

## 1. Initialize

```matlab
cd('/home/farid/Projects/cobratoolbox-f-develop');
initCobraToolbox(false, 'agent');   % fast, non-interactive; no solver check needed
```

## 2. Run the four targeted, already-existing test suites first (regression baseline — FR-008/SC-005)

```matlab
runtests({'testGetModelSubSystems','testFindRxnsFromSubSystem', ...
          'testIsReactionInSubSystem','testBuildRxn2subSystem','testWriteSBML'})
```

Expected: all pass, same assertion count as before this feature (no source change to the four already-converted functions).

## 3. Reproduce the two bugs this feature fixes (should FAIL before implementation, PASS after)

```matlab
model = getDistributedModel('ecoli_core_model.mat');
modelNested = model;
modelNested.subSystems{1} = {'Glycolysis','Pentose Phosphate'};

% US1 / FR-001: model2JSON must not drop the second subsystem name.
% Scope the check to reaction 1's own JSON block: ecoli_core_model
% already legitimately has 8 other reactions in "Pentose Phosphate
% Pathway", so a whole-file contains() check would false-pass even
% against the pre-fix code.
tmp = [tempname() '.json'];
model2JSON(modelNested, tmp);
txt = fileread(tmp); delete(tmp);
idStart = strfind(txt, ['"' model.rxns{1} '"']);
window = txt(idStart(1):min(idStart(1)+2000, numel(txt)));
subsystemValue = regexp(window, '"subsystem":"([^"]*)"', 'tokens', 'once');
assert(contains(subsystemValue{1},'Glycolysis') && contains(subsystemValue{1},'Pentose Phosphate'), ...
    'model2JSON dropped a subsystem name');

% US2 / FR-004: sammi's subsystem grouping must not error on a nested-cell model
modelUniform = model;
modelUniform.subSystems = cellfun(@(x) {x}, model.subSystems, 'UniformOutput', false);
modelUniform.subSystems{1} = {'Glycolysis','Pentose Phosphate'};
options = struct('load', false, 'htmlName', [tempname() '.html']);
sammi(modelUniform, 'subSystems', [], [], options);   % must not throw
delete(options.htmlName);
```

## 4. Verify the internal-consistency and validator stories

```matlab
% US3 / FR-003: getModelSubSystems output unchanged across all three legacy shapes
namesBefore = {'...'};  % captured from pre-change run, or compare against buildRxn2subSystem's own name list
names = getModelSubSystems(modelNested);
[~, ~, subSystemNames] = buildRxn2subSystem(modelNested, false);
assert(isequal(sort(names), sort(subSystemNames)), 'getModelSubSystems diverged from the matrix path');

% US4 / FR-006: verifyModel no longer blanket-suppresses subSystems errors
modelBad = model;
modelBad.subSystems{20} = 5;   % genuinely malformed: neither char nor cell of char
res = verifyModel(modelBad, 'silentCheck', true);
assert(isfield(res,'Errors') && isfield(res.Errors,'propertiesNotMatched') && ...
       isfield(res.Errors.propertiesNotMatched,'subSystems'), ...
       'verifyModel did not report the malformed subSystems entry');

modelOk = model;   % flat-char shape, valid
resOk = verifyModel(modelOk, 'silentCheck', true);
assert(~(isfield(resOk,'Errors') && isfield(resOk.Errors,'propertiesNotMatched') && ...
         isfield(resOk.Errors.propertiesNotMatched,'subSystems')), ...
       'verifyModel false-flagged a valid subSystems field');

% FR-011/SC-007: none of the three updated functions may mutate model.subSystems
subSystemsBefore = modelNested.subSystems;
getModelSubSystems(modelNested);
assert(isequal(modelNested.subSystems, subSystemsBefore), 'getModelSubSystems mutated model.subSystems');
verifyModel(modelNested, 'silentCheck', true);
assert(isequal(modelNested.subSystems, subSystemsBefore), 'verifyModel mutated model.subSystems');
subSystemsBeforeUniform = modelUniform.subSystems;
options2 = struct('load', false, 'htmlName', [tempname() '.html']);
sammi(modelUniform, 'subSystems', [], [], options2);
delete(options2.htmlName);
assert(isequal(modelUniform.subSystems, subSystemsBeforeUniform), 'sammi mutated model.subSystems');
```

## 5. Run the full targeted suite again post-implementation

```matlab
runtests({'testGetModelSubSystems','testFindRxnsFromSubSystem', ...
          'testIsReactionInSubSystem','testBuildRxn2subSystem','testWriteSBML', ...
          'testSammi','testVerifyModel','testModel2JSON'})
```

Expected: all pass. `testModel2JSON` is not new: it is the existing, git-tracked `test/verifiedTests/base/testIO/testModel2JSON` (missing its `.m` extension, and therefore never previously executed by `test/testAll.m` — research.md R7) relocated to `test/verifiedTests/base/testIO/testModel2JSON/testModel2JSON.m` and extended (spec FR-009).

## Notes

- Steps 3-4 are illustrative smoke checks for this quickstart, not a substitute for the actual `test<FunctionName>.m` assertions `/speckit-tasks` will place in `test/verifiedTests/` (Constitution III-Naming).
- No step above requires a solver, network access, or GUI interaction (spec SC-006).
