function [subsysSummary, uniqSubsys, countSubPerEFM] = efmSubsystemsExtraction(model, EFMRxns)
% This function finds all unique subsystems in the input set of EFMs
%
% USAGE:
%    [subsysSummary, uniqSubsys, countSubPerEFM] = efmSubsystemsExtraction(model, EFMRxns);
%    
% INPUTS:
%    model:      COBRA model that was used for EFM calculation
%    EFMRxns:    matlab array containing reactions in EFMs (as returned by the function efmImport)
%
% OUTPUTS:
%    subsysSummary:    
%    uniqSubsys:  
%    countSubPerEFM:  
%
% EXAMPLE:
%
%
%
% .. Author: Last modified: Chaitra Sarathy, 1 Oct 2019

uniqSubsys = unique(string(model.subSystems(reshape(nonzeros(EFMRxns), [], 1))));
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
