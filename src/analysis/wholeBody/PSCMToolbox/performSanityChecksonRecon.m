function [TableChecks, Table_csources, CSourcesTestedRxns, TestSolutionNameOpenSinks,TestSolutionNameClosedSinks] = performSanityChecksonRecon(model,resultsFileName,ExtraCellCompIn,ExtraCellCompOut,runSingleGeneDeletion)
% This function performs various quality control and quality assurance
% tests.
% [TableChecks, Table_csources, CSourcesTestedRxns, TestSolutionNameOpenSinks,TestSolutionNameClosedSinks] = performSanityChecksonRecon(model,resultsFileName,ExtraCellCompIn,ExtraCellCompOut,runSingleGeneDeletion)
%
% INPUT
% model                         model structure
% resultsFileName               File name of the generated output file 
% ExtraCellCompIn               [e] compartment by default, if extracellular
%                               uptake compartment is named differently, it
%                               can be specified here
% ExtraCellCompOut              [e] compartment by default, if extracellular
%                               secretion compartment is named differently, it
%                               can be specified here
% runSingleGeneDeletion         if 0 (default): function does not run single gene deletion otw choose 1
%
% OUTPUT
% TableChecks                   Table overview of the performed tests and
%                               their outcomes
% Table_csources                Table the test results for ATP yield from
%                               various carbon scources under aerobic and anaerobic conditions
% CSourcesTestedRxns            List of reactions active when testing the ATP
%                               yield from the various carbon sources

% TestSolutionNameOpenSinks     List of results when testing for 460 metabolic
%                               functions with all sinks open
% TestSolutionNameClosedSinks   List of results when testing for 460 metabolic
%                               functions with all sinks closed
%
% Ines Thiele 2016-2019 

global resultsPath
resultsPath = which('MethodSection3.mlx');
resultsPath = strrep(resultsPath,'MethodSection3.mlx',['Results' filesep]);

if ~exist([resultsPath 'OrganChecks'],'dir')
    mkdir([resultsPath 'OrganChecks'])
end

if ~exist('ExtraCellCompIn','var')
    ExtraCellCompIn = '[e]'; % [e] compartment by default
end
if ~exist('ExtraCellCompOut','var')
    ExtraCellCompOut = '[e]'; % [e] compartment by default
end

if ~exist('runSingleGeneDeletion','var')
    runSingleGeneDeletion = 0; % do not run single gene deletion by default
end

global saveDiary
if saveDiary
    %save each diary to PSCM/Results/OrganChecks/
    global resultsPath
    resultsPath = which('MethodSection3.mlx');
    resultsPath = strrep(resultsPath,'MethodSection3.mlx',['Results' filesep]);
    resultsFileName=[resultsFileName '_diary'];
    diary([resultsPath 'OrganChecks' filesep resultsFileName])
end

% if 1
%     changeCobraSolver('tomlab_cplex','lp');
%     changeCobraSolver('tomlab_cplex','qp');
% end
cnt = 1;
tol = 1e-6;

model.rxns(find(ismember(model.rxns,'ATPM')))={'DM_atp_c_'};
model.rxns(find(ismember(model.rxns,'ATPhyd')))={'DM_atp_c_'};
% adds DM_atp to model if not exist

if isempty(strmatch('DM_atp_c_',model.rxns))
    [model, rxnIDexists] = addReaction(model,'DM_atp_c_', 'reactionFormula', 'h2o[c] + atp[c]  -> adp[c] + h[c] + pi[c] ');
end

model.rxns(find(ismember(model.rxns,'EX_biomass_reaction')))={'biomass_reaction'};
model.rxns(find(ismember(model.rxns,'EX_biomass_maintenance')))={'biomass_maintenance'};
model.rxns(find(ismember(model.rxns,'EX_biomass_maintenance_noTrTr')))={'biomass_maintenance_noTrTr'};
model.lb(find(ismember(model.rxns,'biomass_reaction')))=0;
model.lb(find(ismember(model.rxns,'biomass_maintenance_noTrTr')))=0;
model.lb(find(ismember(model.rxns,'biomass_maintenance')))=0;


