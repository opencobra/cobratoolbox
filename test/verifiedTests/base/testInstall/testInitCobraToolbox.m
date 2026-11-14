% The COBRAToolbox: testInitCobraToolbox.m
%
% Purpose:
%     - Test the 'agent' and 'runmat' modes and the argument validation of
%       initCobraToolbox(updateToolbox, mode).
%
%     Test 1 (regression): mode omitted — globals set, sslVerify unchanged.
%     Test 2 (agent mode): initCobraToolbox(false, 'agent') sets CBTDIR,
%       SOLVERS, OPT_PROB_TYPES; leaves global http.sslVerify unchanged;
%       marks glpk, pdco, mosek and matlab installed and working exactly when
%       their local file or license check holds; sets CBT_NLP_SOLVER to
%       'matlab' only when the Optimization Toolbox is present; leaves no
%       thermochemistry new/ folder on the path; and, where mosek is present,
%       leaves mosek selectable as LP solver.
%     Test 3 (invalid mode): initCobraToolbox(false, 'nope') raises
%       initCobraToolbox:invalidMode.
%     Test 4 (runmat mode arguments): the invalid-mode message lists
%       'runmat'; initCobraToolbox(true, 'runmat') raises
%       initCobraToolbox:invalidMode naming the combination.
%     Test 5 (runmat mode in MATLAB): initCobraToolbox(false, 'runmat') gives
%       the same CBTDIR and the same COBRA path entries as 'agent' mode, sets
%       SOLVERS and OPT_PROB_TYPES, and leaves global http.sslVerify unchanged.
%       The RunMat-specific code paths are listed in
%       test/runtimeCompatibility/RunMat/debtRegister.md.
%
% Authors:
%     - Ronan M.T. Fleming, June 2026
%     - 'runmat' mode tests: feature 20261104-001324-runmat-init-mode, November 2026
%     - agent-mode solver flags and new/ folders: feature
%       20261107-133937-r2026a-test-failures, November 2026
%

global CBTDIR SOLVERS OPT_PROB_TYPES ENV_VARS CBT_INITIALIZED CBT_NLP_SOLVER

fprintf('Testing initCobraToolbox agent mode ...\n');

% -------------------------------------------------------------------------
% Helper: read current global git http.sslVerify setting ('' if not set)
% -------------------------------------------------------------------------
[~, sslBefore] = system('git config --global --get http.sslVerify 2>/dev/null');
sslBefore = strtrim(sslBefore);

% -------------------------------------------------------------------------
% Test 3: invalid mode raises bounded error (run first — fastest, no init)
% -------------------------------------------------------------------------
fprintf('  Test 3: invalid mode raises initCobraToolbox:invalidMode ... ');
try
    initCobraToolbox(false, 'nope');
    error('testInitCobraToolbox:noError', ...
        'Expected an error for mode=''nope'' but none was thrown.');
catch ME
    assert(strcmp(ME.identifier, 'initCobraToolbox:invalidMode'), ...
        'Wrong error ID: expected initCobraToolbox:invalidMode, got %s', ME.identifier);
    assert(~isempty(strfind(ME.message, 'agent')), ...
        'Error message should list accepted values including ''agent''.');
end
fprintf('PASSED\n');

% -------------------------------------------------------------------------
% Test 4: 'runmat' mode argument checks (no initialisation runs)
% -------------------------------------------------------------------------
fprintf('  Test 4: runmat mode argument checks ... ');
try
    initCobraToolbox(false, 'nope');
    error('testInitCobraToolbox:noError', ...
        'Expected an error for mode=''nope'' but none was thrown.');
catch ME
    assert(strcmp(ME.identifier, 'initCobraToolbox:invalidMode'), ...
        'Wrong error ID: expected initCobraToolbox:invalidMode, got %s', ME.identifier);
    assert(contains(ME.message, 'runmat'), ...
        'Error message should list accepted values including ''runmat''.');
