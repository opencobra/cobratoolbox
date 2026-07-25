function dk = lin_sym_solver_mldivide(Hk, grad)
% Solves the linear system :math:`Hkdk = -grad`.
%
% USAGE:
%
%   dk = lin_sym_solver_mldivide(Hk, grad)
%
% INPUTS:
%    Hk:      the (Gauss-Newton) Hessian approximation matrix
%    grad:    gradient of the merit function at `xk`
%
% OUTPUT:
%    dk:      the solution of the linear system

dk = -(Hk\grad);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% End of lin_sym_solver_mldivide.m %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
