function [model, solution] = componentContribution(model, combinedModel, param)
% Perform the component contribution method
%
% Note, we assume DfG0 for '[H+]' is zero

% USAGE:
%
%    [model, params] = componentContribution(model, combinedModel)
%
% INPUTS:
%    model:             COBRA structure
%
% combinedModel:
% combinedModel.S:                          k x n stoichiometric matrix of training padded with zero rows for metabolites exclusive to test data
% combinedModel.drG0:                       n x 1 experimental standard reaction Gibbs energy
% combinedModel.drG0_prime:                 n x 1 experimental standard transformed reaction Gibbs energy
% combinedModel.T:                          n x 1 temperature
% combinedModel.I:                          n x 1 ionic strength
% combinedModel.pH:                         n x 1 pH
% combinedModel.pMg:                        n x 1 pMg
% combinedModel.G:                          k x g group incidence matrix
% combinedModel.groups:                     g x 1 cell array of group definitions
% combinedModel.trainingMetBool             k x 1 boolean indicating training metabolites in G
% combinedModel.testMetBool                 k x 1 boolean indicating test metabolites in G
% combinedModel.groupDecomposableBool:      k x 1 boolean indicating metabolites with group decomposition
% combinedModel.inchiBool                   k x 1 boolean indicating metabolites with inchi
% combinedModel.test2CombinedModelMap:      m x 1 mapping of model.mets to combinedModel.mets
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
if ~isfield(combinedModel,'DrG0')
    if isfield(combinedModel,'dG0')
        combinedModel.DrG0 = combinedModel.dG0;
        combinedModel = rmfield(combinedModel,'dG0');
    end
end
[S,G,DrG0]=deal(combinedModel.S, combinedModel.G, combinedModel.DrG0);
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

method = 'lsqminnorm';

