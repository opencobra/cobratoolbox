function samples = loadSamples(filename, numFiles, pointsPerFile,numSkipped,randPts)
% Loads a set of sampled data points
%
% USAGE:
%
%    samples = loadSamples(filename, numFiles, pointsPerFile, numSkipped, randPts)
%
% INPUTS:
%    filename:          The name of the files containing the sample points.
%    numFiles:          The number of files containing the sample points.
%    pointsPerFile:     The number of points to be taken from each file.
%
% OPTIONAL INPUTS:
%    numSkipped:        Number of files skipped (default = 0)
%    randPts:           Select random points from each file (true/false, default = false)
%
% OUTPUT:
%    samples:           Sample flux distributions
%
% .. Authors: - Gregory Hannum and Markus Herrgard 8/17/05.

if (nargin < 4)
    numSkipped = 0;
end
if (nargin < 5)
    randPts = false;
end

samples = [];

showprogress(0,'Loading samples ...');
%load points from the files into pset
for i = 1:numFiles
    if (i > numSkipped)

        try
            data = load([filename '_' num2str(i) '.mat']);
        catch
            fprintf('Unable to read file ''%s_%d.mat''. No such file or directory. Check sampling time limit.\n',filename,i);
            break;
        end
        selPoints = any(data.points ~= 0);
        numPoints = sum(selPoints);
        if (randPts)
          % Pick a random set of points
            pointInd = randperm(numPoints);
            samples = [samples data.points(:,pointInd(1:min([pointsPerFile,numPoints])))];
        else
          % Pick points at regular intervals
            pSkip = max([floor(numPoints/pointsPerFile) 1]);
            samples = [samples data.points(:,1:pSkip:numPoints)];
        end
        showprogress((i-numSkipped)/(numFiles-numSkipped));
    end
end
