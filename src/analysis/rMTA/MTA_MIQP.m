
function [v_res, solution] = MTA_MIQP (CplexModel, KOrxn, numWorkers, timelimit, printLevel)
% Returns the CPLEX solution of a particular MTA problem and an specific
% model
% 
% USAGE:
%
%    [v_res, success, unsuccess] = MTA_MIQP (Model, KOrxn, numWorkers, printLevel)
%
% INPUT:
%    CplexModel:       Cplex Model struct
%    KOrxn:            perturbation in the model (reactions)
%    numWorkers:       number of threads used by Cplex.
%    printLevel:       1 if the process is wanted to be shown on the
%                      screen, 0 otherwise. Default: 1.
%
% OUTPUTS:
%    Vout:             Solution flux of MIQP formulation for each case
%    solution:         Cplex solution struct
%
% .. Authors:
%       - Luis V. Valcarcel, 03/06/2015, University of Navarra, CIMA & TECNUN School of Engineering.
% .. Revisions:
%       - Luis V. Valcarcel, 26/10/2018, University of Navarra, CIMA & TECNUN School of Engineering.

%Indexation of variables
v = CplexModel.idx_variables.v;
y_plus_F = CplexModel.idx_variables.y_plus_F;
y_minus_F = CplexModel.idx_variables.y_minus_F;
y_plus_B = CplexModel.idx_variables.y_plus_B;
y_minus_B = CplexModel.idx_variables.y_minus_B;
CplexModel = rmfield(CplexModel,'idx_variables');

% Generate CPLEX model
cplex = Cplex('MIQP');
cplex.Model = CplexModel;
% include the knock-out reactions
cplex.Model.lb(KOrxn) = 0;
cplex.Model.ub(KOrxn) = 0;

% Cplex Parameter
if numWorkers>0
    cplex.Param.threads.Cur = numWorkers;
end
if printLevel <=1
    cplex.Param.output.clonelog.Cur = 0;
    cplex.DisplayFunc = [];
elseif printLevel <=2
    cplex.Param.output.clonelog.Cur = 0;
end
if timelimit < 1e75
    cplex.Param.timelimit.Cur = timelimit;
end
%reduce the tolerance
cplex.Param.mip.tolerances.mipgap.Cur = 1e-5;
% cplex.Param.mip.tolerances.absmipgap.Cur = 1e-8;
% cplex.Param.threads.Cur = 16;

% SOLVE the CPLEX problem if not singular
try
    cplex.solve();
catch
    v_res = zeros(length(v),1);
    return
end

if cplex.Solution.status ~= 103
    v_res = cplex.Solution.x(v);
    solution = cplex.Solution;
else
    v_res = zeros(length(v),1);
    solution = nan;
end

% clear the cplex object
delete(cplex)
clear cplex

end
