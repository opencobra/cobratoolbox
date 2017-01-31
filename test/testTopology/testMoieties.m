% Test code to identify conserved moieties in metabolic networks by graph
% theoretical analysis of atom transition networks.

load ../../tutorials/moieties/Data/DAS.mat % The dopamine synthesis network
rxnfileDir = '../../tutorials/moieties/Data/AlternativeAtomMappingFiles/'; % Predicted atom mappings from DREAM (http://selene.princeton.edu/dream/)

% Generate atom transition network
ATN = buildAtomTransitionNetwork(model,rxnfileDir);

% Identify conserved moieties
[L,Lambda,moietyFormulas,moieties2mets,moieties2vectors,atoms2moieties] = identifyConservedMoieties(model,ATN);

% Classify moieties
types = classifyMoieties(L,model.S);

% Decompose moiety vectors
rbool = ismember(model.rxns,ATN.rxns); % True for reactions included in ATN
mbool = any(model.S(:,rbool),2); % True for metabolites in ATN reactions
N = model.S(mbool,rbool);

changeCobraSolver('gurobi6','milp');
D = decomposeMoietyVectors(L,N);

% Estimate chemical formulas of decomposed moieties
load ../../tutorials/moieties/Data/elementalMatrix.mat % Load elemental matrix
[decomposedMoietyFormulas,M] = estimateMoietyFormulas(D,E,elements);

% Check results
load moietyResults.mat % saved results for comparison

assert(all(all(ATN.A == ATN0.A)),'Atom transition network does not match reference.')
assert(all(all(L == L0)),'Moiety matrix does not match reference.')
assert(all(all(Lambda == Lambda0)),'Moiety graph does not match reference.')
assert(all(strcmp(types,types0)),'Moiety classifications do not match reference.')
assert(all(all(D == D0)),'Decomposed moiety matrix does not match reference.')
assert(all(strcmp(decomposedMoietyFormulas,decomposedMoietyFormulas0)),'Estimated formulas of decomposed moieties do not match reference.')