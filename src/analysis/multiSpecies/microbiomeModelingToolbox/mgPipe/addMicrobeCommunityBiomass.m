function model = addMicrobeCommunityBiomass(model, microbeNames, abundances)
% Adds a community biomass reaction to a model structure with multiple
% microbes based on their relative abundances. If no abundance values are
% provided, all n microbes get equal weights (1/n). Assumes a lumen
% compartment [u] and a fecal secretion comparment [fe]. Creates a community
% biomass metabolite 'microbeBiomass' that is secreted from [u] to [fe] and
% exchanged from fecal compartment.
%
% USAGE:
%
%   model = addMicrobeCommunityBiomass(model, microbeNames, abundances)
%
% INPUTS:
%   model:           COBRA model structure with n joined microbes with biomass
%                    metabolites 'Microbe_biomass[c]'.
%   microbeNames:    nx1 cell array of n unique strings that represent
%                    each microbe in the model.
%
% OPTIONAL INPUT:
%   abundances:      nx1 vector with the relative abundance of each microbe.
%
% OUTPUT:
%   model:           COBRA model structure
%
% .. Author: Stefania Magnusdottir June 2016

dummy = createModel(); %makeDummyModel(length(microbeNames) + 2, 3);

mets = [strcat(microbeNames, '_biomass[c]'); 'microbeBiomass[u]'; 'microbeBiomass[fe]'];
rxns = {'communityBiomass'; 'UFEt_microbeBiomass'; 'EX_microbeBiomass[fe]'};
if ~exist('abundances','var') || isempty(abundances)    
    S = [-ones(size(microbeNames)) / length(microbeNames); 1; 0];    
else
    S = [-abundances; 1; 0];
end
S(end-1:end,2) = [-1; 1];
S(end,3) = -1;
% three reactions are added
lb = [0;0;-1000];
ub = ones(3,1) * 1000;
dummy = addMultipleMetabolites(dummy,mets);
dummy = addMultipleReactions(dummy,rxns,mets,S,'lb',lb,'ub',ub);
% join models
model = mergeTwoModels(dummy, model, 2, 0);
