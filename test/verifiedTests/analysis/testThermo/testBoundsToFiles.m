% The COBRAToolbox: testBoundsToFiles.m
%
% Purpose:
%     - boundsToFiles writes the metabolite concentration bounds (met(m).abbreviation,
%       met(m).concMin, met(m).concMax) to model_met_bounds.txt and the reaction flux bounds
%       (rxn(n).abbreviation, lb(n), ub(n)) to model_rxn_bounds.txt in the current folder, one
%       tab-delimited line per metabolite or reaction with the numbers in the format %g. This
%       test checks both files, character by character, for a hand-built model, the six
%       significant digits of %g, and a model without metabolites. The expected text is worked
%       out from the format '%s\t%g\t%g\n' of the function and the C rules of %g.
%
% Function under test:
%     src/analysis/thermo/experimentalData/boundsToFiles.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - hand-built model with the met and rxn structure arrays the function reads, two
%     text files in a tempname folder, no solver.
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
fileDir = fileparts(which('testBoundsToFiles'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the function writes into the current folder: work in a temporary folder
workDir = tempname;
mkdir(workDir);
cd(workDir);

% hand-built model: 2 metabolites, 3 reactions (a[c] -> b[c], b[c] <=> , a[c] <=>)
model = struct();
model.S = [-1 0 1; 1 -1 0];
model.lb = [0; -1000; -2.5];
model.ub = [1000; 1000; 1.25e-3];
model.met(1).abbreviation = 'a[c]';
model.met(1).concMin = 1e-5;
model.met(1).concMax = 0.02;
model.met(2).abbreviation = 'b[c]';
model.met(2).concMin = 1e-6;
model.met(2).concMax = 1;
model.rxn(1).abbreviation = 'R1';
model.rxn(2).abbreviation = 'EX_b';
model.rxn(3).abbreviation = 'EX_a';

%% both files: one tab-delimited line per metabolite and per reaction, in model order

boundsToFiles(model);
% %g prints 1e-05 and 1e-06 in exponent form (exponent < -4) and the others as plain numbers
expectedMetText = sprintf('a[c]\t1e-05\t0.02\nb[c]\t1e-06\t1\n');
expectedRxnText = sprintf('R1\t0\t1000\nEX_b\t-1000\t1000\nEX_a\t-2.5\t0.00125\n');
% the files are text, so the comparison is exact
assert(isequal(fileread('model_met_bounds.txt'), expectedMetText));
assert(isequal(fileread('model_rxn_bounds.txt'), expectedRxnText));

% read back as the documented table: the numbers have at most six significant digits, so
% they are recovered exactly
fid = fopen('model_rxn_bounds.txt', 'r');
rxnTable = textscan(fid, '%s %f %f', 'Delimiter', '\t');
fclose(fid);
assert(isequal(rxnTable{1}, {'R1'; 'EX_b'; 'EX_a'}));
assert(isequal(rxnTable{2}, model.lb) && isequal(rxnTable{3}, model.ub));
% one line per column of S
assert(numel(rxnTable{1}) == size(model.S, 2));

%% %g keeps six significant digits

modelDigits = model;
modelDigits.met(1).concMin = 1.23456789e-5;
modelDigits.lb(1) = 123456789;
boundsToFiles(modelDigits);
% 1.23456789e-5 -> 1.23457e-05 and 123456789 -> 1.23457e+08 (rounded to six digits)
assert(isequal(fileread('model_met_bounds.txt'), sprintf('a[c]\t1.23457e-05\t0.02\nb[c]\t1e-06\t1\n')));
assert(isequal(fileread('model_rxn_bounds.txt'), ...
    sprintf('R1\t1.23457e+08\t1000\nEX_b\t-1000\t1000\nEX_a\t-2.5\t0.00125\n')));

%% a model without metabolites writes an empty metabolite file

modelNoMets = struct();
modelNoMets.S = zeros(0, 1);
modelNoMets.lb = -1;
modelNoMets.ub = 1;
modelNoMets.met = struct('abbreviation', {}, 'concMin', {}, 'concMax', {});
modelNoMets.rxn(1).abbreviation = 'R1';
boundsToFiles(modelNoMets);
% the files are overwritten: no metabolite line, one reaction line
assert(isempty(fileread('model_met_bounds.txt')));
assert(isequal(fileread('model_rxn_bounds.txt'), sprintf('R1\t-1\t1\n')));

% remove the temporary folder and change the directory
cd(currentDir);
rmdir(workDir, 's');
