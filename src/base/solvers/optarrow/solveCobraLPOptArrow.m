function result = solveCobraLPOptArrow(LPproblem, problemTypeParams, solverParams)
% solveCobraLPOptArrow  COBRA dispatch entry point for LP via OptArrow.
%
% This is a thin wrapper required by COBRA's solver dispatch naming
% convention. All logic lives in solveCobraOptArrow.
%
% .. Author: - Farid Zare 07/04/2026

if nargin < 2, problemTypeParams = struct(); end
if nargin < 3, solverParams = struct(); end
result = solveCobraOptArrow('LP', LPproblem, problemTypeParams, solverParams);
end
