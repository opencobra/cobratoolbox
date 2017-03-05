function [dG0_cc, cov_dG0, params] = componentContribution(S, G, b, w)
% Perform the component contribution method on the training data
%
% INPUTS
% S     the stoichiometric matrix of measured reactions
% G 	the group incidence matrix
% b     the observation vector (standard Gibbs energy of reactions)
% w     the weight vector for each reaction in S
%
% OUTPUTS
%


[m, n] = size(S);
%assert Generate an error when a condition is violated.
assert (size(G, 1) == m);
assert (size(b, 1) == n);
assert (size(b, 2) == 1);
assert (length(w) == size(S, 2));

% Apply weighing
W = diag(w);
GS = G' * S;

%[inv_A, r, P_R, P_N] = invertProjection(A, epsilon)
%     inv_A - the pseudoinverse of A
%     r     - the rank of A
%     P_R   - the projection matrix onto the range(A)
%     P_N   - the projection matrix onto the null(A')
% Linear regression for the reactant layer (aka RC)
[inv_S, r_rc, P_R_rc, P_N_rc] = invertProjection(S * W);

% calculate the reactant contribution
dG0_rc = inv_S' * W * b;

% Linear regression for the group layer (aka GC)
[inv_GS, r_gc, P_R_gc, P_N_gc] = invertProjection(GS * W);

% calculate the group contribution
dG0_gc = inv_GS' * W * b;

% Calculate the contributions in the stoichiometric space
dG0_cc = P_R_rc * dG0_rc + P_N_rc * G * dG0_gc;

% Calculate the residual error (unweighted squared error divided by N - rank)
e_rc = (S' * dG0_rc - b); %sign opposite to eq 3 in suText_S1.pdf
MSE_rc = (e_rc' * W * e_rc) / (n - r_rc);

%e_gc = (S' * G_gc - b); - was this in Hulda's code - Ronan
e_gc = (GS' * dG0_gc - b); %this is as in Elad's v2 matlab code on git
MSE_gc = (e_gc' * W * e_gc) / (n - r_gc);

MSE_inf = 1e10;

% Calculate the uncertainty covariance matrices
[inv_SWS, ~, ~, ~] = invertProjection(S*W*S');
[inv_GSWGS, ~, ~, ~] = invertProjection(GS*W*GS');

V_rc = P_R_rc * inv_SWS * P_R_rc;
V_gc  = P_N_rc * G * inv_GSWGS * G' * P_N_rc;
V_inf = P_N_rc * G * P_N_gc * G' * P_N_rc;

% Put all the calculated data in 'params' for the sake of debugging
params.contributions = {dG0_rc, dG0_gc};
params.covariances = {V_rc, V_gc, V_inf};
params.MSEs = {MSE_rc, MSE_gc, MSE_inf};
params.projections = {              P_R_rc, ...
                      P_R_gc * G' * P_N_rc, ...
                      P_N_gc * G' * P_N_rc};

% Calculate the total of the contributions and covariances
cov_dG0 = V_rc * MSE_rc + V_gc * MSE_gc + V_inf * MSE_inf;

