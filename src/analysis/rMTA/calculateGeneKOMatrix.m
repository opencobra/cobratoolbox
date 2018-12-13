function [geneKO] = calculateGeneKOMatrix(model, varargin)
% Build a rxn-gene matrix such that the i-th column indicates what
% reactions become inactive because of the i-th gene's knock-out.
%
% USAGE:
%
%    geneKO = calculateGeneKOMatrix(model, SeparateTranscript, printLevel)
%
% INPUT:
%    model:             The COBRA Model structure
%
% OPTIONAL INPUTS:
%    SeparateTranscript Character used to separate
%                       different transcripts of a gene. (default = '')
%                       Examples:
%                           - SeparateTranscript = ''
%                              - gene 10005.1    ==>    gene 10005.1
%                              - gene 10005.2    ==>    gene 10005.2
%                              - gene 10005.3    ==>    gene 10005.3
%                           - SeparateTranscript = '.'
%                              - gene 10005.1
%                              - gene 10005.2    ==>    gene 10005
%                              - gene 10005.3
%    printLevel:       Integer. 1 if the process is wanted to be shown
%                      on the screen, 0 otherwise. (default = 1)
%
% OUTPUT:
%    geneKO:            Struct which contains matrix with blocked
%                       reactions for each gene in the metabolic model,
%                       name of reactions and name of genes.
%
% .. Authors:
%       - Luis V. Valcarcel, Oct 2017, University of Navarra, CIMA & TECNUN School of Engineering.
%       - Luis V. Valcarcel, 03/11/2018, University of Navarra, CIMA & TECNUN School of Engineering.

p = inputParser; % check the input information
addRequired(p, 'model');
addOptional(p, 'SeparateTranscript', '', @ischar);
addOptional(p, 'printLevel', 1, @(x)isnumeric(x)&&isscalar(x));
parse(p, model, varargin{:});

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

    transcripts = model.genes(strcmp(strtok(model.genes,p.Results.SeparateTranscript),genes{gen})); % to support R2015b
    [~, hasEffect, constrRxnNames] = deleteModelGenes(model, transcripts);

    if hasEffect
        % search index of bloced reactions
        [~,idx] = ismember(constrRxnNames,model.rxns);
        ko_rxn_gene(idx,gen) = 1;
    end
end
if p.Results.printLevel > 0
    fprintf('\tGeneKOMatrix calculated\n');
end

% geneKO
geneKO.genes = genes;
geneKO.rxns = model.rxns;
geneKO.matrix = (ko_rxn_gene~=0);
end
