function [indNumb, sampName, organisms] = getIndividualSizeName(abunFilePath)
% This function automatically detects organisms, names and number of individuals present
% in the study.
%
% USAGE:
%
%   [indNumb, sampName, organisms] = getIndividualSizeName(abunFilePath)
%
% INPUTS:
%   abunFilePath:        char with path and name of file from which to retrieve information
%
% OUTPUTS:
%   indNumb:             number of individuals in the study
%   sampName:            nx1 cell array cell array with names of individuals in the study
%   organisms:           nx1 cell array cell array with names of organisms in the study
%
% .. Author: Federico Baldini 2017-2018

[sampName] = readtable(abunFilePath, 'ReadVariableNames', false);
s = size(sampName);
s = s(1, 2);
sampName = sampName(1, 3:s);
sampName = table2cell(sampName);
sampName = sampName';
indNumb = length(sampName);  % number of individuals

% getting info on present strains
% Reading models names
[strains] = readtable(abunFilePath);
strains = strains(:, 2);
organisms = table2cell(strains);  % extracted names of models
end
