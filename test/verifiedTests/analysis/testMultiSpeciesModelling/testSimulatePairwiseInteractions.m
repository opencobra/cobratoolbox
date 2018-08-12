% The COBRAToolbox: testSimulatePairwiseInteractions.m
%
% Purpose:
%     - ensure that pairwise and single growth rates are predicted and
%     correctly interpreted in the function simulatePairwiseInteractions.
%
%       tests the following: if the interaction was interpreted beneficial for
%       one species,the growth rate for the species has to be at least 10% higher
%       in co-growth compared with single growth. If the interaction was
%       interpreted detrimental for one species,the growth rate for the species
%       has to be at least 10% lower in co-growth than in single growth. If the
%       interaction was considered neutral for one species, the growth rate has
%       to differ by less than 10% in co-growth compared with single growth.
%
% Author:
%     - Almut Heinken - March 2017
%     - CI integration - Laurent Heirendt - March 2017
%     - renamed script from testSimulationPairwiseInteractions to
%       testSimulatePairwiseInteractions and adapted to the new module
%       Microbiome_Modeling_Toolbox - Almut Heinken - 02/2018

currentDir = pwd;

fileDir = fileparts(which('testSimulatePairwiseInteractions'));
cd(fileDir);

% if the pairedModelInfo file does not exist yet, build the models first
if ~exist('pairedModelInfo', 'var')
    modelList={
        'Abiotrophia_defectiva_ATCC_49176'
        'Acidaminococcus_fermentans_DSM_20731'
        'Acidaminococcus_intestini_RyC_MR95'
        'Acidaminococcus_sp_D21'
        'Acinetobacter_calcoaceticus_PHEA_2'
        };
    for i=1:length(modelList)
        model = getDistributedModel([modelList{i} '.mat']);
        inputModels{i,1}=model;
    end
    [pairedModels,pairedModelInfo] = joinModelsPairwiseFromList(modelList,inputModels);
end

% define the solver packages to be used to run this test
solverPkgs = {'gurobi', 'tomlab_cplex', 'glpk'};

for p = 1:length(solverPkgs)

    solverOK = changeCobraSolver(solverPkgs{p}, 'LP', 0);

    if solverOK == 1

        fprintf('   Testing simulation of pairwise interactions using %s ... ', solverPkgs{p});
        sigD = 0.1;
        % launch the simulation for pairwise interactions
        [pairwiseInteractions]=simulatePairwiseInteractions(pairedModels,pairedModelInfo,'sigD',sigD);

        for i = 2:size(pairwiseInteractions, 1)
            if strcmp(pairwiseInteractions{i, 8}, 'Competition')
                assert((abs(pairwiseInteractions{i, 6} / pairwiseInteractions{i, 4})) - 1 > sigD)
                assert((abs(pairwiseInteractions{i, 7} / pairwiseInteractions{i, 5})) - 1 > sigD)
                assert(strcmp(pairwiseInteractions{i, 9}, 'Competition'))
                assert(strcmp(pairwiseInteractions{i, 10}, 'Competition'))
            end
            if strcmp(pairwiseInteractions{i, 8}, 'Parasitism_Giver')
                assert((abs(pairwiseInteractions{i, 6} / pairwiseInteractions{i, 4})) - 1 > sigD)
                assert((abs(pairwiseInteractions{i, 5} / pairwiseInteractions{i, 7})) - 1 > sigD)
                assert(strcmp(pairwiseInteractions{i, 9}, 'Parasitism_Taker'))
                assert(strcmp(pairwiseInteractions{i, 10}, 'Parasitism'))
            end
            if strcmp(pairwiseInteractions{i, 8}, 'Parasitism_Taker')
                assert((abs(pairwiseInteractions{i, 4} / pairwiseInteractions{i, 6})) - 1 > sigD)
                assert((abs(pairwiseInteractions{i, 7} / pairwiseInteractions{i, 5})) - 1 > sigD)
                assert(strcmp(pairwiseInteractions{i, 9}, 'Parasitism_Giver'))
                assert(strcmp(pairwiseInteractions{i, 10}, 'Parasitism'))
            end
            if strcmp(pairwiseInteractions{i, 8}, 'Amensalism_Affected')
                assert((abs(pairwiseInteractions{i, 6} / pairwiseInteractions{i, 4})) - 1 > sigD)
                assert(1 - (abs(pairwiseInteractions{i, 5} / pairwiseInteractions{i, 7})) < sigD)
                assert(strcmp(pairwiseInteractions{i, 9}, 'Amensalism_Unaffected'))
                assert(strcmp(pairwiseInteractions{i, 10}, 'Amensalism'))
            end
            if strcmp(pairwiseInteractions{i, 8}, 'Amensalism_Unaffected')
                assert(abs(1 - (pairwiseInteractions{i, 4} / pairwiseInteractions{i, 6})) < sigD)
                assert((abs(pairwiseInteractions{i, 7} / pairwiseInteractions{i, 5})) - 1 > sigD)
                assert(strcmp(pairwiseInteractions{i, 9}, 'Amensalism_Affected'))
                assert(strcmp(pairwiseInteractions{i, 10}, 'Amensalism'))
            end
            if strcmp(pairwiseInteractions{i, 8}, 'Neutralism')
                assert(abs(1 - (pairwiseInteractions{i, 4} / pairwiseInteractions{i, 6})) < sigD)
                assert(abs(1 - (pairwiseInteractions{i, 5} / pairwiseInteractions{i, 7})) < sigD)
                assert(strcmp(pairwiseInteractions{i, 9}, 'Neutralism'))
                assert(strcmp(pairwiseInteractions{i, 10}, 'Neutralism'))
            end
            if strcmp(pairwiseInteractions{i, 8}, 'Commensalism_Taker')
                assert((abs(pairwiseInteractions{i, 4} / pairwiseInteractions{i, 6})) - 1 > sigD)
                assert(abs(1 - (pairwiseInteractions{i, 5} / pairwiseInteractions{i, 7})) < sigD)
                assert(strcmp(pairwiseInteractions{i, 9}, 'Commensalism_Giver'))
                assert(strcmp(pairwiseInteractions{i, 10}, 'Commensalism'))
            end
            if strcmp(pairwiseInteractions{i, 8}, 'Commensalism_Giver')
                assert(abs(1 - (pairwiseInteractions{i, 4} / pairwiseInteractions{i, 6})) < sigD)
                assert((abs(pairwiseInteractions{i, 5} / pairwiseInteractions{i, 7})) - 1 > sigD)
                assert(strcmp(pairwiseInteractions{i, 9}, 'Commensalism_Taker'))
                assert(strcmp(pairwiseInteractions{i, 10}, 'Commensalism'))
            end
            if strcmp(pairwiseInteractions{i, 8}, 'Mutualism')
                assert((abs(pairwiseInteractions{i, 4} / pairwiseInteractions{i, 6})) - 1 > sigD)
                assert((abs(pairwiseInteractions{i, 5} / pairwiseInteractions{i, 7})) - 1 > sigD)
                assert(strcmp(pairwiseInteractions{i, 9}, 'Mutualism'))
                assert(strcmp(pairwiseInteractions{i, 10}, 'Mutualism'))
            end
        end
        % output a success message
        fprintf('Done.\n');
    end
end

% change to the current directory
cd(currentDir)
