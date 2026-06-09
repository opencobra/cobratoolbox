% The COBRA Toolbox: testrFastcormics.m
%
% Purpose:
%     - test rFastcormics function
%
% Authors:
%     - Vanille Lejal, University of Luxembourg, June 2026

% required toolboxes and solvers
solvers = prepareTest('needsLP', true, 'requireOneSolverOf', {'gurobi','ibm_cplex'}, 'requiredToolboxes', {'statistics_toolbox'});

% check presence of curvefit
assert(~isempty(ver('curvefit')), 'Curve Fitting Toolbox not found');

% initiate a model for testing
reactionFormulas = {'A -> 2 B', '2 B -> C', 'G -> F', 'F -> 2 B', '2 B -> D', 'D -> E', ...
                    'H <=> 2 B', 'A <=>', 'G <=>', 'C ->', 'H <=>', 'E ->'};
reactionNames = {'v1', 'v2', 'v3', 'v4', 'v5', 'v6', 'v7', 'Ex1', 'Ex2', 'Ex3', 'Ex4', 'Ex5'};
geneNames = {'Gene1', 'Gene2', 'Gene3', 'Gene4', 'Gene5', 'Gene6', 'Gene7', 'GeneEx1', 'GeneEx2', 'GeneEx3', 'GeneEx4', 'GeneEx5'};
model = createModel(reactionNames, reactionNames, reactionFormulas, 'grRuleList', geneNames);

% check model consistency
% A = fastcc(model, 1e-4, 2); % A contains the indexes of reactions kept in the consistent model
% assert(all(A == model));

% set an objective function
model = changeObjective(model, 'Ex5');

% create a discretized matrix for testing
% -1 for inactive reactions (non-expressed genes), 1 for core reactions (expressed genes), 0 for non-core reactions.
discretized = [1; -1; 0; 0; 0; 0; 1; 0; 0; 1; 0; 0];

% create expected context specific model
%expectedReactionFormulas = {'A -> 2 B', '2 B -> D', 'D -> E', 'H <=> 2 B', 'A <=>', 'H <=>', 'E ->'};
expectedReactionNames = {'v1', 'v5', 'v6', 'v7', 'Ex1', 'Ex4', 'Ex5'};
%expectedGeneNames = {'Gene1', 'Gene5', 'Gene6', 'Gene7','GeneEx1', 'GeneEx4', 'GeneEx5'};
%expectedModel = createModel(expectedReactionNames, expectedReactionNames, expectedReactionFormulas, 'grRuleList', expectedGeneNames);
%expectedModel = changeObjective(expectedModel, 'Ex5');
%expectedModel.rev = [0; 0; 0; 1; 1; 1; 0]; % field added in rFastcormics

% initialize required inputs
rownames = model.genes;
dico = table(model.genes, model.genes);
biomass = 'Ex5';

for k = 1:length(solvers.LP)
    % checking with each accepted solver
    solverLPOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);

    % run rFastcormics
    [~, retainedReactions] = rFastcormics(model, discretized, rownames, dico, biomass);

    % compare output with expected model
    assert(isequal(model.rxns(retainedReactions), expectedReactionNames'));
end






