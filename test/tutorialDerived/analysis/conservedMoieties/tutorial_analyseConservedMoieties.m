%% Analyse properties of conserved moieties
%% Author(s): Ronan M.T. Fleming, School of Medicine, University of Galway
%% Reviewer(s): 
%% INTRODUCTION
% Given a set of conserved moieties, this tutorial analyses several of its properties.
% 
% 
% 
% These tutorials should generally be used in the following order:
% 
% 1. Initialise and set the paths to inputs and outputs
% 
% COBRA.tutorials/driver_initConservedMoietyPaths.mlx   
% 
% 2. Build an atom transition graph
% 
% tutorial_buildAtomTransitionMultigraph.mlx
% 
% 3. Identify conserved moieties, given an atom transition graph                                               
% 
% tutorial_identifyConservedMoieties.mlx
% 
% 4. Analyse the output of #3
% 
% tutorial_analyseConservedMoieties.mlx 
% 
% 5. Prepare for visualisation of individual conserved moieties (beta)      
% 
% tutorial_visualiseConservedMoieties.mlx
% 
% 

tutorial_initConservedMoietyPaths
if ~recompute
    load([resultsDir  modelName '_ConservedMoietiesAnalysis.mat'])
    return
end
%% 
% Load the atomically resolved models derived from identifyConservedMoieties.m

load([resultsDir modelName '_arm.mat'])
%% 
% Basic properties of atomically resolved models

disp(arm)
%% 
% Load the model, unless it is also saved with the results.

if 0
    load([dataDir modelName '.mat'])
    model = iDopaNeuro;
else
    model=arm.MRH;
end
%% 
% Identify the stoichiometrically consistent subset of the model

massBalanceCheck=0;
printLevel=1;
[SConsistentMetBool, SConsistentRxnBool1, SInConsistentMetBool, SInConsistentRxnBool, unknownSConsistencyMetBool, unknownSConsistencyRxnBool, model]...
    = findStoichConsistentSubset(model,massBalanceCheck,printLevel);
%% 
% Remove non-atom mapped part of the model, but keep the external reactions

keepRxnBool = getCorrespondingCols(arm.MRH.S, arm.MRH.metAtomMappedBool, true(size(arm.MRH.S,2),1), 'inclusive');
keepRxnBool = keepRxnBool & ~SConsistentRxnBool1;
removeRxnBool = ~(arm.MRH.rxnAtomMappedBool | keepRxnBool);
model = removeRxns(arm.MRH, arm.MRH.rxns(removeRxnBool));
%% 
% Identify the stoichiometrically consistent subset of the model

massBalanceCheck=1;
printLevel=1;
[SConsistentMetBool, SConsistentRxnBool2, SInConsistentMetBool, SInConsistentRxnBool, unknownSConsistencyMetBool, unknownSConsistencyRxnBool, model]...
    = findStoichConsistentSubset(model,massBalanceCheck,printLevel);
%% 
% Table of model properties

rankN=getRankLUSOL(arm.MRH.S(arm.MRH.metAtomMappedBool,arm.MRH.rxnAtomMappedBool));
rankL=getRankLUSOL(arm.L);
rankdATM=getRankLUSOL(incidence(arm.dATM));
rankATG=getRankLUSOL(incidence(arm.ATG));
rankMTG=getRankLUSOL(incidence(arm.MTG));

