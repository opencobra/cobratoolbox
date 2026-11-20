% The COBRAToolbox: testGetCompartment.m
%
% Purpose:
%     - getCompartment splits metabolite identifiers into the metabolite abbreviation and the
%       compartment symbol, in the bracket format metAbbr[c] or the underscore format metAbbr_c
%       (a single letter after the last underscore); identifiers in neither format are kept
%       as abbreviation with an empty compartment. It returns the compartments, the unique
%       compartments, the abbreviations and the unique abbreviations, as char for a single
%       char input and as column cell arrays for a cell input. This test checks a single
%       char identifier in each format, a column and a row cell array mixing the formats,
%       multi-letter bracket compartments, identifiers that only resemble a format, and an
%       empty cell array. Expected values are read off the documented formats (hand
%       derivation); unique values are sorted as MATLAB's unique sorts them.
%
% Function under test:
%     src/analysis/thermo/vonBertalanffy/getCompartment.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built identifiers.
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
fileDir = fileparts(which('testGetCompartment'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% single char identifier in the bracket format: every output is a char

[compartments, uniqueCompartments, abbr, uniqueAbbr] = getCompartment('atp[c]');
assert(ischar(compartments) && strcmp(compartments, 'c'));
assert(ischar(uniqueCompartments) && strcmp(uniqueCompartments, 'c'));
assert(ischar(abbr) && strcmp(abbr, 'atp'));
assert(ischar(uniqueAbbr) && strcmp(uniqueAbbr, 'atp'));

%% single char identifier in the underscore format: only the last underscore separates

% glc__D_e: the compartment is the single letter after the last underscore; the double
% underscore of the BiGG abbreviation stays in the abbreviation
[compartments, uniqueCompartments, abbr, uniqueAbbr] = getCompartment('glc__D_e');
assert(strcmp(compartments, 'e') && strcmp(uniqueCompartments, 'e'));
assert(strcmp(abbr, 'glc__D') && strcmp(uniqueAbbr, 'glc__D'));

%% single char identifier without compartment: kept as abbreviation, empty compartment

[compartments, uniqueCompartments, abbr, uniqueAbbr] = getCompartment('h2o');
assert(ischar(compartments) && isempty(compartments));
assert(ischar(uniqueCompartments) && isempty(uniqueCompartments));
assert(strcmp(abbr, 'h2o') && strcmp(uniqueAbbr, 'h2o'));

%% column cell array mixing the formats: column outputs and sorted unique values

mets = {'atp[c]'; 'glc__D_e'; 'h2o'; 'atp[m]'};
[compartments, uniqueCompartments, abbr, uniqueAbbr] = getCompartment(mets);
assert(isequal(compartments, {'c'; 'e'; ''; 'm'}));
assert(isequal(abbr, {'atp'; 'glc__D'; 'h2o'; 'atp'}));
% unique sorts the empty compartment first; atp occurs twice and is listed once
assert(isequal(uniqueCompartments, {''; 'c'; 'e'; 'm'}));
assert(isequal(uniqueAbbr, {'atp'; 'glc__D'; 'h2o'}));

%% row cell array: the outputs are column cell arrays

[compartments, uniqueCompartments, abbr, uniqueAbbr] = getCompartment({'pyr[c]', 'pyr_e', 'pyr[c]'});
assert(isequal(compartments, {'c'; 'e'; 'c'}) && isequal(abbr, {'pyr'; 'pyr'; 'pyr'}));
assert(isequal(uniqueCompartments, {'c'; 'e'}) && isequal(uniqueAbbr, {'pyr'}));

%% multi-letter bracket compartments and identifiers that only resemble a format

% the bracket format accepts any symbol up to the closing bracket; the underscore format
% only a single letter, so atp_12 and coa_ce have no compartment; an opening bracket without
% a closing one is not the bracket format
[compartments, ~, abbr] = getCompartment({'met[ce]'; 'atp_12'; 'coa_ce'; 'atp[c'});
assert(isequal(compartments, {'ce'; ''; ''; ''}));
assert(isequal(abbr, {'met'; 'atp_12'; 'coa_ce'; 'atp[c'}));

%% empty cell array: empty column outputs

[compartments, uniqueCompartments, abbr, uniqueAbbr] = getCompartment({});
assert(iscell(compartments) && isequal(size(compartments), [0 1]));
assert(iscell(abbr) && isequal(size(abbr), [0 1]));
assert(iscell(uniqueCompartments) && isempty(uniqueCompartments));
assert(iscell(uniqueAbbr) && isempty(uniqueAbbr));

% change the directory
cd(currentDir)
