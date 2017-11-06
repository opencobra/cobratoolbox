function [func, grad, Hess] = FuncGradHessSub(x, y, F, R, kin, rho)
% `SubGradHess` provides the function value, the gradient, and the Hessian
% of the subproblem of DCA and BDCA to be used in `fminunc`.
%
% USAGE:
%
%    [func, grad, Hess] = FuncGradHessSub(x, y, F, R, kin, rho)
%
% INPUTS:
%    x,y:     points
%    F:       Forward stoichiometric matrix
%    kin:     kinetics parameter in :math:`R^{2n}`
%    rho:     strongly comvex modulus
%
%
% OUTPUTS:
%    f:       function value
%    grad:    gradient
%    H:       Hessian

m            = size(F,1);
FR           = [F,R];
RF           = [R,F];
FR_plus_RF   = FR+RF;
exp_x        = exp(kin+FR'*x);
exp_y        = exp(kin+FR'*y);
ux           = FR*exp_x;
wx           = RF*exp_x;
uy_plus_wy   = FR_plus_RF*exp_y;
FRdiag_x     = FR*diag(exp_x);
dux          = FRdiag_x*FR';
dwx          = FRdiag_x*RF';
FRdiag_y     = FR*diag(exp_y);
duy_plus_dwy = FRdiag_y*FR_plus_RF';
gx           = 2*(norm(ux)^2+norm(wx)^2)+rho/2*norm(x)^2;
dgx          = 4*(dux*ux+dwx*wx)+rho*x;
dhy          = 2*duy_plus_dwy*uy_plus_wy+rho*y;

func = gx-dhy'*x;
grad = dgx-dhy;
H    = dux*dux.'+dwx*dwx.';
for j = 1:m
    H = H+ux(j)*FR*diag(exp_x.*FR(j,:)')*FR'+ ...
                                     wx(j)*FR*diag(exp_x.*RF(j,:)')*FR';
end
Hess = 4*H+rho*eye(m);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% End of FuncGradHessSub.m %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