end
try
    initCobraToolbox(true, 'runmat');
    error('testInitCobraToolbox:noError', ...
        'Expected an error for updateToolbox=true with mode=''runmat'' but none was thrown.');
catch ME
    assert(strcmp(ME.identifier, 'initCobraToolbox:invalidMode'), ...
        'Wrong error ID: expected initCobraToolbox:invalidMode, got %s', ME.identifier);
    assert(contains(ME.message, 'runmat') && contains(ME.message, 'updateToolbox'), ...
        'Error message should name the combination updateToolbox = true with ''runmat''.');
end
fprintf('PASSED\n');

% -------------------------------------------------------------------------
% Test 2: agent mode — fast init, globals set, git config untouched
% -------------------------------------------------------------------------
fprintf('  Test 2: initCobraToolbox(false, ''agent'') ...\n');

% reset the idempotency guard so that agent mode really runs here
CBT_INITIALIZED = false;
initCobraToolbox(false, 'agent');

% globals must be set
assert(~isempty(CBTDIR) && ischar(CBTDIR), 'CBTDIR not set after agent init');
assert(isstruct(SOLVERS) && ~isempty(fieldnames(SOLVERS)), 'SOLVERS not set after agent init');
assert(iscell(OPT_PROB_TYPES) && ~isempty(OPT_PROB_TYPES), 'OPT_PROB_TYPES not set after agent init');

% global git http.sslVerify must be unchanged
[~, sslAfterAgent] = system('git config --global --get http.sslVerify 2>/dev/null');
sslAfterAgent = strtrim(sslAfterAgent);
assert(strcmp(sslBefore, sslAfterAgent), ...
    'http.sslVerify was modified by agent mode (before=''%s'', after=''%s'')', ...
    sslBefore, sslAfterAgent);

% solver flags must match the local checks: a solver that is not present must
% not be reported installed or working (otherwise tests fail instead of skip)
solverPresent = struct( ...
    'glpk', exist('glpkmex', 'file') >= 2, ...
    'pdco', exist('pdco', 'file') >= 2, ...
    'mosek', exist('mosekopt', 'file') >= 2, ...
    'matlab', ~isempty(ver('optim')) && license('test', 'Optimization_Toolbox'));
for solverName = fieldnames(solverPresent)'
    sname = solverName{1};
    assert(isequal(SOLVERS.(sname).installed, solverPresent.(sname)) ...
        && isequal(SOLVERS.(sname).working, solverPresent.(sname)), ...
        'Agent mode: SOLVERS.%s installed=%d working=%d, but the local check gives %d', ...
        sname, SOLVERS.(sname).installed, SOLVERS.(sname).working, solverPresent.(sname));
end

% the NLP default is set only when its solver is present
assert(isequal(strcmp(CBT_NLP_SOLVER, 'matlab'), solverPresent.matlab), ...
    'Agent mode: CBT_NLP_SOLVER is ''%s'' but the Optimization Toolbox check gives %d', ...
    CBT_NLP_SOLVER, solverPresent.matlab);

% no thermochemistry new/ folder may remain on the path (as in default mode)
thermoBase = strrep(which('initVonBertalanffy'), ['vonBertalanffy' filesep 'initVonBertalanffy.m'], '');
pathEntries = strsplit(path, pathsep);
newFolders = pathEntries(startsWith(pathEntries, thermoBase) & contains(pathEntries, [filesep 'new']));
assert(isempty(newFolders), 'Agent mode left %d thermochemistry new/ folder(s) on the path, e.g. %s', ...
    numel(newFolders), strjoin(newFolders(1:min(1, end)), ''));

% where mosek is present, it must be selectable as LP solver without validation
if solverPresent.mosek
    [solverOK, ~] = changeCobraSolver('mosek', 'LP', 0);
    assert(solverOK == 1, 'changeCobraSolver(''mosek'',''LP'',0) failed after agent init');
end

fprintf('  Test 2: PASSED\n');

