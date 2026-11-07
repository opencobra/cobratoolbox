function runSuiteForBaseline(repoRoot, outCsv)
% Run the COBRA verified test suite of one checkout and write one row per test.
%
% Used for FR-012 (feature 20261106-213424-greedy-basis-reconcile): the same harness
% runs on old develop, upstream/develop and the merged tree, so outcomes compare.
% It replaces `COBRA_CI=1 testAll`, whose restoredefaultpath drops the gurobi 13.0.3
% and mosek folders that the user's startup.m adds, and whose start-up depends on
% the current folder that startup.m changes.
%
% USAGE:
%    matlab -batch "addpath('<featureDir>/verification'); runSuiteForBaseline('<repoRoot>', '<out.csv>')"
%
% INPUTS:
%    repoRoot:  absolute path of the checkout to test
%    outCsv:    absolute path of the CSV to write (TestName, Status, Time)

verificationDir = fileparts(mfilename('fullpath'));
restoredefaultpath;
addpath(verificationDir);
clear functions; %#ok<CLFUNC> drop the main checkout loaded by startup.m

% solvers exactly as ~/Documents/MATLAB/startup.m sets them
setenv('GUROBI_HOME', '/usr/local/bin/gurobi1303/linux64');
setenv('GRB_LICENSE_FILE', '/usr/local/bin/gurobi1303/gurobi.lic2/gurobi.lic');
addpath('/usr/local/bin/gurobi1303/linux64/matlab/');
addpath('/usr/local/bin/mosektoolslinux64x86/mosek/11.2/toolbox/r2019b');

setenv('COBRA_TEST_MODE', 'fast');
cd(repoRoot);
initCobraToolbox(false, 'agent');   % agent mode skips the git block, which mistakes a worktree's .git file for an untracked tree
fprintf('runSuiteForBaseline: initCobraToolbox resolved to %s\n', which('initCobraToolbox'));
fprintf('runSuiteForBaseline: test mode %s\n', getCobraTestMode());

cd(fullfile(repoRoot, 'test'));
[~, resultTable] = runTestSuite();

status = repmat({'Passed'}, height(resultTable), 1);
status(logical(resultTable.Skipped)) = {'Skipped'};
status(logical(resultTable.Failed)) = {'Failed'};
out = table(resultTable.TestName, status, resultTable.Time, ...
    'VariableNames', {'TestName', 'Status', 'Time'});
writetable(out, outCsv);
fprintf('runSuiteForBaseline: %d tests, %d passed, %d failed, %d skipped -> %s\n', ...
    height(out), nnz(strcmp(status, 'Passed')), nnz(strcmp(status, 'Failed')), ...
    nnz(strcmp(status, 'Skipped')), outCsv);
end
