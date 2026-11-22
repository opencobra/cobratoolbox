% The COBRAToolbox: testReadSimPhenyGPR.m
%
% Purpose:
%     - readSimPhenyGPR reads a SimPheny gene-protein-reaction file: one reaction per line of
%       eight double-quoted, comma-separated fields (ID, name, -, subsystem, EC number, -,
%       gene association, protein association). Lines with another number of fields are
%       skipped. It returns one structure per reaction (ID, name, subSystem, EC, gra, rule,
%       genes, gpa), the column list of reaction IDs and the sorted list of all genes. This
%       test writes a small file by hand (empty fields, a comma inside a field, a skipped
%       line, a reaction without genes) and checks every field; the rule and genes follow
%       the documented output of parseBoolean ("x(i)" in the order of first appearance,
%       & and |), derived by hand.
%
% Function under test:
%     src/base/io/utilities/readSimPhenyGPR.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, a hand-written text file in a temporary folder.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A file without reaction lines stops with an error
%       SEVERITY: limitation
%       TRIGGER: readSimPhenyGPR on an empty file (or one without lines of eight fields)
%       OBSERVED: "Unrecognized function or variable 'rxns'." (rxns and rxnInfo are only
%         created when a reaction line is read)
%       EXPECTED: empty outputs (no reaction, no gene)
%       LINES: 48
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReadSimPhenyGPR'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

tmpDir = tempname;
mkdir(tmpDir);
gprFile = fullfile(tmpDir, 'model_gpr.txt');
fid = fopen(gprFile, 'w');
fprintf(fid, '%s\n', ...
    '"R1","Reaction one","x","Glycolysis","1.1.1.1","y","(b0001 and b0002) or b0003","P1"', ...
    '"R2","Reaction, two","","","","","b0003",""', ...
    'a line without the eight fields is skipped', ...
    '"R3","r3","x","Transport","","y","","P3"');
fclose(fid);

%% every reaction line is read; the skipped line is not a reaction

[rxnInfo, rxns, allGenes] = readSimPhenyGPR(gprFile);
assert(isequal(rxns, {'R1'; 'R2'; 'R3'}));
assert(numel(rxnInfo) == 3);
assert(isequal(fieldnames(rxnInfo), {'ID'; 'name'; 'subSystem'; 'EC'; 'gra'; 'rule'; 'genes'; 'gpa'}));
% every gene once, sorted
assert(isequal(allGenes, {'b0001', 'b0002', 'b0003'}));

%% fields of a reaction with a gene association

assert(strcmp(rxnInfo(1).ID, 'R1') && strcmp(rxnInfo(1).name, 'Reaction one'));
% the subsystem is wrapped in a cell
assert(isequal(rxnInfo(1).subSystem, {'Glycolysis'}));
assert(strcmp(rxnInfo(1).EC, '1.1.1.1') && strcmp(rxnInfo(1).gpa, 'P1'));
assert(strcmp(rxnInfo(1).gra, '(b0001 and b0002) or b0003'));
% genes numbered in the order of first appearance, and/or written as &/|
assert(isequal(rxnInfo(1).genes, {'b0001', 'b0002', 'b0003'}));
assert(strcmp(rxnInfo(1).rule, '(x(1) & x(2)) | x(3)'));

%% empty fields and a comma inside a field

% the comma inside "Reaction, two" is part of the name (fields are separated by ",")
assert(strcmp(rxnInfo(2).name, 'Reaction, two'));
assert(isequal(rxnInfo(2).subSystem, {''}) && isempty(rxnInfo(2).EC) && isempty(rxnInfo(2).gpa));
% the rule numbers the genes of this reaction only
assert(isequal(rxnInfo(2).genes, {'b0003'}) && strcmp(rxnInfo(2).rule, 'x(1)'));

%% a reaction without gene association

assert(isempty(rxnInfo(3).gra) && isempty(rxnInfo(3).rule) && isempty(rxnInfo(3).genes));
assert(isequal(rxnInfo(3).subSystem, {'Transport'}) && strcmp(rxnInfo(3).gpa, 'P3'));

%% a file that cannot be opened raises an error

assert(verifyCobraFunctionError('readSimPhenyGPR', 'inputs', {fullfile(tmpDir, 'missing_gpr.txt')}));

rmdir(tmpDir, 's');

% change the directory
cd(currentDir)
