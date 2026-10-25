% The COBRAToolbox: testGetAnnotationFieldName.m
%
% Purpose:
%     - getAnnotationFieldName gives the COBRA model field that stores the annotation of a database
%     for a field (met, rxn, ...): the defined field when the toolbox knows the database, otherwise
%     a generated field name.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/io/definitions/getAnnotationFieldName.m
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
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetAnnotationFieldName'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% a database with a defined field

[fieldNames, dbIDs, relations] = getAnnotationFieldName('met', 'hmdb', 'is');
assert(isequal(fieldNames, {'metHMDBID'}) && isequal(dbIDs, {'hmdb'}) && isequal(relations, {'is'}));

%% an unknown database gets a generated field name: field + qualifier + converted database + ID

[fieldNames, dbIDs, relations] = getAnnotationFieldName('met', 'unknownDB', 'is');
assert(isequal(fieldNames, {'metisunknownDBID'}) && isequal(dbIDs, {'unknownDB'}) && isequal(relations, {'is'}));
% characters that are not allowed in field names are converted
fieldNames = getAnnotationFieldName('rxn', 'foo-bar', 'bqbiol:is');
assert(isequal(fieldNames, {'rxnbqbiol:isfoo__45__barID'}));

%% several databases at once, known and unknown

[fieldNames, dbIDs] = getAnnotationFieldName('met', {'hmdb', 'unknownDB'}, {'is', 'is'});
assert(isequal(fieldNames, {'metHMDBID'; 'metisunknownDBID'}));
assert(isequal(dbIDs, {'hmdb'; 'unknownDB'}));

%% qualifiers can be excluded, or (inverted) the only ones used

% the qualifier 'is' is excluded from the defined mappings
assert(isempty(getAnnotationFieldName('met', 'hmdb', 'is', {'is'}, false)));
% inverted: only the qualifier 'is' is used
assert(isequal(getAnnotationFieldName('met', 'hmdb', 'is', {'is'}, true), {'metHMDBID'}));

% change the directory
cd(currentDir)
