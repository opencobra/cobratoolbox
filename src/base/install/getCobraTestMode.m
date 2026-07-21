function result = getCobraTestMode(query)
% Resolve the effective COBRA test-suite execution mode.
%
% The COBRA Toolbox test suite runs in one of two modes:
%
%   'fast' (default) - reduces redundant work (per-test loops over every
%                      installed solver when the assertions are solver
%                      independent, large-model re-parsing, dead waits,
%                      duplicated model builds) while preserving essentially
%                      the same code coverage.
%   'full'           - runs the complete, slower suite exactly as before this
%                      feature (no fast-mode trimming). Continuous integration
%                      runs in this mode by default so the coverage gate keeps
%                      its thorough baseline, unless a mode is requested
%                      explicitly (see NOTE).
%
% USAGE:
%    mode = getCobraTestMode()
%    tf   = getCobraTestMode('isFast')
%
% OPTIONAL INPUT:
%    query:     if 'isFast', return a logical that is true when the effective
%               mode is 'fast'. Any other value returns the mode string.
%
% OUTPUT:
%    result:    the mode string 'fast' or 'full', or (for 'isFast') a logical.
%
% NOTE:
%    Resolution order (highest precedence first):
%      1. the global variable `CBT_TEST_MODE`, if set to 'fast'/'full';
%      2. the environment variable `COBRA_TEST_MODE`, if set to 'fast'/'full';
%      3. the CI environment (`COBRA_CI == '1'`) defaults to 'full' when no
%         explicit mode (1 or 2) is set;
%      4. otherwise the default, 'fast'.
%    An explicit mode (1 or 2) is honoured even under CI. Any set value other
%    than 'fast'/'full' raises COBRA:testMode:invalid.
%
% .. Author: - COBRA Toolbox, feature 002-testall-performance-modes.

    global CBT_TEST_MODE

    validModes = {'fast', 'full'};

    mode = '';

    % 1. explicit global override (highest precedence, honoured even in CI)
    if ~isempty(CBT_TEST_MODE)
        mode = validateMode(CBT_TEST_MODE, validModes, 'global CBT_TEST_MODE');
    end

    % 2. explicit environment override (honoured even in CI)
    if isempty(mode)
        envMode = getenv('COBRA_TEST_MODE');
        if ~isempty(envMode)
            mode = validateMode(envMode, validModes, 'environment variable COBRA_TEST_MODE');
        end
    end

    % 3. CI default: full when the workflow requests no explicit mode, so the
    %    001 coverage-gate baseline stays thorough by default.
    if isempty(mode) && strcmp(getenv('COBRA_CI'), '1')
        mode = 'full';
    end

    % 4. default
    if isempty(mode)
        mode = 'fast';
    end

    if nargin > 0 && ischar(query) && strcmpi(query, 'isFast')
        result = strcmp(mode, 'fast');
    else
        result = mode;
    end
end

function mode = validateMode(value, validModes, sourceName)
% Normalise and validate a mode string, erroring on anything unexpected.
    if ~ischar(value) && ~(isstring(value) && isscalar(value))
        error('COBRA:testMode:invalid', ...
            'The COBRA test mode from %s must be a string; accepted values are ''fast'' or ''full''.', ...
            sourceName);
    end
    mode = lower(char(value));
    if ~any(strcmp(mode, validModes))
        error('COBRA:testMode:invalid', ...
            'Invalid COBRA test mode ''%s'' from %s; accepted values are ''fast'' or ''full''.', ...
            mode, sourceName);
    end
end
