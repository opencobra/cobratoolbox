function [IsCutSet, IsMinimal, geneNotMinimal] = checkGeneMCS(model, gMCSs, isoform_separator)
% Check if the gMCS is Minimal and Cut Set
% gMCS = gene Minimal Cut Set
% Minimal = the knock-off of all the genes of the gMCS is neccesary to
% eliminate the objective function
% Cut Set = The elimination of all the genes ensures the elimination of the
% objective reaction
%
% USAGE:
%
%    [IsCutSet, IsMinimal, geneNotMinimal] = checkGeneMCS(model, gMCSs, isoform_separator)
%
% INPUTS:
%    model:                 Metabolic model in COBRA format.
%    gMCSs:                 cell array which stores all the gMCSs previously
%                           calculated. Each position contains a gMCS.
%    isoform_separator:     genes in the model have different isoformes,
%                           which are identificated by a separator from the
%                           gene name. (Default = '').
% 
% OUTPUT:
%    IsCutSet:              array which indicates the biomass producion if
%                           all genes of the gMCSs are deleted
%    IsMinimal:             array which indicates the maximum of biomass if
%                           any gene is deleted
%    geneNotMinimal:        cell array which stores all the genes which
%                           make the gMCS not minimal (this errors are 
%                           produced by the restriction of coputation
%                           time).
%
% NOTE:
%    The isoform separator is neccesary to consider some genes as the same
%    gene. Example: genes 555.1, 555.2 and 555.3 are considered as gene 555
%
% .. Author: - Luis V. Valcarcel 2017-11-13

if nargin < 3 || isempty(isoform_separator)
    isoform_separator='';   % Default is each gene in model represent a real gene
end

if nargin < 2 || isempty(gMCSs)
    % Nothing to check
    BiomassCutSet = nan;
    BiomassMinimal = nan;
    geneNotMinimal = nan;
    warning('There is no gMCS to check');
    return
end

% Define the variables
BiomassCutSet = zeros(size(gMCSs));
BiomassMinimal = zeros(size(gMCSs));
geneNotMinimal = cell(size(gMCSs));

% Loop for all the gMCSs
showprogress(0,'Check all gMCS')
for i = 1:numel(gMCSs)
    showprogress(i/numel(gMCSs));
    gmcs = gMCSs{i};
    % Check if Cut Set
    BiomassCutSet(i) = checkGeneCutSet(model,gmcs,isoform_separator);
    % Check if Minimal
%     if nargout > 1
    if true
        if length(gmcs) == 1
            sol = optimizeCbModel(model);
            BiomassMinimal(i) = sol.obj;
        else
            check_Minimal = zeros(size(gmcs));
            % Loop to check if a subset of the gMCS is also gMCS
            for g = 1:numel(gmcs)
                idx = true(size(gmcs));
                idx(g) = 0; % not include the gene in pos "g"
                gmcs_aux = gmcs(idx);
                check_Minimal(g) = checkGeneCutSet(model,gmcs_aux,isoform_separator);
            end
            % Select a threshold for the objective function similar to the MCS target
            threshold_objective = 1e-3;
            geneNotMinimal{i} = gmcs(check_Minimal>threshold_objective);
            BiomassMinimal(i) = min(check_Minimal); % if any of them is a Cut Set, 
                                                 % the sum is > 0, not minimal
        end
    end
    
end


th = 1e-4; % same as default target b for gMCS

IsCutSet = BiomassCutSet < th;
IsMinimal = BiomassMinimal > th;

end


function biomassCS = checkGeneCutSet(model_raw,gMCS,isoform_separator)
% Check if the gMCS is a Cut Set
% Cut Set = The elimination of all the genes ensures the elimination of the
% objective reaction
%
% USAGE:
%
%    checkCS = checkGeneCutSet(model_raw,gMCS,isoform_separator)
%
% INPUTS:
%    model:                 Metabolic model in COBRA format.
%    gMCSs:                 cell array which stores a set of genes which we
%                           want to knock-out in order to knock-off the
%                           objective function.
%    isoform_separator:     genes in the model have different isoformes,
%                           which are identificated by a separator from the
%                           gene name. (Default = '').
% 
% OUTPUT:
%    checkCS:               biomass value which indicates if the set of 
%                           genes are a Cut Sets
%
% NOTE:
%    The isoform separator is neccesary to consider some genes as the same
%    gene. Example: genes 555.1, 555.2 and 555.3 are considered as gene 555
%
% .. Author: - Luis V. Valcarcel 2017-11-13

% change include in gene name "G_"
% This is done to diferentiate better between different genes which use
% ENTREZ ID (as in Recon1, Recon2, ...)
gMCS = strcat('G_',gMCS);
model_raw.genes = strcat('G_',model_raw.genes);

% Generate a list of genes (using isoforms)
if strcmp(isoform_separator,'')
    geneList = gMCS;
else
    geneList = [];
    for g = 1:numel(gMCS)
        idx = ~cellfun(@isempty, regexp(model_raw.genes,['^' gMCS{g} isoform_separator]));
        geneList = [geneList; model_raw.genes(idx)];
    end
    geneList = unique(geneList);
end

% Generate a model in which we delete the genes of the Cut Set
[model, ~, ~, deletedGenes] = deleteModelGenes(model_raw, geneList);

% Check that eliminated genes and geneList are the same
if ~isequal(geneList,deletedGenes)
    error('Elimated genes and Cut Set are not the same');
end

% check if the elimination of all genes is effective
sol = optimizeCbModel(model);
biomassCS = sol.obj ;

end