TT={'Model', 'm+'  , 'Metabolites', size(arm.MRH.S,1);
       ''     , 'm'   , 'Mapped metabolites', nnz(arm.MRH.metAtomMappedBool);
   ''     , 'n+'  , 'Reactions', size(arm.MRH.S,2);
   ''     , ''    ,  'Internal reactions', nnz(SConsistentRxnBool1);
   ''     , ''    ,  'External reactions', nnz(~SConsistentRxnBool1);
   ''     , 'n'   , 'Mapped reactions', nnz(arm.MRH.rxnAtomMappedBool);
   'Mapped model'     , 'm'   , 'size(model.S,1)', rankN;
   ''     , 'n+k'   , 'size(model.S,2)', size(model.S,2);
   ''     , ''    ,  'Internal reactions', nnz(SConsistentRxnBool2);
   ''     , ''    ,  'External reactions', nnz(~SConsistentRxnBool2);
   ''     , 'r'   , 'Rank(N)', rankN;
   ''     , 'm-r' , 'Row rank deficiency(N)', nnz(arm.MRH.metAtomMappedBool) - rankN;
   ''     , ''    ,  'Isomorphism classes', size(arm.L,1); 
   ''     , ''    ,  'Independent isomorphism classes', rankL; 
   'MTG'  , ''    ,  'Moieties', size(arm.I2M,2); 
   ''     , ''    ,  'Moiety transitions', size(arm.M2I,1); 
   ''     , ''    ,  'Rank(M)', rankMTG; 
  'ATG'   , ''    ,  'Atoms', size(arm.I2A,2); 
   ''     , ''    ,  'Atom transitions', size(arm.A2I,1); 
   ''     , ''    ,  'Rank(A)', rankATG; 
   ''     , ''    ,  'Row rank deficiency(A)', size(arm.I2A,2) - rankATG;
   ''     , ''    ,  'Components', size(arm.C2A,1); 
'dATM'    , ''    ,  'Atoms', size(arm.dATM.Nodes,1); 
   ''     , ''    ,  'Directed atom transition instances', size(arm.dATM.Edges,1); 
   ''     , ''    ,  'Rank(dATM)', rankdATM; 
   ''     , ''    ,  'Row rank deficiency(dATM)', size(arm.dATM.Edges,1) - rankdATM;
   ''     , ''    ,  '', NaN;  
   };
disp(TT)
%% 
%% Properties of conserved moieties

[moietyMasses, knownmoietyMasses, unknownElements, Ematrix, elements] = getMolecularMass(moietyFormulae);
[metMasses, knownmetMasses, unknownElements, Ematrix, elements] = getMolecularMass(model.metFormulas);
%% 
% Compare the distributions of the molecular moietyMasses

figure
hold on
h = histogram(moietyMasses);
xlabel('mass (AMU)')
ylabel('conserved moiety abundance')
title('Molecular mass of conserved moieties in model')
%%
%h2.BinWidth = 0.25;
figure
moietyIncidence = sum(arm.L~=0,2);
loglog(moietyMasses,moietyIncidence,'.')
title('Conserved moiety mass vs incidence')
xlabel('mass (AMU)')
ylabel('metabolite incidence')
%% 
% The metabolite mass vs mass weighted incidence of moieties in each metabolite 
% should be a straight line trough the origin if all of the moieties that make 
% up a metabolite are present and the formula for the metabolite is correct. Sometimes 
% the metabolite formula is ambiguous, e.g., FULLR in the formula, so the mass 
% will be incorrect.

figure
approxMetMasses = arm.L'*moietyMasses;
plot(metMasses,approxMetMasses,'.')
xlabel('Metabolite mass')
ylabel('Mass weighted incidence of moieties in each metabolite')
massDifference = abs(approxMetMasses-metMasses)./metMasses;
bool=massDifference >0.1;
n=1;
C = cell(nnz(bool),6);
for i=1:size(model.S,1)
    if bool(i)
        C(n,:)={i, massDifference(i),model.mets{i},model.metFormulas{i},metMasses(i),approxMetMasses(i)};
        n=n+1;
    end
end
C=sortrows(C,5,'descend');
T=cell2table(C);
T.Properties.VariableNames={'index','massDifference','mets','metFormula','metMass','approxMetMass'};
disp(T)
%% 
% 
%% 
% Metabolites with mass most similar to the mass of the moiety they contain

[minimalMassMetabolite, minimalMassFraction, numMinimalMassMetabolites] = representativeMolecule(arm.L,moietyFormulae,model.mets);
if ~isfield(model,'metNames')
    model.metNames = model.mets;
end
%% High molecular weight moieties that are present in many metabolites.

