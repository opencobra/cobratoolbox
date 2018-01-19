function solvers = getAvailableSolversByType()
% Get the available Solvers for the different Types on the system.
%
% USAGE:
%    solvers = getAvailableSolversByType()
%
% OUTPUT:
%    solvers:   struct containing one field per Problem type listing all
%               solvers installed on the system for that problem type.
%

global OPT_PROB_TYPES;
global SOLVERS;

if isempty(SOLVERS) || isempty(OPT_PROB_TYPES)
    ENV_VARS.printLevel = false;
    initCobraToolbox;
    ENV_VARS.printLevel = true;
end

solverNames = fieldnames(SOLVERS);
solvers = struct();
for i = 1:numel(OPT_PROB_TYPES)
    solvers.(OPT_PROB_TYPES{i}) = {};
end
    
for i = 1:numel(solverNames)
   if SOLVERS.(solverNames{i}).working
       availableTypes = SOLVERS.(solverNames{i}).type;
       for j = 1:numel(availableTypes)
           solvers.(availableTypes{j}) = union(solvers.(availableTypes{j}), solverNames{i});
       end
   end
end