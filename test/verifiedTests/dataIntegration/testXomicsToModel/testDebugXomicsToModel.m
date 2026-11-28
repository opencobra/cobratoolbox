% The COBRAToolbox: testDebugXomicsToModel.m
%
% Purpose:
%     - debugXomicsToModel prints, for the generic model and for the model saved in every
%       debug file of a folder (files named <n>.debug_*.mat, in increasing order of n; Model.mat
%       and files without 'debug' are ignored), how many of the core genes, reactions and
%       metabolites are still present, the model sizes, the lower bound of the single
%       objective reaction (NaN otherwise), the FBA objective and whether FBA is feasible. The
%       core lists come from modelGenerationReport when it is not empty, otherwise from
%       coreData (numeric gene identifiers are converted to text; missing lists count as
%       empty). The printed text is recorded with diary in a temporary file and every row is
%       checked against counts and objective values derived by hand from the toy models.
%
% Function under test:
%     src/dataIntegration/XomicsToModel/analysis/debugXomicsToModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - one FBA per model on hand-built toy models; every available LP solver among
%     gurobi and glpk.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Numeric gene identifiers leave the command window in format long g
%       SEVERITY: cosmetic
%       TRIGGER: debugXomicsToModel(genericModel, debugDir, [], struct('genes', [10; 30]))
%         (coreData.genes numeric, as in the first section below)
%       OBSERVED: (code reading, R2025a, 2026-11-25) line 43 runs "format long g", which
%         changes the display format of the whole MATLAB session and is not restored; the
%         conversion of line 46 (num2str) does not depend on it. The test restores the format
%         and asserts nothing about it
%       EXPECTED: no change of the session's display format, which the help does not mention
%       LINES: 43
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDebugXomicsToModel'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});

% the solver selection is saved and restored; any global created while reading it or by the
% solver interfaces is removed at the end
globalsBefore = who('global');
initialSolverState = CobraSolverState.get();

% the function switches the command window to "format long g" for numeric gene identifiers
% (line 43); the display format is restored at the end
previousFormat = format;

% the LP optimality tolerance is far below the printed precision, so the printed numbers are
% compared as text

% generic model: R1 takes up A (at most 10), R2: A -> B, R3: B -> (objective, lb 0),
% R4: A -> ; genes carry a transcript suffix '.1' that the function removes
genericModel = createModel({'R1'; 'R2'; 'R3'; 'R4'}, {'r1'; 'r2'; 'r3'; 'r4'}, ...
    {' -> A'; 'A -> B'; 'B -> '; 'A -> '}, 'grRuleList', {''; '10.1'; '20.1 or 30.1'; '40.1'});
genericModel.lb = [0; 0; 0; 0];
genericModel.ub = [10; 10; 10; 10];
genericModel.c = [0; 0; 1; 0];

% stage 1: R4 and gene 40.1 removed, still feasible (objective 10)
stage1Model = createModel({'R1'; 'R2'; 'R3'}, {'r1'; 'r2'; 'r3'}, ...
    {' -> A'; 'A -> B'; 'B -> '}, 'grRuleList', {''; '10.1'; '20.1 or 30.1'});
stage1Model.lb = [0; 0; 2];
stage1Model.ub = [10; 10; 10];
stage1Model.c = [0; 0; 1];
% stage 2: R3 must carry 20 but R1 is capped at 10 (infeasible), two objective reactions
stage2Model = stage1Model;
stage2Model.lb = [0; 0; 20];
stage2Model.c = [0; 1; 1];
% stage 10: only the uptake R1 and a drain R2 of A remain (objective R1, at most 10)
stage10Model = createModel({'R1'; 'R2'}, {'r1'; 'r2'}, {' -> A'; 'A -> '}, ...
    'grRuleList', {''; '10.1'});
stage10Model.lb = [0; 0];
stage10Model.ub = [10; 10];
stage10Model.c = [1; 0];

