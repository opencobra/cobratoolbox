% The COBRAToolbox: testWriteGDXFromCOBRA.m
%
% Purpose:
%     - writeGDXFromCOBRA(cobraStruct, 'FileName', f, 'IncludeSets', s, 'IncludeBounds', b)
%       builds the GAMS GDX symbols S (full stoichiometric matrix over met x rxn), isRev
%       (lb < 0), optionally the sets rxn and met and the parameters lb and ub, passes them to
%       wgdx (GAMS) and returns a GAMS load example; without wgdx it only prints a message.
%       GAMS is not installed on the reference machine: a test double wgdx.m, written to a
%       temporary folder, stores its arguments in a .mat file, so the test checks the
%       symbols the function builds and the help text (expected values written out by hand
%       from the documented GDX layout and the function's text). Any real wgdx is taken off
%       the path for the "not found" case; the MATLAB path is restored at the end.
%
% Function under test:
%     src/base/io/writeGDXFromCOBRA.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a hand-built 2 x 3 model and a test double of wgdx.
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
fileDir = fileparts(which('testWriteGDXFromCOBRA'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the test changes the MATLAB path: save it
savedPath = path;

% work in a temporary folder (the help text names the current folder)
workDir = tempname;
mkdir(workDir);
cd(workDir);

% a 2 x 3 model: r1 reversible (lb < 0), r2 and r3 irreversible; S is sparse to check the
% conversion to a full matrix
model.S = sparse([-1 1 0; 0 -1 2]);
model.mets = {'a'; 'b'};
model.rxns = {'r1'; 'r2'; 'r3'};
model.lb = [-10; 0; 0];
model.ub = [10; 5; 1000];

%% without wgdx on the path only a message is printed

% take any real GAMS wgdx off the path
while exist('wgdx', 'file') ~= 0
    rmpath(fileparts(which('wgdx')));
end
writeGDXFromCOBRA(model, 'FileName', 'none.gdx');
% nothing is written
workListing = dir(workDir);
assert(all(ismember({workListing.name}, {'.', '..'})));

%% a test double of wgdx stores the symbols it receives

fakeDir = tempname;
mkdir(fakeDir);
callFile = [fakeDir filesep 'wgdxCall.mat'];
fid = fopen([fakeDir filesep 'wgdx.m'], 'w');
fprintf(fid, 'function wgdx(fileName, varargin)\n');
fprintf(fid, '%% test double of the GAMS wgdx: stores its arguments next to this file\n');
fprintf(fid, 'save(fullfile(fileparts(mfilename(''fullpath'')), ''wgdxCall.mat''), ''fileName'', ''varargin'');\n');
fprintf(fid, 'end\n');
fclose(fid);
addpath(fakeDir);
assert(exist('wgdx', 'file') ~= 0);

%% default options: S, isRev, the sets rxn and met, and the bounds lb and ub

helpText = writeGDXFromCOBRA(model, 'FileName', 'model.gdx');
wgdxCall = load(callFile);
assert(strcmp(wgdxCall.fileName, 'model.gdx'));
symbols = wgdxCall.varargin;
assert(numel(symbols) == 6);
assert(isequal(cellfun(@(x) x.name, symbols, 'UniformOutput', false), {'S', 'isRev', 'rxn', 'met', 'lb', 'ub'}));

% S: the full matrix with metabolites and reactions as row vectors of labels (exact copy)
assert(isequal(symbols{1}.val, [-1 1 0; 0 -1 2]) && ~issparse(symbols{1}.val));
assert(isequal(symbols{1}.uels, {{'a', 'b'}, {'r1', 'r2', 'r3'}}));
assert(strcmp(symbols{1}.form, 'full') && strcmp(symbols{1}.type, 'parameter'));

% isRev: 1 where lb < 0, as double
assert(isequal(symbols{2}.val, [1; 0; 0]) && isa(symbols{2}.val, 'double'));
assert(isequal(symbols{2}.uels, {'r1', 'r2', 'r3'}));
assert(strcmp(symbols{2}.form, 'full') && strcmp(symbols{2}.type, 'parameter'));

% the sets carry only labels
assert(isequal(symbols{3}, struct('name', 'rxn', 'uels', {{'r1', 'r2', 'r3'}})));
assert(isequal(symbols{4}, struct('name', 'met', 'uels', {{'a', 'b'}})));

% the bounds are copied unchanged
assert(isequal(symbols{5}.val, model.lb) && isequal(symbols{5}.uels, {'r1', 'r2', 'r3'}));
assert(isequal(symbols{6}.val, model.ub) && isequal(symbols{6}.uels, {'r1', 'r2', 'r3'}));
assert(strcmp(symbols{5}.form, 'full') && strcmp(symbols{6}.type, 'parameter'));

% the help text, written out from the function's documented load example
expectedHelp = sprintf(['Example load for .gms file:\n\nsets met,rxn;\nparameters S,isRev,lb,ub;\n', ...
                        '$gdxin %s%c%s  \n$load %s \n$gdxin'], pwd, filesep, 'model.gdx', 'S isRev met rxn lb ub');
assert(strcmp(helpText, expectedHelp));

%% IncludeSets and IncludeBounds false: only S and isRev, sets loaded from the domains of S

delete(callFile);
helpText = writeGDXFromCOBRA(model, 'FileName', 'small.gdx', 'IncludeSets', false, 'IncludeBounds', false);
wgdxCall = load(callFile);
assert(strcmp(wgdxCall.fileName, 'small.gdx'));
assert(isequal(cellfun(@(x) x.name, wgdxCall.varargin, 'UniformOutput', false), {'S', 'isRev'}));
expectedHelp = sprintf(['Example load for .gms file:\n\nsets met,rxn;\nparameters S,isRev;\n', ...
                        '$gdxin %s%c%s  \n$load %s \n$gdxin'], pwd, filesep, 'small.gdx', 'S isRev met<S.dim1 rxn<S.dim2');
assert(strcmp(helpText, expectedHelp));

%% sets without bounds, and the default file name COBRAModel_<mmddyyHHMMSS>.gdx

delete(callFile);
helpText = writeGDXFromCOBRA(model, 'IncludeBounds', false);
wgdxCall = load(callFile);
assert(~isempty(regexp(wgdxCall.fileName, '^COBRAModel_\d{12}\.gdx$', 'once')));
assert(isequal(cellfun(@(x) x.name, wgdxCall.varargin, 'UniformOutput', false), {'S', 'isRev', 'rxn', 'met'}));
assert(contains(helpText, sprintf('parameters S,isRev;\n')));
assert(contains(helpText, '$load S isRev met rxn '));

%% invalid inputs are rejected by the input parser

% the model must be a structure, IncludeSets/IncludeBounds logical, FileName text
assert(verifyCobraFunctionError('writeGDXFromCOBRA', 'inputs', {model.S}));
assert(verifyCobraFunctionError('writeGDXFromCOBRA', 'inputs', {model, 'IncludeSets', 1}));
assert(verifyCobraFunctionError('writeGDXFromCOBRA', 'inputs', {model, 'IncludeBounds', 'no'}));
assert(verifyCobraFunctionError('writeGDXFromCOBRA', 'inputs', {model, 'FileName', 3}));

% restore the MATLAB path, remove the temporary folders
path(savedPath);
cd(fileDir);
rmdir(fakeDir, 's');
rmdir(workDir, 's');

% change the directory
cd(currentDir)
