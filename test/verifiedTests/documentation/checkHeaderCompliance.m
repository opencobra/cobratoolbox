function report = checkHeaderCompliance(scopePath, printLevel)
% Scan a scope of src for function-header violations and return a compliance report
%
% Walks every `*.m` file under `scopePath`, classifies each file, runs
% `checkFunctionHeaders` on it, and assembles the machine-readable
% `ComplianceReport` defined in
% `specs/014-src-header-compliance/data-model.md`. Pure text analysis: no
% solver, internet, GUI, or `initCobraToolbox`.
%
% USAGE:
%
%    report = checkHeaderCompliance(scopePath, printLevel)
%
% OPTIONAL INPUTS:
%    scopePath:         char, folder to scan, absolute or repo-relative
%                       (default `src`). A relative path is resolved against
%                       the repository root when not found from the cwd.
%    printLevel:        double, 0 = quiet (default), 1 = print a per-domain
%                       summary. Console output is minimal and gated.
%
% OUTPUT:
%    report:            struct, the ComplianceReport, with fields:
%
%                         * .generatedFrom - the resolved absolute scope path
%                         * .totals - struct with counts: filesScanned,
%                           inScope, functions, scripts, excluded
%                         * .perDomain - table of domain -> files,
%                           filesWithViolations, errorViolations,
%                           warningViolations
%                         * .perRule - table of ruleId -> count
%                         * .violations - struct array of all Violation entries
%                         * .excluded - struct array of excluded files
%                           (.file, .reason)
%
% .. Author: - Feature 014-src-header-compliance, US1 report generator (T004/T007)

    if ~exist('scopePath', 'var') || isempty(scopePath)
        scopePath = 'src';
    end
    if ~exist('printLevel', 'var') || isempty(printLevel)
        printLevel = 0;
    end

    absScope = resolveScope(scopePath);

    listing = dir(fullfile(absScope, '**', '*.m'));
    listing = listing(~[listing.isdir]);

    ruleIds = {'H-EMPTY', 'H-DESC', 'H-PCT', 'H-USAGE', 'H-IN', 'H-OUT', ...
        'H-ARGFMT', 'H-FIELD', 'H-FIELDUSE', 'H-NV', 'H-SIG', 'H-BODYGAP', ...
        'H-AUTHOR'};

    allViolations = struct('file', {}, 'ruleId', {}, 'line', {}, ...
        'detail', {}, 'severity', {});
    excluded = struct('file', {}, 'reason', {});

    nFunctions = 0;
    nScripts = 0;
    nExcluded = 0;

    % Per-file domain bookkeeping accumulated into maps keyed by domain.
    domainNames = {};
    domainFiles = [];
    domainFilesWithViol = [];
    domainErr = [];
    domainWarn = [];

    for i = 1:numel(listing)
        fullPath = fullfile(listing(i).folder, listing(i).name);
        relPath = toRepoRelative(fullPath);
        [viol, classification] = checkFunctionHeaders(fullPath);

        if strcmp(classification, 'excluded-vendored')
            nExcluded = nExcluded + 1;
            [~, reason] = headerComplianceExclusions(relPath);
            if isempty(reason)
                reason = 'licence-guard';
            end
            excluded(end + 1) = struct('file', relPath, 'reason', reason); %#ok<AGROW>
            continue;
        end

        if strcmp(classification, 'function')
            nFunctions = nFunctions + 1;
        else
            nScripts = nScripts + 1;
        end

        domain = domainOf(relPath);
        dIdx = find(strcmp(domainNames, domain), 1);
        if isempty(dIdx)
            domainNames{end + 1} = domain; %#ok<AGROW>
            domainFiles(end + 1) = 0; %#ok<AGROW>
            domainFilesWithViol(end + 1) = 0; %#ok<AGROW>
            domainErr(end + 1) = 0; %#ok<AGROW>
            domainWarn(end + 1) = 0; %#ok<AGROW>
            dIdx = numel(domainNames);
        end
        domainFiles(dIdx) = domainFiles(dIdx) + 1;

        if ~isempty(viol)
            allViolations = [allViolations, viol(:)']; %#ok<AGROW>
            nErr = sum(strcmp({viol.severity}, 'error'));
            nWarn = sum(strcmp({viol.severity}, 'warning'));
            domainErr(dIdx) = domainErr(dIdx) + nErr;
            domainWarn(dIdx) = domainWarn(dIdx) + nWarn;
            if nErr > 0 || nWarn > 0
                domainFilesWithViol(dIdx) = domainFilesWithViol(dIdx) + 1;
            end
        end
    end

    % Sort domains alphabetically for a stable report.
    [domainNames, order] = sort(domainNames);
    domainFiles = domainFiles(order);
    domainFilesWithViol = domainFilesWithViol(order);
    domainErr = domainErr(order);
    domainWarn = domainWarn(order);

    perDomain = table(domainNames(:), domainFiles(:), domainFilesWithViol(:), ...
        domainErr(:), domainWarn(:), 'VariableNames', ...
        {'Domain', 'Files', 'FilesWithViolations', 'ErrorViolations', 'WarningViolations'});

    % Per-rule counts.
    ruleCounts = zeros(numel(ruleIds), 1);
    if ~isempty(allViolations)
        vRules = {allViolations.ruleId};
        for r = 1:numel(ruleIds)
            ruleCounts(r) = sum(strcmp(vRules, ruleIds{r}));
        end
    end
    perRule = table(ruleIds(:), ruleCounts, 'VariableNames', {'RuleId', 'Count'});

    totals = struct('filesScanned', numel(listing), ...
        'inScope', nFunctions + nScripts, ...
        'functions', nFunctions, ...
        'scripts', nScripts, ...
        'excluded', nExcluded);

    report = struct();
    report.generatedFrom = absScope;
    report.totals = totals;
    report.perDomain = perDomain;
    report.perRule = perRule;
    report.violations = allViolations;
    report.excluded = excluded;

    if printLevel >= 1
        nErrTotal = 0;
        if ~isempty(allViolations)
            nErrTotal = sum(strcmp({allViolations.severity}, 'error'));
        end
        fprintf('Header compliance: %d in-scope file(s), %d excluded, %d error-severity violation(s).\n', ...
            totals.inScope, totals.excluded, nErrTotal);
        disp(perDomain);
    end
end

% ===== Local helper functions =====

function absScope = resolveScope(scopePath)
% Resolve a scope path to an absolute folder, anchoring at the repo root
    if exist(scopePath, 'dir') == 7
        absScope = char(java.io.File(scopePath).getCanonicalPath());
        return;
    end
    repoRoot = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
    candidate = fullfile(repoRoot, scopePath);
    if exist(candidate, 'dir') == 7
        absScope = candidate;
        return;
    end
    error('checkHeaderCompliance:scopeNotFound', ...
        'Scope path "%s" was not found from the current folder or the repository root "%s".', ...
        scopePath, repoRoot);
end

function relPath = toRepoRelative(filePath)
% Convert a path to a repo-relative path with forward slashes, anchored at src
    p = strrep(filePath, '\', '/');
    tok = regexp(p, '(src/.*)$', 'tokens', 'once');
    if ~isempty(tok)
        relPath = tok{1};
    else
        [~, nm, ext] = fileparts(p);
        relPath = [nm ext];
    end
end

function domain = domainOf(relPath)
% Return the src domain (second path segment) for a repo-relative path
    parts = strsplit(relPath, '/');
    if numel(parts) >= 2 && strcmp(parts{1}, 'src')
        domain = parts{2};
    else
        domain = 'unknown';
    end
end
