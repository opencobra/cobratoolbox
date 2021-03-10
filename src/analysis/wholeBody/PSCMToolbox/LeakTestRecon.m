
%changeCobraSolver('tomlab_cplex','lp');
%modelClosed = modelConsistent;
clear FF R
% add demands for all metabolites in Recon
%modelClosed = model;
%modelClosed = addDemandReaction(modelClosed,modelClosed.mets);

modelexchanges1 = strmatch('Ex_',modelClosed.rxns);
modelexchanges4 = strmatch('EX_',modelClosed.rxns);
modelexchanges2 = strmatch('DM_',modelClosed.rxns);
modelexchanges3 = strmatch('sink_',modelClosed.rxns);
selExc = (find( full((sum(abs(modelClosed.S)==1,1) ==1) & (sum(modelClosed.S~=0) == 1))))';

modelexchanges = unique([modelexchanges1;modelexchanges2;modelexchanges3;modelexchanges4;selExc]);
modelClosed.lb(ismember(modelClosed.rxns,modelClosed.rxns(modelexchanges)))=0;
%modelClosed.ub(find(ismember(modelClosed.rxns,modelClosed.rxns(modelexchanges))))=0;

[LeakMets,modelClosed] = fastLeakTest(modelClosed, modelClosed.rxns(modelexchanges),0);
