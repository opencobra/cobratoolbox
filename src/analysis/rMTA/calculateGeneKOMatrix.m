
function [geneKO] = calculateGeneKOMatrix(model, varargin)
% Build a rxn-gene matrix such that the i-th column indicates what
% reactions become inactive because of the i-th gene's knock-out.
%
% USAGE:
%
%    geneKO = calculateGeneKOMatrix(model)
%
% INPUT:
%    model:             The COBRA Model structure
%
% OUTPUT:
%    geneKO:            Struct which contains matrix with blocked 
%                       reactions for each gene in the metabolic model,
%                       name of reactions and name of genes.
%
% .. Authors: - Luis V. Valcarcel, Oct 2017


%% Check the input information
p = inputParser;
addParameter(p, 'SeparateTranscript', '');
addParameter(p, 'printLevel', 1);
parse(p);

% define gene set
genes = unique(strtok(model.genes, p.Results.SeparateTranscript));
ngenes = numel(genes);

% generate output matrix
ko_rxn_gene = zeros(numel(model.rxns),ngenes);

% affected reactions
if p.Results.printLevel > 0
    showprogress(0, 'Calculate Gene Knock-out matrix');
end
for gen = 1:ngenes
    if p.Results.printLevel > 0
        showprogress(gen/ngenes, 'Calculate Gene Knock-out matrix');
    end
    
    transcripts = model.genes(startsWith(model.genes,[genes{gen} SeparateTranscript]));
    [~, hasEffect, constrRxnNames] = deleteModelGenes(model, transcripts);
    
    if hasEffect
        % search index of bloced reactions
        [~,idx] = ismember(constrRxnNames,model.rxns);
        ko_rxn_gene(idx,gen) = 1;
    end
end
if p.Results.printLevel > 0
    fprintf('\n\tGeneKOMatrix calculated\n');
end

% geneKO
geneKO.genes = genes;
geneKO.rxns = model.rxns;
geneKO.matrix = (ko_rxn_gene~=0);
end
