% The COBRAToolbox: testConnectedRxnsByEFM.m
%
% Purpose:
%     - connectedRxnsByEFM links the reactions of each connected component of internal cycles
%       that share an elementary flux mode (EFM), computed by EFMtool (CalculateFluxModes). This
%       test checks the documented empty result when EFMtool is not on the path, and then
%       replaces EFMtool by a stub (two files in a tempname folder) to check what the function
%       sends to EFMtool for each component (the sub-matrix of S without empty rows, with the
%       columns of the reactions that are in cycles only in the forward direction negated, the
%       reversibility vector and the options) and how it builds the linkage matrix from the
%       EFMs returned (worked out by hand), and that an error of EFMtool gives an empty result.
%
% Function under test:
%     src/analysis/thermo/thermoFBA/connectedRxnsByEFM.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a createModel model and an EFMtool stub, no solver. EFMtool is not distributed
%     with the toolbox and is not installed on the reference machine; the stub returns
%     hand-written EFMs, so the test checks the use of EFMtool, not EFMtool itself.
%
% Coverage exemptions:
%     None. Every executable line is reached below (lines 33-37 only where EFMtool is not on the
%     path; the first section is skipped where it is).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The working directory is not restored when EFMtool fails
%       SEVERITY: cosmetic
%       TRIGGER: an error inside the loop over components, e.g. CalculateFluxModes raising an
%       error
%       OBSERVED: the catch block returns at line 68 without cd(p), so the caller is left in the
%       EFMtool folder (MATLAB R2025a, with the stub below); rxnLink = [] as documented
%       EXPECTED: the working directory of the caller is restored, as at line 71
%       LINES: 68
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConnectedRxnsByEFM'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed; the call is the standard opening of a COBRA
% test and the place where a requirement would be added later
prepareTest();

% component 1: the cycle r1 -> r2 -> r3; component 2: r4, r5, r6 on D, E, F; r7 is not in a cycle
model = createModel({'r1', 'r2', 'r3', 'r4', 'r5', 'r6', 'r7'}, {'r1', 'r2', 'r3', 'r4', 'r5', 'r6', 'r7'}, ...
    {'A -> B', 'B -> C', 'C -> A', 'D -> E', 'E -> F', 'F -> D', 'A -> G'}, 'printLevel', 0);
conComp = [1; 1; 1; 2; 2; 2; 0];
% r1 and r4 are in cycles only forward, r2 and r5 in both directions, r3 and r6 only in reverse
rxnInLoops = logical([1 0; 1 1; 0 1; 1 0; 1 1; 0 1; 0 0]);

%% EFMtool not on the path: empty result, with and without a message

if isempty(which('CalculateFluxModes.m'))
    assert(isempty(connectedRxnsByEFM(model, conComp, rxnInLoops)));
    assert(isempty(connectedRxnsByEFM(model, conComp, rxnInLoops, 1)));
end

%% EFMtool stub: what is sent to EFMtool and how the linkage matrix is built

stubDir = tempname;
mkdir(stubDir);
% CreateFluxModeOpts returns its arguments; CalculateFluxModes records its inputs and returns
% the next hand-written EFM matrix (or raises an error when asked to)
fid = fopen(fullfile(stubDir, 'CreateFluxModeOpts.m'), 'w');
fprintf(fid, 'function opts = CreateFluxModeOpts(varargin)\nopts = struct(''args'', {varargin});\nend\n');
fclose(fid);
fid = fopen(fullfile(stubDir, 'CalculateFluxModes.m'), 'w');
fprintf(fid, ['function result = CalculateFluxModes(S, rev, opts)\n', ...
    'if getappdata(0, ''efmStubError''), error(''efmStub:failure'', ''EFM stub failure''); end\n', ...
    'calls = getappdata(0, ''efmStubCalls'');\n', ...
    'calls{end + 1} = {S, rev, opts};\n', ...
    'setappdata(0, ''efmStubCalls'', calls);\n', ...
    'efms = getappdata(0, ''efmStubEfms'');\n', ...
    'result.efms = efms{numel(calls)};\n', 'end\n']);
fclose(fid);
addpath(stubDir);

% EFMs (reactions x modes): component 1 has the single cycle r1 r2 r3; component 2 has two
% modes, {r4, r5} and {r5, r6}
setappdata(0, 'efmStubError', false);
setappdata(0, 'efmStubCalls', {});
setappdata(0, 'efmStubEfms', {[1; 1; 1], [1 0; 1 1; 0 1]});

rxnLink = connectedRxnsByEFM(model, conComp, rxnInLoops);
calls = getappdata(0, 'efmStubCalls');
assert(numel(calls) == 2);

% the working directory is restored after a successful run
assert(strcmp(pwd, fileDir));

% component 1: rows of A, B, C only (the empty rows are dropped), column r1 negated
% (forward-only), reversibility only for r2 (both directions); the entries are integers
rowsComp1 = any(model.S(:, 1:3), 2);
expectedS1 = full(model.S(rowsComp1, 1:3));
expectedS1(:, 1) = -expectedS1(:, 1);
assert(isequal(calls{1}{1}, expectedS1));
assert(isequal(calls{1}{2}, [0; 1; 0]));
assert(isequal(calls{1}{3}.args, {'sign-only', true, 'level', 'WARNING'}));
% component 2: rows of D, E, F, column r4 negated, r5 reversible
rowsComp2 = any(model.S(:, 4:6), 2);
expectedS2 = full(model.S(rowsComp2, 4:6));
expectedS2(:, 1) = -expectedS2(:, 1);
assert(isequal(calls{2}{1}, expectedS2));
assert(isequal(calls{2}{2}, [0; 1; 0]));

% linkage: reaction i is linked to every reaction of an EFM that contains i; r1..r3 are all
% linked; r4 is linked to r4, r5; r5 to r4, r5, r6; r6 to r5, r6; r7 to nothing
expectedLink = zeros(7);
expectedLink(1:3, 1:3) = 1;
expectedLink(4:6, 4:6) = [1 1 0; 1 1 1; 0 1 1];
assert(issparse(rxnLink));
assert(isequal(full(rxnLink), expectedLink));

%% an error of EFMtool gives an empty linkage matrix

setappdata(0, 'efmStubError', true);
rxnLink = connectedRxnsByEFM(model, conComp, rxnInLoops, 1);
assert(isempty(rxnLink));

% return to the test folder (the function leaves the stub folder as the working directory
% after an error, see the known defect) and remove the stub
cd(fileDir);
rmpath(stubDir);
rmdir(stubDir, 's');
rmappdata(0, 'efmStubError');
rmappdata(0, 'efmStubCalls');
rmappdata(0, 'efmStubEfms');

% change the directory
cd(currentDir)