% -------------------------------------------------------------------------
% Test 5: 'runmat' mode in MATLAB equals 'agent' mode (CBTDIR, COBRA path)
% Each mode starts from the same path with every entry under CBTDIR removed
% except CBTDIR itself (where initCobraToolbox.m lives), so the comparison
% sees exactly the entries each mode adds.
% -------------------------------------------------------------------------
fprintf('  Test 5: initCobraToolbox(false, ''runmat'') equals agent mode ...\n');

originalPath = path;
cbtRoot = CBTDIR;
pathEntries = strsplit(originalPath, pathsep);
isUnderRoot = startsWith(pathEntries, [cbtRoot filesep]);
strippedPath = strjoin(pathEntries(~isUnderRoot), pathsep);

path(strippedPath);
CBT_INITIALIZED = false;
initCobraToolbox(false, 'agent');
agentRoot = CBTDIR;
agentEntries = strsplit(path, pathsep);
agentEntries = sort(agentEntries(startsWith(agentEntries, [agentRoot filesep])));

path(strippedPath);
CBT_INITIALIZED = false;
initCobraToolbox(false, 'runmat');
runmatRoot = CBTDIR;
runmatEntries = strsplit(path, pathsep);
runmatEntries = sort(runmatEntries(startsWith(runmatEntries, [runmatRoot filesep])));

assert(ischar(runmatRoot) && strcmp(runmatRoot, agentRoot), ...
    'CBTDIR differs: agent ''%s'', runmat ''%s''', agentRoot, runmatRoot);
assert(isequal(runmatEntries, agentEntries), ...
    'COBRA path entries differ between agent mode (%d) and runmat mode (%d)', ...
    numel(agentEntries), numel(runmatEntries));
assert(isstruct(SOLVERS) && ~isempty(fieldnames(SOLVERS)), 'SOLVERS not set after runmat init');
assert(iscell(OPT_PROB_TYPES) && ~isempty(OPT_PROB_TYPES), 'OPT_PROB_TYPES not set after runmat init');

[~, sslAfterRunmat] = system('git config --global --get http.sslVerify 2>/dev/null');
sslAfterRunmat = strtrim(sslAfterRunmat);
assert(strcmp(sslBefore, sslAfterRunmat), ...
    'http.sslVerify was modified by runmat mode (before=''%s'', after=''%s'')', ...
    sslBefore, sslAfterRunmat);

path(originalPath);
fprintf('  Test 5: PASSED\n');

% -------------------------------------------------------------------------
% Test 1: default mode (regression) — omit mode, globals set, sslVerify
% unchanged overall (it is set then restored internally).
% The idempotency guard usually returns early here, so the default-mode banner
% (a desktop hyperlink when usejava('desktop') is true) is checked by running
% initCobraToolbox(false) after clear global (feature 20261104-001324, T013).
% NOTE: this test performs a full init including git/network operations;
% it may take ~30 s and requires an internet connection.
% -------------------------------------------------------------------------
fprintf('  Test 1: initCobraToolbox(false) regression (full init) ...\n');

initCobraToolbox(false);

assert(~isempty(CBTDIR) && ischar(CBTDIR), 'CBTDIR not set after default init');
assert(isstruct(SOLVERS) && ~isempty(fieldnames(SOLVERS)), 'SOLVERS not set after default init');
assert(iscell(OPT_PROB_TYPES) && ~isempty(OPT_PROB_TYPES), 'OPT_PROB_TYPES not set after default init');

[~, sslAfterDefault] = system('git config --global --get http.sslVerify 2>/dev/null');
sslAfterDefault = strtrim(sslAfterDefault);
assert(strcmp(sslBefore, sslAfterDefault), ...
    'http.sslVerify not restored after default init (before=''%s'', after=''%s'')', ...
    sslBefore, sslAfterDefault);

fprintf('  Test 1: PASSED\n');

fprintf('All initCobraToolbox tests PASSED.\n');
