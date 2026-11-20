% The COBRAToolbox: testPlotFRresults.m
%
% Purpose:
%     - plotFRresults draws, for each reconstruction in FRresults (output of
%       checkRankFRdriver), a subplot of the counts of rows and columns of S, of its
%       stoichiometrically consistent part and of the flux consistent part of [F,R], after
%       printing the reconstructions whose [F,R] or [Fb,Rb] lacks full row rank and those with
%       less than 90% stoichiometrically consistent rows, which it does not plot. Quarantined:
%       no behaviour of plotFRresults is asserted until the defects below are fixed.
%
% Function under test:
%     src/analysis/topology/FR/plotFRresults.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - figures from hand-built result structures of small models, no solver.
%
% Coverage exemptions:
%     every line - plotFRresults is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Reconstructions with few stoichiometrically consistent rows are never reported
%       SEVERITY: wrong-result
%       TRIGGER: plotFRresults(FRresults, 2, 2, [], [], 1, modelMetaData) with FRresults(1).model
%         a 4 x 2 S with SConsistentMetBool = [1; 0; 0; 0] (25% consistent rows) and
%         FRresults(2).model fully consistent
%       OBSERVED: the list under "Reconstructions with less than 90% stoichiometrically
%         inconsistent rows..." is empty and MATLAB prints "2 models that are sufficiently
%         stochiometrically consistent for plotting."; both models are plotted. Line 89
%         computes size(S,1)/nnz(SConsistentMetBool), which is never below 0.9, and reads
%         FRresults(k), the last model, instead of FRresults(j)
%       EXPECTED: model m1 (1 of 4 rows consistent) listed and not plotted (lines 153-155),
%         using nnz(SConsistentMetBool)/size(S,1) of model j
%       LINES: 89-92
%     - DEFECT: Row rank deficiency of [F,R] and [Fb,Rb] is misreported
%       SEVERITY: wrong-result
%       TRIGGER: the call above, with FRresults(2).model.FRrows having 2 nonzeros and
%         FRresults(2).rankFR = 2, and FRresults(1).model.Frb with 3 rows and
%         rankBilinearFrRr = 2
%       OBSERVED: m2 is listed under "[F,R] does not have full row rank for:" (line 66 compares
%         nnz(FRrows) with nnz(rankFR), which is 1 for any nonzero rank, and line 67 prints
%         the whole FRrows vector); m1 is not listed under "[Fb,Rb] does not have full row
%         rank" because line 75 loops over k=nReconstructions, the last model only
%       EXPECTED: [F,R] listed when nnz(FRrows) differs from rankFR; [Fb,Rb] checked for every
%         model
%       LINES: 66-67, 75
%     - DEFECT: The optional input modelMetaData cannot be omitted
%       SEVERITY: error
%       TRIGGER: plotFRresults(FRresults) or any call with fewer than seven inputs
%       OBSERVED: error "Not enough input arguments." at line 43, which passes modelMetaData
%         to makeFRresultsTable without a default; the defaults of lines 21, 24, 29, 33 and 39
%         are only reached by such calls; line 33 is a folder in one developer's home
%       EXPECTED: modelMetaData defaulting to empty, as for makeFRresultsTable
%       LINES: 21, 24, 29, 33, 39, 43
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPlotFRresults'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
