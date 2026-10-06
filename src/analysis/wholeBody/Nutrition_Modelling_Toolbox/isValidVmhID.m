function [isValid, isNotInVmh] = isValidVmhID(vmhIDs)
% Check which entries of an info file vmhID column hold a single usable VMH
% metabolite ID. Empty entries, placeholders ('0', '-', 'Not in VMH',
% 'Not in the VMH') and entries with multiple IDs or whitespace (e.g.,
% 'fl,hf') are not valid.
%
% USAGE:
%
%    [isValid, isNotInVmh] = isValidVmhID(vmhIDs)
%
% INPUT:
%    vmhIDs:      Cell array of VMH metabolite IDs from an info file
%
% OUTPUTS:
%    isValid:     Logical vector, true for entries with a single VMH ID
%    isNotInVmh:  Logical vector, true for entries explicitly marked as not
%                 in the VMH ('Not in VMH' or 'Not in the VMH')
%
% .. Author: - Bram Nap, 10-2026

vmhIDs = string(vmhIDs);
vmhIDs(ismissing(vmhIDs)) = "";
vmhIDs = cellstr(vmhIDs);

isNotInVmh = ~cellfun(@isempty, regexpi(strtrim(vmhIDs), '^not in (the )?vmh$', 'once'));
isValid = ~cellfun(@isempty, strtrim(vmhIDs)) & ~isNotInVmh ...
    & ~ismember(lower(strtrim(vmhIDs)), {'0', '-', 'nan'}) ...
    & cellfun(@isempty, regexp(vmhIDs, '[,;\s]', 'once'));
end
