% The COBRAToolbox: testSubspaces.m
%
% Purpose:
%     - test the subspaceProjector function return the matrix for projection
%       onto the subspace of the internal reaction stoichiometric matrix
%       specified by `subspace`
%
% Authors:
%     - Original test file: Ronan Fleming
%     - CI integration: Laurent Heirendt January 2017

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSubspaces'));
cd(fileDir);

% define the tolerance
tol = 1e-6;

% load the model
load([CBTDIR, filesep, 'test' filesep 'models' filesep 'ecoli_core_model.mat'], 'model');

% find the internal vs exchange/demand/sink reactions.
model = findSExRxnInd(model);

% internal reactions from stoichiometric matrix
SInt = model.S(:, model.SIntRxnBool);

[m, n] = size(SInt);

sub_space = {'R', 'N', 'C', 'L'};

% calculate the subspace projectors
for printLevel = 0:1
    for i = 1:length(sub_space)
        [PR, PN, PC, PL] = subspaceProjector(model, printLevel, sub_space{i});
    end
end

sub_space = 'all';

[PR, PN, PC, PL] = subspaceProjector(model, printLevel, sub_space);

u = rand(m, 1);
v = rand(n, 1);

% Let M denote the Moore-Penrose pseudoinverse of the internal reaction
% stoichiometric matrix and the subscripts are the following
% _R row space
% _N nullspace
% _C column space
% _L left nullspace
%
% Let v = v_R + v_N
%
% v_R = M * S * v = PR * v
v_R = PR * v;

% v_N = (I - M * S) * v = PN * v
v_N = PN * v;

% Let u = u_C + u_L
%
% u_C = S * M * u = PC * u
u_C = PC * u;

% u_L = (I - S * M) * u = PL *u
u_L = PL * u;

% perform the test
assert(norm(v - v_R - v_N) < tol)
assert(norm(u - u_C - u_L) < tol)

% change the directory
cd(currentDir)
