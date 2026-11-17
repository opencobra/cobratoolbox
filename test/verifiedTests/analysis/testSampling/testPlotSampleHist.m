% The COBRAToolbox: testPlotSampleHist.m
%
% Purpose:
%     - plotSampleHist draws, in a new figure, one subplot per reaction with the smoothed and
%       normalised flux histogram of each sample, optionally with marker lines and labels
%       (add2Plot). A model that lacks a reaction but holds its flipped copy <rxn>_r (the name
%       convertToIrreversible gives a backward-only reaction) is meant to contribute the
%       negated samples of <rxn>_r (lines 130-138 and 158-165).
%     - Once the defects below are fixed, the test should check, on hand-written samples of
%       createModel models (figures invisible and closed): the reactions kept (those present
%       in every model, or present as <rxn>_r), the bin centres linspace(min, max, nBins), the
%       normalisation of each histogram to 1, the look-up of each reaction by name in each
%       model, the negated histogram of a <rxn>_r reaction, the rescaling of a constant flux,
%       the axis limits widened for add2Plot, the labels, the legend, the figure size for two
%       rows of subplots, and a call in which no requested reaction is kept.
%       Quarantined: no behaviour of plotSampleHist is asserted until the wrong-result and
%       error defects below are fixed; this file only opens the test.
%
% Function under test:
%     src/analysis/sampling/plotSampleHist.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - createModel models, hand-written samples, invisible figures, no solver.
%
% Coverage exemptions:
%     every line - plotSampleHist is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A reaction held as its flipped copy <rxn>_r in one model is never plotted
%       SEVERITY: wrong-result
%       TRIGGER: model1 = createModel({'r1', 'r2'}, {'r1', 'r2'}, {'A -> B', 'B -> C'});
%         modelBack = createModel({'r1', 'r2'}, {'r1', 'r2'}, {'A <=> B', 'B -> C'}) with
%         lb(1) = -10, ub(1) = 0; model2 = convertToIrreversible(modelBack) (reactions r1_r,
%         r2); rng(1); plotSampleHist({'r1', 'r2'}, {rand(2, 50), rand(2, 50)}, {model1,
%         model2}, 5)
%       OBSERVED: (R2025a, 2026-11-17) one subplot only, 'Flux of r2': lines 91-106 drop every
%         reaction that is absent under its plain name from any model, and findRxnIDs returns
%         0 (never empty) for an absent name, so the handling code of lines 130-138 and
%         158-165 that looks up <rxn>_r and plots it with sampleSign = -1 is never reached
%       EXPECTED: a subplot for r1 as well, with the histogram of -samples of r1_r for model 2,
%         as the handling code of lines 130-138 and 158-165 intends
%       LINES: 91-106, 130-138, 158-165
%     - DEFECT: A call in which no requested reaction is kept stops with an index error
%       SEVERITY: error
%       TRIGGER: plotSampleHist({'r1'}, {rand(2, 50), rand(2, 50)}, {model1, model2}, 5) with
%         model1 and model2 of the entry above (r1 is held as r1_r in model2); also
%         plotSampleHist({'r1_x'}, {rand(2, 50)}, {model1}, 5) (a name absent from the model)
%       OBSERVED: (R2025a, 2026-11-17) 'Index exceeds array bounds.' at line 128: line 106
%         leaves rxnNameList empty (nRxns = 0) and the plotting loop still reads
%         rxnNameList{1}; the empty figure of line 119 is left open
%       EXPECTED: no error (an empty plot, or the 'Reaction does not exist' warning that line
%         137 intends for an absent reaction)
%       LINES: 106-107, 119-128
%     - DEFECT: The subplot grid is transposed for perScreen = [nY, nX]
%       SEVERITY: cosmetic
%       TRIGGER: perScreen = [1 2] (documented as [nY, nX], one row of two plots)
%       OBSERVED: line 171 calls subplot(nX, nY, ...), so the plots are drawn in two rows of one
%         (read from the code; not asserted)
%       EXPECTED: subplot(nY, nX, ...), one row of two plots
%       LINES: 171
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.
%     - Quarantined after the independent review (T027/T028), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPlotSampleHist'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed; the call is the standard opening of a COBRA
% test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
