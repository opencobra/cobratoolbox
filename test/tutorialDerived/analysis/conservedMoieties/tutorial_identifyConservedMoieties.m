%% Identify Conserved Moieties
%% Author(s): Ronan M.T. Fleming, School of Medicine, University of Galway
%% Reviewer(s): 
%% INTRODUCTION
% Given an atom transition multgraph for a metabolic model, this tutorial identifies 
% its conserved moieties, as described elsewhere [1,2]. 
% 
% 
% 
% These tutorials should generally be used in the following order:
% 
% 1. Initialise and set the paths to inputs and outputs
% 
% COBRA.tutorials/driver_initConservedMoietyPaths.mlx   
% 
% 2. Build an atom transition graph
% 
% tutorial_buildAtomTransitionMultigraph.mlx
% 
% 3. Identify conserved moieties, given an atom transition graph                                               
% 
% tutorial_identifyConservedMoieties.mlx
% 
% 4. Analyse the output of #3
% 
% tutorial_analyseConservedMoieties.mlx 
% 
% 5. Prepare for visualisation of individual conserved moieties (beta)      
% 
% tutorial_visualiseConservedMoieties.mlx
% 
% 

if ~exist('resultsDir','var')
    driver_initConservedMoietyPaths
end
%%
if ~recompute %|| isequal(modelName,'iDopaNeuro1')
    load([resultsDir modelName '_arm.mat'])
    return
end
% 1.2.3. Conserved moieties 
% With the atom mappings we obtained, we can compute the conserved moieties 
% for the iDopaNeuro metabolic network using the atom transition network and the 
% COBRA function |identifyConservedMoieties|.

switch modelName
    case 'DAS'
        load([dataDir filesep 'models' filesep modelName '.mat'])
        load([resultsDir filesep modelName '_dATM.mat'])
    case 'iDopaNeuro1'
        load([resultsDir filesep modelName '.mat'])
        load([resultsDir filesep modelName '_dATM.mat'])
        
    case {'centralMetabolism','centralMetabolism_fastCore','centralMetabolism_thermoKernel'}
        load([resultsDir filesep modelName '.mat'])
        load([resultsDir filesep modelName '_dATM.mat'])
    otherwise
        load([dataDir filesep modelName '.mat'])
end

%%
options.sanityChecks=1;
[arm, moietyFormulae] = identifyConservedMoieties(model, dATM, options);
%%
save([resultsDir filesep modelName '_arm.mat'],'arm', 'moietyFormulae','options')
%% _Acknowledgments_
% Co-funded by the European Union's Horizon Europe Framework Programme (101080997)
%% REFERENCES
%% 
% # Ghaderi, S., Haraldsdóttir, H. S., Ahookhosh, M., Arreckx, S., & Fleming, 
% R. M. T. (2020). Structural conserved moiety splitting of a stoichiometric matrix. 
% Journal of Theoretical Biology, 499, 110276. <https://doi.org/10.1016/j.jtbi.2020.110276 
% https://doi.org/10.1016/j.jtbi.2020.110276>
% # Rahou, H., Haraldsdóttir, H. S., Martinelli, F., Thiele, I., & Fleming, 
% R. M. T. (2026). Characterisation of conserved and reacting moieties in chemical 
% reaction networks. Journal of Theoretical Biology, 112348. <https://doi.org/10.1016/j.jtbi.2025.112348 
% https://doi.org/10.1016/j.jtbi.2025.112348> 
%% 
%