% The COBRAToolbox: testCobraSmooth.m
%
% Purpose:
%     - cobraSmooth is the plain-MATLAB replacement for smooth (Curve Fitting Toolbox), methods
%       'moving' and 'lowess'. This test checks every syntax used by the call sites in src/
%       (smooth(bins, n') with bins and counts from hist), the other supported syntaxes
%       (smooth(y), smooth(y, span), smooth(x, y, span), each with an optional method), the
%       rules of mathworks-semantics.md section 15 and of the MathWorks pages (moving: span 5
%       by default, an even span reduced by 1, a fraction of the number of points, the window
%       shrinking at the ends so that it stays centred and odd; lowess: local linear
%       regression with tricube weights over the span nearest points, the window one-sided
%       at the ends; data sorted by x and returned in the original order; column output),
%       the automatic choice of method (moving for uniform x, lowess for non-uniform x or NaN
%       in y), the errors for the other methods and bad input, and parity with smooth when
%       the toolbox is installed.
%     - Reference values: (a) the end-point formulas of
%       https://www.mathworks.com/help/curvefit/smooth.html (yy(1) = y(1),
%       yy(2) = (y(1)+y(2)+y(3))/3, yy(3) = mean(y(1:5)), yy(4) = mean(y(2:6))); (b) for
%       'moving', a hand computation of the documented rule with exactly rounded sums
%       (math.fsum), compared with a relative tolerance of 1e-14 (sums of at most 11 small
%       numbers); (c) for 'lowess', an independent NumPy 1.26.4 implementation of the rule of
%       https://www.mathworks.com/help/curvefit/smoothing-data.html solved with
%       numpy.linalg.lstsq (cobraSmooth uses the closed-form normal equations), compared with
%       a relative tolerance of 1e-12 (observed differences up to 1.5e-15). Both are in
%       specs/20261103-120403-toolbox-free-replacements/references/tables.py (Python 3,
%       SciPy 1.16.0 environment; SciPy and NumPy have no smooth or lowess function).
%     - Choices not documented by MathWorks (UNCONFIRMED; see the cobraSmooth header) are
%       tested as cobraSmooth's documented behaviour. Recalled from MathWorks' smooth.m
%       (UNCONFIRMED): the uniform-spacing test (every second difference of x, in the order
%       given, at most eps * max(abs(x(1)), abs(x(end))), tested on both sides of the limit),
%       lowess on uniform x (span limited to numel(y) and made odd upwards; references from
%       uniform_lowess_rule in tables.py), and 'moving' with repeated x (references from
%       moving_ties_rule, exact sums). Own choices: lowess ties at the span-th distance, NaN
%       in y with lowess, weights below eps, the weighted mean where the line is not
%       determined, the error for NaN with 'moving'.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraSmooth.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCobraSmooth'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% smooth(y): moving average with span 5, the window shrinks at the ends (documentation)

y = [2 7 1 8 2 8 1 8 2 8 4.5];
yy = cobraSmooth(y);
% the output is a column even for a row input
assert(iscolumn(yy) && numel(yy) == numel(y));
assert(yy(1) == y(1) && abs(yy(2) - mean(y(1:3))) <= 1e-14 * yy(2));
assert(abs(yy(3) - mean(y(1:5))) <= 1e-14 * yy(3) && abs(yy(4) - mean(y(2:6))) <= 1e-14 * yy(4));
assert(yy(end) == y(end) && abs(yy(end - 1) - mean(y(end - 2:end))) <= 1e-14 * yy(end - 1));
% tables.py moving span 5
referenceSpan5 = [2 3.3333333333333335 4 5.2000000000000002 4 5.4000000000000004 ...
    4.2000000000000002 5.4000000000000004 4.7000000000000002 4.833333333333333 4.5]';
assert(max(abs(yy - referenceSpan5) ./ referenceSpan5) <= 1e-14);
% a column input and the explicit method give the same result
assert(isequal(cobraSmooth(y'), yy) && isequal(cobraSmooth(y, 'moving'), yy));

%% smooth(y, span) moving: odd spans, even spans reduced by 1, fractions of the number of points

y = [2 7 1 8 2 8 1 8 2 8 4.5];
% tables.py moving span 3, 7 and 11
referenceSpan3 = [2 3.3333333333333335 5.333333333333333 3.6666666666666665 6 ...
    3.6666666666666665 5.666666666666667 3.6666666666666665 6 4.833333333333333 4.5]';
referenceSpan7 = [2 3.3333333333333335 4 4.1428571428571432 5 4.2857142857142856 ...
    5.2857142857142856 4.7857142857142856 4.7000000000000002 4.833333333333333 4.5]';
referenceSpan11 = [2 3.3333333333333335 4 4.1428571428571432 4.333333333333333 ...
    4.6818181818181817 4.7222222222222223 4.7857142857142856 4.7000000000000002 ...
    4.833333333333333 4.5]';
assert(max(abs(cobraSmooth(y, 3) - referenceSpan3) ./ referenceSpan3) <= 1e-14);
assert(max(abs(cobraSmooth(y, 7) - referenceSpan7) ./ referenceSpan7) <= 1e-14);
assert(max(abs(cobraSmooth(y, 11) - referenceSpan11) ./ referenceSpan11) <= 1e-14);
% an even span is reduced by 1; a span longer than the data still shrinks at the ends
assert(isequal(cobraSmooth(y, 4), cobraSmooth(y, 3)));
assert(isequal(cobraSmooth(y, 12), cobraSmooth(y, 11)) && isequal(cobraSmooth(y, 25), cobraSmooth(y, 11)));
% a fraction of the 11 points is rounded up: 0.5 -> 6 -> 5, 0.3 -> 4 -> 3
assert(isequal(cobraSmooth(y, 0.5), cobraSmooth(y, 5)));
assert(isequal(cobraSmooth(y, 0.3), cobraSmooth(y, 3, 'moving')));
% span 1 returns the data
assert(isequal(cobraSmooth(y, 1), y'));

%% moving with x: data sorted by x, result in the original order; x only orders the points

x = [6 2 10 4 8 12 14 18 16 20 22];
y = [2 7 1 8 2 8 1 8 2 8 4.5];
% tables.py: sort by x, smooth with span 5, put back in the original order
referenceOriginalOrder = [4 7 2.7999999999999998 5.666666666666667 4.2000000000000002 ...
    2.7999999999999998 4 4.7000000000000002 5.4000000000000004 6.833333333333333 4.5]';
yy = cobraSmooth(x, y, 'moving');
assert(max(abs(yy - referenceOriginalOrder) ./ referenceOriginalOrder) <= 1e-14);
assert(isequal(cobraSmooth(x, y, 5, 'moving'), yy));
[~, order] = sort(x);
yy3 = cobraSmooth(x, y, 3, 'moving');
assert(isequal(yy3(order), cobraSmooth(y(order), 3)));
% uniform bins: the same as no x (the call-site syntax smooth(bins, n'))
assert(isequal(cobraSmooth(0.5:1:10.5, y'), cobraSmooth(y)));
% uniformity is judged in the order given: decreasing uniform x is uniform (moving, which is
% symmetric, so the same as no x), unsorted x is not (lowess; tables.py lowess span 5)
assert(isequal(cobraSmooth(11:-1:1, y), cobraSmooth(y)));
referenceUnsortedLowess = [3.7178631051752928 7.9849530866042215 3.2904841402337244 ...
    5.8379597728356369 1.7136894824707847 3.9916527545909846 3.2904841402337244 ...
    6.2821368948247098 3.431552587646078 6.3282102441904371 5.8135554218051313]';
assert(max(abs(cobraSmooth(x, y) - referenceUnsortedLowess) ./ referenceUnsortedLowess) <= 1e-12);
% an explicit 'moving' with non-uniform x: x only orders the points
xNonUniform = 2 .^ (0:10);
assert(isequal(cobraSmooth(xNonUniform, y, 'moving'), cobraSmooth(y)));
assert(isequal(cobraSmooth(xNonUniform, y, 7, "Moving"), cobraSmooth(y, 7)));

%% call sites plotSampleHist and sampleScatterMatrix: smooth(bins, n') from hist uses lowess

% the bin centres from hist are uniform only to rounding (second differences of about
% 2.5 * eps * max(abs(x))), so without a method smooth chooses lowess with span 5
rngState = rng;
rng(1, 'twister');
[n, bins] = hist(randn(1, 1000), 30);
rng(rngState);
smoothedCounts = cobraSmooth(bins, n');
% tables.py lowess with span 5 on the same bins and counts (bins printed with %.17g)
referenceHist = [1.8175380269993282 3.1312821427171955 4.5726210350584298 6.7136894824707873 ...
    11.863105175292151 17.850584307178639 24.00417362270451 25.991652754590984 ...
    32.01669449081804 41.419031719532562 58.871452420701175 71.979131886477461 ...
    80.149415692821393 85.863105175292134 89.83806343906511 86.149415692821378 ...
    80.004173622704513 70.265442404006677 55.444073455759614 41.141068447412358 ...
    33.286310517529209 26.145242070116868 18.709515859766285 11.576794657762941 ...
    6.5726210350584324 4.4273789649415685 2.8589315525876478 1.9999999999999998 ...
    2.365126665045135 2.7810944277705389]';
assert(iscolumn(smoothedCounts) && numel(smoothedCounts) == 30);
assert(max(abs(smoothedCounts - referenceHist) ./ referenceHist) <= 1e-12);
assert(isequal(smoothedCounts, cobraSmooth(bins, n', 'lowess')));
assert(~isequal(smoothedCounts, cobraSmooth(n')));

%% uniform spacing is judged with the tolerance eps * max(abs(x(1)), abs(x(end)))

y = [3 1 4 1 5 9];
% x = 0:0.1:0.5 from the colon operator counts as uniform: moving average
assert(isequal(cobraSmooth(0:0.1:0.5, y), cobraSmooth(y)));
% second differences of 2 * eps(3) (below eps * 5) still count as uniform
xNearlyUniform = (0:5)';
xNearlyUniform(4) = xNearlyUniform(4) + eps(3);
assert(isequal(cobraSmooth(xNearlyUniform, y), cobraSmooth(y)));
% second differences of 8 * eps(5) (above eps * 5) count as non-uniform: lowess
xNotUniform = (0:5)';
xNotUniform(4) = xNotUniform(4) + 4 * eps(5);
assert(isequal(cobraSmooth(xNotUniform, y), cobraSmooth(xNotUniform, y, 'lowess')));
assert(~isequal(cobraSmooth(xNotUniform, y), cobraSmooth(y)));

%% lowess on non-uniform x: span nearest points, tricube weights, one-sided at the ends

y = [2 7 1 8 2 8 1 8 2 8 4.5];
xGeometric = 2 .^ (0:10);
% tables.py lowess span 5 and span 4 (on non-uniform x an even span is used as given)
referenceGeometric5 = [2.9984007394528711 3.5058736700017472 4.6057691616806444 ...
    7.4328993169056767 2.4050701009242319 7.6406470627690677 1.3849064261125199 ...
    7.5729696195740965 2.4014768915443159 7.6406470627690704 4.8080454478566672]';
referenceGeometric4 = [4.2287175620476383 3.6139843395474593 1.4553790421047088 ...
    7.8031574124220455 2.2072027237662653 7.8135175486103572 1.1968425875779523 ...
    7.7824371400454195 2.2072027237662657 7.8135175486103616 4.6605821109188552]';
assert(max(abs(cobraSmooth(xGeometric, y) - referenceGeometric5) ./ referenceGeometric5) <= 1e-12);
assert(max(abs(cobraSmooth(xGeometric, y, 4) - referenceGeometric4) ./ referenceGeometric4) <= 1e-12);
assert(isequal(cobraSmooth(xGeometric, y, 4, 'lowess'), cobraSmooth(xGeometric, y, 4)));
% a fraction of the 11 points is rounded up and not reduced: 0.3 -> 4
assert(isequal(cobraSmooth(xGeometric, y, 0.3), cobraSmooth(xGeometric, y, 4)));

%% lowess on uniform x with an explicit method (recalled uniform rule)

y = [2 7 1 8 2 8 1 8 2 8 4.5];
% tables.py uniform_lowess_rule span 5 and 7 on x = 1:11 (they agree with the
% nearest-neighbour rule to 3.6e-15 for an odd span not above numel(y))
referenceUniform5 = [3.2219584700197172 3.8369406121652836 4.722036727879801 ...
    4.2779632721202017 5.4357262103505866 4.2779632721202008 5.0083472454090163 ...
    4.2779632721202017 5.4357262103505866 5.3189895383743879 5.4848310981758583]';
referenceUniform7 = [3.3613449319100401 3.8427036173431359 4.3541648786608311 ...
    4.5669336134086027 4.876518897787113 4.6669875862471368 4.7895059297186107 ...
    4.6669875862471359 5.1085631798379021 5.3236068238941598 5.57682570279953]';
assert(max(abs(cobraSmooth(y, 'lowess') - referenceUniform5) ./ referenceUniform5) <= 1e-12);
assert(max(abs(cobraSmooth(y, 7, 'LOWESS') - referenceUniform7) ./ referenceUniform7) <= 1e-12);
% x = 1:11 given explicitly gives the same values
assert(isequal(cobraSmooth(1:11, y, 7, "lowess"), cobraSmooth(y, 7, 'lowess')));
% an even span is made odd upwards: 4 -> 5 (tables.py uniform span4 = uniform span5)
assert(max(abs(cobraSmooth(y, 4, 'lowess') - referenceUniform5) ./ referenceUniform5) <= 1e-12);
% a span above numel(y) is limited to numel(y), then made odd: [3 1 4 1] with span 5 -> 4 -> 5,
% where the end weights use the distance to a 5th point beyond the data; [3 1 4 1 5] with
% span 7 -> 5 (tables.py)
referenceShort4 = [2.4528580578547046 2.4317868970740895 2.1374453665221766 1.8572785008750921]';
referenceShort5 = [2.4528580578547046 2.4317868970740895 2.2821368948247085 3.16204022716436 ...
    4.0150469133957802]';
assert(max(abs(cobraSmooth([3 1 4 1], 'lowess') - referenceShort4) ./ referenceShort4) <= 1e-12);
assert(max(abs(cobraSmooth([3 1 4 1 5], 7, 'lowess') - referenceShort5) ./ referenceShort5) <= 1e-12);
% one or two points: span 1 returns the data
assert(isequal(cobraSmooth(5, 'lowess'), 5) && isequal(cobraSmooth([3 1], 1, 'lowess'), [3; 1]));

%% lowess with unsorted x and ties: points at the span-th distance are all used

y = [2 7 1 8 2 8 1 8 2 8 4.5];
xTies = [3 1 2 2 5 4 4 4 7 6 8];
% tables.py lowess span 5 (in the original order of x)
referenceTies = [2 6.9999999999999982 4.4999999999999991 4.4999999999999991 2 ...
    5.666666666666667 5.666666666666667 5.666666666666667 4.3158837965804757 ...
    4.5642737896494152 3.7340744740536014]';
yyTies = cobraSmooth(xTies, y);
assert(max(abs(yyTies - referenceTies) ./ referenceTies) <= 1e-12);
% equal x values get equal smoothed values
assert(yyTies(6) == yyTies(7) && yyTies(7) == yyTies(8));
% repeated x followed by further points: the window keeps moving past the ties
% (tables.py 'repeated x span2')
assert(isequal(cobraSmooth([1 1 1 2 5 6 9], [1 3 2 5 4 8 7], 2, 'lowess'), [2; 2; 2; 5; 4; 8; 7]));
% a window with one point of nonzero weight at a nonzero distance (x = 5.5, whose y is NaN)
% gives that point's value (tables.py 'one weighted point span2')
assert(max(abs(cobraSmooth([2 2 2.5 5.5], [0.05 0.65 1.37 NaN], 2) - [0.35; 0.35; 1.37; 1.37])) <= 1e-14);

%% NaN in y: smooth uses lowess, NaN points are not used but get a smoothed value

yNaN = [2 7 NaN 8 2 8 1 NaN 2 8 4.5];
% tables.py lowess span 5 with the NaN points left out of every window
referenceNaN = [3.6402992393892966 4.8654371411052768 5.9561285041948047 6.0720752487440457 ...
    5.5281860528798532 4.0410462107164138 3.2884884790613609 3.324575404133415 ...
    3.6807445178539631 4.8791015090683363 6.0614653970116761]';
yyNaN = cobraSmooth(yNaN);
assert(all(isfinite(yyNaN)) && max(abs(yyNaN - referenceNaN) ./ referenceNaN) <= 1e-12);
assert(isequal(cobraSmooth(1:11, yNaN), yyNaN));
% only NaN gives NaN
assert(all(isnan(cobraSmooth([NaN NaN NaN]))));

%% lowess special cases: weights below eps, a line that is not determined, span 1

% at x = 2 the two nearest data points (x = 1 and 3) are both at the largest distance, so
% their tricube weights are 0; the weights are then set to 1 and the line through (1, 1)
% and (3, 5) gives 3 (tables.py: 2.9999999999999996)
assert(max(abs(cobraSmooth([1 NaN 5 7], 2, 'lowess') - [1; 3; 5; 7])) <= 1e-12);
% four equal x values: the line is not determined, so the (equally weighted) mean 2.5;
% at x = 2 only the point itself has a nonzero weight (tables.py: [2.5 2.5 2.5 2.5 10])
assert(isequal(cobraSmooth([1 1 1 1 2], [1 2 3 4 10], 3), [2.5; 2.5; 2.5; 2.5; 10]));
% span 1 returns the data unchanged, NaN included
assert(isequal(cobraSmooth([1 2 4 8], [3 1 4 1], 1, 'lowess'), [3; 1; 4; 1]));
assert(isequaln(cobraSmooth([1 2 4 8], [3 NaN 4 1], 1, 'lowess'), [3; NaN; 4; 1]));

%% moving with repeated x: tied points share the mean of a window widened to whole groups

y = [2 7 1 8 2 8 1 8 2 8 4.5];
xRepeated = [1 2 2 3 4 4 4 5 6 7 8];
% tables.py moving_ties_rule span 5 and 3 (recalled rule)
referenceTied5 = [2 4.5 4.5 4.5 5.4000000000000004 5.4000000000000004 5.4000000000000004 ...
    4.833333333333333 4.7857142857142856 4.833333333333333 4.5]';
referenceTied3 = [2 4.5 4.5 4.5 3.6666666666666665 3.6666666666666665 3.6666666666666665 ...
    4.2000000000000002 6 4.833333333333333 4.5]';
assert(max(abs(cobraSmooth(xRepeated, y, 'moving') - referenceTied5) ./ referenceTied5) <= 1e-14);
assert(max(abs(cobraSmooth(xRepeated, y, 3, 'moving') - referenceTied3) ./ referenceTied3) <= 1e-14);
% unsorted repeated x, result in the original order
referenceTiedUnsorted = [4.2000000000000002 7 4.5 4.2000000000000002 3.6666666666666665 4.5 ...
    4.2000000000000002 4.833333333333333 4.7857142857142856 4.833333333333333 4.5]';
yyTied = cobraSmooth([4 1 2 4 3 2 4 5 6 7 8], y, 'moving');
assert(max(abs(yyTied - referenceTiedUnsorted) ./ referenceTiedUnsorted) <= 1e-14);
% all x equal: one group, the mean of all points (x is uniform, so also without a method)
assert(isequal(cobraSmooth([2 2 2 2], [1 2 3 6]), [3; 3; 3; 3]));

%% empty span, scalar second input, single precision

y = [2 7 1 8 2 8 1 8 2 8 4.5];
x = 0.5:1:10.5;
% [] means the default span 5, in either position
assert(isequal(cobraSmooth(y, []), cobraSmooth(y)));
assert(isequal(cobraSmooth(y, [], 'moving'), cobraSmooth(y)));
assert(isequal(cobraSmooth(x, y, []), cobraSmooth(x, y)));
% a scalar second input is the span: one data point, span 3
assert(isequal(cobraSmooth(4, 3), 4));
% the output has the class of y
ySingle = single(y);
assert(isa(cobraSmooth(ySingle), 'single') && isa(cobraSmooth(ySingle, 'lowess'), 'single'));
assert(max(abs(double(cobraSmooth(ySingle)) - cobraSmooth(y))) <= 1e-5);
assert(isa(cobraSmooth(single([])), 'single'));

%% short and empty data

assert(isequal(cobraSmooth(4), 4));
assert(isequal(cobraSmooth([1 5]), [1; 5]));
assert(isequal(cobraSmooth([1 2 6]), [1; 3; 6]));
emptySmooth = cobraSmooth([]);
assert(isequal(size(emptySmooth), [0 1]));

%% other methods and bad input raise an error naming them

for method = {'loess', 'sgolay', 'rlowess', 'rloess'}
    assert(verifyCobraFunctionError('cobraSmooth', 'inputs', {1:9, method{1}}, ...
        'testMessage', sprintf(['cobraSmooth: the method ''%s'' is not supported; ' ...
        'only ''moving'' and ''lowess'' are.'], method{1})));
end
assert(verifyCobraFunctionError('cobraSmooth', 'inputs', {1:9, 5, 'sgolay', 2}, ...
    'testMessage', 'cobraSmooth: the method ''sgolay'' is not supported; only ''moving'' and ''lowess'' are.'));
assert(verifyCobraFunctionError('cobraSmooth', 'inputs', {1:9, 'moving', 3}, ...
    'testMessage', 'cobraSmooth: no input may follow the method ''moving''.'));
assert(verifyCobraFunctionError('cobraSmooth', 'inputs', {[1 NaN 3 4 5], 'moving'}, ...
    'testMessage', 'cobraSmooth: NaN in the data is not supported with ''moving''.'));
assert(verifyCobraFunctionError('cobraSmooth', 'inputs', {[1 2 NaN 4 5], 1:5}, ...
    'testMessage', 'cobraSmooth: NaN in x is not supported.'));
assert(verifyCobraFunctionError('cobraSmooth', 'inputs', {1:9, 1:9, 3, 4}, ...
    'testMessage', 'cobraSmooth: expected 1 to 3 numeric inputs.'));
assert(verifyCobraFunctionError('cobraSmooth', ...
    'testMessage', 'cobraSmooth: expected 1 to 3 numeric inputs.'));
assert(verifyCobraFunctionError('cobraSmooth', 'inputs', {1:9, 1:8}, ...
    'testMessage', 'cobraSmooth: x and y must have the same length.'));
assert(verifyCobraFunctionError('cobraSmooth', 'inputs', {1:9, 0}, ...
    'testMessage', 'cobraSmooth: span must be a positive scalar.'));
assert(verifyCobraFunctionError('cobraSmooth', 'inputs', {1:9, 1:9, [3 5]}, ...
    'testMessage', 'cobraSmooth: span must be a positive scalar.'));

%% parity with smooth when the Curve Fitting Toolbox is installed

if exist('smooth', 'file') && license('test', 'Curve_Fitting_Toolbox')
    y = [2 7 1 8 2 8 1 8 2 8 4.5];
    x = [6 2 10 4 8 12 14 18 16 20 22];
    % moving: smooth uses a filter-based sum, so the results agree to rounding
    assert(max(abs(cobraSmooth(y) - smooth(y))) <= 1e-12);
    assert(max(abs(cobraSmooth(y, 3) - smooth(y, 3))) <= 1e-12);
    assert(max(abs(cobraSmooth(y, 0.5) - smooth(y, 0.5))) <= 1e-12);
    assert(max(abs(cobraSmooth(x, y) - smooth(x, y))) <= 1e-12);
    % lowess, explicit and automatic (non-uniform x, NaN in y, hist bins)
    assert(max(abs(cobraSmooth(y, 'lowess') - smooth(y, 'lowess'))) <= 1e-10);
    assert(max(abs(cobraSmooth(2 .^ (0:10), y) - smooth(2 .^ (0:10), y))) <= 1e-10);
    yNaN = [2 7 NaN 8 2 8 1 NaN 2 8 4.5];
    assert(max(abs(cobraSmooth(yNaN) - smooth(yNaN))) <= 1e-10);
    rngState = rng;
    rng(1, 'twister');
    [n, bins] = hist(randn(1, 1000), 30);
    rng(rngState);
    assert(max(abs(cobraSmooth(bins, n') - smooth(bins, n'))) <= 1e-10);
else
    fprintf('skipped: Curve Fitting Toolbox not installed\n');
end

% change the directory
cd(currentDir)
