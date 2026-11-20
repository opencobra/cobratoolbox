% The COBRAToolbox: testParse_Atomic_Weights_and_Isotopic_Compositions_for_All_Elem.m
%
% Purpose:
%     - parse_Atomic_Weights_and_Isotopic_Compositions_for_All_Elements reads the NIST table
%       Atomic_Weights_and_Isotopic_Compositions_for_All_Elements.txt (shipped next to the
%       function, records of 7 "name = value" lines separated by a blank line) into a struct
%       array atomicWeights.data with one element per isotope record, and the list of atomic
%       symbols atomicWeights.AtomicSymbol. The test checks the number of records (the 2816 lines
%       read are 352 records of 8 lines), the numeric and text fields of hydrogen, tritium,
%       carbon-12/13/14 and nitrogen-14 against the NIST values written in the data file, the
%       empty fields (an empty isotopic composition is NaN) and the last record (element 116).
%       Expected values are the decimal numbers of the data file (NIST, Coursey et al.).
%     - File name: test<Name> (III-Naming) would be 67 characters, longer than the 63 MATLAB
%       allows for a name (namelengthmax); MATLAB then cuts the name, and the CI coverage run
%       fails with "Unrecognized function or variable". The file therefore has the name
%       test<Name> cut to 63 characters, the name MATLAB itself uses for it.
%
% Function under test:
%     src/dataIntegration/chemoInformatics/molecularWeight/basicPhysicochemicalData/parse_Atomic_Weights_and_Isotopic_Compositions_for_All_Elements.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; the input is the data file shipped with the function.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Renamed to a name of 63 characters, MATLAB's limit (T036), 2026-11-20.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testParse_Atomic_Weights_and_Isotopic_Compositions_for_All_Elem'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% parse the data file once (the function finds it on the MATLAB path)
atomicWeights = parse_Atomic_Weights_and_Isotopic_Compositions_for_All_Elements();

%% one record per isotope: 2816 lines / 8 lines per record = 352 records

% counts are integers, so they are compared exactly
assert(numel(atomicWeights.data) == 352);
assert(iscell(atomicWeights.AtomicSymbol) && isequal(size(atomicWeights.AtomicSymbol), [1, 352]));
assert(isequal(atomicWeights.AtomicSymbol(1:6), {'H', 'D', 'T', 'He', 'He', 'Li'}));
assert(strcmp(atomicWeights.AtomicSymbol{end}, 'Uuh'));
expectedFields = {'AtomicNumber'; 'AtomicSymbol'; 'MassNumber'; 'RelativeAtomicMass'; ...
    'IsotopicComposition'; 'StandardAtomicWeight'; 'Notes'};
assert(isequal(fieldnames(atomicWeights.data), expectedFields));

%% numeric and text fields of hydrogen (record 1)

% decimal numbers of the data file; textscan converts the same decimal text that the literal
% below denotes, so the doubles agree to rounding (tolerance 1e-12 relative)
tol = 1e-12;
hydrogen = atomicWeights.data(1);
assert(hydrogen.AtomicNumber == 1 && hydrogen.MassNumber == 1);
assert(isequal(hydrogen.AtomicSymbol, {'H'}));
assert(abs(hydrogen.RelativeAtomicMass - 1.0078250321) < tol);
assert(abs(hydrogen.IsotopicComposition - 99.9885) < tol * 100);
assert(abs(hydrogen.StandardAtomicWeight - 1.00794) < tol);
assert(isequal(hydrogen.Notes, {'g,m,r,c,w'}));

%% an empty isotopic composition is read as NaN (tritium, record 3)

tritium = atomicWeights.data(3);
assert(isequal(tritium.AtomicSymbol, {'T'}) && tritium.MassNumber == 3);
assert(abs(tritium.RelativeAtomicMass - 3.0160492675) < tol);
assert(isnan(tritium.IsotopicComposition));

%% carbon isotopes 12, 13, 14 (records 11-13) and nitrogen-14 (record 14)

carbonRecords = find(strcmp(atomicWeights.AtomicSymbol, 'C'));
assert(isequal(carbonRecords, [11, 12, 13]));
assert(isequal([atomicWeights.data(carbonRecords).MassNumber], [12, 13, 14]));
assert(isequal([atomicWeights.data(carbonRecords).AtomicNumber], [6, 6, 6]));
% carbon-12 defines the atomic mass unit: exactly 12
assert(atomicWeights.data(11).RelativeAtomicMass == 12);
assert(abs(atomicWeights.data(12).RelativeAtomicMass - 13.0033548378) < tol * 13);
assert(abs(atomicWeights.data(11).IsotopicComposition - 98.93) < tol * 100);
assert(abs(atomicWeights.data(12).IsotopicComposition - 1.07) < tol);
assert(isnan(atomicWeights.data(13).IsotopicComposition));
% every carbon isotope carries the standard atomic weight of the element, 12.0107
assert(all(abs([atomicWeights.data(carbonRecords).StandardAtomicWeight] - 12.0107) < tol * 12));
assert(isequal(atomicWeights.data(13).Notes, {'g,r'}));
nitrogen = atomicWeights.data(14);
assert(isequal(nitrogen.AtomicSymbol, {'N'}) && nitrogen.AtomicNumber == 7 && nitrogen.MassNumber == 14);
assert(abs(nitrogen.StandardAtomicWeight - 14.0067) < tol * 14);
assert(isequal(nitrogen.Notes, {'g,r,e'}));

%% the last record: element 116 with empty masses

lastRecord = atomicWeights.data(end);
assert(lastRecord.AtomicNumber == 116 && lastRecord.MassNumber == 292);
assert(isnan(lastRecord.RelativeAtomicMass) && isnan(lastRecord.IsotopicComposition));
assert(isequal(lastRecord.AtomicSymbol, {'Uuh'}));

% change the directory
cd(currentDir)