TestSolutionNameOpenSinks ='';
TestSolutionNameClosedSinks = '';

model.rxns = regexprep(model.rxns,'\(','\[');
model.rxns = regexprep(model.rxns,'\)','\]');
% vanilla leak test

if 1
    modelClosed = model;
    LeakTestRecon;
    TableChecks{cnt,1} = 'fastLeakTest 1';
    if length(LeakMets)>0
        warning('model leaks metabolites!')
        TableChecks{cnt,2} = 'Model leaks metabolites!';
    else
        TableChecks{cnt,2} = 'Leak free!';
    end
    cnt = cnt + 1;
end

if 0
    % test if something leaks when demand are added
    modelClosed = model;
    modelexchanges1 = strmatch('Ex_',modelClosed.rxns);
    modelexchanges4 = strmatch('EX_',modelClosed.rxns);
    modelexchanges2 = strmatch('DM_',modelClosed.rxns);
    modelexchanges3 = strmatch('sink_',modelClosed.rxns);
    selExc = (find( full((sum(abs(modelClosed.S)==1,1) ==1) & (sum(modelClosed.S~=0) == 1))))';
    
    modelexchanges = unique([modelexchanges1;modelexchanges2;modelexchanges3;modelexchanges4;selExc]);
    modelClosed.lb(find(ismember(modelClosed.rxns,modelClosed.rxns(modelexchanges))))=0;
    [modelClosed,rxnNames] = addDemandReaction(modelClosed,modelClosed.mets);
    
    [LeakRxns,modelTested] = fastLeakTest(modelClosed,modelClosed.rxns(selExc));
    
    TableChecks{cnt,1} = 'fastLeakTest 2 - add demand reactions for each metabolite in the model';
    if length(LeakMets)>0
        TableChecks{cnt,2} = 'Model leaks metabolites when demand reactions are added!';
    else
        TableChecks{cnt,2} = 'Leak free when demand reactions are added!';
    end
    cnt = cnt + 1;
end

if 1
    %%model produces energy from water!
    modelClosed = model;
    
    modelexchanges1 = strmatch('Ex_',modelClosed.rxns);
    modelexchanges4 = strmatch('EX_',modelClosed.rxns);
    modelexchanges2 = strmatch('DM_',modelClosed.rxns);
    modelexchanges3 = strmatch('sink_',modelClosed.rxns);
    selExc = (find( full((sum(abs(modelClosed.S)==1,1) ==1) & (sum(modelClosed.S~=0) == 1))))';
    
    modelexchanges = unique([modelexchanges1;modelexchanges2;modelexchanges3;modelexchanges4;selExc]);
    modelClosed.lb(find(ismember(modelClosed.rxns,modelClosed.rxns(modelexchanges))))=0;
    modelClosedATP = changeObjective(modelClosed,'DM_atp_c_');
    modelClosedATP = changeRxnBounds(modelClosedATP,'DM_atp_c_',0,'l');
    modelClosedATP = changeRxnBounds(modelClosedATP,strcat('EX_h2o',ExtraCellCompIn),-1,'l');
    FBA3=optimizeCbModel(modelClosedATP);
    TableChecks{cnt,1} = 'Exchanges, sinks, and demands have  lb = 0, except h2o';
    if abs(FBA3.f) > 1e-6
        TableChecks{cnt,2} = 'model produces energy from water!';
    else
        TableChecks{cnt,2} = 'model DOES NOT produce energy from water!';
    end
    cnt = cnt + 1;
