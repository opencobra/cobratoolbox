function [violations, classification] = checkFunctionHeaders(filePath)
% Check one MATLAB file's primary-function header against the openCOBRA
% documentation-generator rule catalog and return the violations found
%
% The rule catalog is
% `specs/014-src-header-compliance/contracts/header-rules.md`, derived from
% `documentation/source/guides/documentationGuide.rst`. Only the PRIMARY
% (first) function's header is evaluated (the comment block between the
% signature line and the first executable line); sub/local functions are out
% of scope. The file is classified first: a `function` file gets the full
% catalog, a `script` (or `classdef`) file gets only H-DESC and H-PCT, and an
% excluded-vendored file gets no rules and an empty result.
%
% Precision over recall: a rule is only emitted where the violation can be
% detected reliably from static text plus light body regex. Aspects that
% cannot be evaluated without false positives are deliberately not flagged and
% are noted inline (H-USAGE blank-line placement, H-FIELD indent alignment,
% the non-inputParser name-value idioms for H-NV).
%
% Counting convention: block-presence and line-format rules (H-EMPTY, H-DESC,
% H-PCT, H-USAGE, H-FIELD, H-BODYGAP, H-SIG, H-AUTHOR) emit at most one
% violation per file; per-argument and per-field rules (H-IN, H-OUT, H-ARGFMT,
% H-NV, H-FIELDUSE) emit one violation per offending argument/input.
%
% USAGE:
%
%    [violations, classification] = checkFunctionHeaders(filePath)
%
% INPUT:
%    filePath:          char, path to the `.m` file to check (absolute or
%                       relative). Only the file text is read; no code is run.
%
% OUTPUTS:
%    violations:        struct array of header-rule violations, each with fields:
%
%                         * .file - repo-relative path of the checked file
%                         * .ruleId - the rule id that failed (e.g. `H-OUT`)
%                         * .line - 1-indexed offending line (0 if whole-header)
%                         * .detail - human-readable specifics of the failure
%                         * .severity - `error` (blocks the gate) or `warning`
%    classification:    char, one of `function`, `script`, or
%                       `excluded-vendored` (data-model.md FileClassification)
%
% NOTE:
%    Pure base MATLAB only (`fileread`, `regexp`); no solver, internet, GUI,
%    or `initCobraToolbox`. Safe to run headless over the whole `src/` tree.
%
% .. Author: - Feature 014-src-header-compliance, US1 checker (T003)

    violations = emptyViolation();
    classification = 'script';

    if ~exist('filePath', 'var') || isempty(filePath)
        error('checkFunctionHeaders:noInput', ...
            'A file path is required. Provide the path to a .m file to check.');
    end

    relPath = toRepoRelative(filePath);

    % Read the file text; a read failure is surfaced, not swallowed.
    try
        raw = fileread(filePath);
    catch ME
        if ~isempty(ME.stack)
            error('checkFunctionHeaders:readFailed', ...
                'Could not read "%s": %s (%s line %d).', filePath, ME.message, ...
                ME.stack(1).name, ME.stack(1).line);
        else
            error('checkFunctionHeaders:readFailed', ...
                'Could not read "%s": %s.', filePath, ME.message);
        end
    end

    lines = splitLines(raw);
    n = numel(lines);

    % Classify each line as comment / blank / code.
    isComment = false(n, 1);
    isBlank = false(n, 1);
    for i = 1:n
        t = strtrim(lines{i});
        if isempty(t)
            isBlank(i) = true;
        elseif t(1) == '%'
            isComment(i) = true;
        end
    end
    isCode = ~isComment & ~isBlank;

    firstCodeIdx = find(isCode, 1, 'first');

    % Determine classification and the primary-function structure.
    isFunctionFile = false;
    sigStart = 0;
    sigEnd = 0;
    if ~isempty(firstCodeIdx)
        firstCode = strtrim(lines{firstCodeIdx});
        if ~isempty(regexp(firstCode, '^function\>', 'once'))
            isFunctionFile = true;
            classification = 'function';
            sigStart = firstCodeIdx;
            sigEnd = signatureEnd(lines, sigStart);
        elseif ~isempty(regexp(firstCode, '^classdef\>', 'once'))
            % classdef files: treat as script-like (H-DESC, H-PCT only) to
            % avoid misparsing method signatures as the primary header.
            classification = 'script';
        else
            classification = 'script';
        end
    end

    % Compute the header region and the first body line.
    if isFunctionFile
        headerIdx = (sigEnd + 1):n;
        bodyRel = find(isCode(sigEnd + 1:end), 1, 'first');
        if isempty(bodyRel)
            firstBodyIdx = 0;
        else
            firstBodyIdx = sigEnd + bodyRel;
            headerIdx = (sigEnd + 1):(firstBodyIdx - 1);
        end
    else
        % script/classdef: header is the leading comment block before code.
        if isempty(firstCodeIdx)
            headerIdx = 1:n;
        else
            headerIdx = 1:(firstCodeIdx - 1);
        end
        firstBodyIdx = firstCodeIdx;
    end

    headerLines = lines(headerIdx);
    headerAbs = headerIdx(:);
    headerText = strjoin(headerLines, newline);

    % Exclusion check (subtree glob + file-level licence guard on the header).
    [isExcluded, ~] = headerComplianceExclusions(relPath, headerText);
    if isExcluded
        classification = 'excluded-vendored';
        violations = emptyViolation();
        return;
    end

    % Identify header comment lines (documentation content candidates).
    headerIsComment = false(numel(headerLines), 1);
    for i = 1:numel(headerLines)
        t = strtrim(headerLines{i});
        headerIsComment(i) = ~isempty(t) && t(1) == '%';
    end

    % Assign each header line to a keyword block (DESC before any keyword).
    blockOf = repmat({'DESC'}, numel(headerLines), 1);
    isKeywordLine = false(numel(headerLines), 1);
    current = 'DESC';
    for i = 1:numel(headerLines)
        kw = keywordOf(headerLines{i});
        if ~isempty(kw)
            current = kw;
            isKeywordLine(i) = true;
        end
        blockOf{i} = current;
    end

    % ---- H-PCT (both): one space after % on every content line ----
    pctLine = 0;
    pctCount = 0;
    for i = 1:numel(headerLines)
        if headerIsComment(i) && isMissingSpaceAfterPercent(headerLines{i})
            pctCount = pctCount + 1;
            if pctLine == 0
                pctLine = headerAbs(i);
            end
        end
    end
    if pctCount > 0
        violations(end + 1) = makeViolation(relPath, 'H-PCT', pctLine, ...
            sprintf('%d header line(s) have no space after %% (e.g. %%text); the generator ignores them', pctCount), ...
            'error');
    end

    % ---- H-DESC (both): a description line before the first keyword ----
    hasDescription = false;
    for i = 1:numel(headerLines)
        if headerIsComment(i) && strcmp(blockOf{i}, 'DESC') && ~isKeywordLine(i) ...
                && isContentLine(headerLines{i})
            hasDescription = true;
            break;
        end
    end
    anyHeaderComment = any(headerIsComment);

    if isFunctionFile
        % ---- H-EMPTY (function): at least one header comment line ----
        if ~anyHeaderComment
            headerLine0 = sigEnd + 1;
            violations(end + 1) = makeViolation(relPath, 'H-EMPTY', headerLine0, ...
                'Function header is empty: the signature is not followed by any comment line', ...
                'error');
        elseif ~hasDescription
            violations(end + 1) = makeViolation(relPath, 'H-DESC', firstHeaderLine(headerAbs, headerIsComment), ...
                'Header does not open with a description line before the first keyword block', ...
                'error');
        end
    else
        % scripts/classdef: only H-DESC and H-PCT apply.
        if ~hasDescription
            ln = firstHeaderLine(headerAbs, headerIsComment);
            violations(end + 1) = makeViolation(relPath, 'H-DESC', ln, ...
                'Script header has no description line', 'error');
        end
        return;
    end

    % ===== Function-only rules below =====

    % Parse the primary signature.
    sigRaw = joinSignature(lines, sigStart, sigEnd);
    sig = parseSignature(sigRaw);

    % ---- H-SIG (function): canonical signature spacing ----
    sigIssues = signatureSpacingIssues(sigRaw);
    if ~isempty(sigIssues)
        violations(end + 1) = makeViolation(relPath, 'H-SIG', sigStart, ...
            ['Signature spacing not canonical: ' strjoin(sigIssues, '; ')], 'error');
    end

    % ---- H-USAGE (function): USAGE block present with the call signature ----
    usageIdx = find(strcmp(blockOf, 'USAGE') & isKeywordLine, 1, 'first');
    if isempty(usageIdx)
        violations(end + 1) = makeViolation(relPath, 'H-USAGE', firstHeaderLine(headerAbs, headerIsComment), ...
            'No USAGE: block found in the header', 'error');
    elseif ~isempty(sig.name)
        usageBlock = strjoin(headerLines(strcmp(blockOf, 'USAGE')), newline);
        if isempty(regexp(usageBlock, ['\<' regexptranslate('escape', sig.name) '\s*\('], 'once'))
            violations(end + 1) = makeViolation(relPath, 'H-USAGE', headerAbs(usageIdx), ...
                sprintf('USAGE: block does not contain the call signature for %s(...)', sig.name), ...
                'error');
        end
    end

    % Input / output documentation regions.
    inMask = strcmp(blockOf, 'INPUT');
    outMask = strcmp(blockOf, 'OUTPUT');
    inLines = headerLines(inMask);
    inAbs = headerAbs(inMask);
    outLines = headerLines(outMask);
    outAbs = headerAbs(outMask);

    % ---- H-IN (function) and H-ARGFMT for inputs ----
    for k = 1:numel(sig.inputs)
        name = sig.inputs{k};
        if strcmp(name, 'varargin')
            continue;
        end
        [status, ln] = checkArgDoc(inLines, inAbs, name);
        switch status
            case 'missing'
                violations(end + 1) = makeViolation(relPath, 'H-IN', 0, ...
                    sprintf('input "%s" is declared but not documented in an INPUTS/OPTIONAL INPUTS block', name), ...
                    'error');
            case 'nocolon'
                violations(end + 1) = makeViolation(relPath, 'H-ARGFMT', ln, ...
                    sprintf('input "%s" documentation line has no colon after the name', name), 'error');
            case 'indent'
                violations(end + 1) = makeViolation(relPath, 'H-ARGFMT', ln, ...
                    sprintf('input "%s" documentation line is not indented 4 spaces after %%', name), 'error');
            case 'gap'
                violations(end + 1) = makeViolation(relPath, 'H-ARGFMT', ln, ...
                    sprintf('input "%s" has fewer than 4 spaces between the colon and its description', name), 'error');
        end
    end

    % ---- H-OUT (function) and H-ARGFMT for outputs ----
    for k = 1:numel(sig.outputs)
        name = sig.outputs{k};
        [status, ln] = checkArgDoc(outLines, outAbs, name);
        switch status
            case 'missing'
                violations(end + 1) = makeViolation(relPath, 'H-OUT', 0, ...
                    sprintf('output "%s" is declared but not documented in an OUTPUTS block', name), ...
                    'error');
            case 'nocolon'
                violations(end + 1) = makeViolation(relPath, 'H-ARGFMT', ln, ...
                    sprintf('output "%s" documentation line has no colon after the name', name), 'error');
            case 'indent'
                violations(end + 1) = makeViolation(relPath, 'H-ARGFMT', ln, ...
                    sprintf('output "%s" documentation line is not indented 4 spaces after %%', name), 'error');
            case 'gap'
                violations(end + 1) = makeViolation(relPath, 'H-ARGFMT', ln, ...
                    sprintf('output "%s" has fewer than 4 spaces between the colon and its description', name), 'error');
        end
    end

    % Body text (used for H-NV and H-FIELDUSE static interrogation). Strip
    % comments per line first: a `name.field` mention inside a comment (e.g. an
    % illustrative "% see model.field" or a "model.rxn" typo in a comment) is
    % NOT a real field read and must not force documentation of a phantom field.
    % Stripping at % may truncate a rare in-string %, causing under-detection
    % only (precision over recall), never a false positive.
    if firstBodyIdx > 0
        bodyCode = regexprep(lines(firstBodyIdx:end), '%.*$', '');
        bodyText = strjoin(bodyCode, newline);
    else
        bodyText = '';
    end

    % ---- H-NV (function, where detectable): consumed name-value params ----
    if any(strcmp(sig.inputs, 'varargin')) && ~isempty(bodyText)
        nvNames = inputParserParams(bodyText);
        for k = 1:numel(nvNames)
            name = nvNames{k};
            if any(strcmp(sig.inputs, name))
                continue;  % a positional arg, covered by H-IN
            end
            if isempty(regexp(headerText, ['\<' regexptranslate('escape', name) '\>'], 'once'))
                violations(end + 1) = makeViolation(relPath, 'H-NV', 0, ...
                    sprintf('name-value parameter "%s" is consumed from varargin (inputParser) but not documented', name), ...
                    'error');
            end
        end
    end

    % ---- H-FIELD (function): struct field sub-bullet format ----
    fieldFmtLine = 0;
    fieldFmtCount = 0;
    for i = 1:numel(headerLines)
        if ~isempty(regexp(headerLines{i}, '^\s*%\s*\*\.', 'once'))
            fieldFmtCount = fieldFmtCount + 1;
            if fieldFmtLine == 0
                fieldFmtLine = headerAbs(i);
            end
        end
    end
    if fieldFmtCount > 0
        violations(end + 1) = makeViolation(relPath, 'H-FIELD', fieldFmtLine, ...
            sprintf('%d struct-field bullet(s) use "*.field" instead of "* .field" (missing space after *)', fieldFmtCount), ...
            'error');
    end

    % ---- H-FIELDUSE (function, where detectable): used struct fields documented ----
    if ~isempty(bodyText)
        for k = 1:numel(sig.inputs)
            name = sig.inputs{k};
            if strcmp(name, 'varargin')
                continue;
            end
            % Only interrogate inputs that are actually documented (else H-IN
            % already flags the bigger gap and this would double-report).
            [st, ~] = checkArgDoc(inLines, inAbs, name);
            if ~strcmp(st, 'ok') && ~strcmp(st, 'gap') && ~strcmp(st, 'indent') && ~strcmp(st, 'nocolon')
                continue;
            end
            usedFields = structFieldReads(bodyText, name);
            missing = {};
            for f = 1:numel(usedFields)
                fld = usedFields{f};
                if isempty(regexp(headerText, ['\.' regexptranslate('escape', fld) '\>'], 'once'))
                    missing{end + 1} = fld; %#ok<AGROW>
                end
            end
            if ~isempty(missing)
                shown = missing;
                suffix = '';
                if numel(shown) > 12
                    shown = shown(1:12);
                    suffix = ', ...';
                end
                violations(end + 1) = makeViolation(relPath, 'H-FIELDUSE', 0, ...
                    sprintf('input "%s": field(s) .%s%s read in the body but not documented', ...
                    name, strjoin(shown, ', .'), suffix), 'error');
            end
        end
    end

    % ---- H-BODYGAP (function, warning): one blank line before the body ----
    if firstBodyIdx > 1
        prevLine = strtrim(lines{firstBodyIdx - 1});
        if ~isempty(prevLine) && prevLine(1) == '%'
            violations(end + 1) = makeViolation(relPath, 'H-BODYGAP', firstBodyIdx - 1, ...
                'A comment line sits directly above the first code line (no blank line before the body)', ...
                'warning');
        end
    end

    % ---- H-AUTHOR (function, warning): provenance lines prefixed with .. ----
    for i = 1:numel(headerLines)
        ln = headerLines{i};
        if ~isempty(regexp(ln, '^\s*%\s*[Aa]uthors?\>', 'once')) ...
                && isempty(regexp(ln, '\.\.', 'once'))
            violations(end + 1) = makeViolation(relPath, 'H-AUTHOR', headerAbs(i), ...
                'Author/Authors provenance line is not prefixed with "% .." and will render in the docs', ...
                'warning');
            break;
        end
    end
