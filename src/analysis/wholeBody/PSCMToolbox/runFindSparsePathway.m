function [tablePathwayRxns] = runFindSparsePathway(model,modelType,start,stop,via,CandidateSubSystem,specificMetabolites2Ignore);
% This function takes in a model (either metabolic model or a whole-body
% model), a start metabolite, and a stop metabolite and finds a shortest
% pathway
ignoreMetabolites = {'atp','h','coa','pi','h2o','o2','nh4','h2o2','nadph','nadh','nadp','nad','adp','udp','na1','hco3',...
    'ppi', 'imp','xmp','amp','ppa','fad','fadh2','oh1','co2','gmp','so4','pap','paps','mg2','zn2',...
    'cl','ca2','cu2','adpcbl','fe3','vitd3','i','caro','mn2','fe2','avite1','btn','ascb_L','phyQ','pnto_R','pydx','k'};

%% do not change hereafter

ignoreMetabolites = [specificMetabolites2Ignore';ignoreMetabolites'];
tablePathwayRxns ='';
s=' ';
osenseStr = 'max';

model = addReaction(model,['start_', start],'reactionFormula',[start,s,'<=>']);
model = addReaction(model,['stop_', stop],'reactionFormula',[stop,s,'<=>']);
printRxnFormula(model,model.rxns(end-1:end))

model2 = model;
compartments = {'e','c','m','n','p','r','l','g','x'};
ignoreMet = [];
for i = 1 : length(compartments)
    ignoreM =strcat(ignoreMetabolites,'[',compartments{i},']');
    ignoreMet = [ignoreMet;ignoreM'];
end
if strcmp(modelType,'WBM')
    sex = model.sex;
    % load list of organs
    OrganLists;
    % expand list of compartments for biofluids
    biofluids = {'bc','bcK','bp','d','u','lu','luLI','luSI','fe','csf','luC','a','aL','sw','luI','bpC','bpL'};
    
    for i = 1 : length(biofluids)
        ignoreM =strcat(ignoreMetabolites,'[',biofluids{i},']');
        ignoreMet = [ignoreMet;ignoreM'];
    end
    clear ignoreM
    ignoreMet2 =[ignoreMet];
    for i = 1 : length(OrgansListExt)
        ignoreM =strcat(OrgansListExt{i},'_',ignoreMet);
        ignoreMet2 = [ignoreMet2;ignoreM];
    end
    ignoreMet = ignoreMet2;
end

[model2, rxnRemoveList] = removeMetabolites(model2, ignoreMet,true,'legacy');


%Excl_R = [find(contains(model2.rxns,'DM_'));find(contains(model2.rxns,'sink_'));];
%model2 = changeRxnBounds(model2,model2.rxns(Excl_R),0,'b');

% needed for WBM
% set whole
if strcmp(modelType,'WBM')
    model2 = changeRxnBounds(model2,'Whole_body_objective_rxn',0,'l');
    model2 = changeRxnBounds(model2,'Whole_body_objective_rxn',1,'u');
end
%remove all constraints
model2.lb(find(model2.lb<0))=-10000000;
model2.ub(find(model2.ub<0))=0;
model2.lb(find(model2.lb>0))=0;
model2.ub(find(model2.ub>0))=10000000;

% remove coupling constraints if present
if isfield(model2,'C')
    model2 = rmfield(model2,'C');
    model2 = rmfield(model2,'ctrs');
end

% does not work for WBM

%model = changeRxnBounds(model,model.rxns(find(contains(model.rxns,'EX_'))),-1,'l');

model2 = changeObjective(model2,['stop_', stop]);
model2 = changeRxnBounds(model2,['start_', start],-1000,'b');
model2 = changeRxnBounds(model2,['stop_', stop],1000,'l');

if ~isempty(via)
    % enforce flux through via reactions
  
 %   model2 = changeRxnBounds(model2,via,-1*ones(length(via),1),'u');
    model2 = changeRxnBounds(model2,via,1*ones(length(via),1),'l');
end
    

FBA = optimizeCbModel(model2);

if FBA.origStat == 1 %problem is feasible
    %%
    param.printLevel = 0;
    param.regularizeOuter = 1;
    rxnPenalty = ones(length(model2.rxns),1);
    % not implemented yet 
    %RS = findRxnsFromSubSystem(model2,CandidateSubSystem);
    %rxnPenalty(ismember(model2.rxns,RS)) = 0;
    rxnPenalty(ismember(model2.rxns,['stop_', stop])) = -1;
    rxnPenalty(ismember(model2.rxns,['start_', start])) = -1;
    rxnPenalty(ismember(model2.rxns,via)) = -1;
    [solution,sparseRxnBool2] = findSparsePathway(model2,rxnPenalty,param);
    sparse = model2.rxns(sparseRxnBool2)
    nnz(sparseRxnBool2)
    nnz(solution.v)
    pathwayRxnsAbbr = sparse;
    pathwayRxnsFormulae = printRxnFormula(model,'rxnAbbrList',sparse,'printFlag',0);
    tablePathwayRxns = table(pathwayRxnsAbbr,pathwayRxnsFormulae);
    nnz(solution.v)
    if 1
        % without ignore metabolites
        [involvedMets, deadEnds] = draw_by_rxn(model2, sparse, 'true');
    else
        % with ignored metabolites
        [involvedMets, deadEnds] = draw_by_rxn(model, sparse, 'true');
    end
else
    fprintf('Problem is infeasible.\n');
end