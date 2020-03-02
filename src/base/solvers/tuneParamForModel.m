function optimParam = tuneParamForModel(model,varargin)
% Optimizes cplex parameters to make model resolution faster.
% Particularly interetsing for large-scale MILP models and repeated runs of
% optimisation.
% While, it won't optimize memory space nor model constraints for numerical
% infeasibilities, tuneParam will provide the optimal set of solver
% parameters for feasbile models. It requires IBM ILOG cplex (for now).
%
% USAGE:
%
%    optimalParameters = tuneParam(model,contFunctName,1000,1000,0);
%
% INPUT:
%         model:         A COBRA model struct.
%         contFunctName: Parameters structure containing the name and value.
%                        A set of routine parameters will be added by the solver
%                        but won't be reported.
%         timelimit:     default is 10000 second
%         nrepeat:       number of row/column permutation of the original
%                        problem, reports robust results.
%                        sets the CPX_PARAM_TUNINGREPEAT parameter
%                        High values of nrepeat would require consequent
%                        memory and swap.
%         printLevel:    0/1/2/3
%
% OUTPUT:
%         optimParam: structure of optimal parameter values directly usable as
%                     contFunctName argument in solveCobraLP function
%
% NOTE:
%       This is just a wrapper function that calls the tuneParam function
%       using a Cobra model structure converted to a LP problem.
%
% .. Author: Thomas Pfau Dec 2017

optimParam = tuneParam(buildLPproblemFromModel(model),varargin{:});