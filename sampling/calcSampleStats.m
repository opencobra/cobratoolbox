function sampleStats = calcSampleStats(samples)
%calcSampleStats Calculate sample modes, means, standard devs, and medians
%
% sampleStats = calcSampleStats(samples)
%
%INPUT
% samples       Samples to analyze
%
%OUTPUT
% sampleStats           Structure with the following fields
%   mean
%   std
%   mode
%   median
%   skew
%   kurt
%
% Markus Herrgard 8/22/06

if (~iscell(samples))
    samplesTmp = samples;
    clear samples;
    samples{1} = samplesTmp;
end

for i = 1:length(samples)
    fprintf('Processing sample %d\n',i);
    sampleStats.mean(:,i) = mean(samples{i}')';
    sampleStats.std(:,i) = std(samples{i}')';
    sampleStats.mode(:,i) = mode(samples{i}')';
    sampleStats.median(:,i) = median(samples{i}')';
    sampleStats.skew(:,i) = skewness(samples{i}')';
    sampleStats.kurt(:,i) = kurtosis(samples{i}')';
end

