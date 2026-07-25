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
%                      always runs in this mode so the coverage gate keeps its
%                      thorough baseline.
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
%      1. the CI environment (`COBRA_CI == '1'`) always resolves to 'full';
%      2. the global variable `CBT_TEST_MODE`, if set to 'fast'/'full';
%      3. the environment variable `COBRA_TEST_MODE`, if set to 'fast'/'full';
%      4. otherwise the default, 'fast'.
%    Any set value other than 'fast'/'full' raises COBRA:testMode:invalid.
%
% .. Author: - COBRA Toolbox, feature 002-testall-performance-modes.

    global CBT_TEST_MODE

    validModes = {'fast', 'full'};

    % 1. CI always forces full mode (keeps the 001 coverage-gate baseline).
    if strcmp(getenv('COBRA_CI'), '1')
        mode = 'full';
    else
        mode = '';

        % 2. global override
        if ~isempty(CBT_TEST_MODE)
            mode = validateMode(CBT_TEST_MODE, validModes, 'global CBT_TEST_MODE');
        end

        % 3. environment variable
        if isempty(mode)
            envMode = getenv('COBRA_TEST_MODE');
            if ~isempty(envMode)
                mode = validateMode(envMode, validModes, 'environment variable COBRA_TEST_MODE');
            end
        end

        % 4. default
        if isempty(mode)
            mode = 'fast';
        end
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
