function [OrganListLong, OrganListOnly] = findMetinOrgan(WBModel, metabolite)
% Find all organs in which a metabolite participates
%
% USAGE:
%
%    [OrganListLong, OrganListOnly] = findMetinOrgan(WBModel, metabolite)
%
% INPUTS:
%    WBModel:         Whole-body metabolic model, with fields:
%
%                       * .mets - metabolite identifiers
%    metabolite:      Abbreviation of the metabolite to be looked up
%
% OUTPUTS:
%    OrganListLong:    Metabolite identifiers (with organ prefix) in which the
%                     metabolite participates
%    OrganListOnly:    Unique list of organs in which the metabolite occurs
%
% .. Author: - Ines Thiele, July 2020

metList = WBModel.mets;
OrganListLong= WBModel.mets(find(~cellfun(@isempty,strfind(WBModel.mets,strcat('_',metabolite)))));
OrganListOnly = unique(strtok(OrganListLong,'_'));