% debug folder: the stages are saved under the names XomicsToModel uses; Model.mat and a file
% without 'debug' in its name must be ignored
debugDir = tempname;
mkdir(debugDir);
model = stage1Model;
save(fullfile(debugDir, '1.debug_prior_to_stage_one.mat'), 'model');
model = stage2Model;
save(fullfile(debugDir, '2.debug_prior_to_stage_two.mat'), 'model');
model = stage10Model;
save(fullfile(debugDir, '10.debug_prior_to_stage_ten.mat'), 'model');
model = genericModel;
save(fullfile(debugDir, 'Model.mat'), 'model');
save(fullfile(debugDir, 'notes.mat'), 'model');
clear model

% record the command window in a temporary file; the previous diary state is restored below
diaryWasOn = strcmp(get(0, 'Diary'), 'on');
previousDiaryFile = get(0, 'DiaryFile');
if diaryWasOn
    diary('off');
end

% one row is found by matching its numbers separated by blanks, followed by its stage
rowPattern = @(numbers, stage) ['\s' regexprep(strjoin(numbers, ' '), ' ', '\\s+') '\s+' stage];

for k = 1:length(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if solverOK
        fprintf('   Testing debugXomicsToModel using %s ... \n', solvers.LP{k});

        %% core lists from coreData, numeric gene identifiers
        % core genes 10 and 30 are generic genes (99 is not), core reactions R2 and R3 (R9 is
        % not), core metabolite A[c] (Z[c] is not)
        coreData = struct('genes', [10; 30; 99], 'rxns', {{'R2'; 'R3'; 'R9'}}, ...
            'mets', {{'A[c]'; 'Z[c]'}});
        diaryFile = fullfile(debugDir, [solvers.LP{k} '_coreData.txt']);
        diary(diaryFile);
        debugXomicsToModel(genericModel, debugDir, [], coreData);
        diary('off');
        printedText = fileread(diaryFile);

        % the active list: 3 genes, 3 reactions, 2 metabolites
        assert(~isempty(regexp(printedText, rowPattern({'3', '3', '2'}, 'Active list'), 'once')));
        % generic model: 2 of 4 genes, 2 of 4 reactions, 1 of 2 metabolites, lb of the single
        % objective R3 is 0, FBA objective 10 (uptake limit), feasible
        assert(~isempty(regexp(printedText, rowPattern({'2', '4', '2', '4', '1', '2', '0', ...
            '10', 'Feasible'}, 'Generic model'), 'once')));
        % stage 1: 2 of 3 genes (10, 30), 2 of 3 reactions, 1 of 2 metabolites, lb 2,
        % objective 10
        assert(~isempty(regexp(printedText, rowPattern({'2', '3', '2', '3', '1', '2', '2', ...
            '10', 'Feasible'}, '1.debug_prior_to_stage_one.mat'), 'once')));
        % stage 2: infeasible, two objective reactions so lb_obj is NaN
        assert(~isempty(regexp(printedText, rowPattern({'2', '3', '2', '3', '1', '2', 'NaN', ...
            '\S+', 'Infeasible'}, '2.debug_prior_to_stage_two.mat'), 'once')));
        % stage 10: gene 10 of 1, reaction R2 of 2, metabolite A[c] of 1; objective R1 has
        % lb 0 and reaches its bound 10
        assert(~isempty(regexp(printedText, rowPattern({'1', '1', '1', '2', '1', '1', '0', ...
            '10', 'Feasible'}, '10.debug_prior_to_stage_ten.mat'), 'once')));
        % the stages are listed by their number (2 before 10), Model.mat and notes.mat are not
        assert(strfind(printedText, '2.debug_prior') < strfind(printedText, '10.debug_prior'));
        assert(~contains(printedText, 'Model.mat'));
        assert(~contains(printedText, 'notes.mat'));

        %% core lists from modelGenerationReport (coreData is then ignored)
        % report: genes 20 and 40 (both generic, 20 also in stage 1), reaction R4 (generic
        % only), metabolites A[c] and B[c]
        report = struct('coreRxnAbbr0', {{'R4'}}, 'coreMetAbbr0', {{'A[c]'; 'B[c]'}}, ...
            'activeEntrezGeneID0', {{'20'; '40'}});
        diaryFile = fullfile(debugDir, [solvers.LP{k} '_report.txt']);
        diary(diaryFile);
        debugXomicsToModel(genericModel, debugDir, report, []);
        diary('off');
        printedText = fileread(diaryFile);
        assert(~isempty(regexp(printedText, rowPattern({'2', '1', '2'}, 'Active list'), 'once')));
        assert(~isempty(regexp(printedText, rowPattern({'2', '4', '1', '4', '2', '2', '0', ...
            '10', 'Feasible'}, 'Generic model'), 'once')));
        assert(~isempty(regexp(printedText, rowPattern({'1', '3', '0', '3', '2', '2', '2', ...
            '10', 'Feasible'}, '1.debug_prior_to_stage_one.mat'), 'once')));

        %% coreData with text gene identifiers and without core lists
        % text identifiers are used as they are
        coreData = struct('genes', {{'10'; '20'}});
        diaryFile = fullfile(debugDir, [solvers.LP{k} '_textGenes.txt']);
        diary(diaryFile);
        debugXomicsToModel(genericModel, debugDir, [], coreData);
        diary('off');
        printedText = fileread(diaryFile);
        % genes 10 and 20 are found, the missing reaction and metabolite lists count as empty
        assert(~isempty(regexp(printedText, rowPattern({'2', '0', '0'}, 'Active list'), 'once')));
        assert(~isempty(regexp(printedText, rowPattern({'2', '4', '0', '4', '0', '2', '0', ...
            '10', 'Feasible'}, 'Generic model'), 'once')));
        assert(~isempty(regexp(printedText, rowPattern({'1', '1', '0', '2', '0', '1', '0', ...
            '10', 'Feasible'}, '10.debug_prior_to_stage_ten.mat'), 'once')));

        % a coreData without any list: every count is 0
        diaryFile = fullfile(debugDir, [solvers.LP{k} '_noLists.txt']);
        diary(diaryFile);
        debugXomicsToModel(genericModel, debugDir, [], struct());
        diary('off');
        printedText = fileread(diaryFile);
        assert(~isempty(regexp(printedText, rowPattern({'0', '0', '0'}, 'Active list'), 'once')));
        assert(~isempty(regexp(printedText, rowPattern({'0', '4', '0', '4', '0', '2', '0', ...
            '10', 'Feasible'}, 'Generic model'), 'once')));
        assert(~isempty(regexp(printedText, rowPattern({'0', '3', '0', '3', '0', '2', 'NaN', ...
            '\S+', 'Infeasible'}, '2.debug_prior_to_stage_two.mat'), 'once')));

        %% an infeasible generic model with two objective reactions
        % the generic row reports Infeasible and lb_obj NaN (stage 2 used as generic model)
        diaryFile = fullfile(debugDir, [solvers.LP{k} '_infeasibleGeneric.txt']);
        diary(diaryFile);
        debugXomicsToModel(stage2Model, debugDir, [], struct('rxns', {{'R3'}}));
        diary('off');
        printedText = fileread(diaryFile);
        assert(~isempty(regexp(printedText, rowPattern({'0', '3', '1', '3', '0', '2', 'NaN', ...
            '\S+', 'Infeasible'}, 'Generic model'), 'once')));
    end
end

%% errors raised by design
% both core sources empty
assert(verifyCobraFunctionError('debugXomicsToModel', 'inputs', {genericModel, debugDir, [], []}, ...
    'testMessage', 'both modelGenerationReport and coreData must not be empty'));
% a folder that does not exist
missingDir = tempname;
assert(verifyCobraFunctionError('debugXomicsToModel', 'inputs', ...
    {genericModel, missingDir, [], struct('rxns', {{'R1'}})}, ...
    'testMessage', ['Directory ' missingDir ' does not exist']));

% restore the diary, the display format and the solver selection; remove the files
set(0, 'DiaryFile', previousDiaryFile);
if diaryWasOn
    diary('on');
end
format(previousFormat);
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
if ~isempty(newGlobals)
    clear('global', newGlobals{:});
end
rmdir(debugDir, 's');

% change the directory
cd(currentDir)
