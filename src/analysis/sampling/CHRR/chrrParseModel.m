function [P,model] = chrrParseModel(model)
% Parse a COBRA model into the right format for the CHRR sampler
%
% USAGE:
%
%      [P,model] = chrrParseModel(model);
%
% We are trying to sample uniformly at random from the points v that satisfy:
%
% .. math::
%                     Sv = b\\
%             ~~ l_b \leq v \leq u_b
%
% INPUTS:
%    model:    COBRA model structure with fields:
%
%               * .S - The `m x n` stoichiometric matrix
%               * .lb - `n x 1` lower bounds on fluxes
%               * .ub - `n x 1` upper bounds on fluxes
%
% OPTIONAL INPUTS:
%               * .C - 'k x n' matrix of additional inequality constraints
%               * .d - 'k x 1' rhs of the above constraints
%               * .dsense - 'k x 1' the sense of the above constraints ('L' or 'G')
%
% OUTPUTS:
%    P:        A structure with fields:
%
%               * .A_eq - Equality constraint matrix (`model.S`)
%               * .b_eq - Right hand side of equality constraints (`model.b`)
%               * .A - Inequality constraint matrix (`[I_n 0; 0 -I_n]`)
%               * .b - Right hand side of inequality constraints (`[lb; -ub]`)
%
% .. Authors:
%       - Ben Cousins and Hulda Haraldsdóttir, 10/2016
%       - Ben Cousins, 12/2017, Moved objective function handling to preprocess function
%       - Ben Cousins, 05/2019, Added support for C,d inequalities.

dim = length(model.lb);

P.A = [eye(dim); -eye(dim)];
P.b = [model.ub; -model.lb]; 

if isfield(model,'C') && isfield(model,'d')
   for i=1:size(model.C,1)
      if model.dsense(i)=='G'
          % convert constraint to <=
          model.C(i,:) = model.C(i,:)*-1;
          model.d(i) = model.d(i)*-1;
      elseif model.dsense{i}=='E'
          error('Equality constraints not supported in C,d fields.');
      end
   end
   P.A = [P.A; model.C];
   P.b = [P.b; model.d];
end

P.A_eq = model.S;
P.b_eq = model.b;

end