% The COBRAToolbox: testCompareInchis.m
%
% Purpose:
%     - compareInchis scores a list of InChIs for one metabolite of a model: agreement of the
%       InChI net charge and formula (hydrogen ignored) with the model, number of
%       stereochemical sub-layers, standard InChI, how often the same InChI and the same main
%       layer occur in the list, and whether the InChI has the most layers. The test uses
%       short hand-written InChIs whose layers are counted by hand; every column of the table
%       and the total scores (sums of the columns, formula weighted 10) are worked out from
%       them. It covers a row list, an empty entry, the charge fields metCharges and metCharge,
%       a model without charges and a model formula with an R group.
%
% Function under test:
%     src/dataIntegration/chemoInformatics/inchi/compareInchis.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - look-up on a createModel toy model with formulas and charges; no solver.
%
% Coverage exemptions:
%     Line 76: unreachable by any input (defect below) - modelMetFormula is always a cell, and
%     isempty of a 1-by-1 cell is false.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A model formula made only of R groups is not treated as H
%       SEVERITY: limitation
%       TRIGGER: compareInchis(model, inchis, met) with model.metFormulas = {'X'} for met
%       OBSERVED: regexprep({'X'}, ["X", "Y", "*", "FULLR"], '') returns {0x0 char} (a
%         1-by-1 cell), so isempty at line 75 is false and the formula becomes
%         editChemicalFormula({'X'}) = 'R'; no InChI formula (for example 'H' of the proton
%         InChI 'InChI=1S/p+1') then matches
%       EXPECTED: the formula set to 'H' (line 76), so that it matches an InChI whose formula
%         is hydrogen only
%       LINES: 75-76
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCompareInchis'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% glc in two compartments (same formula and charge), the formula with an R group for glcr
model = createModel({'R1', 'R2'}, {'R1', 'R2'}, {'glc[c] -> glc[e]', 'glcr[c] -> h2o[c]'});
model.metFormulas = {'C6H12O6'; 'C6H12O6'; 'C6H12O6X'; 'H2O'};
model.metCharges = [0; 0; 0; 0];

% inchi1 = inchi4: standard, 7 layers, stereo sub-layers t, m and s (3), charge 0
% inchi2: non-standard, 5 layers, a proton layer p-1 (charge -1), no stereo layer
% inchi3: empty (no data)
% inchi5: standard, 4 layers, other formula (C5H10O5), charge 0
inchi1 = 'InChI=1S/C6H12O6/c7-1-2/h2H/t2-/m1/s1';
inchi2 = 'InChI=1/C6H11O6/c7-1-2/h2H/p-1';
inchi5 = 'InChI=1S/C5H10O5/c6-1/h1H';
inchis = {inchi1; inchi2; ''; inchi1; inchi5};

% sums of quarters and integers are exact in binary; 1e-12 only absorbs rounding
tol = 1e-12;

%% scores and table columns for metCharges, row input

comparisonTable = compareInchis(model, inchis', 'glc');
% the row list is turned into a column
assert(isequal(size(comparisonTable), [5, 15]));
assert(isequal(comparisonTable.InChI, inchis));
assert(isequal(comparisonTable.layers, [7; 5; 0; 7; 4]));
assert(isequal(comparisonTable.standard, logical([1; 0; 0; 1; 1])));
assert(isequal(comparisonTable.metFormula([1 2 4 5]), ["C6H12O6"; "C6H11O6"; "C6H12O6"; "C5H10O5"]));
assert(ismissing(comparisonTable.metFormula(3)));
assert(isequal(comparisonTable.mainLayer([1 2 5]), ["InChI=1S/C6H12O6/c7-1-2/h2H"; ...
    "InChI=1/C6H11O6/c7-1-2/h2H"; "InChI=1S/C5H10O5/c6-1/h1H"]));
assert(isequal(comparisonTable.netCharge, [0; -1; 0; 0; 0]));
% the column is logical, so the count of sub-layers (3 for inchi1) is stored as true
assert(islogical(comparisonTable.stereochemicalSubLayers));
assert(isequal(comparisonTable.stereochemicalSubLayers, logical([1; 0; 0; 1; 0])));
assert(isequal(comparisonTable.isotopicLayer, false(5, 1)));
% charge 0 of glc matches inchi1, inchi4 and inchi5; the empty entry never matches
assert(isequal(comparisonTable.chargeOkBool, logical([1; 0; 0; 1; 1])));
% formula without hydrogen C6O6 matches inchi1, inchi2 and inchi4
assert(isequal(comparisonTable.formulaOkBool, logical([1; 1; 0; 1; 0])));
% 4 non-empty InChIs: inchi1 occurs twice (2/4), the others once (1/4); same for main layers
assert(max(abs(comparisonTable.sourceSimilarity - [0.5; 0.25; 0; 0.5; 0.25])) < tol);
assert(max(abs(comparisonTable.mainLayerSimilarity - [0.5; 0.25; 0; 0.5; 0.25])) < tol);
assert(isequal(comparisonTable.inchiWithMoreLayers, logical([1; 0; 0; 1; 0])));
% scores: charge + 10*formula + stereo (logical column: 1 for three sub-layers) + standard
% + source + main layer + most layers
% inchi1: 1 + 10 + 1 + 1 + 0.5 + 0.5 + 1 = 15; inchi2: 0 + 10 + 0 + 0 + 0.25 + 0.25 + 0 = 10.5;
% empty: 0; inchi5: 1 + 0 + 0 + 1 + 0.25 + 0.25 + 0 = 2.5
assert(max(abs(comparisonTable.scores - [15; 10.5; 0; 15; 2.5])) < tol);

%% charge field metCharge: same comparison

modelCharge = rmfield(model, 'metCharges');
modelCharge.metCharge = [-1; -1; 0; 0];
comparisonTable = compareInchis(modelCharge, inchis, 'glc');
% charge -1 matches inchi2 only
assert(isequal(comparisonTable.chargeOkBool, logical([0; 1; 0; 0; 0])));

%% no charge field: no charge match

modelNoCharge = rmfield(model, 'metCharges');
comparisonTable = compareInchis(modelNoCharge, inchis, 'glc');
assert(~any(comparisonTable.chargeOkBool));
assert(max(abs(comparisonTable.scores - [14; 10.5; 0; 14; 1.5])) < tol);

%% model formula with an R group: X becomes R, so no InChI formula matches

comparisonTable = compareInchis(model, inchis, 'glcr');
assert(~any(comparisonTable.formulaOkBool));

% change the directory
cd(currentDir)
