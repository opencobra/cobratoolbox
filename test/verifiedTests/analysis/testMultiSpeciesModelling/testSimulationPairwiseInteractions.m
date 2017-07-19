% The COBRAToolbox: testSimulationPairwiseInteractions.m
%
% Purpose:
%     - ensure that the pairwise and single growth rates predicted in script
%       SimulationPairwiseInteractions were interpreted correctly by the script
%       analyzePairwiseInteractions
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
%

currentDir = pwd;

fileDir = fileparts(which('testSimulationPairwiseInteractions'));
cd(fileDir);

% if the pairedModelsList file does not exist yet, build the models first
if exist('pairedModelsList.mat', 'file') ~= 2
    buildPairwiseModels;
end

% define the solver packages to be used to run this test
solverPkgs = {'gurobi6', 'tomlab_cplex', 'glpk'};

for p = 1:length(solverPkgs)

    solverOK = changeCobraSolver(solverPkgs{p}, 'LP', 0);

    if solverOK == 1

        fprintf('   Testing simulation pairwise interactions using %s ... ', solverPkgs{p});

        % launch the simulation for pairwise interactions
        simulationPairwiseInteractions;

        sigD = 0.1;
        for k = 1:length(conditions)
            load(strcat('pairedGrowthResults_', conditions{k}));
            for i = 2:size(pairedGrowthResults, 1)
                if strcmp(pairedGrowthResults{i, 10}, 'Competition')
                    assert((abs(pairedGrowthResults{i, 8} / pairedGrowthResults{i, 6})) - 1 > sigD)
                    assert((abs(pairedGrowthResults{i, 9} / pairedGrowthResults{i, 7})) - 1 > sigD)
                    assert(strcmp(pairedGrowthResults{i, 11}, 'Competition'))
                    assert(strcmp(pairedGrowthResults{i, 12}, 'Competition'))
                end
                if strcmp(pairedGrowthResults{i, 10}, 'ParasitismGiver')
                    assert((abs(pairedGrowthResults{i, 8} / pairedGrowthResults{i, 6})) - 1 > sigD)
                    assert((abs(pairedGrowthResults{i, 7} / pairedGrowthResults{i, 9})) - 1 > sigD)
                    assert(strcmp(pairedGrowthResults{i, 11}, 'ParasitismTaker'))
                    assert(strcmp(pairedGrowthResults{i, 12}, 'Parasitism'))
                end
                if strcmp(pairedGrowthResults{i, 10}, 'ParasitismTaker')
                    assert((abs(pairedGrowthResults{i, 6} / pairedGrowthResults{i, 8})) - 1 > sigD)
                    assert((abs(pairedGrowthResults{i, 9} / pairedGrowthResults{i, 7})) - 1 > sigD)
                    assert(strcmp(pairedGrowthResults{i, 11}, 'ParasitismGiver'))
                    assert(strcmp(pairedGrowthResults{i, 12}, 'Parasitism'))
                end
                if strcmp(pairedGrowthResults{i, 10}, 'AmensalismNegAff')
                    assert((abs(pairedGrowthResults{i, 8} / pairedGrowthResults{i, 6})) - 1 > sigD)
                    assert(1 - (abs(pairedGrowthResults{i, 7} / pairedGrowthResults{i, 9})) < sigD)
                    assert(strcmp(pairedGrowthResults{i, 11}, 'AmensalismUnaff'))
                    assert(strcmp(pairedGrowthResults{i, 12}, 'Amensalism'))
                end
                if strcmp(pairedGrowthResults{i, 10}, 'AmensalismUnaff')
                    assert(abs(1 - (pairedGrowthResults{i, 6} / pairedGrowthResults{i, 8})) < sigD)
                    assert((abs(pairedGrowthResults{i, 9} / pairedGrowthResults{i, 7})) - 1 > sigD)
                    assert(strcmp(pairedGrowthResults{i, 11}, 'AmensalismNegAff'))
                    assert(strcmp(pairedGrowthResults{i, 12}, 'Amensalism'))
                end
                if strcmp(pairedGrowthResults{i, 10}, 'Neutralism')
                    assert(abs(1 - (pairedGrowthResults{i, 6} / pairedGrowthResults{i, 8})) < sigD)
                    assert(abs(1 - (pairedGrowthResults{i, 7} / pairedGrowthResults{i, 9})) < sigD)
                    assert(strcmp(pairedGrowthResults{i, 11}, 'Neutralism'))
                    assert(strcmp(pairedGrowthResults{i, 12}, 'Neutralism'))
                end
                if strcmp(pairedGrowthResults{i, 10}, 'CommensalismTaker')
                    assert((abs(pairedGrowthResults{i, 6} / pairedGrowthResults{i, 8})) - 1 > sigD)
                    assert(abs(1 - (pairedGrowthResults{i, 7} / pairedGrowthResults{i, 9})) < sigD)
                    assert(strcmp(pairedGrowthResults{i, 11}, 'CommensalismGiver'))
                    assert(strcmp(pairedGrowthResults{i, 12}, 'Commensalism'))
                end
                if strcmp(pairedGrowthResults{i, 10}, 'CommensalismGiver')
                    assert(abs(1 - (pairedGrowthResults{i, 6} / pairedGrowthResults{i, 8})) < sigD)
                    assert((abs(pairedGrowthResults{i, 7} / pairedGrowthResults{i, 9})) - 1 > sigD)
                    assert(strcmp(pairedGrowthResults{i, 11}, 'CommensalismTaker'))
                    assert(strcmp(pairedGrowthResults{i, 12}, 'Commensalism'))
                end
                if strcmp(pairedGrowthResults{i, 10}, 'Mutualism')
                    assert((abs(pairedGrowthResults{i, 6} / pairedGrowthResults{i, 8})) - 1 > sigD)
                    assert((abs(pairedGrowthResults{i, 7} / pairedGrowthResults{i, 9})) - 1 > sigD)
                    assert(strcmp(pairedGrowthResults{i, 11}, 'Mutualism'))
                    assert(strcmp(pairedGrowthResults{i, 12}, 'Mutualism'))
                end
            end
        end

        % output a success message
        fprintf('Done.\n');
    end
end

% change to the current directory
cd(currentDir)
