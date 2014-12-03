% Perform the GERALD method on the training data which comprises
% S - the stoichiometric matrix of measured reactions
% G - the group incidence matrix
% b - the observation vector (standard Gibbs energy of reactions)
% w - the weight vector for each reaction in S
function [G_gerald, cov_G, params] = componentContribution(S, G, b, w)

[m, n] = size(S);
assert (size(G, 1) == m);
assert (size(b, 1) == n);
assert (size(b, 2) == 1);
assert (length(w) == size(S, 2));

% Apply weighing
W = diag(w);
GS = G' * S;

% Linear regression for the reactant layer (aka RC)
[inv_S, r_rc, P_R_rc, P_N_rc] = invertProjection(S * W);

% Linear regression for the group layer (aka GC)
[inv_GS, r_gc, P_R_gc, P_N_gc] = invertProjection(GS * W);

% Calculate the contributions in the stoichiometric space
G_rc = inv_S' * W * b;
G_gc = G * inv_GS' * W * b;
G_gerald = P_R_rc * G_rc + P_N_rc * G_gc;

% Calculate the residual error (unweighted squared error divided by N - rank)
e_rc = (S' * G_rc - b);
MSE_rc = (e_rc' * W * e_rc) / (n - r_rc);
% MSE_rc = (e_rc' * e_rc) / (n - r_rc);

e_gc = (S' * G_gc - b);
MSE_gc = (e_gc' * W * e_gc) / (n - r_gc);
% MSE_gc = (e_gc' * e_gc) / (n - r_gc);

MSE_inf = 1e10;

% Calculate the uncertainty covariance matrices
% [inv_S_orig, ~, ~, ~] = invertProjection(S);
% [inv_GS_orig, ~, ~, ~] = invertProjection(GS);
[inv_SWS, ~, ~, ~] = invertProjection(S*W*S');
[inv_GSWGS, ~, ~, ~] = invertProjection(GS*W*GS');


%V_rc  = P_R_rc * (inv_S_orig' * W * inv_S_orig) * P_R_rc;
%V_gc  = P_N_rc * G * (inv_GS_orig' * W * inv_GS_orig) * G' * P_N_rc;
V_rc = P_R_rc * inv_SWS * P_R_rc;
V_gc  = P_N_rc * G * inv_GSWGS * G' * P_N_rc;
% V_rc  = P_R_rc * (inv_S_orig' * inv_S_orig) * P_R_rc;
% V_gc  = P_N_rc * G * (inv_GS_orig' * inv_GS_orig) * G' * P_N_rc;
V_inf = P_N_rc * G * P_N_gc * G' * P_N_rc;

% Put all the calculated data in 'params' for the sake of debugging
params.contributions = {G_rc, G_gc};
params.covariances = {V_rc, V_gc, V_inf};
params.MSEs = {MSE_rc, MSE_gc, MSE_inf};
params.projections = {              P_R_rc, ...
                      P_R_gc * G' * P_N_rc, ...
                      P_N_gc * G' * P_N_rc};

% Calculate the total of the contributions and covariances
cov_G = V_rc  * MSE_rc + ...
        V_gc  * MSE_gc + ...
        V_inf * MSE_inf;

