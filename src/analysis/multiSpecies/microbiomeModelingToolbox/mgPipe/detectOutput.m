function mapP = detectOutput(resPath, objNam)
% This function checks the existence of a specific file in the results folder.
%
% USAGE:
%
%   mapP = detectOutput(resPath, objNam)
%
% INPUTS:
%   resPath:    char with path of directory where results are saved
%   objNam:     char with name of object to find in the results folder
%
% OUTPUTS:
%   mapP:       double indicating if object was found in the result folder
%
% .. Author: Federico Baldini 2017-2018

cd(resPath);
fnames = dir('*.mat');
numfids = length(fnames);
vals = cell(1, numfids);
for K = 1:numfids
    vals{K} = fnames(K).name;
end
vals = vals';
mapP = strmatch(objNam, vals, 'exact');
end
