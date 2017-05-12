function [sampleDiff,sampleRatio] = calcSampleDifference(sample1,sample2,nPts)
% Selects randomly nPts flux vectors from `sample1` and `sample2` and calcutes
% the difference between the flux vectors
%
% USAGE:
%
%    sampleDiff = calcSampleDifference(sample1,sample2,nPts)
%
% INPUTS:
%    sample1:       First flux sample
%    sample2:       Second flux sample
%    nPts:          Number of flux difference profiles desired
%
% OUTPUTS:
%    sampleDiff:    Difference between the flux vectors
%    sampleRatio:   Ratio of the flux vectors
%
% .. Author: - Markus Herrgard 11/13/06

[nFlux1,nSample1] = size(sample1);
[nFlux2,nSample2] = size(sample2);

if (nFlux1 ~= nFlux2)
   error('Samples have different numbers of rxns');
else
    select1 = randint(nPts,1,nSample1)+1;
    select2 = randint(nPts,1,nSample2)+1;
    sampleDiff = sample2(:,select2) - sample1(:,select1);
    sampleRatio = sample2(:,select2)./sample1(:,select1);
end
