function printSampleStats(sampledModel, commonModel, sampleNames, fileName)
% Prints out sample statistics for multiple samples
%
% USAGE:
%
%    printSampleStats(samples, commonModel, sampleNames, fileName)
%
% INPUTS:
%    sampledModel:   Samples to plot
%    commonModel:    COBRA model structure
%    sampleNames:    Names of the models
%
% OPTIONAL INPUT:
%    fileName:       Name of tab delimited CSV file to generate
%                    (Default = print to command window)
%
% .. Author: - Markus Herrgard

if nargin > 3
    fid = fopen(fileName, 'w');
else
    fid = 1;
end

sampleStats = calcSampleStats(sampledModel);

fprintf(fid, 'Rxn\t');
if (isfield(commonModel, 'subSystems'))
    fprintf(fid, 'Subsystem\t');
end

for i = 1:length(sampleNames)
    fprintf(fid, '%s-mode\t', sampleNames{i});
end
for i = 1:length(sampleNames)
    fprintf(fid, '%s-mean\t', sampleNames{i});
end
for i = 1:length(sampleNames)
    fprintf(fid, '%s-median\t', sampleNames{i});
end
for i = 1:length(sampleNames)
    fprintf(fid, '%s-std\t', sampleNames{i});
end
fprintf(fid, '\n');

for i = 1:length(commonModel.rxns)
    fprintf(fid, '%s\t', commonModel.rxns{i});
    if (isfield(commonModel, 'subSystems'))                
        fprintf(fid, '%s\t', strjoin(commonModel.subSystems{i},';'));
    end
    %for j = 1:length(samples)
    fprintf(fid, '%8.6f\t', sampleStats.mode(i));
    %end
    %for j = 1:length(samples)
    fprintf(fid, '%8.6f\t', sampleStats.mean(i, :));
    %end
    %for j = 1:length(samples)
    fprintf(fid, '%8.6f\t', sampleStats.median(i, :));
    %end
    %for j = 1:length(samples)
    fprintf(fid, '%8.6f\t', sampleStats.std(i, :));
    %end
    fprintf(fid, '\n');
end
if (fid > 1)
    fclose(fid);
end
