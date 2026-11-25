% The COBRAToolbox: testGenerateIsotopomerSolver.m
%
% Purpose:
%     - generateIsotopomerSolver writes IsotopomerModel.txt into its own folder: the input
%       metabolite (default xglcDe), then for each reaction with a carbon mapping
%       (model.isotopomer, 'name reaction!mapping') the reaction line with ' v<index>'
%       inserted after the name and the mapping line, then, when an experiment is given,
%       '!!Measured Metabolites!!' and one line met->fragment per measured fragment. With
%       FVAflag true, reactions that carry no flux in any steady state (fluxVariability,
%       optPercentage 0) are left out. It then runs the Perl scripts generatorEMU.pl,
%       generatorCumomer.pl, optimizerEMU.pl and optimizerCumomer.pl in that folder, which
%       write the solver files slvrEMU.m, slvrCumomer.m, slvrEMU_fast.m, slvrCumomer_fast.m
%       and convertCarbonInput.m.
%     - Expected file contents are derived by hand from the mapping strings of the
%       four-reaction toy model below (string insertion and splitting only). The generated
%       solver files are checked to exist and to define their function; they are never run
%       (they are executed by their own tests from a folder outside src, so that the CI
%       coverage step is not disturbed).
%     - The files the function writes into src are temporary here: solver files present
%       before the test are copied to a temporary folder and put back at the end, and every
%       file the test creates in that folder is deleted.
%
% Function under test:
%     src/dataIntegration/fluxomics/c13solver/generateIsotopomerSolver.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - flux variability analysis (LP) for FVAflag true, with every available LP
%     solver among gurobi and glpk, and Perl for the generator scripts (declared with
%     prepareTest outside Windows, where MATLAB ships its own Perl), on a hand-built
%     four-reaction model.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Without an experiment the solver generation fails in Perl
%       SEVERITY: limitation
%       TRIGGER: generateIsotopomerSolver(modelNoBlocked, 'xglcDe') (no experiment; the help
%         lists experiment among the inputs, but the code treats it as optional, nargin > 2)
%       OBSERVED: (R2025a, 2026-11-25) IsotopomerModel.txt is written without measured
%         metabolites, then perl(generatorEMU.pl) fails with "outputs file not found.  assuming
%         everything is output / should not get here because outputs must be known" (the
%         script dies when no measured metabolite is listed); the working folder is left at
%         the c13solver folder of src, as the cd back to the caller's folder is not reached
%       EXPECTED: experiment is required (an error saying so), or the call works without it
%       LINES: 35-37, 104
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGenerateIsotopomerSolver'));
cd(fileDir);

% note the globals that exist now: the solver interface (parameter globals) and showprogress
% create globals, which are removed at the end
globalsBefore = who('global');

% an LP solver (FVAflag) and Perl (the generator scripts); MATLAB's perl runs the system Perl
% on Linux and macOS, but the Perl shipped with MATLAB on Windows
if ispc
    requiredPrograms = {};
else
    requiredPrograms = {'perl'};
end
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'}, ...
    'requiredSoftwares', requiredPrograms);
initialSolverState = CobraSolverState.get();

% the folder of src the function writes into: copy the files present now to a temporary folder
% (they are put back at the end) and note the file list, to delete every new file at the end
c13Dir = fileparts(which('generateIsotopomerSolver'));
c13Files = {'IsotopomerModel.txt'; 'convertCarbonInput.m'; 'slvrCumomer.m'; 'slvrCumomer_fast.m'; ...
    'slvrEMU.m'; 'slvrEMU_fast.m'};
c13Existed = cellfun(@(f) exist(fullfile(c13Dir, f), 'file') == 2, c13Files);
c13Backup = tempname;
mkdir(c13Backup);
for k = find(c13Existed)'
    copyfile(fullfile(c13Dir, c13Files{k}), c13Backup);
end
filesBefore = {dir(c13Dir).name};

% toy model: glucose (xglcDe, the known input) becomes g6p (GLCUP), g6p is split into two
% pyruvates (G6PSPLIT, carbons abc and fed), pyruvate leaves (PYROUT); BLK makes pyruvate from
% blk, which nothing produces, so it carries no flux in any steady state; NOMAP has no carbon
% mapping and is always left out of the file
rxnIds = {'GLCUP'; 'G6PSPLIT'; 'PYROUT'; 'BLK'; 'NOMAP'};
model = createModel(rxnIds, rxnIds, {' -> g6p'; 'g6p -> 2 pyr'; 'pyr -> '; 'blk -> pyr'; 'pyr -> '}, ...
    'upperBoundList', [10; 1000; 1000; 1000; 1000], 'printLevel', 0);
model.isotopomer = {'GLCUP 1 xglcDe > 1 xg6p!#abcdef > #abcdef'; ...
    'G6PSPLIT 1 xg6p > 1 xpyr 1 xpyr!#abcdef > #abc #fed'; ...
    'PYROUT 1 xpyr >!#abc >'; ...
    'BLK 1 xblk > 1 xpyr!#abc > #abc'; ...
    ''};
