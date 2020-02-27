function solvers = getAvailableSolversByType()
% Get the available solvers for the different solver types on the system.
%
% USAGE:
%    solvers = getAvailableSolversByType()
%
% OUTPUT:
%    solvers:   struct containing one field per Problem type listing all
%               solvers installed on the system for that problem type.
%               Also contains an ALL field indicating all available solvers
%

global OPT_PROB_TYPES
global SOLVERS

if isempty(SOLVERS) || isempty(OPT_PROB_TYPES)
    ENV_VARS.printLevel = false;
    initCobraToolbox(false); %Don't update the toolbox automatically;
    ENV_VARS.printLevel = true;
end

solverNames = fieldnames(SOLVERS);
solvers = struct();
for i = 1:numel(OPT_PROB_TYPES)
    solvers.(OPT_PROB_TYPES{i}) = {};
end

allSolvers = {};

for i = 1:numel(solverNames)
    if SOLVERS.(solverNames{i}).working
        allSolvers{end+1} = solverNames{i};
        availableTypes = SOLVERS.(solverNames{i}).type;
        for j = 1:numel(availableTypes)
            solvers.(availableTypes{j}) = [solvers.(availableTypes{j}), solverNames{i}];
        end
    end
end

solvers.ALL = allSolvers;