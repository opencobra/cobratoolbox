% function x = testMOMA()
%testMOMA tests the functions of MOMA and linearMOMA based on the paper
%   "Analysis of optimality in natural and perturbed metabolic networks"
%   (http://www.pnas.org/content/99/23/15112.full)
%   MOMA employs quadratic programming to identify a point in flux space,
%   which is closest to the wild-type point, compatibly with the gene
%   deletion constraint. 
%   In other words, through MOMA, we test the hypothesis that the real
%   knockout steady state is better approximated by the flux minimal 
%   response to the perturbation than by the optimal one
%   Adapted by MBG - 02/10/2017


global path_TOMLAB

% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end - (length('initCobraToolbox.m') + 1));
initTest([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'testMOMA']);

%load model
load('ecoli_core_model', 'model');

%test solver packages
display('MOMA requires a QP solver to be installed.  QPNG does not work.');
solverPkgs = {'tomlab_cplex'};%,'ILOGcomplex'};

for k = 1:length(solverPkgs)
    fprintf(' -- Running testfindBlockedReaction using the solver interface: %s ... ', solverPkgs{k});
    % add the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        addpath(genpath(path_TOMLAB));
    elseif strcmp(solverPkgs{k}, 'gurobi6')
        addpath(genpath(path_GUROBI));
    end
    
    solverQPOK = changeCobraSolver(solverPkgs{k},'QP');
    solverLQPOK = changeCobraSolver(solverPkgs{k},'LP');
    if solverQPOK
        QPtol = 0.02;
        LPtol = 0.0001;
        
        [modelOut,hasEffect,constrRxnNames,deletedGenes] = deleteModelGenes(model,'b3956'); %gene for reaction PPC
        sol = MOMA(model, modelOut);

        assert(abs(0.8463 - sol.f) < QPtol)

        sol = linearMOMA(model, modelOut);

        assert(abs(0.8608 - sol.f) < LPtol)
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
%return to original director
cd(CBTDIR)
% end