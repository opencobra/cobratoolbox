function [mapped_exchanges, minMax, mapped_uptake, mapped_secretion] = checkExchangeProfiles(samples, path ,nmets)
% The Function generates a summary of the number of uptake exchanges
% and secretion exchanges per samples.
%
% USAGE:
%
%    [mapped_exchanges, minMax, mapped_uptake, mapped_secretion] = checkExchangeProfiles(samples, path, nmets)
%
% INPUTS:
%    samples:
%    path:     path to output of make exchangeprofiles
%    nmets:    number of metabolites in data set (max number of uptake or secreted metabolites)
%
% OUTPUTS:
%    mapped_exchanges:    table listing for each sample the number of uptake and secretion that were mapped to the model
%    minMax:              lists minimal and maximal number of uptakes, secretions, and total number of exchanges
%    mapped_uptake:       table summarizing for each sample the uptake exchange reactions
%    mapped_secretion:    table summarizing for each sample the secretion exchange reactions
%
% .. Author: - Maike K. Aurich 06/08/15

mapped_uptake{nmets,length(samples)}=[];
mapped_secretion{nmets,length(samples)}=[];
mapped_exchanges{3,length(samples)}=[];

for    j = 1:length(samples)

    FILENAME = char(samples(j,1));
    load([path, filesep, FILENAME '.mat']);

    % add number of uptake and secretion
    mapped_exchanges{1,j} = length(secretion);
    mapped_exchanges{2,j} = length(uptake);
    mapped_exchanges{3,j} = sum(cell2mat(mapped_exchanges(:,j)));

    % add names of uptake and secretion
    for i=1:length(uptake)
    mapped_uptake(i,j)=uptake(i);
    end
    for i=1:length(secretion)
    mapped_secretion(i,j)=secretion(i);
    end
end

% Statistics on minimal and maximal number of added uptake and secretion
% metabolites

    minMax(1,1) = min(cell2mat(mapped_exchanges(1,:)));
    minMax(1,2) = min(cell2mat(mapped_exchanges(2,:)));
    minMax(1,3) = min(cell2mat(mapped_exchanges(3,:)));

    minMax(2,1) = max(cell2mat(mapped_exchanges(1,:)));
    minMax(2,2) = max(cell2mat(mapped_exchanges(2,:)));
    minMax(2,3) = max(cell2mat(mapped_exchanges(3,:)));
end
