function samples = loadSamples(filename, numFiles, pointsPerFile,numSkipped,randPts)
%loadSamples Load a set of sampled data points
%
% samples = loadSamples(filename,numFiles,pointsPerFile,numSkipped,randPts)
%
%INPUTS
% filename          The name of the files containing the sample points.
% numFiles          The number of files containing the sample points.
% pointsPerFile     The number of points to be taken from each file.
%
%OPTIONAL INPUTS
% numSkipped        Number of files skipped (default = 0)
% randPts           Select random points from each file (true/false, default = false)
%
%OUTPUT
% samples           Sample flux distributions
%
%Written by Gregory Hannum and Markus Herrgard 8/17/05.

if (nargin < 4)
    numSkipped = 0;
end
if (nargin < 5)
    randPts = false;
end

samples = [];

h = waitbar(0,'Loading samples ...');
%load points from the files into pset
for i = 1:numFiles
    if (i > numSkipped)
        
        data = load([filename '_' num2str(i) '.mat']);
        selPoints = any(data.points ~= 0);
        numPoints = sum(selPoints);        
        if (randPts)
          % Pick a random set of points
            pointInd = randperm(numPoints);
            samples = [samples data.points(:,pointInd(1:pointsPerFile))];
        else
          % Pick points at regular intervals
            pSkip = max([floor(numPoints/pointsPerFile) 1]);
            samples = [samples data.points(:,1:pSkip:numPoints)];
        end
        waitbar((i-numSkipped)/(numFiles-numSkipped),h);
    end
end
close(h);