% the same model without BLK: every reaction carries flux in some steady state
keep = ~strcmp(rxnIds, 'BLK');
modelNoBlocked = createModel(rxnIds(keep), rxnIds(keep), {' -> g6p'; 'g6p -> 2 pyr'; 'pyr -> '; 'pyr -> '}, ...
    'upperBoundList', [10; 1000; 1000; 1000], 'printLevel', 0);
modelNoBlocked.isotopomer = model.isotopomer(keep);
% the measured fragments: all carbons of pyruvate, and its carbons 2 and 3
experiment = struct();
experiment.fragments.f1 = struct('met', 'xpyr', 'fragment', [1; 1; 1]);
experiment.fragments.f2 = struct('met', 'xpyr', 'fragment', [0; 1; 1]);

% the expected file: the input metabolite, then the lines written for the mapped reactions
% (index of each reaction after its name; BLK is the fourth reaction of model and is left out
% by flux variability analysis, NOMAP is never written), then the measured fragments
expectedLines = {'xglcDe'; ...
    'GLCUP v1 1 xglcDe > 1 xg6p'; '#abcdef > #abcdef'; ...
    'G6PSPLIT v2 1 xg6p > 1 xpyr 1 xpyr'; '#abcdef > #abc #fed'; ...
    'PYROUT v3 1 xpyr >'; '#abc >'; ...
    '!!Measured Metabolites!!'; 'xpyr->[1;1;1]'; 'xpyr->[0;1;1]'};
generatedSolvers = {'slvrEMU'; 'slvrCumomer'; 'slvrEMU_fast'; 'slvrCumomer_fast'; 'convertCarbonInput'};

%% the model file cannot be written: error

% a folder named IsotopomerModel.txt cannot be opened for writing; the original file was
% copied above and is removed here so that the folder can take its name
isotopomerPath = fullfile(c13Dir, 'IsotopomerModel.txt');
if exist(isotopomerPath, 'file') == 2
    delete(isotopomerPath);
end
mkdir(isotopomerPath);
assert(verifyCobraFunctionError('generateIsotopomerSolver', 'inputs', {modelNoBlocked, 'xglcDe', experiment}, ...
    'testMessage', ['generateIsotopomerSolver: cannot write ' c13Dir filesep 'IsotopomerModel.txt']));
rmdir(isotopomerPath);

%% three inputs: every mapped reaction and the measured fragments, no flux variability analysis

% (the call with two inputs, without experiment, is not made: see the known defect above)
generateIsotopomerSolver(modelNoBlocked, 'xglcDe', experiment);
% the function returns to the folder it was called from
assert(strcmp(pwd, fileDir));
writtenLines = readlines(isotopomerPath, 'EmptyLineRule', 'skip');
assert(isequal(cellstr(writtenLines), expectedLines));
% the Perl scripts wrote the solver files; each defines its function, whose last input is the
% known input metabolite of the first line (the files are not run)
for k = 1:numel(generatedSolvers)
    solverText = fileread(fullfile(c13Dir, [generatedSolvers{k} '.m']));
    assert(~isempty(regexp(solverText, ['^function [^\n]*' generatedSolvers{k} '\([^\n]*xglcDe\)'], 'once')));
end

for k = 1:numel(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if solverOK
        fprintf('   Testing generateIsotopomerSolver using %s ... \n', solvers.LP{k});

        %% default input metabolite, flux variability analysis leaves out a blocked reaction

        % an empty input metabolite is xglcDe; FVAflag true leaves out BLK (flux range [0, 0])
        % and prints the omitted reactions; the file is the same as above
        generateIsotopomerSolver(model, [], experiment, true);
        assert(strcmp(pwd, fileDir));
        writtenLines = readlines(isotopomerPath, 'EmptyLineRule', 'skip');
        assert(isequal(cellstr(writtenLines), expectedLines));
        for j = 1:numel(generatedSolvers)
            assert(exist(fullfile(c13Dir, [generatedSolvers{j} '.m']), 'file') == 2);
        end

        %% FVAflag true when no reaction is blocked: nothing is left out

        % every reaction of modelNoBlocked carries flux in some steady state, so no reaction is
        % omitted (and the omission message is not printed)
        generateIsotopomerSolver(modelNoBlocked, 'xglcDe', experiment, true);
        writtenLines = readlines(isotopomerPath, 'EmptyLineRule', 'skip');
        assert(isequal(cellstr(writtenLines), expectedLines));
    end
end

% delete every file the test created in the folder of src and put back the files present
% before the test
filesAfter = {dir(c13Dir).name};
newFiles = setdiff(filesAfter, filesBefore);
for k = 1:numel(newFiles)
    delete(fullfile(c13Dir, newFiles{k}));
end
for k = 1:numel(c13Files)
    if c13Existed(k)
        copyfile(fullfile(c13Backup, c13Files{k}), c13Dir);
    elseif exist(fullfile(c13Dir, c13Files{k}), 'file') == 2
        delete(fullfile(c13Dir, c13Files{k}));
    end
end
rmdir(c13Backup, 's');
rehash;

% restore the solver state
CobraSolverState.restore(initialSolverState);

% remove the globals created during the test
newGlobals = setdiff(who('global'), globalsBefore);
for k = 1:numel(newGlobals)
    clearvars('-global', newGlobals{k});
end

% change the directory
cd(currentDir)