if 0
    % Linear regression for the reactant layer (aka RC)
    [inv_St, r_rc, PR_rc, PL_rc] = invertProjection(S');
    
    % calculate the reactant contribution
    dfG0_rc = inv_St*DrG0;
    drG0_rc = PR_rc*DrG0;
    
    % Linear regression for the group layer (aka GC)
    [inv_StG, r_gc, PR_gc, PL_gc] = invertProjection(S'*G);
    
    % calculate the group contribution
    DfG0_gc = inv_StG*DrG0;
    DrG0_gc = PR_gc*DrG0;
    
    % Calculate the component contribution
    DfG0_cc = dfG0_rc + G*DfG0_gc;
    
    %projection matrices onto range(S) and null(S')
    [~,~, PR_S, PL_S] = invertProjection(S);
    %DfG0_cc = P_R_S*inv_St*DrG0 + P_N_St*G*inv_StG*DrG0;
    %DfG0_cc = (P_R_S*inv_St + P_N_St*G*inv_StG) * DrG0;
    DfG0_cc = PR_S*dfG0_rc + PL_S*G*DfG0_gc;
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
    

    %calculate the residual of the model
    e_m = e_gc - e_rc;
    
    %mean square error of component contribution model
    MSE_em = sqrt((e_m' * e_m) / (size(GS,2) - r_gc));
    
    MSE_inf = 1e10;
    
else
    
    % reactant contribution
    switch method
        case 'lsq'
            %Least-Squares Solution of Underdetermined System)
            DfG0_rc = S'\DrG0;
            % Warning: Rank deficient, rank = 520, tol =  1.450190e-09.
            % > In componentContribution (line 131)
        case 'lsqminnorm'
            DfG0_rc = lsqminnorm(S',DrG0);
    end
    
    % residual error (unweighted squared error divided by N - rank)
    e_rc = (DrG0 - S' * DfG0_rc);
    rankS = rank(full(S));
    MSE_rc = (e_rc' *  e_rc) / (size(S',2) - rankS);
    MAE_rc = mean(abs(e_rc));
    
    % group contribution
    StG = combinedModel.S'*combinedModel.G;
    switch method
        case 'lsq'
            %Least-Squares Solution of Underdetermined System
            DfG0_gc = StG\DrG0;
            %     Warning: Rank deficient, rank = 443, tol =  5.741722e-09.
            %     > In componentContribution (line 143)
        case 'lsqminnorm'
            DfG0_gc = lsqminnorm(StG,DrG0);
    end
    
    if isfield(combinedModel,'groups')
        boolH = strcmp('[H+]',combinedModel.groups);
        DfG0_gc(boolH)=0;
    end
    
    e_gc = (DrG0 - StG * DfG0_gc);
    %e_gc_m is the estimate of the group contribution modeling error 
    %it is given by the difference between the two residuals
    e_m = e_gc - e_rc;
    rankStG = rank(full(StG));
    MSE_gc = (e_gc' * e_gc) / (size(StG,2) - rankStG);
    MAE_gc = mean(abs(e_gc));
    MSE_m = (e_m' * e_m) / (size(StG,2) - rankStG);
    MAE_m = mean(abs(e_m));
    
    % component contribution
    %[inv_St, r_rc, PR_rc, PL_rc] = invertProjection(S');
    [~, ~, PR_S, PN_St] = subspaceProjector(S, 0, 'all');
    %zero out very small entries
    PR_S(abs(PR_S)<eps)=0;
    PN_St(abs(PN_St)<eps)=0;
    %DfG0_cc = (PR * inv_S' + PN_St * G * inv_GS')* DrG0;
    DfG0_cc = PR_S * DfG0_rc + PN_St * G * DfG0_gc;
    
    e_cc = (DrG0 - S' * DfG0_cc);
    MSE_cc = (e_cc' * e_cc) / (size(StG,2) - rankStG);
    MAE_cc = mean(abs(e_cc));
    
    %deal with missing vs zero estimates
    %identify the columns of St that are all zero, i.e., not constraining DfG0_rc(j)
    unconstrainedDfG0_rc = (sum(S'~=0,1)==0)';
    %set these corresponding group formation energies to 0
    DfG0_rc(unconstrainedDfG0_rc)=0;
    
    %identify the columns of StG that are all zero, i.e., not constraining DfG0_gc(j)
    unconstrainedDfG0_gc = (sum(StG~=0,1)==0)';
    unconstrainedDfG0_gc(boolH)=0;
    %set these corresponding group formation energies to 0
    DfG0_gc(unconstrainedDfG0_gc)=0;
    
    %identify the fractional reactant vs group contribution
    %reactantContFractionDfG0_cc = PR_St * ones(size(PR_St,2),1);
    %groupContFractionDfG0_cc = PN_St * G * ones(size(G,2),1);
    
    %identify the component contribution estimates that are unconstrained
    reactantContUnconstrainedDfG0_cc = (PR_S * unconstrainedDfG0_rc)~=0;
    groupContUnconstrainedDfG0_cc = (PN_St * G * unconstrainedDfG0_gc)~=0;
    unconstrainedDfG0_cc = (PR_S * unconstrainedDfG0_rc + PN_St * G * unconstrainedDfG0_gc)~=0;
end
   
% Calculate the uncertainty covariance matrices
epsilon = 1e-10;

[inv_SSt, ~, ~, ~] = invertProjection(S*S',epsilon);
%%zero out very small entries
inv_SSt(abs(inv_SSt)<eps)=0;
V_rc = inv_SSt;
[inv_GSGS, ~, ~, ~] = invertProjection(StG'*StG,epsilon);
%%zero out very small entries
inv_GSGS(abs(inv_GSGS)<eps)=0;
V_gc  = G*inv_GSGS*G';

diag_inv_SSt = diag(inv_SSt);
if any(diag_inv_SSt<0)
    fprintf('%s\n',['diag_inv_SSt has ' num2str(nnz(diag_inv_SSt<0)) ' negative entries. min(diag_inv_SSt) = ' num2str(min(diag_inv_SSt))])
    if min(diag_inv_SSt)>-1e-16
        diag_inv_SSt(diag_inv_SSt<0)=0;
    end
end
DfG0_rc_Uncertainty = columnVector(sqrt(MSE_rc*diag_inv_SSt));

diag_inv_GSGS = diag(inv_GSGS);
if any(diag_inv_GSGS<0)
    fprintf('%s\n',['diag_inv_GSGS has ' num2str(nnz(diag_inv_GSGS<0)) ' negative entries. min(diag_inv_GSGS) = ' num2str(min(diag_inv_GSGS))])
    if min(diag_inv_GSGS)>-1e-16
        diag_inv_GSGS(diag_inv_GSGS<0)=0;
    end
end
DfG0_gc_Uncertainty = columnVector(sqrt(MSE_gc*diag_inv_GSGS));

diag_V_gc = diag(V_gc);
if any(diag_V_gc<0)
    fprintf('%s\n',['diag_V_gc has ' num2str(nnz(diag_V_gc<0)) ' negative entries. min(diag_V_gc) = ' num2str(min(diag_V_gc))])
    if min(diag_V_gc)>-1e-16
        diag_V_gc(diag_V_gc<0)=0;
    end
end
DfG0_cc_gc_Uncertainty = columnVector(sqrt(MSE_gc*diag_V_gc));

%covariance for the metabolites with at least one group that is unconstrained by S'*G
if 0
    V_inf = spdiags(ones(mlt,1),0,mlt,mlt);
else
    V_inf = spdiags(groupContUnconstrainedDfG0_cc+0,0,mlt,mlt);
end
%assume the uncertainty is as large as the largest gc uncertainty
MSE_inf = MSE_gc;
    
diag_V_inf = diag(V_inf);
if any(diag_V_inf<0)
    fprintf('%s\n',['diag_V_inf has ' num2str(nnz(diag_V_inf<0)) ' negative entries. min(diag_V_inf) = ' num2str(min(diag_V_inf))])
end
DfG0_cc_inf_Uncertainty = columnVector(sqrt(MSE_inf*diag_V_inf));

% Calculate the weighted total of the contributions and covariances
[~, ~, ~, PN_StGGt] = invertProjection(G*StG',epsilon);
%zero out very small entries
PN_StGGt(abs(PN_StGGt)<eps)=0;

if 0
    DfG0_cc_cov = V_rc * MSE_rc + V_gc * MSE_gc + V_inf * MSE_inf;
else
    if 0
        DfG0_cc_cov = diag((((          PR_S)*columnVector(sqrt(diag(V_rc )))).^2)*MSE_rc...
            +  (((PN_St-PN_StGGt)*columnVector(sqrt(diag(V_gc )))).^2)*MSE_gc...
            +  (((      PN_StGGt)*columnVector(sqrt(diag(V_inf)))).^2)*MSE_inf);
    else
        DfG0_cc_cov =diag(((           PR_S*sqrt(diag(V_rc   ))).^2)*MSE_rc...
                       + (((PN_St-PN_StGGt)*sqrt(diag(V_gc ))).^2)*MSE_gc...
                       + (((      PN_StGGt)*sqrt(diag(V_inf))).^2)*MSE_inf);
    end
end

if any(diag(DfG0_cc_cov)<0)
    error('diag(DfG0_cc_cov) has a negative entries')
end
DfG0_cc_Uncertainty = columnVector(sqrt(diag(DfG0_cc_cov)));

% Put all the calculated data in 'solution' for the sake of debugging
if param.debug
    %reactant contribution
    solution.DfG0_rc = DfG0_rc;
    solution.PR_St = PR_S;
    solution.e_rc = e_rc;
    solution.rankS = rankS;
    solution.MSE_rc = MSE_rc;
    solution.MAE_rc = MAE_rc;
    solution.V_rc = V_rc;
    solution.DfG0_rc_Uncertainty = DfG0_rc_Uncertainty;
    solution.unconstrainedDfG0_rc = unconstrainedDfG0_rc;
    solution.reactantContUnconstrainedDfG0_cc = reactantContUnconstrainedDfG0_cc;
    
    %group contribution
    solution.DfG0_gc = DfG0_gc;
    solution.PN_St = PN_St;
    solution.e_gc = e_gc;
    solution.rankStG = rankStG;
    solution.MSE_gc = MSE_gc;
    solution.MAE_gc = MAE_gc;
    solution.e_m = e_m;
    solution.MSE_m = MSE_m;
    solution.MAE_m = MAE_m;
    solution.V_gc = V_gc;
    solution.DfG0_gc_Uncertainty = DfG0_gc_Uncertainty;
    solution.unconstrainedDfG0_gc = unconstrainedDfG0_gc;
    solution.groupContUnconstrainedDfG0_cc = groupContUnconstrainedDfG0_cc;
    
    % component contribution
    solution.DfG0_cc = DfG0_cc;
    solution.PN_StGGt = PN_StGGt;
    solution.e_cc = e_cc;
    solution.MSE_cc = MSE_cc;
    solution.MAE_cc = MAE_cc;
    solution.V_inf = V_inf;
    solution.MSE_inf = MSE_inf;
    solution.DfG0_cc_Uncertainty = DfG0_cc_Uncertainty;
    solution.DfG0_cc_gc_Uncertainty = DfG0_cc_gc_Uncertainty;
    solution.DfG0_cc_inf_Uncertainty = DfG0_cc_inf_Uncertainty;
    solution.unconstrainedDfG0_cc = unconstrainedDfG0_cc;
    
else
    solution = [];
end

% Standard metabolite Gibbs energy estimates, mapped  back to model
model.DfG0 = DfG0_cc(combinedModel.test2CombinedModelMap);
model.DfG0_Uncertainty=DfG0_cc_Uncertainty(combinedModel.test2CombinedModelMap);
if ~real(model.DfG0_Uncertainty)
    error('DfG0_Uncertainty has a complex part')
end
%note the component contribution metabolite estimates that are partially unconstrained by the group fitting process
model.unconstrainedDfG0_cc = solution.unconstrainedDfG0_cc(combinedModel.test2CombinedModelMap);

% Standard reaction Gibbs energy estimates
model.DrG0 = model.S'*model.DfG0;
if ~isfield(model,'transportRxnBool')
    model.transportRxnBool = transportReactionBool(model);
end
if isfield(model,'SConsistentRxnBool')
    bool = model.transportRxnBool | ~model.SConsistentRxnBool;
else
    bool = model.transportRxnBool | ~model.SIntRxnBool;
end
model.DrG0(bool)=0;

%map matrices back onto model
if 1
    %metabolites
    model.DfG0_cc_cov = DfG0_cc_cov(combinedModel.test2CombinedModelMap,combinedModel.test2CombinedModelMap);
    %reactions
    model.DrG0_cc_cov = model.S'*model.DfG0_cc_cov*model.S;
else
    model.V_rc=V_rc(combinedModel.test2CombinedModelMap,combinedModel.test2CombinedModelMap);
    model.V_gc=V_gc(combinedModel.test2CombinedModelMap,combinedModel.test2CombinedModelMap);
    model.V_inf=V_inf(combinedModel.test2CombinedModelMap,combinedModel.test2CombinedModelMap);
    model.PR_S=PR_S(combinedModel.test2CombinedModelMap,combinedModel.test2CombinedModelMap);
    model.PN_St=PN_St(combinedModel.test2CombinedModelMap,combinedModel.test2CombinedModelMap);
    model.PN_StGGt=PN_StGGt(combinedModel.test2CombinedModelMap,combinedModel.test2CombinedModelMap);
    model.DrG0_cc_cov =   model.S'*(...
                      ((diag(                model.PR_S)*sqrt(diag(model.V_rc ))).^2)*MSE_rc...
                    + ((diag(model.PN_St-model.PN_StGGt)*sqrt(diag(model.V_gc ))).^2)*MSE_gc...
                    + ((diag(            model.PN_StGGt)*sqrt(diag(model.V_inf))).^2)*MSE_inf...
                    )*model.S;
end


%zero uncertainty for transport or exchange reactions
diag_DrG0_cc_cov = diag(model.DrG0_cc_cov);
diag_DrG0_cc_cov(bool)=0;
if any(diag_DrG0_cc_cov<0)
    if norm(diag_DrG0_cc_cov(diag_DrG0_cc_cov<0))<eps
        diag_DrG0_cc_cov(diag_DrG0_cc_cov<0)=0;
    else
        error('diag(model.S''*model.DfG0_cov*model.S) has large negative entries')
    end
end         


model.DrG0_Uncertainty = columnVector(sqrt(diag(model.DrG0_cc_cov)));
if ~real(model.DrG0_Uncertainty)
    error('DrG0_Uncertainty has a complex part')
end

%note the component contribution reaction estimates that are partially unconstrained by the group fitting process
model.unconstrainedDrG0_cc = (model.S'*model.unconstrainedDfG0_cc)~=0;
