% The COBRAToolbox: testReadSimPhenyCMPD.m
%
% Purpose:
%     - readSimPhenyCMPD reads a SimPheny compound file: one metabolite per line of nine
%       double-quoted, comma-separated fields (ID, name, formula, -, charge, CAS number,
%       neutral formula, alternative names separated by '/', KEGG ID). Lines with another
%       number of fields are skipped. It returns one structure per metabolite (ID, name,
%       formula, charge as a number, casNumber, neutralFormula, altNames as a cell array
%       without trailing blanks, KEGGID) and the column list of metabolite IDs. This test
%       writes a small file by hand (empty fields, an empty charge, a comma inside a field, skipped lines)
%       and checks every field; expected values are the fields written (hand derivation).
%
% Function under test:
%     src/base/io/utilities/readSimPhenyCMPD.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, a hand-written text file in a temporary folder.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A file without metabolite lines stops with an error
%       SEVERITY: limitation
%       TRIGGER: readSimPhenyCMPD on an empty file (or one without lines of nine fields)
%       OBSERVED: "Unrecognized function or variable 'mets'." (mets and metInfo are only
%         created when a metabolite line is read)
%       EXPECTED: empty outputs (no metabolite)
%       LINES: 46
%     - DEFECT: Alternative names keep the blank that follows a '/'
%       SEVERITY: cosmetic
%       TRIGGER: a line whose eighth field is "adenosine triphosphate / ATP"
%       OBSERVED: altNames is {'adenosine triphosphate'; ' ATP'} (deblank removes trailing
%         blanks only)
%       EXPECTED: {'adenosine triphosphate'; 'ATP'}, the names without the blanks around the
%         separator that the deblank loop is meant to remove
%       LINES: 40
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReadSimPhenyCMPD'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

tmpDir = tempname;
mkdir(tmpDir);
cmpdFile = fullfile(tmpDir, 'model_cmpd.txt');
fid = fopen(cmpdFile, 'w');
% the alternative names of atp have trailing blanks only (a blank after '/' is the cosmetic
% defect above and is not used)
fprintf(fid, '%s\n', ...
    '"atp","ATP","C10H12N5O13P3","x","-4","56-65-5","C10H16N5O13P3","adenosine triphosphate /ATP ","C00002"', ...
    'a line without the nine fields is skipped', ...
    '"h2o","Water, liquid","H2O","","0","","H2O","","C00001"', ...
    '"x1","unknown charge","R","","","","R","x",""', ...
    '"short","line","with","four"');
fclose(fid);

%% every metabolite line is read; the lines with another number of fields are not

[metInfo, mets] = readSimPhenyCMPD(cmpdFile);
assert(isequal(mets, {'atp'; 'h2o'; 'x1'}));
assert(numel(metInfo) == 3);
assert(isequal(fieldnames(metInfo), {'ID'; 'name'; 'formula'; 'charge'; 'casNumber'; ...
    'neutralFormula'; 'altNames'; 'KEGGID'}));

%% fields of a metabolite with every field filled

assert(strcmp(metInfo(1).ID, 'atp') && strcmp(metInfo(1).name, 'ATP'));
assert(strcmp(metInfo(1).formula, 'C10H12N5O13P3') && strcmp(metInfo(1).neutralFormula, 'C10H16N5O13P3'));
% the charge is converted to a number (exact: an integer)
assert(isequal(metInfo(1).charge, -4));
assert(strcmp(metInfo(1).casNumber, '56-65-5') && strcmp(metInfo(1).KEGGID, 'C00002'));
% the alternative names are split at '/' and their trailing blanks removed
assert(isequal(metInfo(1).altNames, {'adenosine triphosphate'; 'ATP'}));

%% empty fields and a comma inside a field

assert(strcmp(metInfo(2).name, 'Water, liquid'));
assert(isequal(metInfo(2).charge, 0) && isempty(metInfo(2).casNumber));
% no alternative name gives an empty cell array
assert(iscell(metInfo(2).altNames) && isempty(metInfo(2).altNames));
assert(strcmp(metInfo(2).KEGGID, 'C00001'));

%% an empty charge and an empty last field

% str2double of an empty field is NaN; the empty KEGG ID (last field) is read as ''
assert(isnan(metInfo(3).charge));
assert(isequal(metInfo(3).altNames, {'x'}) && isempty(metInfo(3).KEGGID));

%% a file that cannot be opened raises an error

assert(verifyCobraFunctionError('readSimPhenyCMPD', 'inputs', {fullfile(tmpDir, 'missing_cmpd.txt')}));

rmdir(tmpDir, 's');

% change the directory
cd(currentDir)
