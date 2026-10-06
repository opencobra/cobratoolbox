% The COBRAToolbox: testGetIDPositions.m
%
% Purpose:
%     - Characterization test that PINS the current behaviour of getIDPositions,
%       which returns the positions of a list of IDs inside one model field, and
%       whether each ID was found. The function previously had no test (feature
%       025-tier1-test-pilot). It asserts EXISTING behaviour (Constitution
%       Principle III, characterization mode) and must not change getIDPositions.
%
% Function under test:
%     src/reconstruction/refinement/getIDPositions.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver. The "model" is a tiny struct
%     containing only the fields the function reads. Never skipped.
%
% Coverage exemptions:
%     None. Every executable line of getIDPositions is reached below.
%
% Authors:
%     - Generated for feature 025-tier1-test-pilot, 2026-10-06.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetIDPositions'));
cd(fileDir);

% hand-built model stub: only the fields getIDPositions can look at
modelStub.rxns  = {'R1'; 'R2'};
modelStub.mets  = {'a[c]'; 'b[c]'};
modelStub.evars = {'E1'};            % extra variables, appended after rxns
modelStub.ctrs  = {'C1'};            % extra constraints, appended after mets
modelStub.genes = {'g1'; 'g2'};      % an ordinary cellstr field (generic branch)
modelStub.rev   = [0; 1];            % a field that is NOT a cellstr

%% basefield 'rxns' WITH evars: the search vector is [rxns; evars]

% R2 is position 2, E1 is position 3 (after the 2 reactions), 'zz' is absent
[positions, found] = getIDPositions(modelStub, {'R2', 'E1', 'zz'}, 'rxns');
assert(isequal(positions, [2 3 0]));            % 0 means "not found"
assert(isequal(found, [true true false]));

%% basefield 'rxns' WITHOUT evars: the search vector is only rxns

modelNoEvars = rmfield(modelStub, 'evars');
[positions, found] = getIDPositions(modelNoEvars, {'R1', 'E1'}, 'rxns');
assert(isequal(positions, [1 0]));              % E1 is only known through evars
assert(isequal(found, [true false]));

%% basefield 'mets' WITH ctrs: the search vector is [mets; ctrs]

% C1 is position 3 (after the 2 metabolites), b[c] is position 2
[positions, found] = getIDPositions(modelStub, {'C1', 'b[c]'}, 'mets');
assert(isequal(positions, [3 2]));
assert(isequal(found, [true true]));

%% basefield 'mets' WITHOUT ctrs: the search vector is only mets

modelNoCtrs = rmfield(modelStub, 'ctrs');
[positions, found] = getIDPositions(modelNoCtrs, {'a[c]', 'C1'}, 'mets');
assert(isequal(positions, [1 0]));
assert(isequal(found, [true false]));

%% any other basefield that is a cell array of strings

[positions, found] = getIDPositions(modelStub, {'g2', 'g1', 'g3'}, 'genes');
assert(isequal(positions, [2 1 0]));
assert(isequal(found, [true true false]));

%% duplicate IDs

% the same ID asked for twice is found twice at the same position
[positions, found] = getIDPositions(modelStub, {'R1', 'R1'}, 'rxns');
assert(isequal(positions, [1 1]));
assert(all(found));

% an ID that occurs twice in the model is reported at its first (lowest) position
modelDuplicate.rxns = {'R1'; 'R1'; 'R3'};
positions = getIDPositions(modelDuplicate, {'R1', 'R3'}, 'rxns');
assert(isequal(positions, [1 3]));

%% invalid basefield: not a cellstr field, or not a field at all -> error

% the error message (including the double space) is the one the function raises
errorMessage = 'Basefield has to be a  field representing a cell array of strings in the model';
% field exists but is numeric
assert(verifyCobraFunctionError('getIDPositions', 'inputs', {modelStub, {'R1'}, 'rev'}, 'testMessage', errorMessage));
% field does not exist
assert(verifyCobraFunctionError('getIDPositions', 'inputs', {modelStub, {'R1'}, 'noSuchField'}, 'testMessage', errorMessage));

% change the directory
cd(currentDir)
