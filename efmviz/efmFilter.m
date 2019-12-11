function [filteredEFMs, row] = efmFilter(EFMRxns, roi)
% This function returns a subset of EFMs that contain a desired reaction of
% interest
%
% USAGE:
%    filteredEFMs = filterEFMs(EFMRxns, roi);
%    
% INPUTS:
%    EFMRxns:    matlab array containing reactions in EFMs (as returned by the function importEFMs)
%    roi:        (numeric) index of the reaction of interest as in the input model
%
% OUTPUTS:
%    filteredEFMs:    matlab array containing subset of EFMs that contain 'roi'
%
% OPTIONAL OUTPUTS:
%    row:             indices of EFMs that were filtered
%
% EXAMPLE:
%     filteredEFMs = filterEFMs(efmData, 729); % 729 is the ID for acetate release reaction in the iAF1260 model
%
% .. Author: Last modified: Chaitra Sarathy, 1 Oct 2019

[row, ~] = find(EFMRxns == roi);
filteredEFMs = EFMRxns(row, :);
end

