function EFMyield = efmYieldAnalysis(EFMFluxes, uptkRxnID, relRxnID)
% This function performs yield analysis on the input set of EFMs 
%
% USAGE:
%    EFMyield = EFMYieldAnalysis(fluxData, uptkRxnID, relRxnID);
%    
% INPUTS:
%    EFMFluxes:    matlab array containing relative fluxes of reactions in EFM 
%    uptkRxnID:    (numeric) index of the desired uptake reaction as in the input model
%    relRxnID:     (numeric) index of the desired release reaction as in the input model
%
% OUTPUTS:
%    EFMyield:    matlab array with yields for all input set of EFMs
%
% EXAMPLE:
%     EFMyield = EFMYieldAnalysis(EFMFluxes, 729, 889); % 729 is the ID for acetate release reaction in the iAF1260 model
%
% .. Author: Last modified: Chaitra Sarathy, 1 Oct 2019


EFMyield = EFMFluxes(:,relRxnID)./EFMFluxes(:,uptkRxnID);


end

