function [stats,pVals] = compareTwoSamplesStat(sample1,sample2,tests)
% Compares statistically the difference between two
% samples. Does the Kolmogorov-Smirnov, rank-sum, chi-square, and T-tests.
%
% USAGE:
%
%    [stats,pVals] = compareTwoSamplesStat(sample1, sample2, tests)
%
% INPUTS:
%    sample1, sample2:          Samples to compare
%    tests:                     {`test1`, `test2`,...} (Default = all tests)
%
%                                 * 'ks' - Kolmogorov-Smirnov test
%                                 * 'rankSum' - rank-sum test
%                                 * 'chiSquare' - chi-squre test
%                                 * 'tTest' - T-test
%
% OUTPUTS:
%    stats:                     statistics
%    pVals:                     p values
%
% .. Authors:
%       - Markus Herrgard 8/14/06
%       - Richard Que 11/20/09, combined test m-files into this m-file.
%
% Output will be in order that tests are inputed. i.e. {'ks','rankSum'}

if nargin<3
    tests = {'ks', 'rankSum', 'chiSquare', 'tTest'};
end

stats = [];
pVals = [];
[nVar,nSample] = size(sample1);

for i=1:length(tests)
    switch lower(tests{i})
        case 'ks'
            for j = 1:nVar
                [h,pLarger,statLarger] = kstest2(sample1(j,:),sample2(j,:),0.01,'larger');
                [h,pSmaller,statSmaller] = kstest2(sample1(j,:),sample2(j,:),0.01,'smaller');
                if (statLarger > statSmaller)
                    stat(j,1) = statLarger;
                    p(j,1) = pLarger;
                else
                    stat(j,1) = -statSmaller;
                    p(j,1) = pSmaller;
                end
            end
        case 'ranksum'
            for j = 1:nVar
                [p(j,1),h,stats] = ranksum(sample1(j,:),sample2(j,:),'method','approximate');
                stat(j,1) = -stats.zval;
            end
        case 'chisquare'
            warning off MATLAB:divideByZero
            nBin = round(nSample/50);
            for j = 1:nVar
                counts = hist([sample1(j,:)' sample2(j,:)'],nBin)/nSample;
                tmpStat = (counts(:,1)-counts(:,2)).^2./(counts(:,1)+counts(:,2));
                tmpStat(isnan(tmpStat)) = 0;
                stat(j,1) = sum(tmpStat);
            end
            p = chi2cdf(stat,nBin-1);
            warning on MATLAB:divideByZero
        case 'ttest'
            for j = 1:nVar
                [h,p(j,1),tmp,tmpstats] = ttest2(sample1(j,:),sample2(j,:));
                stat(j,1) = tmpstats.tstat;
            end
        otherwise
            fprintf('%s is not a valid option',tests{i});
    end
    stats = [stats stat];
    pVals = [pVals p];
end
