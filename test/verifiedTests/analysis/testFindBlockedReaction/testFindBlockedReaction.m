% The COBRAToolbox: testfindBlockedReaction.m
%
% Purpose:
%     - testfindBlockedReaction tests the findBlockedReaction
%     function and its different methods
%
% Author:
%     - Original file: Marouen BEN GUEBILA - 31/01/2017
%     - CI integration: Laurent Heirendt February 2017
%
% Note: ibm_cplex is not (yet) compatible with R2016b

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testfindBlockedReaction'));
cd(fileDir);

load([CBTDIR, filesep, 'test' filesep 'models' filesep 'ecoli_core_model.mat'], 'model');

ecoli_blckd_rxn = {'EX_fru(e)', 'EX_fum(e)', 'EX_gln_L(e)', 'EX_mal_L(e)', ...
                   'FRUpts2', 'FUMt2_2', 'GLNabc', 'MALt2_2'};

% list of solver packages
solverPkgs = {'tomlab_cplex', 'gurobi6', 'glpk'};

% create a parallel pool
poolobj = gcp('nocreate'); % if no pool, do not create new one.
if isempty(poolobj)
    parpool(2); % launch 2 workers
end

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

        if strcmp(solverPkgs{k}, 'tomlab_cplex')
            % using 2-norm min
            blockedReactions = findBlockedReaction(model, 'L2');

            % asert individual reaction names
            for i = 1:length(ecoli_blckd_rxn)
                assert(strcmp(ecoli_blckd_rxn{i}, blockedReactions{i}));
            end
        end
    end

    % output a success message
    fprintf('Done.\n');
end

% change the directory
cd(currentDir)