end

% ===== Local helper functions =====

function v = emptyViolation()
% Return a 0x0 struct array with the Violation fields
    v = struct('file', {}, 'ruleId', {}, 'line', {}, 'detail', {}, 'severity', {});
end

function v = makeViolation(file, ruleId, line, detail, severity)
% Build a single Violation struct
    v = struct('file', file, 'ruleId', ruleId, 'line', line, ...
        'detail', detail, 'severity', severity);
end

function lines = splitLines(raw)
% Split file text into a cell array of lines, tolerant of CRLF and CR
    raw = strrep(raw, sprintf('\r\n'), newline);
    raw = strrep(raw, sprintf('\r'), newline);
    lines = strsplit(raw, newline, 'CollapseDelimiters', false);
    lines = lines(:);
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

function sigEnd = signatureEnd(lines, sigStart)
% Return the index of the last line of a (possibly continued) signature
    sigEnd = sigStart;
    n = numel(lines);
    while sigEnd <= n
        code = regexprep(lines{sigEnd}, '%.*$', '');
        if ~isempty(regexp(strtrim(code), '\.\.\.$', 'once')) && sigEnd < n
            sigEnd = sigEnd + 1;
        else
            break;
        end
    end
end

function sigRaw = joinSignature(lines, sigStart, sigEnd)
% Join a multi-line signature into one string, stripping continuations/comment
    parts = cell(sigEnd - sigStart + 1, 1);
    for i = sigStart:sigEnd
        code = regexprep(lines{i}, '%.*$', '');
        code = regexprep(code, '\.\.\.\s*$', '');
        parts{i - sigStart + 1} = strtrim(code);
    end
    sigRaw = strtrim(strjoin(parts, ' '));
