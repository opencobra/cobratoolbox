% Computes conserved moieties in the dopamine synthesis network DAS, by
% analysis of the corresponding atom transition network.

load Data/DAS.mat % The dopamine synthesis network
rxnFileDir = 'Data/AtomMappingFiles/'; % Predicted atom mappings from DREAM (http://selene.princeton.edu/dream/)
% rxnFileDir = 'Data/AlternativeAtomMappingFiles/'; % Manually edited atom mappings
intRxnBool = model.SIntRxnBool; % A logical array indicating internal reactions

% Generate atom transition network
tic
ATN = buildAtomTransitionNetwork(model.S,rxnFileDir,model.mets,model.rxns,model.lb,model.ub,intRxnBool);
t1 = toc;

save Results/DopamineATN.mat ATN

% Compute moiety vectors
tic
[L,M,comp_mat,xi,xj] = computeConservedMoieties(model.S,model.mets,intRxnBool,ATN.A,ATN.mets,ATN.reverseBool);
t2 = toc;

save Results/conservedMoietyMatrix.mat L
save Results/nonconservedMoietyMatrix.mat M
save Results/components.mat comp_mat
save Results/xi.mat xi
save Results/xj.mat xj

% Decompose moiety vectors if possible
tic
D = decomposeMoieties(L,model.S,intRxnBool);
t3 = toc;

save Results/conservedMoietyMatrix_decomposed.mat D

fprintf('\nbuildAtomTransitionNetwork: %.1e s = %.1e min\n', t1, t1/60);
fprintf('findConservedMoieties: %.1e s = %.1e min\n', t2, t2/60);
fprintf('Total: %.1e s = %.1e min\n\n', t1 + t2, (t1 + t2)/60);

fprintf('decomposeMoieties: %.1e s = %.1e min\n', t3, t3/60);
