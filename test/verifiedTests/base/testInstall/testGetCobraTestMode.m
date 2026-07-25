% The COBRAToolbox: testGetCobraTestMode.m
%
% Purpose:
%     - test that getCobraTestMode resolves the test execution mode correctly:
%       fast by default, environment/global overrides, CI forces full, and
%       invalid values raise COBRA:testMode:invalid.
%
% Authors:
%     - COBRA Toolbox, feature 002-testall-performance-modes, 2026
%

% save the state so it can be restored regardless of test outcome
origCI = getenv('COBRA_CI');
origEnvMode = getenv('COBRA_TEST_MODE');
global CBT_TEST_MODE
origGlobalMode = CBT_TEST_MODE;

try
    % start from a clean slate (no CI, no env, no global)
    setenv('COBRA_CI', '');
    setenv('COBRA_TEST_MODE', '');
    CBT_TEST_MODE = [];

    % 1. the default mode is fast
    assert(strcmp(getCobraTestMode(), 'fast'));
    assert(getCobraTestMode('isFast') == true);

    % 2. the environment variable selects the mode (case-insensitive)
    setenv('COBRA_TEST_MODE', 'full');
    assert(strcmp(getCobraTestMode(), 'full'));
    assert(getCobraTestMode('isFast') == false);
    setenv('COBRA_TEST_MODE', 'FAST');
    assert(strcmp(getCobraTestMode(), 'fast'));

    % 3. the global variable overrides the environment variable
    CBT_TEST_MODE = 'full';
    assert(strcmp(getCobraTestMode(), 'full'));
    CBT_TEST_MODE = [];

    % 4. the CI environment forces full mode regardless of other settings
    setenv('COBRA_TEST_MODE', 'fast');
    setenv('COBRA_CI', '1');
    assert(strcmp(getCobraTestMode(), 'full'));
    setenv('COBRA_CI', '');

    % 5. an invalid value raises COBRA:testMode:invalid
    setenv('COBRA_TEST_MODE', 'turbo');
    threw = false;
    try
        getCobraTestMode();
    catch ME_invalid
        threw = strcmp(ME_invalid.identifier, 'COBRA:testMode:invalid');
    end
    assert(threw);
    setenv('COBRA_TEST_MODE', '');

catch ME
    % restore state before reporting the failure
    setenv('COBRA_CI', origCI);
    setenv('COBRA_TEST_MODE', origEnvMode);
    CBT_TEST_MODE = origGlobalMode;
    rethrow(ME);
end

% restore the original state
setenv('COBRA_CI', origCI);
setenv('COBRA_TEST_MODE', origEnvMode);
CBT_TEST_MODE = origGlobalMode;