end

function sig = parseSignature(sigRaw)
% Parse a function signature into name, inputs, and outputs
    sig = struct('name', '', 'inputs', {{}}, 'outputs', {{}});
    body = regexprep(sigRaw, '^function\s*', '');
    eqPos = regexp(body, '=', 'once');
    if ~isempty(eqPos)
        outPart = strtrim(body(1:eqPos - 1));
        rest = strtrim(body(eqPos + 1:end));
        outPart = regexprep(outPart, '^\[', '');
        outPart = regexprep(outPart, '\]$', '');
        sig.outputs = tokenizeNames(outPart);
    else
        rest = strtrim(body);
    end
    nameTok = regexp(rest, '^(\w+)', 'tokens', 'once');
    if ~isempty(nameTok)
        sig.name = nameTok{1};
    end
    inTok = regexp(rest, '\((.*)\)', 'tokens', 'once');
    if ~isempty(inTok)
        sig.inputs = tokenizeNames(inTok{1});
    end
end

function names = tokenizeNames(str)
% Split a comma-separated argument list into trimmed, non-empty names
    names = {};
    if isempty(strtrim(str))
        return;
    end
    parts = strsplit(str, ',');
    for i = 1:numel(parts)
        nm = strtrim(parts{i});
        if ~isempty(nm) && ~strcmp(nm, '~')
            names{end + 1} = nm; %#ok<AGROW>
        end
    end
