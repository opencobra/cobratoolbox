%% Component contribution: analysis of updated method applied to Recon3D
%% *Author: Ronan Fleming,* School of Medicine, University of Galway
%% *Reviewers:* 
%% 
% 
%% INTRODUCTION
%% PROCEDURE
%% Configure the environment
% All the installation instructions are in a separate .md file named vonBertalanffy.md 
% in docs/source/installation
% 
% With all dependencies installed correctly, we configure our environment, verfy 
% all dependencies, and add required fields and directories to the matlab path.

aPath = which('initVonBertalanffy');
basePath = strrep(aPath,'vonBertalanffy/initVonBertalanffy.m','');
addpath(genpath(basePath))
folderPattern=[filesep 'old'];
method = 'remove';
editCobraToolboxPath(basePath,folderPattern,method)
aPath = which('initVonBertalanffy');
basePath = strrep(aPath,'vonBertalanffy/initVonBertalanffy.m','');
addpath(genpath(basePath))
folderPattern=[filesep 'new'];
method = 'add';
editCobraToolboxPath(basePath,folderPattern,method)
%%
initVonBertalanffy
%% 
% Load data input for component contribution method

load('data_prior_to_componentContribution')
%% Component Contribution
% Run component contribution method

param.debug = 1;
[model,solution] = componentContribution(model,combinedModel,param);
%% Comparison of weighting of reactant and group contribution for training metabolites

X = combinedModel.S;
XR = solution.PR_St*X;
XN = solution.PN_St*X;
XNR = (solution.PN_St - solution.PN_StGGt)*X;
XNN = solution.PN_StGGt*X;
%% 
% Check that the decomposition into different components is complete

norm(X - (XR + XN),'inf')
norm(XN - (XNR + XNN),'inf')
norm(X - (XR + XNR + XNN),'inf')
%% 
% Stoichiometric degree

