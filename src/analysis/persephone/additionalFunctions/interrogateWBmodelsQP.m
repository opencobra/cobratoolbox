function interrogateWBmodelsQP(directory,resPath, solver, param)
% Performs FBA on a all whole-body models in a folder with the quadratic flux minimisation
% algorithm (QP) and saves the QP FBA results in a separate results folder.
%
% USAGE:
%               interrogateWBmodelsQP(directory,resPath,solver)
% 
%
% INPUTS
% directory     [char] Path to folder with WBMs
% resPath       [char] Path to location of FBA results
% solver        [char] Solver name, e.g., gurobi.
%
% OPTIONAL INPUTS:
% param         [struct] FBA parameters. See OptimizeWBModel.m or
%               OptimizeCbModel.m for more information. All FBA parameters are set to
%               their defaults except for param.minNorm (1e-6) and secondsTimeLimit (500
%               seconds instead of 100 seconds)
%
% AUTHOR:
% - Tim Hensen, January 2026.


if nargin<4
    % Set FBA parameters
    param.minNorm = 1e-6;
    param.secondsTimeLimit = 500;
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

% Remove already analysed models
prevSol = what(resPath);
if ~isempty(prevSol)
    prevSol = prevSol.mat;
    [~,idx] = setdiff(modelNames,prevSol);
    modelPaths = modelPaths(idx);
end

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