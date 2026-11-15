% The COBRAToolbox: testKLdistance.m
%
% Purpose:
%     - KLdistance(data1, data2, num_iter, parameters) compares two populations parameter by
%       parameter (one column of data1 and data2 per parameter): the first distance is the
%       Kullback-Leibler distance (KLDis) between the kernel density estimates
%       (cobraKsdensity) of the second and of the first population; num_iter - 1 further
%       distances are computed after random permutations of the population labels; one figure
%       per parameter shows the histogram of the distances with the first one marked, titled
%       with the parameter name. The output holds the distances of the last parameter.
%     - This test checks: the distance is zero between two identical populations; the first
%       distance is KLDis of the two density estimates; the permutation distances equal those
%       of an independent re-implementation of the label shuffle with the same random seed;
%       all distances are non-negative (each term (P - Q) * log10(P / Q) is >= 0); the number
%       of distances and of figures, and the figure titles.
%
% Function under test:
%     src/analysis/KLdistance/KLdistance.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built data (figures are invisible and closed).
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testKLdistance'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% figures are created by the function: keep them invisible and close them at the end
figureVisibility = get(0, 'DefaultFigureVisible');
set(0, 'DefaultFigureVisible', 'off');
figureNumbers = @() arrayfun(@(f) f.Number, findall(groot, 'Type', 'figure'));
figuresBefore = figureNumbers();

% the reference values below repeat the same floating-point operations, so only rounding
% differences are allowed
tol = 1e-12;

%% two identical populations: the first distance is zero

% identical data give identical density estimates, so every term of KLDis is 0 * log10(1);
% num_iter = 1: no permutation, a single distance
populationA = [1.0; 2.0; 2.5; 4.0; 5.5; 6.0];
dist = KLdistance(populationA, populationA, 1, {'identical'});
assert(isequal(size(dist), [1, 1]));
assert(dist == 0);

%% two parameters, 20 permutations: first distance, permutation distances, figures

% population 1 (6 points) and population 2 (5 points), two parameters (columns)
data1 = [1.0 10; 2.0 12; 2.5 11; 4.0 15; 5.5 13; 6.0 14];
data2 = [3.0 20; 5.0 22; 6.5 19; 7.0 25; 9.0 21];
parameters = {'first parameter', 'second parameter'};
numIter = 20;
figuresBeforeCall = numel(figureNumbers());
rng(20261113);
dist = KLdistance(data1, data2, numIter, parameters);

% one distance per iteration (of the last parameter), all non-negative
assert(isequal(size(dist), [1, numIter]));
assert(all(dist >= 0));

% the first distance is KLDis between the densities of population 2 and population 1
expectedFirst = KLDis(cobraKsdensity(data2(:, 2)), cobraKsdensity(data1(:, 2)));
assert(abs(dist(1) - expectedFirst) < tol);
assert(dist(1) > 0);

% independent re-implementation of the permutations: with the same seed, each parameter in
% turn draws num_iter - 1 permutations of the 11 labels (0 = population 1, 1 = population 2)
rng(20261113);
data = [data1; data2];
labels = [zeros(size(data1, 1), 1); ones(size(data2, 1), 1)];
expectedDist = zeros(1, numIter);
for parameter = 1:size(data, 2)
    expectedDist(1) = KLDis(cobraKsdensity(data(labels == 1, parameter)), ...
        cobraKsdensity(data(labels == 0, parameter)));
    for iteration = 2:numIter
        shuffled = labels(randperm(numel(labels)));
        expectedDist(iteration) = KLDis(cobraKsdensity(data(shuffled == 1, parameter)), ...
            cobraKsdensity(data(shuffled == 0, parameter)));
    end
end
assert(max(abs(dist - expectedDist)) < tol);

% one figure per parameter, titled with the parameter name
assert(numel(figureNumbers()) - figuresBeforeCall == 2);
newFigures = setdiff(figureNumbers(), figuresBefore);
titles = sort(arrayfun(@(n) get(get(get(findobj(groot, 'Type', 'figure', 'Number', n), ...
    'CurrentAxes'), 'Title'), 'String'), newFigures, 'UniformOutput', false));
assert(isequal(titles(:)', {'first parameter', 'identical', 'second parameter'}));

% close the figures of the function and restore the figure visibility and the directory
close(setdiff(figureNumbers(), figuresBefore));
set(0, 'DefaultFigureVisible', figureVisibility);
cd(currentDir)