end

function issues = signatureSpacingIssues(sigRaw)
% Detect canonical-spacing violations in a signature (H-SIG)
    issues = {};
    if ~isempty(regexp(sigRaw, ',\S', 'once'))
        issues{end + 1} = 'missing space after a comma';
    end
    if ~isempty(regexp(sigRaw, '\S=|=\S', 'once'))
        issues{end + 1} = 'missing space around =';
    end
    if ~isempty(regexp(sigRaw, '\[\s|\s\]', 'once'))
        issues{end + 1} = 'space padding inside [ ]';
    end
    if ~isempty(regexp(sigRaw, '\(\s|\s\)', 'once'))
        issues{end + 1} = 'space padding inside ( )';
    end
end

function kw = keywordOf(line)
% Return the canonical keyword block name for a header line, or '' if none
    kw = '';
    % A keyword line is a block header (e.g. "% INPUTS:") at low indent, NOT a
    % 4-space-indented argument line whose name happens to equal a keyword (e.g.
    % an output literally named "inputs" documented as "%    inputs:  ..."). The
    % guide writes block keywords with <=3 spaces after %, and argument lines
    % with 4; constraining the post-% indent to <=3 spaces separates the two.
    tok = regexp(line, '^\s*%( {0,3})(OPTIONAL\s+)?([A-Za-z]+)\s*:', 'tokens', 'once');
    if isempty(tok)
        return;
    end
    word = upper(tok{3});
    switch word
        case 'USAGE'
            kw = 'USAGE';
        case {'INPUT', 'INPUTS'}
            kw = 'INPUT';
        case {'OUTPUT', 'OUTPUTS'}
            kw = 'OUTPUT';
        case {'EXAMPLE', 'EXAMPLES'}
            kw = 'EXAMPLE';
        case 'NOTE'
            kw = 'NOTE';
        case {'AUTHOR', 'AUTHORS'}
            kw = 'AUTHOR';
        otherwise
            kw = '';
    end