end
%% model produces energy from water and oxygen!
if 1
    modelClosed = model;
    modelexchanges1 = strmatch('Ex_',modelClosed.rxns);
    modelexchanges4 = strmatch('EX_',modelClosed.rxns);
    modelexchanges2 = strmatch('DM_',modelClosed.rxns);
    modelexchanges3 = strmatch('sink_',modelClosed.rxns);
    selExc = (find( full((sum(abs(modelClosed.S)==1,1) ==1) & (sum(modelClosed.S~=0) == 1))))';
    
    modelexchanges = unique([modelexchanges1;modelexchanges2;modelexchanges3;modelexchanges4;selExc]);
    modelClosed.lb(find(ismember(modelClosed.rxns,modelClosed.rxns(modelexchanges))))=0;
    modelClosedATP = changeObjective(modelClosed,'DM_atp_c_');
    modelClosedATP = changeRxnBounds(modelClosedATP,'DM_atp_c_',0,'l');
    modelClosedATP = changeRxnBounds(modelClosedATP,strcat('EX_h2o',ExtraCellCompIn),-1,'l');
    modelClosedATP = changeRxnBounds(modelClosedATP,strcat('EX_o2',ExtraCellCompIn),-1,'l');
    
    FBA6=optimizeCbModel(modelClosedATP);
    TableChecks{cnt,1} = 'Exchanges, sinks, and demands have  lb = 0, except h2o and o2';
    if abs(FBA6.f) > 1e-6
        TableChecks{cnt,2} = 'model produces energy from water and oxygen!';
    else
        TableChecks{cnt,2} = 'model DOES NOT produce energy from water and oxygen!';
    end
    cnt = cnt + 1;
end
%% model produces matter when atp demand is reversed!
if 1
    modelClosed = model;
    modelexchanges1 = strmatch('Ex_',modelClosed.rxns);
    modelexchanges4 = strmatch('EX_',modelClosed.rxns);
    modelexchanges2 = strmatch('DM_',modelClosed.rxns);
    modelexchanges3 = strmatch('sink_',modelClosed.rxns);
    selExc = (find( full((sum(abs(modelClosed.S)==1,1) ==1) & (sum(modelClosed.S~=0) == 1))))';
    
    modelexchanges = unique([modelexchanges1;modelexchanges2;modelexchanges3;modelexchanges4;selExc]);
    modelClosed.lb(find(ismember(modelClosed.rxns,modelClosed.rxns(modelexchanges))))=0;
    
    modelClosed = changeObjective(modelClosed,'DM_atp_c_');
    modelClosed.lb(find(ismember(modelClosed.rxns,'DM_atp_c_'))) = -1000;
    modelClosed.ub(selExc)=1000;
    FBA = optimizeCbModel(modelClosed);
    TableChecks{cnt,1} = 'Exchanges, sinks, and demands have  lb = 0, allow DM_atp_c_ to be reversible';
    if abs(FBA.f) > 1e-6
        TableChecks{cnt,2} = 'model produces matter when atp demand is reversed!';
    else
        TableChecks{cnt,2} = 'model DOES NOT produce matter when atp demand is reversed!';
    end
    cnt = cnt + 1;
end
%% model has flux through h[m] demand !
if 1
    modelClosed = model;
    modelexchanges1 = strmatch('Ex_',modelClosed.rxns);
    modelexchanges4 = strmatch('EX_',modelClosed.rxns);
    modelexchanges2 = strmatch('DM_',modelClosed.rxns);
    modelexchanges3 = strmatch('sink_',modelClosed.rxns);
    selExc = (find( full((sum(abs(modelClosed.S)==1,1) ==1) & (sum(modelClosed.S~=0) == 1))))';
    
    modelexchanges = unique([modelexchanges1;modelexchanges2;modelexchanges3;modelexchanges4;selExc]);
    modelClosed.lb(find(ismember(modelClosed.rxns,modelClosed.rxns(modelexchanges))))=0;
    modelClosed = addDemandReaction(modelClosed,'h[m]');
    modelClosed = changeObjective(modelClosed,'DM_h[m]');
    modelClosed.ub(find(ismember(modelClosed.rxns,'DM_h[m]'))) = 1000;
    modelClosed.ub(selExc)=1000;
    FBA = optimizeCbModel(modelClosed,'max');
    TableChecks{cnt,1} = 'Exchanges, sinks, and demands have  lb = 0, test flux through DM_h[m] (max)';
    if abs(FBA.f) > 1e-6
        TableChecks{cnt,2} = 'model has flux through h[m] demand (max)!';
    else
        TableChecks{cnt,2} = 'model has NO flux through h[m] demand (max)!';
    end
    cnt = cnt + 1;
