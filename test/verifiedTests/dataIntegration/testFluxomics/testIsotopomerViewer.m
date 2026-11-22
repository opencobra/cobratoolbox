% The COBRAToolbox: testIsotopomerViewer.m
%
% Purpose:
%     - isotopomerViewer draws, for each row of two MDV sample matrices mdv1 and mdv2, the
%       histograms of the samples (round(sqrt(#samples)) bins) in a 4 x 4 grid of subplots:
%       mdv1 as a line in the default colour, mdv2 in green, titled with names{i}; rows whose
%       bin centres are all below 0.02 are drawn in black; after every 16 rows it pauses. The
%       test draws 16 rows of 4 samples into an invisible figure and checks the 16 titles and,
%       for one row with large and one with small values, the plotted bin centres and counts,
%       derived by hand (2 bins, centre = min + (k - 0.5) * range / 2, no sample on a bin
%       edge) and the line colours. Pausing is switched off (pause('off')) so the pause after
%       row 16 returns at once; the pause state is restored at the end.
%
% Function under test:
%     src/dataIntegration/fluxomics/isotopomerViewer.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built matrices, invisible figure.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testIsotopomerViewer'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the plotted values are bin centres (sums of a few decimals) and integer counts; 1e-12 is
% far above the rounding of the bin centre computation
tol = 1e-12;

% pause after row 16 would wait for a key press; switch pausing off and restore it at the end
pauseState = pause('query');
pause('off');

%% 16 rows: titles, and the histograms of a large-valued and a small-valued row

% odd rows: large values [0 0.2 0.4 2] + row (centres row + [0.5 1.5], counts [3 1]);
% even rows: small values [0 0.001 0.002 0.01] (centres [0.0025 0.0075], counts [3 1]);
% mdv2 is mdv1 shifted by 1 (large rows) or halved (small rows)
nRows = 16;
mdv1 = zeros(nRows, 4);
mdv2 = zeros(nRows, 4);
for row = 1:nRows
    if mod(row, 2) == 1
        mdv1(row, :) = [0 0.2 0.4 2] + row;
        mdv2(row, :) = mdv1(row, :) + 1;
    else
        mdv1(row, :) = [0 0.001 0.002 0.01];
        mdv2(row, :) = mdv1(row, :) / 2;
    end
end
names = arrayfun(@(k) sprintf('fragment%d', k), 1:nRows, 'UniformOutput', false);

viewerFigure = figure('Visible', 'off');
isotopomerViewer(mdv1, mdv2, names);

% one subplot per row, titled with its name
for row = 1:nRows
    rowAxes = subplot(4, 4, row);
    assert(strcmp(rowAxes.Title.String, names{row}));
end

% row 1 (large values): the mdv1 line in the default colour, then the green mdv2 line
rowLines = findobj(subplot(4, 4, 1), 'Type', 'line');
assert(numel(rowLines) == 2);
% children are listed newest first
assert(max(abs(rowLines(2).XData - [1.5 2.5])) < tol && isequal(rowLines(2).YData, [3 1]));
assert(~isequal(rowLines(2).Color, [0 0 0]) && ~isequal(rowLines(2).Color, [0 1 0]));
assert(max(abs(rowLines(1).XData - [2.5 3.5])) < tol && isequal(rowLines(1).YData, [3 1]));
assert(isequal(rowLines(1).Color, [0 1 0]));

% row 2 (small values): the mdv1 line is replaced by a black one (hold is off), the green
% mdv2 line is drawn and then drawn again in black on top
rowLines = findobj(subplot(4, 4, 2), 'Type', 'line');
assert(numel(rowLines) == 3);
assert(max(abs(rowLines(3).XData - [0.0025 0.0075])) < tol && isequal(rowLines(3).YData, [3 1]));
assert(isequal(rowLines(3).Color, [0 0 0]));
assert(max(abs(rowLines(2).XData - [0.00125 0.00375])) < tol && isequal(rowLines(2).YData, [3 1]));
assert(isequal(rowLines(2).Color, [0 1 0]));
assert(isequal(rowLines(1).XData, rowLines(2).XData) && isequal(rowLines(1).YData, [3 1]));
assert(isequal(rowLines(1).Color, [0 0 0]));

close(viewerFigure);

% restore the pause state
pause(pauseState);

% change the directory
cd(currentDir)
