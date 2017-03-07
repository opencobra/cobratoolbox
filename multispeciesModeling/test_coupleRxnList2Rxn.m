
%% test coupling constraints
load('Ecoli_core_model.mat');
% remove ATPM constraint so no infeasible model is generated
modelEcore=changeRxnBounds(modelEcore,'ATPM',0,'l');
% couple E. coli reactions (except exchanges and biomass) to biomass
rxnC='Biomass_Ecoli_core_w_GAM';
rxnList=modelEcore.rxns(find(~strncmp('EX_',modelEcore.rxns,3)));
rxnList(strmatch('Biomass',rxnList),:)=[];
c=400;
u=0.01;
[modelCoupled]=coupleRxnList2Rxn(modelEcore,rxnList,rxnC,c,u);
% test if the coupling constraints work
% expected that the absolute flux through one reaction cannot be higher than (flux
% through rxnC*c)+u
% constrain flux through rxnC to a random value between 0.01
% and 0.1
constrFlux=rand*0.1;
solverOK=changeCobraSolver('glpk','LP');
modelCoupled=changeRxnBounds(modelCoupled,rxnC,constrFlux,'u');
% optimize a random coupled reaction 100 times
for i=1:100
rxnInd=rxnList{randi(length(rxnList),1),1};
modelCoupled=changeObjective(modelCoupled,rxnInd);
solution=solveCobraLPCPLEX(modelCoupled,2,0,0,[],0);
% solution=solveCobraLP(modelCoupled)
assert(abs(solution.obj) <= (constrFlux*c)+u)
end

% now do the same test for the uncoupled model-should fail
modelEcore=changeRxnBounds(modelEcore,rxnC,constrFlux,'u');
for i=1:100
rxnInd=rxnList{randi(length(rxnList),1),1};
modelEcore=changeObjective(modelEcore,rxnInd);
solution=solveCobraLPCPLEX(modelEcore,2,0,0,[],0);
assert(abs(solution.obj) <= (constrFlux*c)+u)
end