end
if 0
    modelClosed = model;
    modelexchanges1 = strmatch('Ex_',modelClosed.rxns);
    modelexchanges4 = strmatch('EX_',modelClosed.rxns);
    modelexchanges2 = strmatch('DM_',modelClosed.rxns);
    modelexchanges3 = strmatch('sink_',modelClosed.rxns);
    selExc = (find( full((sum(abs(modelClosed.S)==1,1) ==1) & (sum(modelClosed.S~=0) == 1))))';
    
    modelexchanges = unique([modelexchanges1;modelexchanges2;modelexchanges3;modelexchanges4;selExc]);
    modelClosed.lb(find(ismember(modelClosed.rxns,modelClosed.rxns(modelexchanges))))=0;
    modelClosed = addDemandReaction(modelClosed,'h[m]');
    modelClosed = changeObjective(modelClosed,'DM_h[m]');
    modelClosed.ub(find(ismember(modelClosed.rxns,'DM_h[m]'))) = 1000;
    modelClosed.lb(find(ismember(modelClosed.rxns,'DM_h[m]'))) = -1000;
    modelClosed.ub(selExc)=1000;
    FBA = optimizeCbModel(modelClosed,'min');
    TableChecks{cnt,1} = 'Exchanges, sinks, and demands have  lb = 0, test flux through DM_h[m] (min)';
    if abs(FBA.f) > 1e-6
        TableChecks{cnt,2} = 'model has flux through h[m] demand (min)!';
    else
        TableChecks{cnt,2} = 'model has NO flux through h[m] demand (min)!';
    end
    cnt = cnt + 1;
end
%% model has flux through h[c] demand !
if 1
    modelClosed = model;
    modelexchanges1 = strmatch('Ex_',modelClosed.rxns);
    modelexchanges4 = strmatch('EX_',modelClosed.rxns);
    modelexchanges2 = strmatch('DM_',modelClosed.rxns);
    modelexchanges3 = strmatch('sink_',modelClosed.rxns);
    selExc = (find( full((sum(abs(modelClosed.S)==1,1) ==1) & (sum(modelClosed.S~=0) == 1))))';
    
    modelexchanges = unique([modelexchanges1;modelexchanges2;modelexchanges3;modelexchanges4;selExc]);
    modelClosed.lb(find(ismember(modelClosed.rxns,modelClosed.rxns(modelexchanges))))=0;
    modelClosed = addDemandReaction(modelClosed,'h[c]');
    modelClosed = changeObjective(modelClosed,'DM_h[c]');
    modelClosed.ub(find(ismember(modelClosed.rxns,'DM_h[c]'))) = 1000;
    modelClosed.ub(selExc)=1000;
    FBA = optimizeCbModel(modelClosed,'max');
    TableChecks{cnt,1} = 'Exchanges, sinks, and demands have  lb = 0, test flux through DM_h[c] (max)';
    if abs(FBA.f) > 1e-6
        TableChecks{cnt,2} = 'model has flux through h[c] demand (max)!';
    else
        TableChecks{cnt,2} = 'model has NO flux through h[c] demand (max)!';
    end
    cnt = cnt + 1;
end
if 1
    modelClosed = model;
    modelexchanges1 = strmatch('Ex_',modelClosed.rxns);
    modelexchanges4 = strmatch('EX_',modelClosed.rxns);
    modelexchanges2 = strmatch('DM_',modelClosed.rxns);
    modelexchanges3 = strmatch('sink_',modelClosed.rxns);
    selExc = (find( full((sum(abs(modelClosed.S)==1,1) ==1) & (sum(modelClosed.S~=0) == 1))))';
    
    modelexchanges = unique([modelexchanges1;modelexchanges2;modelexchanges3;modelexchanges4;selExc]);
    modelClosed.lb(find(ismember(modelClosed.rxns,modelClosed.rxns(modelexchanges))))=0;
    modelClosed = addDemandReaction(modelClosed,'h[c]');
    modelClosed = changeObjective(modelClosed,'DM_h[c]');
    modelClosed.ub(find(ismember(modelClosed.rxns,'DM_h[c]'))) = 1000;
    modelClosed.lb(find(ismember(modelClosed.rxns,'DM_h[c]'))) = -1000;
    modelClosed.ub(selExc)=1000;
    modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_h',ExtraCellCompOut)))) = 0;
    FBA = optimizeCbModel(modelClosed,'min');
    TableChecks{cnt,1} = 'Exchanges, sinks, and demands have  lb = 0, ub of EX_h[e] = 0, test flux through DM_h[c] (min)';
    if abs(FBA.f) > 1e-6
        TableChecks{cnt,2} = 'model has flux through h[c] demand (min)!';
    else
        TableChecks{cnt,2} = 'model has NO flux through h[c] demand (min)!';
    end
    cnt = cnt + 1;
