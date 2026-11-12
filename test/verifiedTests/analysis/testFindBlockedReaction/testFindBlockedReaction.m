% The COBRAToolbox: testfindBlockedReaction.m
%
% Purpose:
%     - testfindBlockedReaction tests the findBlockedReaction
%     function and its different methods
%
% Function under test:
%     src/analysis/exploration/findBlockedReaction.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation; ecoli_core_model loaded through getDistributedModel and a toy model,
%     LP solver required, and gurobi as QP solver for the section on 'L2'. The method 'L2' calls solveCobraLP with the option minNorm, which
%     only cplex_direct accepts. That solver is not available here, so a stand-in solveCobraLP in a
%     temporary folder solves the same minimum norm problem with solveCobraQP and passes every
%     other call on to the real solveCobraLP. The real interface is checked as well: with another
%     solver the method 'L2' stops with the message of solveCobraLP.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Author:
%     - Original file: Marouen BEN GUEBILA - 31/01/2017
%     - CI integration: Laurent Heirendt February 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%
% Note: ibm_cplex is not (yet) compatible with R2016b

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testfindBlockedReaction'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available. Only solvers that work here are
% tried: changeCobraSolver on a TOMLAB without licence leaves TOMLAB's gurobi.m first on the path
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'tomlab_cplex', 'gurobi', 'glpk'});

model = getDistributedModel('ecoli_core_model.mat');

ecoli_blckd_rxn = {'EX_fru(e)', 'EX_fum(e)', 'EX_gln_L(e)', 'EX_mal_L(e)', ...
                   'FRUpts2', 'FUMt2_2', 'GLNabc', 'MALt2_2'};

% list of solver packages
solverPkgs = solvers.LP;

for k = 1:length(solverPkgs)

    fprintf(' -- Running testfindBlockedReaction using the solver interface: %s ... ', solverPkgs{k});

    solverLPOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverLPOK

        % using FVA
        blockedReactionsFVA = findBlockedReaction(model);

        % asert individual reaction names
        for i = 1:length(ecoli_blckd_rxn)
            assert(strcmp(ecoli_blckd_rxn{i}, blockedReactionsFVA{i}));
        end

        % the method 'L2' is refused by the real solveCobraLP for every solver but cplex_direct
        assert(verifyCobraFunctionError('findBlockedReaction', 'inputs', {model, 'L2'}, ...
            'testMessage', ['Solver is ' solverPkgs{k} ' but minNorm only works for LP solver ' ...
            '''cplex_direct'' from this interface, use optimizeCbModel for other solvers.']));
    end

    % output a success message
    fprintf('Done.\n');
end

%% 'L2' method, with a stand-in for the minimum norm solve of cplex_direct
if changeCobraSolver('gurobi', 'LP', 0) && changeCobraSolver('gurobi', 'QP', 0)

    % the stand-in lives in a temporary folder, which the cleanup object removes again
    sandboxDir = tempname;
    mkdir(sandboxDir);
    setappdata(0, 'realSolveCobraLP', @solveCobraLP);
    setappdata(0, 'failMinNormSolve', false);
    fid = fopen(fullfile(sandboxDir, 'solveCobraLP.m'), 'w');
    fprintf(fid, '%s\n', ...
        'function solution = solveCobraLP(LPproblem, varargin)', ...
        '% stand-in written by testFindBlockedReaction', ...
        'if numel(varargin) == 2 && strcmp(varargin{1}, ''minNorm'')', ...
        '    if getappdata(0, ''failMinNormSolve'')', ...
        '        solution = struct(''stat'', 0);', ...
        '        return', ...
        '    end', ...
        '    n = size(LPproblem.S, 2);', ...
        '    QPproblem = struct(''A'', LPproblem.S, ''b'', LPproblem.b, ''c'', zeros(n, 1), ...', ...
        '        ''lb'', LPproblem.lb, ''ub'', LPproblem.ub, ''F'', speye(n), ''osense'', 1, ...', ...
        '        ''csense'', LPproblem.csense(:));', ...
        '    solution = solveCobraQP(QPproblem);', ...
        '    solution.full(abs(solution.full) < 1e-8) = 0; % accuracy of the QP solver', ...
        'else', ...
        '    realSolver = getappdata(0, ''realSolveCobraLP'');', ...
        '    solution = realSolver(LPproblem, varargin{:});', ...
        'end', ...
        'end');
    fclose(fid);
    addpath(sandboxDir);
    removeSandbox = onCleanup(@() removeStandIn(sandboxDir));
    rehash path
    % the sandbox is active: this call reaches the stand-in and not the real interface
    assert(startsWith(which('solveCobraLP'), sandboxDir));

    % using L2 preprocessing + targeted FVA
    blockedReactions = findBlockedReaction(model, 'L2');

    % L2+FVA must return the exact same set as full FVA
    assert(length(blockedReactions) == length(ecoli_blckd_rxn), ...
        'L2: expected %d blocked reactions, got %d', ...
        length(ecoli_blckd_rxn), length(blockedReactions));

    assert(isempty(setdiff(ecoli_blckd_rxn, blockedReactions)) && ...
           isempty(setdiff(blockedReactions, ecoli_blckd_rxn)), ...
        'L2: blocked reaction sets do not match');

    % when the minimum norm solve fails, a warning is given and full FVA is used
    setappdata(0, 'failMinNormSolve', true);
    lastwarn('');
    blockedReactions = findBlockedReaction(model, 'L2');
    assert(contains(lastwarn, 'L2 solve failed (status 0), falling back to full FVA'));
    assert(isempty(setxor(ecoli_blckd_rxn, blockedReactions)));
    setappdata(0, 'failMinNormSolve', false);

    % a linear pathway forced to carry flux has no blocked reaction and no candidate
    toyModel = struct('S', sparse([1, -1, 0; 0, 1, -1]), 'rxns', {{'R1'; 'R2'; 'R3'}}, ...
        'mets', {{'A'; 'B'}}, 'lb', [1; 1; 1], 'ub', [10; 10; 10], 'c', [0; 0; 1], 'b', [0; 0], ...
        'csense', ['E'; 'E']);
    blockedReactions = findBlockedReaction(toyModel, 'L2');
    assert(isempty(blockedReactions) && iscell(blockedReactions));

    clear removeSandbox
    assert(~strcmp(fileparts(which('solveCobraLP')), sandboxDir));

else
    fprintf('Section on the method L2 skipped: it needs gurobi as LP and QP solver.\n');
end

% change the directory
cd(currentDir)


function removeStandIn(sandboxDir)
    % removes the temporary folder with the stand-in of solveCobraLP and what it depends on
    rmpath(sandboxDir);
    rmappdata(0, 'realSolveCobraLP');
    rmappdata(0, 'failMinNormSolve');
    rmdir(sandboxDir, 's');
    rehash path
end
