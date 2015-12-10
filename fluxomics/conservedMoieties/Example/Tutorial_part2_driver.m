% Runs through Part 2 of tutorial: Effects of variable atom mappings
% between reoccurring metabolite pairs

load Data/DAS.mat % The dopamine synthesis network
rxnfileDir = 'Data/AlternativeAtomMappingFiles/'; % Predicted atom mappings from DREAM (http://selene.princeton.edu/dream/)

% Generate atom transition network
ATN = buildAtomTransitionNetwork(model,rxnfileDir);

% Identify conserved moieties
[L,Lambda,moietyFormulas,moieties2mets,moieties2vectors,atoms2moieties] = identifyConservedMoieties(model,ATN);

% Decompose moiety vectors
rbool = ismember(model.rxns,ATN.rxns); % True for reactions included in ATN
mbool = any(model.S(:,rbool),2); % True for metabolites in ATN reactions
N = model.S(mbool,rbool);

changeCobraSolver('gurobi5','milp');
D = decomposeMoietyVectors(L,N);

% Estimate chemical formulas of decomposed moieties
load Data/elementalMatrix.mat % Load elemental matrix
[decomposedMoietyFormulas,M] = estimateMoietyFormulas(D,E,elements);

% Check results
load Results/part2_reference.mat % saved results for comparison

assert(all(all(ATN.A == ATN0.A)),'Atom transition network does not match reference.')
assert(all(all(L == L0)),'Moiety matrix does not match reference.')
assert(all(all(Lambda == Lambda0)),'Moiety graph does not match reference.')
assert(all(all(D == D0)),'Decomposed moiety matrix does not match reference.')
assert(all(strcmp(decomposedMoietyFormulas,decomposedMoietyFormulas0)),'Estimated formulas of decomposed moieties do not match reference.')

fprintf('Part 2 of tutorial completed successfully.\n\n')
clear ATN0 L0 Lambda0 moietyFormulas0 moieties2mets0 moieties2vectors0 atoms2moieties0 D0 decomposedMoietyFormulas0