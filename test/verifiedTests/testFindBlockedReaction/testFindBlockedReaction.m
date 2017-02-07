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

% define global paths
global path_TOMLAB
global path_GUROBI

% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end - (length('initCobraToolbox.m') + 1));

initTest([CBTDIR '/test/verifiedTests/testFindBlockedReaction'])

load ecoli_core_model.mat;

ecoli_blckd_rxn = {'EX_fru(e)', 'EX_fum(e)', 'EX_gln_L(e)', 'EX_mal_L(e)', ...
                   'FRUpts2', 'FUMt2_2', 'GLNabc', 'MALt2_2'};

% list of solver packages
solverPkgs = {'tomlab_cplex', 'gurobi', 'glpk'};

poolobj = gcp('nocreate'); % If no pool, do not create new one.
if isempty(poolobj)
    % launch 2 workers
    parpool(2);
end

for k = 1:length(solverPkgs)

    fprintf(' -- Running testfindBlockedReaction using the solver interface: %s ... ', solverPkgs{k});

    % add the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        addpath(genpath(path_TOMLAB));
    elseif strcmp(solverPkgs{k}, 'gurobi6')
        addpath(genpath(path_GUROBI));
    end

    solverLPOK = changeCobraSolver(solverPkgs{k});

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

    % remove the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        rmpath(genpath(path_TOMLAB));
    elseif strcmp(solverPkgs{k}, 'gurobi6')
        rmpath(genpath(path_GUROBI));
    end

    % output a success message
    fprintf('Done.\n');
end
