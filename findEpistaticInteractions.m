function [interactions,epistaticEffect] = findEpistaticInteractions(model,doubleDeletionFitness,lethalFlag,minEffect)
%findEpistaticInteractions Finds synthetic lethal and/or synthetic sick
%interactions based on double deletion analysis data
%
% [interactions,epistaticEffect] = findEpistaticInteractions(model,doubleDeletionFitness,lethalFlag,minEffect)
%
%INPUTS
% model                 COBRA model structure
% doubleDeletionFitness A matrix of fitness (or growth rate) values for
%                       each of the double deletion strains. The diagonal
%                       of this matrix contains the single deletion fitness
%                       values.
%
%OPTIONAL INPUTS
% lethalFlag            Only consider SL interactions (Default = false)
% minEffect             Minimum fitness effect considered to be significant
%                       (Default = 1e-2)
% 
%OUTPUTS
% interactions          A sparse binary matrix indicating a SL or SS
%                       interaction between two genes in the model
% epistaticEffect       Magnitude of the epistatic interaction defined as
%                       min(f1-f12,f2-f12) where f1 and f2 are the fitness
%                       values for the deletion strain of gene 1 and gene 2
%                       respectively and f12 is the fitness value for the
%                       double deletion strain of genes 1 and 2
% 
% The criteria for establishing a synthetic sick interaction are that the
% double deletion strain fitness must be at least minEffect lower than the
% fitness of either of the single deletion strains, i.e. 
%       f12 < f1-minEffect and f12 < f2-minEffect
%
% The additional criterion for establishing a synthetic lethal interaction
% is that the double deletion fitness value is smaller than minEffect (i.e.
% essentially zero)
%       f12 < minEffect
% 
% Note that the interactions matrix double counts all interactions
%
% Markus Herrgard 1/17/07

if (nargin < 3)
    lethalFlag = false;
end
if (nargin < 4)
    minEffect = 1e-2;
end

nGenes = length(model.genes);

singleDeletionFitness = diag(doubleDeletionFitness);

interactions = sparse(nGenes,nGenes);
epistaticEffect = zeros(nGenes,nGenes);

for i = 1:nGenes
    fitness1 = singleDeletionFitness(i);
    for j = i+1:nGenes        
        fitness2 = singleDeletionFitness(j);
        fitness12 = doubleDeletionFitness(i,j);
        isInteraction = fitness12 < fitness1-minEffect &  fitness12 < fitness2-minEffect;
        if (lethalFlag)
            isInteraction = isInteraction & fitness12 < minEffect;
        end
        if (isInteraction)
                interactions(i,j) = 1;
                interactions(j,i) = 1;
                epistaticEffect(i,j) = min(fitness1-fitness12,fitness2-fitness12);
                epistaticEffect(j,i) = min(fitness1-fitness12,fitness2-fitness12);
            end
        end
    end
end