end
%% model produces too much atp demand from glc -- old remove
if 0
    modelClosed = model;
    modelexchanges1 = strmatch('Ex_',modelClosed.rxns);
    modelexchanges4 = strmatch('EX_',modelClosed.rxns);
    modelexchanges2 = strmatch('DM_',modelClosed.rxns);
    modelexchanges3 = strmatch('sink_',modelClosed.rxns);
    selExc = (find( full((sum(abs(modelClosed.S)==1,1) ==1) & (sum(modelClosed.S~=0) == 1))))';
    
    modelexchanges = unique([modelexchanges1;modelexchanges2;modelexchanges3;modelexchanges4;selExc]);
    modelClosed.lb(find(ismember(modelClosed.rxns,modelClosed.rxns(modelexchanges))))=0;
    modelClosed.c = zeros(length(modelClosed.rxns),1);
    modelClosed = changeObjective(modelClosed,'DM_atp_c_');
    modelClosed.lb(find(ismember(modelClosed.rxns,strcat('EX_o2',ExtraCellCompIn)))) = -1000;
    modelClosed.lb(find(ismember(modelClosed.rxns,strcat('EX_h2o',ExtraCellCompIn)))) = -1000;
    modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_h2o',ExtraCellCompOut)))) = 1000;
    modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_co2',ExtraCellCompOut)))) = 1000;
    %modelClosed.lb(find(ismember(modelClosed.rxns,'EX_pi[e]'))) = -1000;
    %modelClosed = addExchangeRxn(modelClosed,{'glc_D[e]'});
    modelClosed.lb(find(ismember(modelClosed.rxns,strcat('EX_glc_D',ExtraCellCompIn)))) = -1;
    modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_glc_D',ExtraCellCompIn)))) = -1;
    
    modelClosed.ub(selExc)=1000;
    %    FBA = optimizeCbModel(modelClosed,'max',1e-6);
    FBA = optimizeCbModel(modelClosed,'max');
    
    TableChecks{cnt,1} = 'ATP yield ';
    if abs(FBA.f) > 1e-6
        FBA.f
        %  modelClosed = changeObjective(modelClosed,'ATPS4m');
        %  FBA = optimizeCbModel(modelClosed,'max',1e-6);
        FBA.x(find(ismember(modelClosed.rxns,'ATPS4m')))
        % prepare table

        warning('model produces too much atp demand from glc!');
    else
        warning('model DOES NOT produce too much atp demand from glc!');
    end
    
    
end

TableChecks{cnt,1} = 'Test metabolic objective functions with open sinks';
if 1 % perform test function
    [TestSolution,TestSolutionNameOpenSinks, TestedRxnsSinks, PercSinks] = Test4HumanFctExtv5(model,'all');
    TableChecks{cnt,2} = strcat('Done. See variable TestSolutionNameOpenSinks for results. The model passes ', num2str(length(find(abs(TestSolution)>tol))),' out of ', num2str(length(TestSolution)), 'tests');
else
    TableChecks{cnt,2} = 'Not performed.';
end
cnt =  cnt + 1;

TableChecks{cnt,1} = 'Test metabolic objective functions with closed sinks (lb)';
if 0 % perform test functions
    [TestSolution,TestSolutionNameClosedSinks, TestedRxnsClosedSinks, PercClosedSinks] = Test4HumanFctExtv5(model,'all',0);
    TableChecks{cnt,2} = strcat('Done. See variable TestSolutionNameClosedSinks for results. The model passes ', num2str(length(find(abs(TestSolution)>tol))),' out of ', num2str(length(TestSolution)), 'tests');