end

function tf = isMissingSpaceAfterPercent(line)
% True if a header comment line has no space after its leading % (H-PCT)
    tf = false;
    t = strtrim(line);
    if isempty(t) || t(1) ~= '%'
        return;
    end
    if numel(t) < 2
        return;  % bare "%"
    end
    if t(2) == '%'
        return;  % "%%" section header, exempt
    end
    if ~isempty(regexp(t, '^%\s*\.\.', 'once'))
        return;  % "% .." ignore/author line, exempt
    end
    tf = ~isempty(regexp(t, '^%\S', 'once'));
end

function tf = isContentLine(line)
% True if a comment line carries rendered text (not blank, %%, or % ..)
    t = strtrim(line);
    tf = false;
    if isempty(t) || t(1) ~= '%'
        return;
    end
    if numel(t) >= 2 && t(2) == '%'
        return;
    end
    if ~isempty(regexp(t, '^%\s*\.\.', 'once'))
        return;
    end
    body = strtrim(regexprep(t, '^%', ''));
    tf = ~isempty(body);
end

function ln = firstHeaderLine(headerAbs, headerIsComment)
% Return the line number of the first header comment, else 0
    idx = find(headerIsComment, 1, 'first');
    if isempty(idx)
        ln = 0;
    else
        ln = headerAbs(idx);
    end
