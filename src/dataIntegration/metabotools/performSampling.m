function performSampling(model,warmupn,fileName,nFiles,pointsPerFile,stepsPerPoint,fileBaseNo,maxTime,path, nPointsCheck)
% The function performs the sampling analysis for one model, combines
% multiple COBRA toolbox functions 
%
% USAGE:
%
%    performSampling(model, warmupn, fileName, nFiles, pointsPerFile, stepsPerPoint, fileBaseNo, maxTime, path)
%
% INPUTS:
%
%    model:                      Model to be sampled
%
%    warmupn:                    Number of warm-up points
%    fileName:                   Name for output files
%    nFiles:                     Number of files saved
%    pointsPerFilePoints:        Points saved per file
%    stepsPerPoint:              Steps skipped between two saved points, in order to increase mixing
%    fileBaseNo:                 Counter for the numbering of the output files, e.g., 0 to start with 1;
%    maxTime:                    Maximal running time after which the analysis should be terminated, e.g., 3600000; 
%    path:                       Path to file
%    nPointsCheck:               Correct number of warm up points to nRxns*2 if nPoints < nRxns*2 (Default = true)
%
%
% Automatically saved to path using specified file name
%
% .. Author: - Maike K. Aurich 22/08/15

if nargin < 10
    nPointsCheck = true;
else
    nPointsCheck = false;
end

warmupPoints = createHRWarmup(model,warmupn, false, [], nPointsCheck);
initPoint = (warmupPoints(:,1));
fileName = [path filesep fileName];
ACHRSampler(model,warmupPoints,fileName,nFiles,pointsPerFile,stepsPerPoint,initPoint,fileBaseNo,maxTime);

end
