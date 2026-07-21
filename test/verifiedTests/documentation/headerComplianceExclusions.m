function [isExcluded, reason, subtrees] = headerComplianceExclusions(relPath, headerText)
% Decide whether a src file is excluded (vendored/read-only) from header remediation
%
% Two-part deterministic exclusion rule from research R2 of feature
% 014-src-header-compliance:
%
%   1. Enumerated vendored subtrees (authoritative): any file under
%      `src/reconstruction/rBioNet/` or
%      `src/reconstruction/comparison/modelBorgifier/`.
%   2. File-level licence guard: any file whose HEADER carries an explicit
%      software-licence / redistribution notice, detected by a case-insensitive
%      match against a fixed phrase list (SPDX identifiers, GPL notices, BSD
%      redistribution clauses, MIT permission grants, and free-software
%      declarations). The exact matched strings are the `licencePhrases`
%      literal in the body, so the list is single-sourced.
%
% Excluded files are reported as vendored and never edited. The subtree list
% is always returned so callers can display or reuse it.
%
% USAGE:
%
%    [isExcluded, reason, subtrees] = headerComplianceExclusions(relPath, headerText)
%    subtrees = headerComplianceExclusions()
%
% OPTIONAL INPUTS:
%    relPath:           char, repo-relative path (forward slashes, e.g.
%                       `src/base/io/foo.m`). If omitted, only `subtrees` is
%                       meaningful and `isExcluded` is false.
%    headerText:        char, the file's header comment block, used for the
%                       licence guard. If omitted while `relPath` is given, the
%                       file is read and its leading comment block extracted.
%
% OUTPUTS:
%    isExcluded:        logical, true if the file is vendored/read-only
%    reason:            char, `vendored-subtree`, `licence-guard`, or `''`
%    subtrees:          cell array of char, the enumerated vendored subtree
%                       prefixes (always returned)
%
% .. Author: - Feature 014-src-header-compliance, US1 exclusions (T002)

    subtrees = {'src/reconstruction/rBioNet/', ...
                'src/reconstruction/comparison/modelBorgifier/'};
    isExcluded = false;
    reason = '';

    if ~exist('relPath', 'var') || isempty(relPath)
        return;
    end

    relPath = strrep(relPath, '\', '/');

    % 1. Enumerated vendored subtrees.
    for i = 1:numel(subtrees)
        if startsWith(relPath, subtrees{i})
            isExcluded = true;
            reason = 'vendored-subtree';
            return;
        end
    end

    % 2. File-level licence guard on the header text.
    if ~exist('headerText', 'var')
        headerText = readHeaderText(relPath);
    end
    if isempty(headerText)
        return;
    end

    licencePhrases = {'SPDX-License', 'GNU General Public', ...
        'redistribution and use', 'permission is hereby granted', ...
        'is free software'};
    lowerHeader = lower(headerText);
    for i = 1:numel(licencePhrases)
        if contains(lowerHeader, lower(licencePhrases{i}))
            isExcluded = true;
            reason = 'licence-guard';
            return;
        end
    end
end

function headerText = readHeaderText(relPath)
% Read a file and return its leading comment block up to the first code line
    headerText = '';
    repoRoot = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
    fullPath = fullfile(repoRoot, relPath);
    if exist(fullPath, 'file') ~= 2
        return;
    end
    try
        raw = fileread(fullPath);
    catch ME
        if ~isempty(ME.stack)
            warning('headerComplianceExclusions:readFailed', ...
                'Could not read "%s": %s (%s line %d).', fullPath, ME.message, ...
                ME.stack(1).name, ME.stack(1).line);
        else
            warning('headerComplianceExclusions:readFailed', ...
                'Could not read "%s": %s.', fullPath, ME.message);
        end
        return;
    end
    raw = strrep(raw, sprintf('\r\n'), newline);
    raw = strrep(raw, sprintf('\r'), newline);
    lines = strsplit(raw, newline, 'CollapseDelimiters', false);
    keep = {};
    seenCode = false;
    for i = 1:numel(lines)
        t = strtrim(lines{i});
        if isempty(t)
            continue;
        end
        if t(1) == '%'
            keep{end + 1} = lines{i}; %#ok<AGROW>
        elseif ~isempty(regexp(t, '^function\>', 'once'))
            if seenCode
                break;  % header block already collected past the signature
            end
            seenCode = true;  % keep scanning comments after the signature line
        else
            % first real body line: stop once we have started collecting
            if seenCode || ~isempty(keep)
                break;
            end
        end
    end
    headerText = strjoin(keep, newline);
end