end

function [status, ln] = checkArgDoc(regionLines, regionAbs, name)
% Check how a declared argument is documented within a keyword block region
%
% status: 'ok' | 'missing' | 'nocolon' | 'indent' | 'gap'
    status = 'missing';
    ln = 0;
    esc = regexptranslate('escape', name);
    for i = 1:numel(regionLines)
        line = regionLines{i};
        if isempty(regexp(line, ['^\s*%\s*' esc '\>'], 'once'))
            continue;
        end
        ln = regionAbs(i);
        tok = regexp(line, ['^\s*%(\s*)' esc '\s*(:?)(\s*)(\S?)'], 'tokens', 'once');
        if isempty(tok)
            status = 'nocolon';
            return;
        end
        indent = numel(tok{1});
        hasColon = strcmp(tok{2}, ':');
        gap = numel(tok{3});
        hasDesc = ~isempty(tok{4});
        if ~hasColon
            status = 'nocolon';
        elseif indent < 4
            status = 'indent';
        elseif hasDesc && gap < 4
            status = 'gap';
        else
            status = 'ok';
        end
        return;
    end
end

function names = inputParserParams(bodyText)
% Extract inputParser addParameter/addOptional/addRequired names from body
    names = {};
    tok = regexp(bodyText, ...
        'add(?:Parameter|Optional|Required|ParamValue)\s*\(\s*\w+\s*,\s*[''"]([A-Za-z]\w*)[''"]', ...
        'tokens');
    for i = 1:numel(tok)
        names{end + 1} = tok{i}{1}; %#ok<AGROW>
    end
    names = unique(names, 'stable');
end

function fields = structFieldReads(bodyText, name)
% Collect field names read as name.field in the body (excluding method calls)
    fields = {};
    esc = regexptranslate('escape', name);
    tok = regexp(bodyText, ['\<' esc '\.([A-Za-z]\w*)\>(?!\s*\()'], 'tokens');
    for i = 1:numel(tok)
        fields{end + 1} = tok{i}{1}; %#ok<AGROW>
    end
    fields = unique(fields, 'stable');
end
