function [model, params] = componentContribution(model, trainingData)
% Perform the component contribution method
%
% USAGE:
%
%    [model, params] = componentContribution(model, trainingData)
%
% INPUTS:
%    model:             COBRA structure
%    trainingData:      structure from `prepareTrainingData` with the following fields:
%
%                         * .S - the stoichiometric matrix of measured reactions
%                         * .G - the group incidence matrix
%                         * .dG0 - the observation vector (standard Gibbs energy of reactions)
%                         * .weights - the weight vector for each reaction in `S`
%                         * .Model2TrainingMap
%
% OUTPUTS:
%    model:             structure with the following fields:
%
%                         * .DfG0 - `m x 1` array of component contribution estimated
%                           standard Gibbs energies of formation.
%                         * .covf - `m x m` estimated covariance matrix for standard
%                           Gibbs energies of formation.
%                         * .DfG0_Uncertainty - `m x 1` array of uncertainty in estimated standard
%                           Gibbs energies of formation. Will be large for
%                           metabolites that are not covered by component
%                           contributions.
%                         * .DrG0_Uncertainty - `n x 1` array of uncertainty in standard reaction
%                           Gibbs energy estimates.  Will be large for
%                           reactions that are not covered by component
%                           contributions.
%    params:            structure

if ~isfield(model,'SIntRxnBool')
    model = findSExRxnInd(model);
end

fprintf('Running Component Contribution method\n');
[S,G,dG0,weights]=deal(trainingData.S, trainingData.G, trainingData.dG0, trainingData.weights);
[m, n] = size(S);
%assert Generate an error when a condition is violated.
assert (size(G, 1) == m);
assert (size(dG0, 1) == n);
assert (size(dG0, 2) == 1);
assert (length(weights) == size(S, 2));

% Apply weighing
W = diag(weights);
GS = G' * S;

%[inv_A, r, P_R, P_N] = invertProjection(A, epsilon)
%     inv_A - the pseudoinverse of A
%     r     - the rank of A
%     P_R   - the projection matrix onto the range(A)
%     P_N   - the projection matrix onto the null(A')
% Linear regression for the reactant layer (aka RC)
[inv_S, r_rc, P_R_rc, P_N_rc] = invertProjection(S * W);

% calculate the reactant contribution
dG0_rc = inv_S' * W * dG0;

% Linear regression for the group layer (aka GC)
[inv_GS, r_gc, P_R_gc, P_N_gc] = invertProjection(GS * W);

% calculate the group contribution
dG0_gc = inv_GS' * W * dG0;

% Calculate the contributions in the stoichiometric space
dG0_cc = P_R_rc * dG0_rc + P_N_rc * G * dG0_gc;

% Calculate the residual error (unweighted squared error divided by N - rank)
e_rc = (S' * dG0_rc - dG0); %sign opposite to eq 3 in suText_S1.pdf
MSE_rc = (e_rc' * W * e_rc) / (n - r_rc);

%e_gc = (S' * G_gc - dG0); - was this in Elad's v1 matlab code
e_gc = (GS' * dG0_gc - dG0); %this is as in Elad's v2 matlab code on git
%e_gc = (GS.T * dG0_gc - b); %this is as in Elad's python code on git
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

% dG0_cc
% cov_dG0       %uf = diag(sqrt(model.covf));
% params

% Map estimates back to model
model.DfG0 = dG0_cc(trainingData.Model2TrainingMap);
model.covf = cov_dG0(trainingData.Model2TrainingMap, trainingData.Model2TrainingMap);

%model.DfG0_Uncertainty = diag(sqrt(model.covf));
diag_conf=diag(model.covf);
if any(diag_conf<0)
    error('diag(model.covf) has a negative entries')
end
model.DfG0_Uncertainty=sqrt(diag_conf);
if ~real(model.DfG0_Uncertainty)
    error('DfG0_Uncertainty has a complex part')
end
DfG0NaNBool=isnan(model.DfG0);
if any(DfG0NaNBool)
    error([int2str(nnz(DfG0NaNBool)) ' DfG0 are NaN']);
end

diag_St_conf_S=diag(model.S'*model.covf*model.S);
model.DrGt0_Uncertainty(model.SIntRxnBool)=NaN;
if any(diag_St_conf_S<0)
    if norm(diag_St_conf_S(diag_St_conf_S<0))<1e-12
        diag_St_conf_S(diag_St_conf_S<0)=0;
    else
        error('diag(model.S''*model.covf*model.S) has a large negative entries')
    end
end
model.DrGt0_Uncertainty = sqrt(diag_St_conf_S);
if ~real(model.DrGt0_Uncertainty)
    error('DrGt0_Uncertainty has a complex part')
end
model.DrGt0_Uncertainty(~model.SIntRxnBool)=NaN;
% model.DrGt0_Uncertainty(model.DrGt0_Uncertainty >= 1e3) = 1e10; % Set large uncertainty in reaction energies to inf
% model.DrGt0_Uncertainty(sum(model.S~=0)==1) = 1e10; % set uncertainty of exchange, demand and sink reactions to inf

% Debug
% model.G = trainingData.G(trainingData.Model2TrainingMap,:);
% model.groups = trainingData.groups;
% model.has_gv = trainingData.has_gv(trainingData.Model2TrainingMap);