massWeightedIncidence=diag(moietyMasses)*arm.L*ones(size(arm.L,2),1);
[massWeightedIncidenceSorted, xi] = sort(massWeightedIncidence,'descend');
bool=false(size(arm.L,1),1);
bool(xi(1:min(length(xi),30)))=1;
C = cell(nnz(bool),9);
n=1;
for i=1:size(arm.L,1)
    if bool(i)
        ind = find(strcmp(minimalMassMetabolite{i},model.mets));
        C(n,1:9) = {i,nnz(arm.L(i,:)),nnz(model.S((arm.L(i,:)~=0)',:)~=0),moietyFormulae{i},moietyMasses(i),minimalMassMetabolite{i},model.metNames{ind},model.metFormulas{ind},minimalMassFraction(i)};
        n=n+1;
    end
end

C=sortrows(C,5,'descend');
T=cell2table(C);
T.Properties.VariableNames={'index','metabolites','rxns','moietyformula','mass','Minimalmassmetabolite','Name','Formula','Massfraction'};
size(T,1)
disp(T)
%% Moieties that are present in a near maximal number of metabolites.

if 1
    bool=moietyIncidence>=mean(moietyIncidence) + std(moietyIncidence);
else
    bool=moietyIncidence>=100;
end
C = cell(nnz(bool),9);
n=1;
for i=1:size(arm.L,1)
    if bool(i)
        ind = find(strcmp(minimalMassMetabolite{i},model.mets));
        C(n,1:9) = {i,nnz(arm.L(i,:)),nnz(model.S((arm.L(i,:)~=0)',:)~=0),moietyFormulae{i},moietyMasses(i),minimalMassMetabolite{i},model.metNames{ind},model.metFormulas{ind},minimalMassFraction(i)};
        n=n+1;
    end
end

C=sortrows(C,2,'descend');
T=cell2table(C);
T.Properties.VariableNames={'index','metabolites','rxns','moietyformula','mass','Minimalmassmetabolite','Name','Formula','Massfraction'};
size(T,1)
disp(T)
%% Moieties that are present in a moderate number of metabolites.

if 1 
    bool= moietyIncidence>=(mean(moietyIncidence)- std(moietyIncidence)) & moietyIncidence<=(mean(moietyIncidence)+ std(moietyIncidence));
else
    bool= moietyIncidence>=10 & moietyIncidence<=100;
end
C = cell(nnz(bool),9);
n=1;
for i=1:size(arm.L,1)
    if bool(i)
        ind = find(strcmp(minimalMassMetabolite{i},model.mets));
        C(n,1:9) = {i,nnz(arm.L(i,:)),nnz(model.S((arm.L(i,:)~=0)',:)~=0),moietyFormulae{i},moietyMasses(i),minimalMassMetabolite{i},model.metNames{ind},model.metFormulas{ind},minimalMassFraction(i)};
        n=n+1;
    end
end

C=sortrows(C,9,'descend');
T=cell2table(C);
T.Properties.VariableNames={'index','metabolites','rxns','moietyformula','mass','Minimalmassmetabolite','Name','Formula','Massfraction'};
size(T,1)
disp(T)
%% Moieties that are present in a small number of metabolites.

bool= moietyIncidence>2 & moietyIncidence<=10;
C = cell(nnz(bool),9);
n=1;
for i=1:size(arm.L,1)
    if bool(i)
        ind = find(strcmp(minimalMassMetabolite{i},model.mets));
        C(n,1:9) = {i,nnz(arm.L(i,:)),nnz(model.S((arm.L(i,:)~=0)',:)~=0),moietyFormulae{i},moietyMasses(i),minimalMassMetabolite{i},model.metNames{ind},model.metFormulas{ind},minimalMassFraction(i)};
        n=n+1;
    end
end

C=sortrows(C,5,'descend');
T=cell2table(C);
T.Properties.VariableNames={'index','metabolites','rxns','moietyformula','mass','Minimalmassmetabolite','Name','Formula','Massfraction'};
size(T,1)
disp(T)
%% Moieties that are present in a minimal number of metabolites.

bool=moietyIncidence==2;
C = cell(nnz(bool),11);
n=1;
for i=1:size(arm.L,1)
    if bool(i)
        ind = find(arm.L(i,:)~=0);
        C(n,1:11) = {i,moietyFormulae{i},moietyMasses(i),model.mets{ind(1)},model.metNames{ind(1)},model.metFormulas{ind(1)},model.mets{ind(2)},model.metNames{ind(2)},model.metFormulas{ind(2)},minimalMassMetabolite{i},minimalMassFraction(i)};
        n=n+1;
    end
end

C=sortrows(C,3,'descend');
T=cell2table(C);
T.Properties.VariableNames={'index','moietyformula','mass','met1','name1','formula1','met2','name2','formula2','Minimalmassmetabolite','Massfraction'};
size(T,1)
disp(T)
%% Classification of conserved moieties

moietyTypes = classifyMoieties(arm.L, model.S);
% An 'Internal' moiety is one that either does not participate in any exchange reaction or is conserved by all exchange reactions

isInternalMoiety = strcmp('Internal',moietyTypes);
bool = isInternalMoiety;
C = cell(nnz(bool),8);
n=1;
for i=1:size(arm.L,1)
    if bool(i)
        ind = find(arm.L(i,:)~=0);
        C(n,1:8) = {i,nnz(arm.L(i,:)),nnz(model.S((arm.L(i,:)~=0)',:)~=0),moietyFormulae{i},moietyMasses(i),model.mets{ind(1)},model.metNames{ind(1)},model.metFormulas{ind(1)}};
        n=n+1;
    end
end

C=sortrows(C,5,'descend');
T=cell2table(C);
T.Properties.VariableNames={'index','metabolites','rxns','moietyformula','mass','Examplemet','Examplename','Exampleformula'};
size(T,1)
disp(T)
% A 'Transitive' moiety is one that is only found in primary metabolites

isTransititiveMoiety= strcmp('Transitive',moietyTypes);
bool = isTransititiveMoiety;
C = cell(nnz(bool),9);
n=1;
for i=1:size(arm.L,1)
    if bool(i)
        ind = find(strcmp(minimalMassMetabolite{i},model.mets));
        C(n,1:9) = {i,nnz(arm.L(i,:)),nnz(model.S((arm.L(i,:)~=0)',:)~=0),moietyFormulae{i},moietyMasses(i),minimalMassMetabolite{i},model.metNames{ind},model.metFormulas{ind},minimalMassFraction(i)};
        n=n+1;
    end
end

C=sortrows(C,9,'descend');
T=cell2table(C);
T.Properties.VariableNames={'index','metabolites','rxns','moietyformula','mass','Minimalmassmetabolite','Name','Formula','Massfraction'};
size(T,1)
disp(T)
% An 'Integrative' moiety is one that is not conserved in the open network and found in both primary and secondary metabolites.

bool= strcmp('Integrative',moietyTypes);
C = cell(nnz(bool),8);
n=1;
for i=1:size(arm.L,1)
    if bool(i)
        ind = find(arm.L(i,:)~=0);
        C(n,1:8) = {i,nnz(arm.L(i,:)),nnz(model.S((arm.L(i,:)~=0)',:)~=0),moietyFormulae{i},moietyMasses(i),model.mets{ind(1)},model.metNames{ind(1)},model.metFormulas{ind(1)}};
        n=n+1;
    end
end

C=sortrows(C,5,'descend');
T=cell2table(C);
T.Properties.VariableNames={'index','metabolites','rxns','moietyformula','mass','Examplemet','Examplename','Exampleformula'};
size(T,1)
disp(T)
%% Mitochondrially localised moieties

[compartments, uniqueCompartments] = getCompartment(model.mets);
isMitochondrial=strcmp('m',compartments);
nnz(isMitochondrial)
isCompletelyMitochondrialMoiety = ~any(arm.L(:,~isMitochondrial),2);
nnz(isCompletelyMitochondrialMoiety)
mitochondrialMoietyFraction = sum(arm.L(:,isMitochondrial),2)./sum(arm.L,2);
figure;
title('Fraction of moiety incidence that is mitochondrial')
hist(mitochondrialMoietyFraction)
bool= mitochondrialMoietyFraction==1;
C = cell(nnz(bool),8);
n=1;
for i=1:size(arm.L,1)
    if bool(i)
        ind = find(arm.L(i,:)~=0);
        C(n,1:8) = {i,nnz(arm.L(i,:)),nnz(model.S((arm.L(i,:)~=0)',:)~=0),moietyFormulae{i},moietyMasses(i),model.mets{ind(1)},model.metNames{ind(1)},model.metFormulas{ind(1)}};
        n=n+1;
    end
end

C=sortrows(C,5,'descend');
T=cell2table(C);
T.Properties.VariableNames={'index','metabolites','rxns','moietyformula','mass','Examplemet','Examplename','Exampleformula'};
size(T,1)
disp(T)
%% 
% Transitive moiety, of sufficient mass, with moderate incidence

isTransititiveMoiety= strcmp('Transitive',moietyTypes);
isModerateIncidence = moietyIncidence>=7 & moietyIncidence<=100;
isSufficientMass = moietyMasses > 2;
isSufficientMinimalMassFraction = minimalMassFraction > 0.1;
bool = isTransititiveMoiety & isModerateIncidence & isSufficientMass & isSufficientMinimalMassFraction;
C = cell(nnz(bool),9);
n=1;
for i=1:size(arm.L,1)
    if bool(i)
        ind = find(strcmp(minimalMassMetabolite{i},model.mets));
        C(n,1:9) = {i,nnz(arm.L(i,:)),nnz(model.S((arm.L(i,:)~=0)',:)~=0),moietyFormulae{i},moietyMasses(i),minimalMassMetabolite{i},model.metNames{ind},model.metFormulas{ind},minimalMassFraction(i)};
        n=n+1;
    end
end

C=sortrows(C,9,'descend');
T=cell2table(C);
T.Properties.VariableNames={'index','metabolites','rxns','moietyformula','mass','Minimalmassmetabolite','Name','Formula','Massfraction'};
size(T,1)
disp(T)
%% Individual moiety subnetwork
% Examine the metabolites and reactions in an individual moiety subnetwork.

ind = min(size(arm.L,1),32);% anth moiety
mBool=arm.L(ind,:)~=0;
nnz(mBool)
rBool = getCorrespondingCols(model.S, mBool, true(size(model.S,2),1), 'inclusive');
nnz(rBool)
%% 
% Metabolites

bool=mBool;
C = cell(nnz(bool),5);
n=1;
for i=1:size(model.S,1)
    if bool(i)
        C(n,1:5) = {i,model.mets{i},model.metNames{i},model.metFormulas{i},metMasses(i)};
        n=n+1;
    end
end
C=sortrows(C,5,'descend');
T=cell2table(C);
T.Properties.VariableNames={'index','met','name','formula','mass'};
disp(T)
%% 
% Reactions

formulas = printRxnFormula(model, model.rxns(rBool));
return
% Another Individual moiety subnetwork
% Specify the index of a particular moiety

ind = min(size(arm.L,1),215);% Nicotinate moiety in iDopaNeuro1.
mBool=arm.L(ind,:)~=0;
nnz(mBool)
rBool = getCorrespondingCols(model.S, mBool, true(size(model.S,2),1), 'inclusive');
nnz(rBool)
%% 
% Metabolites

bool=mBool;
C = cell(nnz(bool),5);
n=1;
for i=1:size(model.S,1)
    if bool(i)
        C(n,1:5) = {i,model.mets{i},model.metNames{i},model.metFormulas{i},metMasses(i)};
        n=n+1;
    end
end
C=sortrows(C,5,'descend');
T=cell2table(C);
T.Properties.VariableNames={'index','met','name','formula','mass'};
disp(T)
%% 
% Reactions

formulas = printRxnFormula(model, model.rxns(rBool));
%% 
% Save analysis results

save([resultsDir  modelName '_ConservedMoietiesAnalysis.mat'])
%% _Acknowledgments_
% Co-funded by the European Union's Horizon Europe Framework Programme (101080997)
%% REFERENCES
%% 
% # Ghaderi, S., Haraldsdóttir, H. S., Ahookhosh, M., Arreckx, S., & Fleming, 
% R. M. T. (2020). Structural conserved moiety splitting of a stoichiometric matrix. 
% Journal of Theoretical Biology, 499, 110276. <https://doi.org/10.1016/j.jtbi.2020.110276 
% https://doi.org/10.1016/j.jtbi.2020.110276>
% # Rahou, H., Haraldsdóttir, H. S., Martinelli, F., Thiele, I., & Fleming, 
% R. M. T. (2026). Characterisation of conserved and reacting moieties in chemical 
% reaction networks. Journal of Theoretical Biology, 112348. <https://doi.org/10.1016/j.jtbi.2025.112348 
% https://doi.org/10.1016/j.jtbi.2025.112348>