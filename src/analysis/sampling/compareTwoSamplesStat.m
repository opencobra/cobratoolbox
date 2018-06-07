function [stats, pVals] = compareTwoSamplesStat(sample1, sample2, tests)
% Compares statistically the difference between two
% samples. Does the Kolmogorov-Smirnov, rank-sum, chi-square, and T-tests.
%
% USAGE:
%
%    [stats, pVals] = compareTwoSamplesStat(sample1, sample2, tests)
%
% INPUTS:
%    sample1, sample2:    Samples to compare
%    tests:               {`test1`, `test2`,...} (Default = all tests)
%
%                           * 'ks' - Kolmogorov-Smirnov test
%                           * 'rankSum' - rank-sum test
%                           * 'chiSquare' - chi-squre test
%                           * 'tTest' - T-test
%
% OUTPUTS:
%    stats:               Struct array with statistics of the selected
%                         tests.
%    pVals:               Struct array with `p` values of the selected
%                         tests.
%
% EXAMPLE:
%
%    example 1:
%    [stats, pVals] = compareTwoSamplesStat(sample1, sample2)
%    example 2:
%    [stats, pVals] = compareTwoSamplesStat(sample1, sample2, {'ks', 'rankSum'})
%
% .. Authors:
%       - Markus Herrgard 8/14/06
%       - Richard Que 11/20/09, combined test m-files into this m-file.
%
% Output will be in order that tests are inputed. i.e. {'ks','rankSum'}

if nargin < 3
    tests = {'ks', 'rankSum', 'chiSquare', 'tTest'};
end

[nVar, nSample] = size(sample1);

for i = 1:length(tests)
    switch lower(tests{i})
        case 'ks'
            for j = 1:nVar
                [~, pLarger, statLarger] = kstest2(sample1(j, :), ...
                                                   sample2(j, :), 0.01, 'larger');
                [~, pSmaller, statSmaller] = kstest2(sample1(j, :), ...
                                                     sample2(j, :), 0.01, 'smaller');
                if statLarger > statSmaller
                    stats.ks(j, 1) = statLarger;
                    pVals.ks(j, 1) = pLarger;
                else
                    stats.ks(j, 1) = -statSmaller;
                    pVals.ks(j, 1) = pSmaller;
                end
            end
        case 'ranksum'
            for j = 1:nVar
                [p, ~, stat] = ranksum(sample1(j, :), ...
                                       sample2(j, :), 'method', 'approximate');
                pVals.ranksum(j, 1) = p;
                stats.ranksum(j, 1) = -stat.zval;
            end
        case 'chisquare'
            nBin = round(nSample / 50);
            for j = 1:nVar
                counts = hist([sample1(j, :)' sample2(j, :)'], nBin) / nSample;
                tmpStat = (counts(:, 1) - counts(:, 2)).^2. / (counts(:, 1) + counts(:, 2));
                tmpStat(isnan(tmpStat)) = 0;
                stats.chisquare(j, 1) = sum(tmpStat);
            end
            pVals.chisquare = chi2cdf([stats.chisquare], nBin - 1);
        case 'ttest'
            for j = 1:nVar
                [~, pVals.ttest(j, 1), tmp, tmpstats] = ttest2(sample1(j, :), sample2(j, :));
                stats.ttest(j, 1) = tmpstats.tstat;
            end
        otherwise
            fprintf('%s is not a valid option', tests{i});
    end
end
