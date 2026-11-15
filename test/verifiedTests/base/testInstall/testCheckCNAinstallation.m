% The COBRAToolbox: testCheckCNAinstallation.m
%
% Purpose:
%     - checkCNAinstallation(printLevel) makes sure the CnaCobraInterface submodule
%       (external/analysis/CnaCobraInterface) provides CNAcobra2cna, returns true when
%       CellNetAnalyzer (startcna) is on the MATLAB path - removing CNA's own libSBML and
%       efmtool folders from the path - and false otherwise, printing a message when
%       printLevel > 0. CellNetAnalyzer is not installed on the reference machine: a temporary
%       folder with a stub startcna.m and the code/ext/libSBML and code/ext/efmtool folders
%       stands in for it, so the expected values follow from the folders the test creates.
%       Any real startcna is taken off the path first, and the MATLAB path is restored at
%       the end.
%
% Function under test:
%     src/base/install/checkCNAinstallation.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a stub CellNetAnalyzer folder replaces the installation.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCheckCNAinstallation'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the function changes the MATLAB path: save it
savedPath = path;

% take any real CellNetAnalyzer off the path so that the absent case is reproducible
while ~isempty(which('startcna'))
    rmpath(fileparts(which('startcna')));
end

%% CellNetAnalyzer absent: false, with and without the message

% printLevel 0 prints nothing, the default printLevel (1) prints the message
assert(checkCNAinstallation(0) == false);
assert(checkCNAinstallation() == false);
assert(checkCNAinstallation(1) == false);

%% the interface submodule is put back on the path when CNAcobra2cna is not found there

% remove the submodule folder: CNAcobra2cna is then not found in an 'external' folder, and
% the function adds the folder again
interfaceDir = [CBTDIR filesep 'external' filesep 'analysis' filesep 'CnaCobraInterface'];
rmpath(genpath(interfaceDir));
assert(~contains(which('CNAcobra2cna'), 'external'));
assert(checkCNAinstallation(0) == false);
assert(contains(path, interfaceDir));

%% CellNetAnalyzer present: true, and CNA's libSBML and efmtool folders leave the path

% a stub installation: startcna.m plus the two external folders of CNA (libSBML with a
% subfolder, to check that the whole tree is removed)
cnaDir = tempname;
libSBMLDir = [cnaDir filesep 'code' filesep 'ext' filesep 'libSBML'];
efmtoolDir = [cnaDir filesep 'code' filesep 'ext' filesep 'efmtool'];
mkdir([libSBMLDir filesep 'matlab']);
mkdir(efmtoolDir);
fid = fopen([cnaDir filesep 'startcna.m'], 'w');
fprintf(fid, 'function startcna()\n%% stub of the CellNetAnalyzer start script (test double)\nend\n');
fclose(fid);
addpath(cnaDir);
addpath(genpath(libSBMLDir));
addpath(efmtoolDir);
assert(contains(path, [libSBMLDir pathsep]));
assert(contains(path, [efmtoolDir pathsep]));

assert(checkCNAinstallation(1) == true);
% both trees are gone, the CNA folder itself stays
assert(~contains(path, libSBMLDir));
assert(~contains(path, efmtoolDir));
assert(strcmp(which('startcna'), [cnaDir filesep 'startcna.m']));

% a second call finds nothing to remove and is still true (silent with printLevel 0)
assert(checkCNAinstallation(0) == true);

% restore the MATLAB path and remove the stub installation
path(savedPath);
rmdir(cnaDir, 's');

% change the directory
cd(currentDir)
