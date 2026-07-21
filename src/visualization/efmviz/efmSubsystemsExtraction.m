function [subsysSummary, uniqSubsys, countSubPerEFM] = efmSubsystemsExtraction(model, EFMRxns)
% This function finds all unique subsystems in the input set of EFMs
%
% USAGE:
%    [subsysSummary, uniqSubsys, countSubPerEFM] = efmSubsystemsExtraction(model, EFMRxns);
%
% INPUTS:
%    model:      COBRA model that was used for EFM calculation, with fields:
%
%                  * .subSystems - `m x 1` cell array of subsystem name(s) per reaction
%    EFMRxns:    matlab array containing reactions in EFMs (as returned by the function efmImport)
%
% OUTPUTS:
%    subsysSummary:      table (from `tabulate`) of the unique subsystems
%                        present in the input EFMs, sorted by descending
%                        occurrence count, with columns for subsystem name,
%                        count, and percentage
%    uniqSubsys:         cell array of unique, non-empty subsystem names
%                        found among the reactions in the input EFMs
%    countSubPerEFM:     `numel(uniqSubsys) x size(EFMRxns, 1)` matrix; each
%                        entry is the number of reactions belonging to that
%                        subsystem in the corresponding EFM
%
% .. Author: Last modified: Chaitra Sarathy, 1 Oct 2019

uniqSubsys = unique(string(model.subSystems(reshape(nonzeros(EFMRxns), [], 1))));
%TODO
%STR = string(C) converts cell array C to a string array. but cellfun
%expects a cell array, this needs to be fixed
if ~iscell(uniqSubsys)
    error('uniqSubsys is not a cell')
end
uniqSubsys(find(cellfun('isempty', uniqSubsys)))=[];
subsysSummary = sortrows(tabulate(string(model.subSystems(reshape(nonzeros(EFMRxns), [], 1)))),2, 'descend');
countSubPerEFM = zeros(length(uniqSubsys), size(EFMRxns, 1));
for ii = 1:size(EFMRxns, 1)
    singleEFM = nonzeros(EFMRxns(ii,:));
    allSubsys = string(model.subSystems(singleEFM));
    for jj = 1:length(uniqSubsys)
        countSubPerEFM(jj,ii) = length(find(contains(allSubsys, uniqSubsys(jj))));
    end
end   




end
