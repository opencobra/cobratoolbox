%% Apply component contribution method and analyse solution
%% *Author: Ronan Fleming, Leiden University*
%% *Reviewers:* 
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
%% 
% Run component contribution method

 param.debug = 1;
 [model,solution] = componentContribution(model,combinedModel,param);
 
%%
 figure;
 histogram(solution.e_rc)
  text(-30,700,{['MSE = ' num2str(solution.MSE_rc)],['MAE = ' num2str(solution.MAE_rc)]});
 title('Reactant contribution model fitting residual')
 ylabel('KJ/Mol')
%%
 [rcErrorSorted,rcSI]=sort(solution.e_rc);
 N=10;
 for i=1:N
     rxnFormula = printRxnFormula(combinedModel,'rxnAbbrList',combinedModel.rxns(rcSI(i)),'printFlag',0);
     fprintf('%g\t%s\t%s\n',solution.e_rc(rcSI(i)),combinedModel.rxns{rcSI(i)},rxnFormula{1});
 end
%%
 [gcErrorSorted,gcSI]=sort(solution.e_gc);
 figure;
 histogram(solution.e_gc)
 title('Sorted group contribution model fitting residual')
 ylabel('KJ/Mol');
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
 histogram(solution.e_cc)
  text(-30,600,{['MSE = ' num2str(solution.MSE_cc)],['MAE = ' num2str(solution.MAE_cc)]});
 title('Component contribution model fitting residual')
 ylabel('KJ/Mol')
%%
 [rcErrorSorted,ccSI]=sort(solution.e_cc);
 N=10;
 for i=1:N
     rxnFormula = printRxnFormula(combinedModel,'rxnAbbrList',combinedModel.rxns(ccSI(i)),'printFlag',0);
     fprintf('%g\t%s\t%s\n',solution.e_cc(rcSI(i)),combinedModel.rxns{ccSI(i)},rxnFormula{1});
 end
%%
DfG0_gc = solution.DfG0_gc(solution.DfG0_gc~=0);
 DfG0_gc_sorted = sort(DfG0_gc);
 figure;
 plot(DfG0_gc_sorted,'.')
 title('Sorted nonzero $\Delta_{f} G^{0}_{gc}$','Interpreter','latex')