dX = diag(X*X');
fprintf('%u%s\n',nnz(dX),' metabolites with non-zero training stoichiometric degree')
fprintf('%u%s\n',nnz(dX==0),' metabolites with zero training stoichiometric degree')
dXR = diag(XR*XR');
fprintf('%u%s\n',nnz(dXR),' metabolites with non-zero training stoichiometric degree, in the range of S''')
fprintf('%u%s\n',nnz(dXR==0),' metabolites with zero training stoichiometric degree, in the range of S''')
dXN = diag(XN*XN');
fprintf('%u%s\n',nnz(dXN),' metabolites with non-zero training stoichiometric degree, in the nullspace of S''')
fprintf('%u%s\n',nnz(dXN==0),' metabolites with zero training stoichiometric degree, in the nullspace of S''')
dXNR = diag(XNR*XNR');
fprintf('%u%s\n',nnz(dXNR),' metabolites with non-zero training stoichiometric degree, in the nullspace of S'' and G''x in the range of G''S')
fprintf('%u%s\n',nnz(dXNR==0),' metabolites with zero training stoichiometric degree, in the nullspace of S'' and G''x in the range of G''S')
dXNN = diag(XNN*XNN');
fprintf('%u%s\n',nnz(dXNN),' metabolites with non-zero training stoichiometric degree, in the nullspace of S'' and in the nullspace of S''GG'' ')
fprintf('%u%s\n',nnz(dXNN==0),' metabolites with zero training stoichiometric degree, in the nullspace of S'' and in the nullspace of S''GG'' ')
%%
norm(dX - (dXR + dXN),'inf')
norm(dXN - (dXNR + dXNN),'inf')

norm(dX - (dXR + dXNR + dXNN),'inf')
norm(dX.^2 - (dXR.^2 + dXNR.^2 + dXNN.^2),'inf')
%% 
% Sort by stoichiometric degree of reactant contribution (for each metabolite)

dXtotal = dXR + dXNR + dXNN;
Y = [dXR./dXtotal,dXNR./dXtotal,dXNN./dXtotal];
[dXRsorted,xi]=sort(dXR./dXtotal,'descend');
figure
bar(Y(xi,:),'stacked')
ylim([0 1])
title('Stoichiometric contributions to $\Delta_{f} G^{0}_{cc}$','Interpreter','latex')
xlabel('Metabolites, sorted by stoic. degree of reactant contribution')
ylabel('stoichiometric degree')
legend({'reactant','group','unconstrained group'})
Y = [dXNR./dXtotal,dXR./dXtotal,dXNN./dXtotal];
[~,xi]=sort(dXNR./dXtotal,'descend');
figure
bar(Y(xi,:),'stacked')
ylim([0 1])
title('Stoichiometric contributions to $\Delta_{f} G^{0}_{cc}$','Interpreter','latex')
xlabel('Metabolites, sorted by stoic. degree of (constrained) group contribution')
ylabel('stoichiometric degree')
legend({'group','reactant','unconstrained group'})
Y = [dXNN./dXtotal,dXNR./dXtotal,dXR./dXtotal];
[~,xi]=sort(dXNN./dXtotal,'descend');
figure
bar(Y(xi,:),'stacked')
ylim([0 1])
title('Stoichiometric contributions to $\Delta_{f} G^{0}_{cc}$','Interpreter','latex')
xlabel('Metabolites, sorted by stoic. degree of (unconstrained) group contribution')
ylabel('stoichiometric degree')
legend({'unconstrained group','group','reactant'})
%% Analyse reactant contribution

figure
histogram(solution.DfG0_rc(~solution.unconstrainedDfG0_rc))
title('$\textrm{Reactant contribution } \Delta_{f} G^{0}_{rc}$','Interpreter','latex')
ylabel('(KJ/Mol)')
nCombinedMet=size(combinedModel.S,1);
fprintf('%u%s\n',nCombinedMet,' formation energies')
fprintf('%u%s\n',nnz(solution.unconstrainedDfG0_rc),' of which DfG0_rc are unconstrained. i.e., number of formation energies that cannot be determined by reactant contribution')
fprintf('%g%s\n',nnz(solution.unconstrainedDfG0_rc)/nCombinedMet,' = fraction of DfG0 unconstrained by reactant contribution.')
figure
histogram(solution.DfG0_rc_Uncertainty(~solution.unconstrainedDfG0_rc))
title('Reactant contribution uncertainty')
ylabel('#Metabolites')
xlabel('Uncertainty in $\Delta_{f} G^{0}_{rc}$  ((KJ/Mol))','Interpreter','latex')
fprintf('%g%s\n',nnz(solution.DfG0_rc_Uncertainty==0 & ~solution.unconstrainedDfG0_rc),' number of zero uncertainty in constrained DfG0_rc')
fprintf('%g%s\n',nnz(solution.DfG0_rc_Uncertainty==0 & solution.unconstrainedDfG0_rc),' number of zero uncertainty in unconstrained DfG0_rc')
figure;
histogram(solution.e_rc(~solution.unconstrainedDfG0_rc))
text(-30,700,{['MSE = ' num2str(solution.MSE_rc)],['MAE = ' num2str(solution.MAE_rc)]});
title('Reactant contribution residual')
xlabel('((KJ/Mol))');
ylabel('# Experimental reactions')
%% 
% Experiments contributing the largest to residuals in the reactant contribution 
% method

 [rcErrorSorted,rcSI]=sort(solution.e_rc);
 N=10;
 for i=1:N
     rxnFormula = printRxnFormula(combinedModel,'rxnAbbrList',combinedModel.rxns(rcSI(i)),'printFlag',0);
     fprintf('%g\t%s\t%s\n',solution.e_rc(rcSI(i)),combinedModel.rxns{rcSI(i)},rxnFormula{1});
 end
%% Analyse group contribution

 figure
 histogram(solution.DfG0_gc(~solution.unconstrainedDfG0_gc))
 title('Constrained group formation energies')
xlabel('$\Delta_{f} G^{0}_{gc}$ (KJ/Mol)','Interpreter','latex')
ylabel('#Constrained Moieties')
figure
histogram(solution.DfG0_gc(solution.DfG0_gc~=0 & ~solution.unconstrainedDfG0_gc))
title('Nonzero, constrained group formation energies')
xlabel('$\Delta_{f} G^{0}_{gc}$ (KJ/Mol)','Interpreter','latex')
ylabel('#Nonzero constrained Moieties')
%%
nGroups =size(combinedModel.G,2);
fprintf('%u%s\n',nGroups,' estimated group formation energies')
 fprintf('%u%s\n',nnz(solution.unconstrainedDfG0_gc),' of which DfG0_gc(j) is unconstrained. i.e., group formation energies not constrained by group contribution')
 fprintf('%g%s\n',nnz(solution.unconstrainedDfG0_gc)/nGroups,' fraction of unconstrained DfG0_gc')
figure
histogram(solution.DfG0_gc_Uncertainty(~solution.unconstrainedDfG0_gc))
title('Uncertainty in group contribution')
ylabel('#Constrained Moieties')
xlabel('$\Delta_{f} G^{0}_{gc}$ (KJ/Mol)','Interpreter','latex')
fprintf('%g%s\n',nnz(solution.DfG0_gc_Uncertainty==0 & ~solution.unconstrainedDfG0_gc),' number of zero uncertainty in constrained DfG0_gc')
fprintf('%g%s\n',nnz(solution.DfG0_gc_Uncertainty==0 & solution.unconstrainedDfG0_gc),' number of zero uncertainty in unconstrained DfG0_gc')
fprintf('%g%s\n',max(solution.DfG0_gc_Uncertainty),' maximum uncertainty for any group.')
%% 
% Analyse the number of metabolites with different numbers of unconstrained 
% Moieties

 nUnconstrainedGroupsPerMet = combinedModel.G*solution.unconstrainedDfG0_gc;
 figure
 histogram(nUnconstrainedGroupsPerMet,'BinWidth',1)
 xlabel('#Moieties unconstrained')
 ylabel('#Metabolites')
%% 
% Conclusion: most metabolites only have one or two unconstrained Moieties.  

fprintf('%u%s\n',nnz(nUnconstrainedGroupsPerMet==0),' metabolites have no unconstrained moieties')
fprintf('%u%s\n',nnz(nUnconstrainedGroupsPerMet),' metabolites have at least one unconstrained moiety')
%%
figure;
histogram(solution.e_gc)
title('Group contribution residual')
xlabel('(KJ/Mol)');
ylabel('# Experimental reactions')
text(-30,800,{['MSE = ' num2str(solution.MSE_gc)],['MAE = ' num2str(solution.MAE_gc)]});
%%
[gcErrorSorted,gcSI]=sort(solution.e_gc);
 N=10;
 for i=1:N
     rxnFormula = printRxnFormula(combinedModel,'rxnAbbrList',combinedModel.rxns(gcSI(i)),'printFlag',0);
     fprintf('%g\t%s\t%s\n',solution.e_gc(rcSI(i)),combinedModel.rxns{gcSI(i)},rxnFormula{1});
 end
%%
 figure;
 histogram(solution.e_m)
 title('Group contribution modelling error')
 xlabel('(KJ/Mol)');
 ylabel('# Experimental reactions')
 text(-30,800,{['MSE = ' num2str(solution.MSE_m)],['MAE = ' num2str(solution.MAE_m)]});
%% Analyse component contribution

figure
histogram(solution.DfG0_cc(~solution.unconstrainedDfG0_cc))
title('Component contribution')
ylabel('#Metabolites')
xlabel('$\Delta_{f} G^{0}_{cc}$ (KJ/Mol)','Interpreter','latex')
fprintf('%u%s\n',length(solution.DfG0_cc),' estimated reactant formation energies.')
fprintf('%u%s\n',nnz(solution.unconstrainedDfG0_cc),' of which DfG0_cc are partially unconstrained by component contribution')
fprintf('%g%s\n',nnz(solution.unconstrainedDfG0_cc)/length(solution.unconstrainedDfG0_cc),' = fraction of partially unconstrained DfG0_cc')
%% 
% Uncertainty in component contribution

figure
histogram(solution.DfG0_cc_Uncertainty(~solution.unconstrainedDfG0_cc))
title('Uncertainty in component contribution')
ylabel('#Metabolites')
xlabel('$\Delta_{f} G^{0}_{gc}$ (KJ/Mol)','Interpreter','latex')
fprintf('%g%s\n',nnz(solution.DfG0_cc_Uncertainty==0 & ~solution.unconstrainedDfG0_cc),' number of zero uncertainty in constrained DfG0_cc')
fprintf('%g%s\n',nnz(solution.DfG0_cc_Uncertainty==0 & solution.unconstrainedDfG0_cc),' number of zero uncertainty in unconstrained DfG0_cc')
figure
histogram(solution.DfG0_cc_Uncertainty(solution.unconstrainedDfG0_cc))
title('Uncertainty in component contribution') 
ylabel('#Partially constrained Metabolites')
xlabel('$\Delta_{f} G^{0}_{gc}$ (KJ/Mol)','Interpreter','latex')
%% 
% Breakdown of contributions to uncertainty in component contribution. Bar graph, 
% with one bar for each reaction (row of the matrix). The height of each bar is 
% the sum of the uncertainties in the reaction (row).

figure
Y = [solution.DfG0_cc_inf_Uncertainty,solution.DfG0_cc_gc_Uncertainty,solution.DfG0_rc_Uncertainty];
%% 
% Sort by uncertainty in reactant contribution (for each metabolite)

[~,xi]=sort(solution.DfG0_rc_Uncertainty);
bar(Y(xi(solution.DfG0_rc_Uncertainty(xi)~=0),:),'stacked')
title('Contributions to uncertainty in $\Delta_{f} G^{0}_{cc}$','Interpreter','latex')
xlabel('Metabolites, sorted by uncertainty in $\Delta_{f} G^{0}_{cc(rc)}$ (KJ/Mol)','Interpreter','latex')
ylabel('(KJ/Mol)')
legend({'$\Delta_{f} G^{0}_{cc(inf)}$','$\Delta_{f} G^{0}_{cc(gc)}$','$\Delta_{f} G^{0}_{cc(rc)}$'},'Interpreter','latex')
%% 
% Sort by uncertainty in group contribution (for each metabolite)

[~,xi]=sort(solution.DfG0_cc_gc_Uncertainty);
bar(Y(xi,:),'stacked')
title('Contributions to uncertainty in $\Delta_{f} G^{0}_{cc}$','Interpreter','latex')
xlabel('Metabolites, sorted by uncertainty in $\Delta_{f} G^{0}_{cc(gc)}$ (KJ/Mol)','Interpreter','latex')
ylabel('(KJ/Mol)')
legend({'$\Delta_{f} G^{0}_{cc(inf)}$','$\Delta_{f} G^{0}_{cc(gc)}$','$\Delta_{f} G^{0}_{cc(rc)}$'},'Interpreter','latex')
%% 
% Component contribution model fitting residual

figure;
histogram(solution.e_cc)
text(-30,600,{['MSE = ' num2str(solution.MSE_cc)],['MAE = ' num2str(solution.MAE_cc)]});
title('Component contribution model fitting residual')
xlabel('(KJ/Mol)')
ylabel('#Metabolites')
%%
 [ccErrorSorted,ccSI]=sort(solution.e_cc);
 N=10;
 for i=1:N
     rxnFormula = printRxnFormula(combinedModel,'rxnAbbrList',combinedModel.rxns(ccSI(i)),'printFlag',0);
     fprintf('%g\t%s\t%s\n',solution.e_cc(ccSI(i)),combinedModel.rxns{ccSI(i)},rxnFormula{1});
 end
%% Comparison of weighting of reactant and group contribution for test metabolites

clear X
X(combinedModel.test2CombinedModelMap,:) = model.S;
XR = solution.PR_St*X;
XN = solution.PN_St*X;
XNR = (solution.PN_St - solution.PN_StGGt)*X;
XNN = solution.PN_StGGt*X;
%% 
% Check that the decomposition into different components is complete

norm(X - (XR + XNR + XNN),'inf')
%% 
% Stoichiometric degree

dX = diag(X*X');
fprintf('%u%s\n',nnz(dX),' metabolites with non-zero test stoichiometric degree')
fprintf('%u%s\n',nnz(dX==0),' metabolites with zero test stoichiometric degree')
dXR = diag(XR*XR');
fprintf('%u%s\n',nnz(dX),' metabolites with non-zero test stoichiometric degree, in the range of S''')
fprintf('%u%s\n',nnz(dX==0),' metabolites with zero test stoichiometric degree, in the range of S''')
dXN = diag(XN*XN');
fprintf('%u%s\n',nnz(dXN),' metabolites with non-zero test stoichiometric degree, in the nullspace of S''')
fprintf('%u%s\n',nnz(dXN==0),' metabolites with zero test stoichiometric degree, in the nullspace of S''')
dXNR = diag(XNR*XNR');
fprintf('%u%s\n',nnz(dXNR),' metabolites with non-zero test stoichiometric degree, in the nullspace of S'' and G''x in the range of G''S')
fprintf('%u%s\n',nnz(dXNR==0),' metabolites with zero test stoichiometric degree, in the nullspace of S'' and G''x in the range of G''S')
dXNN = diag(XNN*XNN');
fprintf('%u%s\n',nnz(dXNN),' metabolites with non-zero test stoichiometric degree, in the nullspace of S'' and in the nullspace of S''GG'' ')
fprintf('%u%s\n',nnz(dXNN==0),' metabolites with zero test stoichiometric degree, in the nullspace of S'' and in the nullspace of S''GG'' ')
%% 
% Sort by stoichiometric degree of reactant contribution (for each metabolite)

dXtotal = dXR + dXNR + dXNN;
Y = [dXR./dXtotal,dXNR./dXtotal,dXNN./dXtotal];
[dXRsorted,xi]=sort(dXR,'descend');
figure
bar(Y(xi,:),'stacked')
ylim([0 1])
title('Stoichiometric contributions to $\Delta_{f} G^{0}_{cc}$','Interpreter','latex')
xlabel('Metabolites, sorted by stoic. degree of reactant contribution')
ylabel('stoichiometric degree')
legend({'reactant','group','unconstrained group'})
Y = [dXNR./dXtotal,dXR./dXtotal,dXNN./dXtotal];
[~,xi]=sort(dXNR./dXtotal,'descend');
figure
bar(Y(xi,:),'stacked')
ylim([0 1])
title('Stoichiometric contributions to $\Delta_{f} G^{0}_{cc}$','Interpreter','latex')
xlabel('Metabolites, sorted by stoic. degree of (constrained) group contribution')
ylabel('stoichiometric degree')
legend({'group','reactant','unconstrained group'})
Y = [dXNN./dXtotal,dXNR./dXtotal,dXR./dXtotal];
[~,xi]=sort(dXNN./dXtotal,'descend');
figure
bar(Y(xi,:),'stacked')
ylim([0 1])
title('Stoichiometric contributions to $\Delta_{f} G^{0}_{cc}$','Interpreter','latex')
xlabel('Metabolites, sorted by stoic. degree of (unconstrained) group contribution')
ylabel('stoichiometric degree')
legend({'unconstrained group','group','reactant'})
%% Analyse reacting moieties in the test model

transportRxnBool = transportReactionBool(model);
model.G=combinedModel.G(combinedModel.test2CombinedModelMap,:);
StG=model.S'*model.G;
bool = model.SIntRxnBool & ~transportRxnBool;
figure
spy(StG(bool,:))
xlabel([int2str(size(StG(bool,:),2)) ' Moieties'])
ylabel([int2str(size(StG(bool,:),1)) ' non-transport internal reactions'])
nReactingMoieties=full(sum(StG~=0,2));
histogram(nReactingMoieties(bool),'BinWidth',2)
title('Number of Reacting Moieties per reaction')
xlabel('#Reacting Moieties')
ylabel('#Reactions')
%%
fprintf('%u%s\n',nnz(nReactingMoieties==0 & bool),' internal non-transport reactions without reacting moieties.')
printRxnFormula(model,model.rxns(bool & nReactingMoieties==0));
%%
AtG=(model.S~=0)'*model.G;
spy(AtG)
nInvolvedMoieties=full(sum(AtG~=0,2));
bool = model.SIntRxnBool & ~transportRxnBool;
plot(nReactingMoieties(bool),nInvolvedMoieties(bool),'.')
xlabel('# Reacting moieties')
ylabel('# Involved moieties')
title('#Reacting vs #Involved Moieties per reaction')
%%
nRxnsMoietiesInvolved=full(sum(AtG(bool,:)~=0,1)');
nRxnsMoietiesReacting=full(sum(StG(bool,:)~=0,1)');
figure
hold on
plot(nRxnsMoietiesReacting,nRxnsMoietiesInvolved,'.')
plot(nRxnsMoietiesReacting(solution.unconstrainedDfG0_gc),nRxnsMoietiesInvolved(solution.unconstrainedDfG0_gc),'.r')
hold off
xlabel('# Rxns per reacting moiety')
ylabel('# Rxns per involved moiety')
title('#Reaction occurence for reacting vs involved moieties')
%% 
% Moieties reacting in a lot of reactions but unconstrained by group contribution

T = table(combinedModel.groups(nRxnsMoietiesReacting>1000 & solution.unconstrainedDfG0_gc),nRxnsMoietiesReacting(nRxnsMoietiesReacting>1000 & solution.unconstrainedDfG0_gc),'VariableNames',{'Reacting_Moiety','#Reactions'});
disp(T)
nConsumedMoieties=sum(StG<0,2);
nProducedMoieties=sum(StG>0,2);
plot(nConsumedMoieties,nProducedMoieties,'.')
xlabel('# Consumed moieties')
ylabel('# Produced moieties')
title('#Consumed vs #Produced Moieties per reaction')
%% Reaction Component contribution taking into account reacting moieties only

nnz(solution.unconstrainedDfG0_cc)

bool = model.SIntRxnBool & ~transportRxnBool;
fprintf('%u%s\n',nnz(bool),' internal non-transport reactions.')
fprintf('%u%s\n',nnz(model.unconstrainedDrG0_cc & bool),' of which have unconstrained DrG0.')
ind=find(model.unconstrainedDrG0_cc & bool);
%% Estimated standard reaction Gibbs energy

 figure;
 bool = model.SIntRxnBool & ~transportRxnBool & ~model.unconstrainedDrG0_cc;
 histogram(model.DrG0(bool))
 title('Internal, non-transport reaction component contribution estimates')
 ylabel('#Reactions')
 xlabel('$\Delta_{f} G^{0}_{cc}$ (KJ/Mol)','Interpreter','latex')
 figure;
 bool = model.SIntRxnBool & ~transportRxnBool & ~model.unconstrainedDrG0_cc;
 histogram(model.DrG0_Uncertainty(bool))
 title('Internal, non-transport reaction component contribution estimates')
 ylabel('#Reactions')
 xlabel('Uncertainty in $\Delta_{f} G^{0}_{cc}$ (KJ/Mol)','Interpreter','latex')
%% 
%% Estimated standard metabolite Gibbs energy vs molecular mass

figure
[metMasses, knownMasses, unknownElements, Ematrix, elements] = getMolecularMass(model.metFormulas);
%%
plot(metMasses(~model.unconstrainedDfG0_cc),model.DfG0(~model.unconstrainedDfG0_cc),'.')
xlabel('Molecular mass')
ylabel('$\Delta_{f} G^{0}_{cc}$ (KJ/Mol)','Interpreter','latex')
%% Estimated standard reaction Gibbs energy vs bonds broken and formed

inputFolder = ['~' filesep 'work' filesep 'sbgCloud' filesep 'programExperimental' filesep 'projects' filesep 'xomics' filesep 'data' filesep 'Recon3D_301'];
BBFmodel = load([inputFolder filesep 'Recon3DModel_301_thermo_BBF.mat']);
%BBFmodel = load('~/work/sbgCloud/programExperimental/projects/xomics/data/Recon3D_301/Recon3DModel_301_thermo_BBF');
BBFmodel=BBFmodel.model;
%%
model.transportRxnBool = transportReactionBool(model);
bool = ~model.unconstrainedDrG0_cc & model.SIntRxnBool & ~model.transportRxnBool;
DfG0_cc = solution.DfG0_cc(combinedModel.test2CombinedModelMap);
DrG0_cc = model.S'*DfG0_cc;
figure
plot(DrG0_cc(bool),BBFmodel.bondsBF(bool),'.')
ylabel('Bonds Broken+Formed')
xlabel('$\Delta_{r} G^{0}_{cc}$ (KJ/Mol)','Interpreter','latex')

plot(DrG0_cc(bool),BBFmodel.bondsE(bool),'.') 
ylabel('Bond Enthalpy')
xlabel('$\Delta_{r} G^{0}_{cc}$ (KJ/Mol)','Interpreter','latex')
% unconstrainedDfG0_cc = model.S
% 
% %DfG0_cc = PR_St * DfG0_rc + PN_St * G * DfG0_gc;
% DfG0_cc = PR_St * DfG0_rc + PN_St * G * DfG0_gc;
% model.PR_St=solution.PR_St(combinedModel.test2CombinedModelMap,:);
% model.PN_St=solution.PN_St(combinedModel.test2CombinedModelMap,:);
% DrG0_rc = model.S'*model.PR_St*solution.DfG0_rc + model.S'*model.PN_St * solution.G * solution.DfG0_gc;
% 
% %identify the component contribution estimates that are unconstrained
% reactantContUnconstrainedDfG0_cc = (PR_St * unconstrainedDfG0_rc)~=0;
% groupContUnconstrainedDfG0_cc = (PN_St * G * unconstrainedDfG0_gc)~=0;
% unconstrainedDfG0_cc = (PR_St * unconstrainedDfG0_rc + PN_St * G * unconstrainedDfG0_gc)~=0;
%% 
% 

% DrG0_cc = model.S'*model.PR_St*solution.DfG0_rc + model.S'*model.PN_St * solution.G * solution.DfG0_gc;
%% 
%