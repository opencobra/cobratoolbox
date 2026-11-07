function recordAncestorCalls(ancestorRoot, outDir)
% Run the ancestor's testGreedyExtremeRayBasis with the recording shim first on the path
% (T005). Same solver set-up as runSuiteForBaseline.
%
% USAGE:
%    matlab -batch "addpath('<featureDir>/verification'); recordAncestorCalls('<ancestorRoot>', '<outDir>')"

verificationDir = fileparts(mfilename('fullpath'));
restoredefaultpath;
clear functions; %#ok<CLFUNC>
setenv('GUROBI_HOME', '/usr/local/bin/gurobi1303/linux64');
setenv('GRB_LICENSE_FILE', '/usr/local/bin/gurobi1303/gurobi.lic2/gurobi.lic');
addpath('/usr/local/bin/gurobi1303/linux64/matlab/');
addpath('/usr/local/bin/mosektoolslinux64x86/mosek/11.2/toolbox/r2019b');
cd(ancestorRoot);
initCobraToolbox(false, 'agent');   % agent mode skips the git block, which mistakes a worktree's .git file for an untracked tree

global GREEDY_RECORD_REALDIR GREEDY_RECORD_OUTDIR GREEDY_RECORD_COUNT
GREEDY_RECORD_REALDIR = fullfile(ancestorRoot, 'src', 'analysis', 'topology', 'extremeRays', 'optimalRays');
GREEDY_RECORD_OUTDIR = outDir;
GREEDY_RECORD_COUNT = 0;
if ~exist(outDir, 'dir')
    mkdir(outDir);
end
addpath(fullfile(verificationDir, 'recorder'), '-begin');
fprintf('recordAncestorCalls: greedyExtremeRayBasis resolves to %s\n', which('greedyExtremeRayBasis'));
fprintf('recordAncestorCalls: real function in %s\n', GREEDY_RECORD_REALDIR);

testFile = fullfile(ancestorRoot, 'test', 'verifiedTests', 'analysis', 'testTopology', 'testGreedyExtremeRayBasis.m');
result = runtests(testFile);
disp(result);
fprintf('recordAncestorCalls: %d calls recorded in %s\n', GREEDY_RECORD_COUNT, outDir);
end
