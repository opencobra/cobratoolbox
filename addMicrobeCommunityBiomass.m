function model = addMicrobeCommunityBiomass(model,microbeNames,abundances)
%Adds a community biomass reaction to a model structure with multiple
%microbes based on their relative abundances. If no abundance values are
%provided, all n microbes get equal weights (1/n). Assumes a lumen
%compartment [u] and a fecal secretion comparment [fe]. Creates a community
%biomass metabolite 'microbeBiomass' that is secreted from [u] to [fe] and
%exchanged from fecal compartment.
%
%INPUT
% model         COBRA model structure with n joined microbes with biomass
%               metabolites 'Microbe_biomass[c]'.
% microbeNames  nx1 cell array of n unique strings that represent
%               each microbe in the model.
%
%OPTIONAL INPUT
% abundances    nx1 vector with the relative abundance of each microbe.
%
%OUTPUT
% model         COBRA model structure
%
% SM June 2016

dummy=makeDummyModel(length(microbeNames)+2,3);
dummy.mets=[strcat(microbeNames,'_biomass[c]');'microbeBiomass[u]';'microbeBiomass[fe]'];
dummy.rxns={'communityBiomass';'UFEt_microbeBiomass';'EX_microbeBiomass[fe]'};
if ~isempty(abundances)
    dummy.S(:,1)=[-abundances;1;0];
else
    dummy.S(:,1)=[-ones(size(microbeNames))/length(microbeNames);1;0];
end
dummy.S(end-1:end,2)=[-1;1];
dummy.S(end,3)=-1;
dummy.rev(end,1)=1;
dummy.lb(end,1)=-1000;
dummy.ub=ones(size(dummy.ub))*1000;
%join models
model=mergeTwoModels(dummy,model,2,0);