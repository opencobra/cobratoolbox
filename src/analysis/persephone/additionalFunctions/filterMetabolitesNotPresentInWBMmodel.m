function [metabolitesPresentInWBM, metabolitesNotPresentInWBM] = filterMetabolitesNotPresentInWBMmodel(metabolitesOfInterest, WBM_compartment)
% Filters a table with metabolites for their presence in selected
% compartment(s) of the unpersonalized Harvey & Harvetta WBM models and returns
% both the present & absent metabolites in seperate tables.
% This process ensures that all metabolites of interest are actually present
% in the models & fluxes can be calculated for.

% INPUTS:
%   metabolitesOfInterest:      Table with VMH abbreviations of unique metabolites 
%                               of interest in column with var-name "ID".
%   
%   WBM_compartment:            Specification of WBM compartment in string 
%                               format, e.g. "[bc]".
% 
% OUTPUTS:
%   metabolitesPresentInWBM:    Table with metabolites of interest which
%                               are present in the selected compartment(s) 
%                               of the WBM models.
%
%   metabolitesNotPresentInWBM: Table with metabolites of interest which
%                               are not present in the selected compartment(s) 
%                               of the WBM models.
%
% AUTHOR:
%   - Jonas Widder, 10/2024


% Load unpersonalized Harvetta & Harvey WBM metabolites of specified compartment
% Load Harvetta WBM model
modelHarvetta = loadPSCMfile('Harvetta');
% Load metabolite id's from Harvetta
modelHarvetta_metabolites = [modelHarvetta.mets];
% Remove any the compartment abbreviation from the metabolite's names
modelHarvetta_metabolites = cellfun(@(x) regexprep(x, '^[^_]*_(?=.*_)', ''), modelHarvetta_metabolites, 'UniformOutput', false);
% Select only the metabolites from the compartment of interest
modelHarvetta_compMetabolitesIdx = contains(modelHarvetta_metabolites, WBM_compartment);
modelHarvetta_compMetabolites = modelHarvetta_metabolites(modelHarvetta_compMetabolitesIdx);

% Load Harvey WBM model
modelHarvey = loadPSCMfile('Harvey');
% Load metabolite id's from Harvey
modelHarvey_metabolites = [modelHarvey.mets];
% Remove any the compartment abbreviation from the metabolite's names
modelHarvey_metabolites = cellfun(@(x) regexprep(x, '^[^_]*_', ''), modelHarvey_metabolites, 'UniformOutput', false);
% Select only the metabolites from the compartment of interest
modelHarvey_compMetabolitesIdx = contains(modelHarvey_metabolites, WBM_compartment);
modelHarvey_compMetabolites = modelHarvey_metabolites(modelHarvey_compMetabolitesIdx);


% Remove WBM_compartment name extension from metabolite names for
% subsequent comparison to metabolitesOfInterest
modelHarvetta_compMetabolites = cellfun(@(x) erase(x, WBM_compartment),modelHarvetta_compMetabolites, 'UniformOutput',false);
modelHarvey_compMetabolites = cellfun(@(x) erase(x, WBM_compartment),modelHarvey_compMetabolites, 'UniformOutput',false);


% Identify all unique WBM_compartment metabolites present in Harvey AND/OR Harvetta
% selected compartment(s)
WBMmodels_compMetabolites = [modelHarvetta_compMetabolites; modelHarvey_compMetabolites];
WBMmodels_compMetabolites = unique(WBMmodels_compMetabolites);
WBMmodels_compMetabolites = cell2table(WBMmodels_compMetabolites, 'VariableNames', "ID");


% Filter out metabolites from the metabolitesOfInterest which are not present in the unpersonalized
% WBM models WBM_compartment & save both subgroups
[~, metabolitesPresentInWBM_idx, ~] = intersect(metabolitesOfInterest.ID, WBMmodels_compMetabolites.ID);
metabolitesPresentInWBM = metabolitesOfInterest(metabolitesPresentInWBM_idx,:);

metabolitesNotPresentInWBM_idx = ~ismember(1:height(metabolitesOfInterest), metabolitesPresentInWBM_idx);
metabolitesNotPresentInWBM = metabolitesOfInterest(metabolitesNotPresentInWBM_idx, :);

end