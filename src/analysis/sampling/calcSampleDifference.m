function [sampleDiff, sampleRatio] = calcSampleDifference(sample1, sample2, nPts)
% Selects randomly nPts flux vectors from `sample1` and `sample2` and calcutes
% the difference between the flux vectors
%
% USAGE:
%
%    [sampleDiff, sampleRatio] = calcSampleDifference(sample1, sample2, nPts)
%
% INPUTS:
%    sample1:        First flux sample
%    sample2:        Second flux sample
%    
% OPTIONAL INPUTS:
%    nPts:           Number of flux difference profiles desired (default: 
%                    10% of the samples)
%
% OUTPUTS:
%    sampleDiff:     Difference between the flux vectors
%    sampleRatio:    Ratio of the flux vectors
%
% EXAMPLE:
%
%    example 1:
%    [sampleDiff, sampleRatio] = calcSampleDifference(sample1, sample2)
%    example 2:
%    [sampleDiff, sampleRatio] = calcSampleDifference(sample1, sample2, 10)
%
% .. Author: - Markus Herrgard 11/13/06
% .. Modified: - German Preciat 07/05/17

[nFlux1, nSample1] = size(sample1);
[nFlux2, nSample2] = size(sample2);

assert(nFlux1 == nFlux2, 'Samples have different numbers of rxns.');

if nargin < 3 || isempty(nPts)
    nPts = nSample1 * 25;
end

select1 = randi(nSample1, 1, nPts);
select2 = randi(nSample2, 1, nPts);
sampleDiff = sample2(:, select2) - sample1(:, select1);
sampleRatio = sample2(:, select2) ./ sample1(:, select1);

