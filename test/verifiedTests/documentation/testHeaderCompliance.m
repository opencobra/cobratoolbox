% The COBRAToolbox: testHeaderCompliance.m
%
% Purpose:
%     - Standing CI gate for feature 014-src-header-compliance. Scans every
%       in-scope src/*.m file with checkHeaderCompliance and asserts that no
%       file has an error-severity function-header violation (SC-001, SC-007).
%     - This is a script-based unit test: it is discovered and run by
%       runtests(...) and by test/testAll.m via runTestSuite (which runs each
%       test file as a script). It uses only base MATLAB, no solver, internet,
%       GUI, or initCobraToolbox.
%
% Note:
%     - On the un-remediated tree this test is EXPECTED to FAIL: that proves it
%       detects the real header violations catalogued in the baseline report.
%       It turns green only once the headers are remediated to zero
%       error-severity violations. Do not weaken the assertion to pass.
%
% Authors:
%     - Feature 014-src-header-compliance, US1 CI gate (T004)

% make the checker and its helpers resolvable even when this file is run
% directly by runtests (without initCobraToolbox having added the folder)
scriptDir = fileparts(mfilename('fullpath'));
if isempty(scriptDir)
    scriptDir = fileparts(which('testHeaderCompliance'));
end
addpath(scriptDir);

% run the checker over the whole in-scope src tree (quiet)
report = checkHeaderCompliance('src', 0);

% collect the error-severity violations that block the gate
if isempty(report.violations)
    errorViolations = report.violations;
else
    errorViolations = report.violations(strcmp({report.violations.severity}, 'error'));
end
numErrors = numel(errorViolations);

% build an informative diagnostic for CI logs (top offending rules)
if numErrors > 0
    ruleIds = {errorViolations.ruleId};
    uniqueRules = unique(ruleIds);
    counts = zeros(numel(uniqueRules), 1);
    for r = 1:numel(uniqueRules)
        counts(r) = sum(strcmp(ruleIds, uniqueRules{r}));
    end
    [counts, order] = sort(counts, 'descend');
    uniqueRules = uniqueRules(order);
    ruleSummary = '';
    for r = 1:numel(uniqueRules)
        ruleSummary = [ruleSummary sprintf('\n    %-12s %d', uniqueRules{r}, counts(r))]; %#ok<AGROW>
    end
    example = errorViolations(1);
    diagnostic = sprintf(['%d error-severity src/ function-header violation(s) found ' ...
        'across %d in-scope file(s).\nPer-rule counts:%s\nExample: %s [%s] %s'], ...
        numErrors, report.totals.inScope, ruleSummary, example.file, example.ruleId, example.detail);
else
    diagnostic = 'All in-scope src/ function headers are compliant.';
end

% the gate: zero error-severity in-scope violations
assert(numErrors == 0, diagnostic);

fprintf('%s\n', diagnostic);
