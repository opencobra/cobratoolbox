function [modelLOD] = setQualitativeConstraints(model,cond_uptake,cond_uptake_LODs, cond_secretion,cond_secretion_LODs,cellConc,t,cellWeight,ambiguous_metabolites,basisMedium)
% This function sets qualitative constraints (by enforcing minimal uptake or secretion based on individual detection limits), e.g., based on the uptake and secretion
% profile of metabolites measured through mass-spectrometry. Uptake is only possible if the lower bound has been set to a value >0 using `setMediumConstraints`
% The minimal allowable uptake and secretion flux is defined by enforcing uptake at or above the limit of detection (mass-spectrometry). If these values are not available, a very small value, e.g., 1.0E-06 can be used. Note that this
% value has to be below the concentrations defined in the medium. Otherwise the model will be infeasible. Alternatively to the LODs a small value can
% be used (e.g., 0.00001). Note that the value has to be above the threshold later called zero.
%
% USAGE:
%
%    [modelLOD] = setQualitativeConstraints(model, cond_uptake, cond_uptake_LODs, cond_secretion, cond_secretion_LODs, cellConc, t, cellWeight, ambiguous_metabolites, basisMedium)
%
% INPUTS:
%    model:                   Metabolic model (Recon), with set constraints (output of `setMediumConstraints`)
%    cond_uptake:             Vector of exchanges of metabolites consumed by the cells in the experiment
%    cond_uptake_LODs:        Vector of detection limits (LOD in Mm) for the compounds and in the experiment
%    cond_secretion:          Vector of metabolite exchanges consumed by the cells in the experiment
%    cond_secretion_LODs:     Vector of detection limits (LOD in Mm) for the compounds and in the experiment
%    cellConc:                Cell concentration (cells per 1 ml)
%    t:                       Time in hours
%    cellWeight:              gDW per cell
%    ambiguous_metabolites:   Since all exchanges, except the ones specified in `uptake` and `secretion` are closed in `modelLOD`, this input
%                             variable allows to specify metabolite exchanges that should remain open. 
%                             Thus, if these exchanges are open in the starting model they can be uptaken
%                             or secreted by the `modelLOD`, e.g., `ambiguous_metabolites`
%                             This can for example be the case if it is suspected that an uptake or secretion might have taken place in concentrations below the
%                             detection limit. 
%    basisMedium:             Vector defining the metabolite exchanges of the basic medium, i.e., `ions`, `mediumCompounds`
%
% OUTPUT:
%    modelLOD:                Model that is constrained qualitatively to the condition-specific uptake and secretion profile
%
% .. Author: - Maike K. Aurich 27/05/15

A = strfind(model.rxns, 'EX_');
%Find all exchange reactions
for i = 1:length(A);
    B= A{i};
       if  isempty(B);
       A{i}=[0];
       end
end
cc = cell2mat(A);
idx_EXreactions= find(cc);
ex_Rxns = model.rxns(idx_EXreactions); %make exchange reaction list

%% Calculate flux rates (LODs)
for i = 1 : length(cond_uptake_LODs)
    [ub_up_flux(i,1)] = conc2Rate(cond_uptake_LODs(i),cellConc, t, cellWeight);
end


for i = 1 : length(cond_secretion_LODs) % conversion from conc.(minimal detection value total, in Mm) to flux value per cell mmol/gDW/hr
        [lb_secr_flux(i,1)] = conc2Rate(cond_secretion_LODs(i),cellConc, t, cellWeight);
end

%% Define which exchanges to close and close them
conditional_exchanges = [cond_uptake;cond_secretion;basisMedium;ambiguous_metabolites];

no_exchange = ex_Rxns(find(~ismember(ex_Rxns,conditional_exchanges)));%find reactions not associated with detected exhange metabolites, basic medium metabolites, low quantity metabolites

model = changeRxnBounds(model,no_exchange,0,'b'); %block all other Exchange reactions


%% Apply LOD constraints to enforce uptake and secretion

for k=1:length(cond_uptake)    
    ub=ub_up_flux(k);
    rxns = cond_uptake(k);
model = changeRxnBounds(model,rxns,-ub,'u'); %enforce uptake of metabolites taken up by cells in the experiment
end
clear k
for k=1:length(cond_secretion)
    lb=lb_secr_flux(k);
model = changeRxnBounds(model,cond_secretion(k),lb,'l');% enforce secretion of metabolites secreted by the cells in the experiment
end

modelLOD = model;
end

