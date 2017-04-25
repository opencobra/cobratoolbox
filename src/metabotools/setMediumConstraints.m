function [modelMedium,basisMedium] = setMediumConstraints(model, set_inf, current_inf, medium_composition, met_Conc_mM, cellConc, t, cellWeight, mediumCompounds, mediumCompounds_lb, customizedConstraints, customizedConstraints_ub, customizedConstraints_lb, close_exchanges)
% Calculates and sets constraints according to medium composition in mM. Is based on the function `Conc2Rate`. Returns a model with constraints.
%
% USAGE:
%
%    [modelMedium, basisMedium] = setMediumConstraints(model, set_inf, current_inf, medium_composition, met_Conc_mM, cellConc, t, cellWeight, mediumCompounds, mediumCompounds_lb, customizedConstraints, customizedConstraints_ub, customizedConstraints_lb, close_exchanges)
%
% INPUTS:
%    model:                     Metabolic model (Recon)
%    current_inf:               Models can have differently defined infinite constraints, e.g., 500
%    set_inf:                   New value for infinite constraints, e.g., 1000
%    medium_composition:        Vector of exchange reactions of metabolites in the cell medium, e.g., RPMI medium
%    met_Conc_mM:               Vector of the same length of 'Exchanges', providing the concentration (in mM) of each metabolite in the respective row
%    cellConc:                  Cell concentration (cells per 1 ml)
%    t:                         Time in hours
%    cellWeight:                Cellular dry weight
%    mediumCompounds:           Composition of basic medium, which are usually not defined in the composition of the medium and need to be defined in addition.
%    mediumCompounds_lb:        Lower bound applied for all mediumCompounds (the same for all)
%
%
% OPTIONAL INPUTS:
%    customizedConstraints:     If additional constraints should be set apart from the basic medium and medium composition, e.g. `EX_o2(e)`
%    customizedConstraints_lb:  Vecor of lower bounds to be set (mmol/gDW/hr), must be of same length as customizedConstraints
%    customizedConstraints_ub:  Vecor of upper bounds to be set (mmol/gDW/hr), must be of same length as customizedConstraints
%    close_exchanges:           If exchange reactions except those specified should be closed (Default = 1) 1= close exchanges, 0=no
%
% OUTPUTS:
%    modelMedium:               Model with set constraints, all exchanges not specified in  mediumCompounds, ions or customizedConstraints are set to secretion only
%    basisMedium:               Vector of adjusted constraints, for reference such that these constraints are not overwritten at a later stage
%
% Please note that if metabolites of `medium_composition` and `mediumCompounds` overlap, the constraints of the `Medium_composition` will
% be set to 0 in the output model. The function depends on the functions `conc2Rate`, `changeRxnBounds`.
%
% .. Authors:
%       - Ines Thiele
%       - Maike K. Aurich 26/05/15

if ~exist('customizedConstraints','var') || isempty(customizedConstraints)
    customizedConstraints = {};
end

if ~exist('customizedConstraints_lb','var') || isempty(customizedConstraints_lb)
    customizedConstraints_lb = [];
end

if ~exist('customizedConstraints_ub','var') || isempty(customizedConstraints_ub)
    customizedConstraints_ub = [];
end

if ~exist('close_exchanges','var') || isempty(close_exchanges)
    close_exchanges = 1;
end


% set infinite constraints
model.lb(find(model.lb==-1*current_inf))=-1*set_inf;
model.ub(find(model.ub==current_inf))=set_inf;

% set basic medium

modelMedium = changeRxnBounds(model,mediumCompounds,mediumCompounds_lb,'l');
modelMedium = changeRxnBounds(modelMedium,customizedConstraints,customizedConstraints_lb,'l');
modelMedium = changeRxnBounds(modelMedium,customizedConstraints,customizedConstraints_ub,'u');

%calculate and apply flux rates as constraints if medium composition is
%supplied
if ~isempty(medium_composition)

    for i = 1 : length(medium_composition)

        [flux_Medium(i,1)] = conc2Rate(met_Conc_mM(i), cellConc, t, cellWeight);%

    end


    modelMedium = changeRxnBounds(modelMedium,medium_composition,-1*flux_Medium,'l');

    %% make output vector of applied constraints
    basisMedium = [customizedConstraints;mediumCompounds];
else
    basisMedium = customizedConstraints;
end
%% exchanges not constrained are set to zero

if close_exchanges ==1
    AllExMedium=modelMedium.rxns(strmatch('EX_',model.rxns));

    AllExMedium(ismember(AllExMedium,medium_composition))='';
    AllExMedium(ismember(AllExMedium,mediumCompounds))='';
    AllExMedium(ismember(AllExMedium,customizedConstraints))='';

    modelMedium.lb(find(ismember(modelMedium.rxns,AllExMedium)))= 0; % all exchanges not specified are set to secretion only
end
