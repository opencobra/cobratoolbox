% The COBRAToolbox: testInitCobraToolboxAgentMode.m
%
% Purpose:
%     - Test the 'agent' fast-path and argument-validation added to
%       initCobraToolbox(updateToolbox, mode).
%
%     Test 1 (regression): mode omitted — globals set, sslVerify unchanged.
%     Test 2 (agent mode): initCobraToolbox(false, 'agent') sets CBTDIR,
%       SOLVERS, OPT_PROB_TYPES; leaves global http.sslVerify unchanged;
%       leaves a usable default LP solver.
%     Test 3 (invalid mode): initCobraToolbox(false, 'nope') raises
%       initCobraToolbox:invalidMode.
%
% Authors:
%     - Ronan M.T. Fleming, June 2026
%

global CBTDIR SOLVERS OPT_PROB_TYPES ENV_VARS

% Test 2 hard-asserts mosek is selectable; require it and skip gracefully if absent
prepareTest('requiredSolvers', {'mosek'});

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
    error('testInitCobraToolboxAgentMode:noError', ...
        'Expected an error for mode=''nope'' but none was thrown.');
catch ME
    assert(strcmp(ME.identifier, 'initCobraToolbox:invalidMode'), ...
        'Wrong error ID: expected initCobraToolbox:invalidMode, got %s', ME.identifier);
    assert(~isempty(strfind(ME.message, 'agent')), ...
        'Error message should list accepted values including ''agent''.');
end
fprintf('PASSED\n');

% -------------------------------------------------------------------------
% Test 2: agent mode — fast init, globals set, git config untouched
% -------------------------------------------------------------------------
fprintf('  Test 2: initCobraToolbox(false, ''agent'') ...\n');

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

% a default LP solver must be selectable without validation
[solverOK, ~] = changeCobraSolver('mosek', 'LP', 0);
assert(solverOK == 1, 'changeCobraSolver(''mosek'',''LP'',0) failed after agent init');

fprintf('  Test 2: PASSED\n');

% -------------------------------------------------------------------------
% Test 1: default mode (regression) — omit mode, globals set, sslVerify
% unchanged overall (it is set then restored internally).
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

fprintf('All initCobraToolbox agent-mode tests PASSED.\n');
