% Runs through Part 1 of tutorial: Identification of conserved moieties in
% the dopamine synthesis network DAS

load Data/DAS.mat % The dopamine synthesis network
rxnfileDir = 'Data/AtomMappingFiles/'; % Manually edited atom mappings

% Generate atom transition network
ATN = buildAtomTransitionNetwork(model,rxnfileDir);

% Identify conserved moieties
tic
[L,Lambda,moietyFormulas,moieties2mets,moieties2vectors,atoms2moieties] = identifyConservedMoieties(model,ATN);
t = toc;

fprintf('Computation time: %.1e s\n\n', t); % Print computation time

% Classify moieties
types = classifyMoieties(L,model.S);

% Check results
load Results/part1_reference.mat % saved results for comparison

assert(all(all(ATN.A == ATN0.A)),'Atom transition network does not match reference.')
assert(all(all(L == L0)),'Moiety matrix does not match reference.')
assert(all(all(Lambda == Lambda0)),'Moiety graph does not match reference.')
assert(all(strcmp(types,types0)),'Moiety classifications do not match reference.')

fprintf('Part 1 of tutorial completed successfully.\n\n')
clear ATN0 L0 Lambda0 moietyFormulas0 moieties2mets0 moieties2vectors0 atoms2moieties0 types0
