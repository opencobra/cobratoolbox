function interrogateWBmodelsQP(directory, resPath, solver, param)
% Performs FBA on all whole-body models in a folder with the quadratic flux minimisation
% algorithm (QP) and saves the QP FBA results in a separate results folder.
%
% USAGE:
%
%    interrogateWBmodelsQP(directory, resPath, solver, param)
%
% INPUTS:
%    directory:    [char] path to the folder with whole-body models
%    resPath:      [char] path to the location where FBA results are saved
%    solver:       [char] solver name, e.g. gurobi
%
% OPTIONAL INPUTS:
%    param:        [struct] FBA parameters. See optimizeWBModel.m or optimizeCbModel.m
%                  for more information. All FBA parameters are set to their defaults
%                  except for the following:
%
%                    * .minNorm - norm used for flux minimisation (default 1e-6)
%                    * .secondsTimeLimit - solver time limit in seconds (default 500)
%
% .. Author: - Tim Hensen, January 2026
%            - Added parameter settings to improve the WBM feasibility on
%            Gurobi. Tim Hensen, October 2026


if nargin<4
    % Set FBA parameters
    param = struct;
end

if ~isfield(param, 'secondsTimeLimit')
    param.secondsTimeLimit = 500;
end

if ~isfield(param, 'minNorm')
    % Add the flag for QP.
    param.minNorm        = 1e-6;
end

% Feasibility problems have been observed with WBMs on gurobi 13.0. The
% following parameter settings have been found to resolve these issues.
% These settings should, in general, improve the QP solutions, but be
% mindful when running the QPs with these settings. - TiH
if strcmp(solver,'gurobi')
    if ~isfield(param, 'ScaleFlag')
        % Gurobi default = 0
        % The bounds of WBMs span many orders of magnitude (from 1e-9 to
        % 1e6), which make the WBMs hard to solve. This parameter rescales
        % rows and columns of S*v=0 so coefficients are of similar
        % magnitude. This improves the conditioning of the barrier method
        % used by Gurobi QP because it reduces the magnitude of scale
        % differences between the stoichiometric coefficients and bounds.
        param.ScaleFlag      = 1;
    end
    if ~isfield(param, 'NumericFocus')
        % Gurobi default = 0, maximum = 3
        % This parameter controls how much effort Gurobi takes to manage
        % numerical issues and achieve an optimal solution. Setting this
        % parameter to 3 will increase compute time, but may make otherwise
        % infeasible problems feasible.
        param.NumericFocus   = 3;
    end
    if ~isfield(param, 'BarConvTol')
        % Gurobi default = 1e-8, maximum = 1
        % Barrier convergence tolerance. To find min ½‖v‖²
        % in the constrained solution space, Gurobi iteratively checks the
        % difference between the current solution and an optimal solution.
        % More precisely, it considers the relative difference between the
        % primal and dual objective values
        % (https://docs.gurobi.com/projects/optimizer/en/current/reference/parameters.html,
        % https://en.wikipedia.org/wiki/Duality_gap). When the gap is zero,
        % the solution is optimal. Gurobi uses a default threshold for zero
        % (barrier convergence tolerance) of 1e-8. However, as WBMs are
        % numerically difficult to solve due to the large differences in S
        % and bound coefficients, Gurobi can sometimes stall before this
        % threshold is reached, resulting in FBA.stat = -1. Setting this
        % parameter to a higher threshold (such as 1e-7), prevents stalling
        % by sacrificing some precision.
        % 
        % An experiment with parameter settings running on Harvey 1.04c gave:
        % ┌────────────────┬───────────────┬────────┬────────────┬─────────┬──────────┬
        % │   BarConvTol   │ Gurobi status │  Time  │ Iterations │ relDiff │ feasable │ 
        % ├────────────────┼───────────────┼────────┼────────────┼─────────┼──────────┼
        % │ 1e-8 (default) │ SUBOPTIMAL    │ 42.0 s │ 119        │ 7.9e-6  │ yes      │
        % ├────────────────┼───────────────┼────────┼────────────┼─────────┼──────────┼
        % │ 1e-7           │ OPTIMAL       │ 41.9 s │ 126        │ 9.8e-6  │ yes      │
        % ├────────────────┼───────────────┼────────┼────────────┼─────────┼──────────┼
        % │ 1e-6           │ OPTIMAL       │ 42.4 s │ 126        │ 9.8e-6  │ yes      │
        % ├────────────────┼───────────────┼────────┼────────────┼─────────┼──────────┼
        % │ 1e-5           │ OPTIMAL       │ 32.4 s │ 71         │ 5.9e-5  │ yes      │
        % ├────────────────┼───────────────┼────────┼────────────┼─────────┼──────────┼
        % │ 1e-4           │ OPTIMAL       │ 30.9 s │ 65         │ 4.5e-4  │ yes      │
        % └────────────────┴───────────────┴────────┴────────────┴─────────┴──────────┴
        % relDiff = ‖v − v_opt‖₂ / ‖v_opt‖₂, where v_opt is the theoretical
        % optimal v, as given by the dual solution. 
        % (https://en.wikipedia.org/wiki/Duality_gap) A smaller relDiff means
        % that the solution is closer to its theoretical optimum. 
        % I am setting 1e-7 here as it provides the best solution for this
        % problem. 
        param.BarConvTol = 1e-7;
    end
    % NOTE: This parameter might not be necessary.
    if ~isfield(param, 'BarHomogeneous')
        % Gurobi default = -1, maximum = 1
        % (https://docs.gurobi.com/projects/optimizer/en/current/reference/parameters.html)
        % This setting forces gurobi to use the homogeneous barrier
        % algorithm instead of the standard barrier algorithm. Setting this
        % parameter can slightly improve the conditioning of the quadratic
        % problem, which has been found to speed up computation by 10-15%
        % if param.ScaleFlag = 1, param.BarConvTol = 1e-5, and
        % param.NumericFocus = 3. The same speedup may not be found with
        % different parameter combinations.
        param.BarHomogeneous = 1;
    end
end

% Set QP solver
changeCobraSolver(solver,'QP',-1)

% Get model names
modelNames = what(directory).mat;
modelPaths = fullfile(directory,modelNames);

% Create output folder if not present already
if ~isfolder(resPath)
    mkdir(resPath)
end

% Remove already analysed models (results are saved as qpFBA_<model name>)
prevSol = what(resPath).mat;
analysed = ismember(append('qpFBA_', modelNames), prevSol);
modelNames = modelNames(~analysed);
modelPaths = modelPaths(~analysed);

for i=1:numel(modelPaths)

    % load model
    disp(append('load and interrogate model : ', modelNames{i}))
    model = loadPSCMfile(modelPaths{i});

    % Set objective at Whole_body_objective_rxn
    model = changeObjective(model, 'Whole_body_objective_rxn');

    % Fix objective flux bounds at one
    model = changeRxnBounds(model,'Whole_body_objective_rxn',1,'b');

    % Minimise the Euclidean norm of all reactions for a fixed objective
    model.osenseStr = 'min';

    tic
    % Perform FBA
    FBA = optimizeWBModel(model, param);
    toc

    % Append metabolites and reactions
    FBA.rxns = model.rxns;
    FBA.mets = model.mets;

    % Save results
    filePath=fullfile(resPath, append('qpFBA_',modelNames{i}));
    solution = FBA;
    save(filePath,'-struct', 'solution')
end
end