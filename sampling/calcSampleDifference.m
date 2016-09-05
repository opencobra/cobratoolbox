function [sampleDiff,sampleRatio] = calcSampleDifference(sample1,sample2,nPts)
%calcSampleDifference Calculate a flux difference sample between two conditions
%
% sampleDiff = calcSampleDifference(sample1,sample2,nPts)
%
% Selects randomly nPts flux vectors from sample1 and sample2 and calcutes
% the difference between the flux vectors
%
%INPUTS
% sample1       First flux sample
% sample2       Second flux sample
% nPts          Number of flux difference profiles desired
%
%OUTPUTS
% sampleDiff    
% sampleRatio   
%
% Markus Herrgard 11/13/06

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

