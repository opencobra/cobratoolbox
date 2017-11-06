function dk = lin_sym_solver_mldivide(Hk, grad)
% Solves the linear system :math:`Hkdk = -grad`.
%
% USAGE:
%
%   dk = lin_sym_solver_mldivide(Hk, grad)
%
% INPUTS:
%    ghxk:    gradient of `h` at `xk`
%    grad:    gradient of the merit function at `xk`
%    muk:     the parameter `muk`
%
% OUTPUT:
%    dk:      the solution of the linear system

dk = -(Hk\grad);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% End of lin_sym_solver_mldivide.m %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