else
    TableChecks{cnt,2} = 'Not performed.';
end
cnt =  cnt + 1;

TableChecks{cnt,1} = 'Compute ATP yield';
if 1 % test ATP yield
    [Table_csources, CSourcesTestedRxns, Perc] = testATPYieldFromCsources(model,[],ExtraCellCompIn,ExtraCellCompOut);
    TableChecks{cnt,2} = 'Done. See variable Table_csources for results.';
else
    TableChecks{cnt,2} = 'Not performed.';
    CSourcesTestedRxns = '';
end
cnt = cnt + 1;

TableChecks{cnt,1} = 'Check duplicated reactions';
if 0
    method='FR';
    removeFlag=0;
    [modelOut,removedRxnInd, keptRxnInd] = checkDuplicateRxn(model,method,removeFlag);
    if isempty(removedRxnInd)
        TableChecks{cnt,2} = 'No duplicated reactions in model.';
    else
        TableChecks{cnt,2} = 'Duplicated reactions in model.';
    end
else
    TableChecks{cnt,2} = 'Not performed.';
end
cnt = cnt + 1;

TableChecks{cnt,1} = 'Check empty columns in rxnGeneMat';
if 1
    E = find(sum(model.rxnGeneMat)==0);
    if isempty(E)
        TableChecks{cnt,2} = 'No empty columns in rxnGeneMat.';
    else
        TableChecks{cnt,2} = 'Empty columns in rxnGeneMat.';
    end
else
    TableChecks{cnt,2} = 'Not performed.';
end
cnt = cnt + 1;

TableChecks{cnt,1} = 'Check that demand reactions have a lb >= 0';
if 1
    DMlb = find(model.lb(strmatch('DM_',model.rxns))<0);
    if isempty(DMlb)
        TableChecks{cnt,2} = 'No demand reaction can have flux in backward direction.';
    else
        TableChecks{cnt,2} = 'Demand reaction can have flux in backward direction.';
    end
else
    TableChecks{cnt,2} = 'Not performed.';
end
cnt = cnt + 1;

TableChecks{cnt,1} = 'Check consistency of model.rev with model.lb';
if 1
    Rev = setdiff(find(model.lb<0), find(model.rev==1));
    if isempty(Rev)
        TableChecks{cnt,2} = 'model.rev and model.lb are consistent.';
    else
        TableChecks{cnt,2} = 'model.rev and model.lb are NOT consistent.';
    end
else
    TableChecks{cnt,2} = 'Not performed.';
end
cnt = cnt + 1;

TableChecks{cnt,1} = 'Check whether singleGeneDeletion runs smoothly';
if runSingleGeneDeletion == 1
    try
        [grRatio,grRateKO,grRateWT,hasEffect,delRxns,fluxSolution] = singleGeneDeletion(model);
        TableChecks{cnt,2} = 'singleGeneDeletion finished without problems.';
    catch
        TableChecks{cnt,2} = 'There are problems with singleGeneDeletion.';
    end
else
    TableChecks{cnt,2} = 'Not performed.';
end
cnt = cnt + 1;

TableChecks{cnt,1} = 'Check for flux consistency';
if 0
    param.epsilon=getCobraSolverParams('LP', 'feasTol')*100;
    param.modeFlag=0;
    %param.method='null_fastcc';
    %param.method='fastcc';
    printLevel = 1;
    [fluxConsistentMetBool,fluxConsistentRxnBool,fluxInConsistentMetBool,fluxInConsistentRxnBool,model] = findFluxConsistentSubset(model,param,printLevel)
    if isempty(find(fluxInConsistentRxnBool))
        TableChecks{cnt,2} = 'Model is flux consistent.';
    else
        TableChecks{cnt,2} = 'Model is NOT flux consistent';
    end
else
    TableChecks{cnt,2} = 'Not performed.';
end
cnt = cnt + 1;


save([resultsPath 'OrganChecks' filesep resultsFileName,'.mat'],'TableChecks', 'Table_csources', 'CSourcesTestedRxns', 'TestSolutionNameOpenSinks','TestSolutionNameClosedSinks');

if saveDiary
    diary off;
end
