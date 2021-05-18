function [model, solution] = componentContribution(model, combinedModel, param)
% Perform the component contribution method
%
% USAGE:
%
%    [model, params] = componentContribution(model, combinedModel)
%
% INPUTS:
%    model:             COBRA structure
%    combinedModel:      structure from `prepareTrainingData` with the following fields:
%
%                         * .S - the stoichiometric matrix of measured reactions
%                         * .G - the group incidence matrix
%                         * .dG0 - the observation vector (standard Gibbs energy of reactions)
%                         * .test2CombinedModelMap
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
%    solution:            structure containing various solution vectors

if ~isfield(model,'SIntRxnBool')
    model = findSExRxnInd(model);
end
if ~exist('param','var')
    param=struct();
end
if ~isfield(param,'debug')
    param.debug = 1;
end

fprintf('Running Component Contribution method\n');
[S,G,DrG0]=deal(combinedModel.S, combinedModel.G, combinedModel.dG0);
[mlt, nlt] = size(S);

%assert Generate an error when a condition is violated.
assert (size(G, 1) == mlt);
assert (size(DrG0, 1) == nlt);
assert (size(DrG0, 2) == 1);

%%
%[inv_A, r, P_R, P_N] = invertProjection(A, epsilon)
%     inv_A - the pseudoinverse of A
%     r     - the rank of A
%     P_R   - the projection matrix onto the range(A)
%     P_N   - the projection matrix onto the null(A')

if 0
    % Linear regression for the reactant layer (aka RC)
    [inv_St, r_rc, P_R_rc, P_N_rc] = invertProjection(S');
    
    % calculate the reactant contribution
    dfG0_rc = inv_St*DrG0;
    drG0_rc = P_R_rc*DrG0;
    
    % Linear regression for the group layer (aka GC)
    [inv_StG, r_gc, P_R_gc, P_N_gc] = invertProjection(S'*G);
    
    % calculate the group contribution
    DgG0_gc = inv_StG*DrG0;
    DrG0_gc = P_R_gc*DrG0;
    
    % Calculate the component contribution
    DfG0_cc = dfG0_rc + G*DgG0_gc;
    
    %projection matrices onto range(S) and null(S')
    [~,~, P_R_S, P_N_St] = invertProjection(S);
    %DfG0_cc = P_R_S*inv_St*DrG0 + P_N_St*G*inv_StG*DrG0;
    %DfG0_cc = (P_R_S*inv_St + P_N_St*G*inv_StG) * DrG0;
    DfG0_cc = P_R_S*dfG0_rc + P_N_St*G*DgG0_gc;
    %DrG0_cc = S'*(P_R_S*inv_St + P_N_St*G*inv_StG) * DrG0;
    %DrG0_cc = S'*DfG0_cc;
    
    DrG0_cc = S'*DfG0_cc;
    
    % Calculate the residual of the reactant contribution
    e_rc = DrG0 - drG0_rc;
    %e_rc = (In - P_R_rc)*DrG0;
    
    %mean square error of reactant contribution (unweighted squared error divided by N - rank)
    MSE_rc = (e_rc' * e_rc) / (min(size(S)) - r_rc);
    
    % Calculate the residual of the group contribution
    e_gc = DrG0 - DrG0_gc;
    
    %mean square error of group contribution
    MSE_gc = (e_gc' * e_gc) / (min(size(S'*G)) - r_gc);
    

    
else
    GS = G' * S;
    
    % Linear regression for the reactant layer (aka RC)
    [inv_S, r_rc, P_R_rc, P_N_rc] = invertProjection(S);
    
    % reactant contribution
    DfG0_rc = inv_S' * DrG0;
    
    % residual error (unweighted squared error divided by N - rank)
    e_rc = (DrG0 - S' * DfG0_rc);
    MSE_rc = (e_rc' *  e_rc) / (min(size(S)) - r_rc);
    
    % Linear regression for the group layer (aka GC)
    [inv_GS, r_gc, P_R_gc, P_N_gc] = invertProjection(GS);
    
    % group contribution
    DgG0_gc = inv_GS' * DrG0;
    
    e_gc = (DrG0 - GS' * DgG0_gc);
    MSE_gc = (e_gc' * e_gc) / (min(size(GS)) - r_gc);
    
    % component contribution
    %DfG0_cc = (P_R_rc * inv_S' + P_N_rc * G * inv_GS')* DrG0;
    DfG0_cc = P_R_rc * DfG0_rc + P_N_rc * G * DgG0_gc;
    
    e_cc = (DrG0 - S' * DfG0_cc);
    MSE_cc = (e_cc' * e_cc) / (min(size(GS)) - r_gc);
end

%DrG0_cc = S'*DfG0_cc;

%calculate the residual of the model
e_m = e_gc - e_rc;

%mean square error of component contribution model
MSE_em = sqrt((e_m' * e_m) / (size(GS,2) - r_gc));

MSE_inf = 1e10;
    
% Calculate the uncertainty covariance matrices
[inv_SWS, ~, ~, ~] = invertProjection(S*S');

epsilon = 1e-10;
[inv_GSWGS, ~, ~, ~] = invertProjection(GS*GS',epsilon);
%zero out small entries
P_N_gc(abs(P_N_gc)<epsilon)=0;

if 0
    V_rc = P_R_rc * inv_SWS * P_R_rc;
    V_gc  = P_N_rc * G * inv_GSWGS * G' * P_N_rc;
    V_inf = P_N_rc * G * P_N_gc * G' * P_N_rc;
else
    V_rc = inv_SWS;
    V_gc  = G * inv_GSWGS * G';
    V_inf = G * P_N_gc * G';
end

MSE_inf = 1e10;

% Put all the calculated data in 'solution' for the sake of debugging
if param.debug
    %reactant contribution
    solution.DfG0_rc = DfG0_rc;
    solution.inv_S = inv_S;
    solution.P_R_rc = P_R_rc;
    solution.e_rc = e_rc;
    solution.MSE_rc = MSE_rc;
    solution.V_rc = V_rc;
    
    %group contribution
    solution.DgG0_gc = DgG0_gc;
    solution.inv_GS = inv_GS;
    solution.P_N_rc = P_N_rc;
    solution.e_gc = e_gc;
    solution.MSE_gc = MSE_gc;
    solution.V_gc = V_gc;
    
    % component contribution
    solution.DfG0_cc = DfG0_cc;
    solution.e_cc = e_cc;
    solution.MSE_cc = MSE_cc;
    
    solution.V_inf = V_inf;
    solution.MSE_inf = MSE_inf;
else
    solution = [];
end

% Calculate the total of the contributions and covariances
cov_dG0 = V_rc * MSE_rc + V_gc * MSE_gc + V_inf * MSE_inf;


% Map estimates back to model
model.DfG0 = DfG0_cc(combinedModel.test2CombinedModelMap);
model.covf = cov_dG0(combinedModel.test2CombinedModelMap, combinedModel.test2CombinedModelMap);

%model.DfG0_Uncertainty = diag(sqrt(model.covf));
diag_conf=diag(model.covf);
if any(diag_conf<0)
    error('diag(model.covf) has a negative entries')
end
model.DfG0_Uncertainty=columnVector(sqrt(diag_conf));
if ~real(model.DfG0_Uncertainty)
    error('DfG0_Uncertainty has a complex part')
end
DfG0NaNBool=isnan(model.DfG0);
if any(DfG0NaNBool)
    error([int2str(nnz(DfG0NaNBool)) ' DfG0 are NaN']);
end

diag_St_conf_S=diag(model.S'*diag(diag(model.covf))*model.S);

diag_St_conf_S(~model.SIntRxnBool)=0;
if any(diag_St_conf_S<0)
    if norm(diag_St_conf_S(diag_St_conf_S<0))<1e-12
        diag_St_conf_S(diag_St_conf_S<0)=0;
    else
        error('diag(model.S''*model.covf*model.S) has large negative entries')
    end
end
model.DrG0_Uncertainty = columnVector(sqrt(diag_St_conf_S));
if ~real(model.DrG0_Uncertainty)
    error('DrG0_Uncertainty has a complex part')
end
model.DrG0_Uncertainty(~model.SIntRxnBool,1)=inf;
%model.DrG0_Uncertainty(model.DrG0_Uncertainty >= 1e3) = 1e10; % Set large uncertainty in reaction energies to inf


