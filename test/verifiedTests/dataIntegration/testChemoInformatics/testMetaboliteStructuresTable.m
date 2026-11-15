% The COBRAToolbox: testMetaboliteStructuresTable.m
%
% Purpose:
%     - metaboliteStructuresTable reads every MDL MOL file of a folder and builds a table with
%       one row per file: the metabolite name (file name without .mol) and its InChIKey, InChI
%       and SMILES, which it obtains from Open Babel through openBabelConverter; optionally the
%       table is written to <saveDir>/metaboliteStructures.txt. The test checks what does not
%       need Open Babel:
%         * a folder without MOL files gives an empty table with the four documented string
%           columns mets, inchikey, inchi, smiles, with and without a trailing file separator;
%         * with saveDir the empty table is written as a header line only, and without saveDir
%           (omitted or empty) nothing is written;
%         * a folder with a MOL file: when obabel cannot be found on the system path (status
%           127), the error of openBabelConverter (installation message) reaches the caller.
%       The system path is set to an empty temporary folder for that call and restored.
%
% Function under test:
%     src/dataIntegration/chemoInformatics/metabolites/metaboliteStructuresTable.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, no external program.
%
% Coverage exemptions:
%     Lines 42-54: need the external program Open Babel (obabel), which cannot be run from
%     MATLAB on the reference machine, so it is treated as not installed: the InChIKey, InChI
%     and SMILES of each file and the next loop iterations.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMetaboliteStructuresTable'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% all files of this test live in a temporary folder removed at the end
workFolder = tempname;
molFolder = [workFolder filesep 'mol'];
saveFolder = [workFolder filesep 'save'];
mkdir(molFolder);
mkdir(saveFolder);
savedTable = [saveFolder filesep 'metaboliteStructures.txt'];

%% a folder without MOL files gives an empty table with the four string columns

% a file with another extension is ignored (only *.mol files are read)
fid = fopen([molFolder filesep 'notes.txt'], 'w');
fprintf(fid, 'not a structure\n');
fclose(fid);

metTable = metaboliteStructuresTable(molFolder);
assert(istable(metTable) && isequal(size(metTable), [0 4]));
assert(isequal(metTable.Properties.VariableNames, {'mets', 'inchikey', 'inchi', 'smiles'}));
assert(isstring(metTable.mets) && isstring(metTable.inchikey) && isstring(metTable.inchi) ...
    && isstring(metTable.smiles));
% an empty saveDir saves nothing either
metTable = metaboliteStructuresTable(molFolder, '');
assert(isequal(size(metTable), [0 4]));
assert(~isfile(savedTable));

%% saveDir with a trailing file separator: the empty table is written as its header line

metTable = metaboliteStructuresTable([molFolder filesep], [saveFolder filesep]);
assert(isequal(size(metTable), [0 4]));
assert(isfile(savedTable));
savedLines = strtrim(splitlines(strtrim(fileread(savedTable))));
assert(isequal(savedLines, {'mets,inchikey,inchi,smiles'}));

%% a MOL file and no Open Babel: the installation error of openBabelConverter reaches the caller

% the content of the file is never read: the Open Babel check comes first
fid = fopen([molFolder filesep 'alanine.mol'], 'w');
fprintf(fid, 'alanine\n\n\n  0  0  0  0  0  0  0  0  0  0999 V2000\nM  END\n');
fclose(fid);

% make obabel unreachable: the system path holds only an empty temporary folder, so the shell
% answers "command not found" (status 127) whether or not Open Babel is installed
originalPath = getenv('PATH');
emptyFolder = tempname;
mkdir(emptyFolder);
setenv('PATH', emptyFolder);
installMessage = ['To use this function, Open Babel must be installed; follow the installation ' ...
    'instructions in https://openbabel.org/wiki/Category:Installation'];
delete(savedTable);
assert(verifyCobraFunctionError('metaboliteStructuresTable', 'inputs', {molFolder, saveFolder}, ...
    'testMessage', installMessage));
% the error comes before the table is saved
assert(~isfile(savedTable));

% restore the system path and remove the temporary folders
setenv('PATH', originalPath);
rmdir(emptyFolder, 's');
rmdir(workFolder, 's');

% change the directory
cd(currentDir)
