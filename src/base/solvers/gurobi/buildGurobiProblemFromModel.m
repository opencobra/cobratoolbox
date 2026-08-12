function gurobiModel = buildGurobiProblemFromModel(model, verify)
% Converts a COBRA genome-scale model structure directly into a struct
% ready to be passed to the native Gurobi MATLAB interface, i.e.
% `gurobi(gurobiModel, params)`.
%
% The native Gurobi struct uses different field names/conventions than
% the COBRA optProblem struct (.c -> .obj, .b -> .rhs, .csense -> .sense,
% .osense -> .modelsense), so calling gurobi() on a raw COBRA
% optProblem/LPproblem struct silently defaults the missing fields
% (zero objective, zero rhs, '<' sense for every row) and returns
% INFEASIBLE. This function performs the same translation used
% internally by solveCobraLP.m's 'gurobi' case.
%
% USAGE:
%    gurobiModel = buildGurobiProblemFromModel(model, verify)
%
% INPUT:
%    model:      A COBRA model structure with at least .S, .c, .lb, .ub
%                (same input accepted by buildOptProblemFromModel)
%
% OPTIONAL INPUT:
%    verify:     Verify the model structure before building (default: false)
%
% OUTPUT:
%    gurobiModel: A struct with native Gurobi fields, ready to pass to gurobi():
%                 * `.A`: constraint matrix
%                 * `.obj`: objective coefficient vector
%                 * `.rhs`: right-hand side vector
%                 * `.sense`: constraint sense per row ('=', '<', '>')
%                 * `.lb`, `.ub`: variable bounds
%                 * `.modelsense`: 'max' or 'min'
%
% EXAMPLE:
%    gurobiModel = buildGurobiProblemFromModel(model);
%    params.OutputFlag = 1;
%    result = gurobi(gurobiModel, params);

if ~exist('verify', 'var')
    verify = false;
end

optProblem = buildOptProblemFromModel(model, verify);

gurobiModel.A = optProblem.A;
gurobiModel.obj = full(double(optProblem.c));
gurobiModel.rhs = full(optProblem.b);
gurobiModel.lb = full(optProblem.lb);
gurobiModel.ub = full(optProblem.ub);

gurobiModel.sense(1:length(optProblem.b), 1) = '=';
gurobiModel.sense(optProblem.csense == 'L') = '<';
gurobiModel.sense(optProblem.csense == 'G') = '>';

if optProblem.osense == -1
    gurobiModel.modelsense = 'max';
else
    gurobiModel.modelsense = 'min';
end

end
