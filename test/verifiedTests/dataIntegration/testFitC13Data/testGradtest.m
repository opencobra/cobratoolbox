% The COBRAToolbox: testGradtest.m
%
% Purpose:
%     - gradtest is a plotting diagnostic of the C13 fit: it converts the flux vector v to
%       null-space coordinates alpha = model.N \ v, evaluates errorComputation2_grad at alpha
%       with the 13 step sizes Prob.user.diff_interval = 10^-k, k = -1:11, and draws one
%       semilogy line per gradient component into the current axes (x = k, y = |gradient
%       component| at step 10^-k), holding the axes so that all lines stay. It prints the loop
%       index and assigns no output (documented). The test uses the fixtures of this folder
%       (flux vector v0 of point.mat, isotopomer model.mat, expdata.mat), as
%       testErrorComputation2_grad does, draws into an invisible figure and compares the plotted
%       lines with gradients derived independently: forward differences recomputed by hand from
%       errorComputation2 (tested by testErrorComputation2), with the step 10^-k / norm(N(:, i))
%       documented by errorComputation2_grad, for every component at step 1e-5 and for three
%       components at every step; for these three components the lines at the steps 1e-4 to
%       1e-6 agree with central differences (a mathematical property of a gradient).
%
% Function under test:
%     src/dataIntegration/fluxomics/gradtest.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - the input carries a model structure (the 335-reaction isotopomer model of this
%     folder, the smallest model the EMU solver is generated for); no optimisation solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGradtest'));
cd(fileDir);

% declare the requirements of this test. This test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% solveLin (called through slvrEMU_fast) turns the warning MATLAB:nearlySingularMatrix off and
% does not turn it on again; save its state to restore it at the end
nearlySingularState = warning('query', 'MATLAB:nearlySingularMatrix');

% cdv2idv and idv2cdv (used by convertCarbonInput) cache matrices in global variables; note the
% globals that exist now to remove the new ones at the end
globalsBefore = who('global');

% fixtures of this folder: flux vector, isotopomer model and experimental data; the EMU solver
% reads the glucose label input as fragment MDVs (expdata.inputfrag)
load('point.mat', 'v0');
load('model.mat', 'model');
load('expdata.mat', 'expdata');
expdata.inputfrag = convertCarbonInput(expdata.input);

% gradtest does not set Prob.user.useparfor, so errorComputation2_grad uses its for loop and no
% parallel pool is started

%% plotted lines: one semilogy line per null-space coordinate, x = the exponents -1:11

% gradtest draws into the current axes; an invisible figure is made current for it, and the
% figures that exist before are noted to check that gradtest opens no other figure
figuresBefore = findall(groot, 'Type', 'figure');
fig = figure('Visible', 'off');
gradtest(v0, model, expdata);
assert(isempty(setdiff(findall(groot, 'Type', 'figure'), [figuresBefore; fig])));

ax = get(fig, 'CurrentAxes');
assert(~isempty(ax));
% semilogy sets a logarithmic y axis, hold on keeps every line
assert(strcmp(get(ax, 'YScale'), 'log'));
assert(strcmp(get(ax, 'NextPlot'), 'add'));

% null-space coordinates of v0 (139 entries); one line per entry, in the order drawn (the
% children of the axes are listed newest first)
alpha = model.N \ v0;
nAlpha = numel(alpha);
hLines = flipud(findobj(ax, 'Type', 'line'));
assert(numel(hLines) == nAlpha);
exponents = -1:11;
for i = 1:nAlpha
    assert(isequal(get(hLines(i), 'XData'), exponents));
end
plotted = cell2mat(arrayfun(@(h) get(h, 'YData'), hLines, 'UniformOutput', false))';
assert(isequal(size(plotted), [numel(exponents), nAlpha]));
assert(all(plotted(:) >= 0));
close(fig);

%% plotted values: |forward differences| recomputed by hand from errorComputation2

Prob = struct();
Prob.user.expdata = expdata;
Prob.user.model = model;
f0 = errorComputation2(alpha, Prob);
% forward difference of component i with step 10^-k / norm(N(:, i)), as errorComputation2_grad
% documents it
handForward = @(i, step) (errorComputation2(alpha + (step / norm(model.N(:, i))) * ...
    ((1:nAlpha)' == i), Prob) - f0) / (step / norm(model.N(:, i)));

% the hand computation repeats the same floating-point operations; their results agree up to
% rounding of the error difference, eps * |f0| divided by the step (relative bound, with a factor
% 10 of margin), so the tolerance grows as the step shrinks
tolerance = @(step, i) 10 * eps(abs(f0)) / (step / norm(model.N(:, i)));

% every component at step 1e-5 (row of exponent 5)
row = find(exponents == 5);
for i = 1:nAlpha
    expected = abs(handForward(i, 1e-5));
    assert(abs(plotted(row, i) - expected) <= tolerance(1e-5, i));
end

% the first, a middle and the last component at every step 10^-k
components = [1, round(nAlpha / 2), nAlpha];
for i = components
    for r = 1:numel(exponents)
        step = 10^(-exponents(r));
        expected = abs(handForward(i, step));
        assert(abs(plotted(r, i) - expected) <= tolerance(step, i));
    end
end

%% the lines show a gradient: at moderate steps they agree with central differences

% at the steps 1e-4 to 1e-6 the forward difference differs from the derivative by order
% step * second derivative plus rounding (relative 2.3e-3 at most observed; at step 1e-3 the
% truncation error reaches 3 percent, so that step is not used), so a relative tolerance of 1e-2
% separates a gradient from a wrong value
for i = components
    centralStep = 1e-4 / norm(model.N(:, i));
    e = zeros(nAlpha, 1);
    e(i) = centralStep;
    central = (errorComputation2(alpha + e, Prob) - errorComputation2(alpha - e, Prob)) / (2 * centralStep);
    for k = 4:6
        assert(abs(plotted(exponents == k, i) - abs(central)) <= 1e-2 * abs(central) + 1e-6);
    end
end

% restore the warning state and remove the globals created by the callees
warning(nearlySingularState.state, 'MATLAB:nearlySingularMatrix');
newGlobals = setdiff(who('global'), globalsBefore);
for k = 1:numel(newGlobals)
    clearvars('-global', newGlobals{k});
end

% change the directory
cd(currentDir)
