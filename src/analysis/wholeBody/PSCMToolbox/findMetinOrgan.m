function [OrganListLong,OrganListOnly] = findMetinOrgan(WBModel,metabolite)

% find all organs in which a metabolite participates
%
% INPUT
% WBmodel       whole body metabolic model
% metabolite    abbrevition of the metabolite to be looked up
%
% OUTPUT
% OrganList     List of organs that the metabolite occurs in
%
% Ines Thiele, July 2020

metList = WBModel.mets;
OrganListLong= WBModel.mets(find(~cellfun(@isempty,strfind(WBModel.mets,strcat('_',metabolite)))));
OrganListOnly = unique(strtok(OrganListLong,'_'));
