function model = untargetedGapFilling(model,osenseStr,database,excludeDMs,excludeSinks)
% This script is part of the DEMETER pipeline and attemps to find a
% reaction from the complete reaction database through the use of
% relaxedFBA that could enable flux through the objective function. This
% function will be performed only if targeted gap-filling failed.
%
% USAGE:
%
%   model = untargetedGapFilling(model,osenseStr,database)
%
% INPUTS
% model:              COBRA model structure
% osenseStr:          Maximize ('max')/minimize ('min')linear part of the
%                     objective.
% database:           rBioNet reaction database containing min. 3 columns:
%                     Column 1: reaction abbreviation, Column 2: reaction
%                     name, Column 3: reaction formula.
%
% OUTPUT
% model:               Gapfilled COBRA model structure
%
% .. Authors:
%       - Ines Thiele and Almut Heinken, 02/2021

% remove human reactions from database
humanComp = {'[m]','[l]','[x]','[r]','[g]','[u]','[ev]','[eb]','[ep]'};
database.reactions(contains(database.reactions(:,3),humanComp),:)=[];

% define reactions that should not be considered
% ExcludeRxns = {'DTTPte'};

if nargin < 4
    excludeDMs=1;
end

if nargin < 5
    excludeSinks=1;
end


tol=0.001;

modelOrg=model;

% get the reaction that needs to be gap-filled
targetRxn=model.rxns{model.c==1,1};

% create model out of reaction database if not existing
if isfile('rBioNetDB.mat')
    load('rBioNetDB.mat');
else
    rBioNetDB = createModel;
    for i = 2 : size(database.reactions,1)
        rBioNetDB = addReaction(rBioNetDB,database.reactions{i,1},database.reactions{i,3});
    end
    save('rBioNetDB','rBioNetDB');
end
% find reaction(s) from the complete reaction database that can enable
% growth

% make the model infeasible
if strcmp(osenseStr,'max')
    model.lb(find(model.c))=tol;
elseif strcmp(osenseStr,'min')
    model.ub(find(model.c))=-tol;
end
FBA = optimizeCbModel(model);
if FBA.origStat ==3 % cannot produce biomass
    % try if adding rBioNetDB would fix the problem of not being able to
    % produce biomass
    [modelExpanded] = mergeTwoModels(rBioNetDB,model,1,0);
    modelExpanded = changeObjective(modelExpanded,targetRxn);
    FBA2 = optimizeCbModel(modelExpanded);
    if FBA2.origStat == 1 && FBA2.f > 0  % feasible non-zero solution found
        % now identify the minimum number of reactions to be added
        % 1. set all rBioNet reaction to 0
        % therefore find all reactions in rBioNetDB but not in model
        R = setdiff(rBioNetDB.rxns,model.rxns);
        modelExpanded.lb(ismember(modelExpanded.rxns,R)) = 0;
        modelExpanded.ub(ismember(modelExpanded.rxns,R)) = 0;
        % 2. use relaxFBA
        % Excluded reactions that are currently in the model to be
        % relaxed
        
        clear param
        param.printLevel = 1; % set to 0 if not print is desired
        
        % do not change these parameters
        param.theta=0.1;
        param.steadyStateRelax = 0;
        % exclude original model reactions to have relaxed
        % bounds
        param.excludedReactions = ismember(modelExpanded.rxns,model.rxns);
        
        % exclude irreversible reactions from relaxing lower bounds
        irrRxns=database.reactions(find(strcmp(database.reactions(:,4),'0')),1);
        param.excludedReactionLB = ismember(modelExpanded.rxns,irrRxns);
        
        % exclude DM reactions to have relaxed bounds
        if excludeDMs
            DMR = contains(modelExpanded.rxns,'DM_');
            param.excludedReactions(DMR)=1;
        end
        if excludeSinks
            % exclude sink reactions to have relaxed bounds
            SinkR = contains(modelExpanded.rxns,'sink_');
            param.excludedReactions(SinkR)=1;
        end
        if exist('ExcludeRxns','var') && ~isempty(ExcludeRxns)
            param.excludedReactions(ismember(modelExpanded.rxns,ExcludeRxns)) = 1;
        end
        % run relaxed FBA
        [solution, relaxedModel] = relaxedFBA(modelExpanded, param);
        
        %% get solutions for relaxation
        LBsol = modelExpanded.rxns(find(relaxedModel.lb(ismember(modelExpanded.rxns,R))));
        UBsol = modelExpanded.rxns(find(relaxedModel.ub(ismember(modelExpanded.rxns,R))));
        % collect solutions into one list
        
        addedRxns=union(LBsol,UBsol);
        
        % find exchange reactions, transporters if not both are in the lsit
        % for a given metabolite
        [C,IA]=intersect(database.reactions(:,1),addedRxns);
        forms=database.reactions(IA,3);
        exRxns=C(find(contains(forms,'[e]')));
        exMetList={};
        for j=1:length(exRxns)
            [metaboliteList, stoichCoeffList, revFlag] = parseRxnFormula(forms{j});
            exMetList=union(exMetList,metaboliteList(contains(metaboliteList,'[e]')));
        end
        if ~isempty(exMetList)
            [exMets,~,J]=unique(exMetList);
            cntExMets = histc(J, 1:numel(exMets));
            for j=1:length(exMets)
                if cntExMets(j) < 2 && isempty(find(strcmp(model.mets,exMets{j})))
                    if ~any(strncmp(exRxns,['EX_' exMets{j}],length(['EX_' exMets{j}])))
                    % find the exchange reaction
                    met=strrep(exMets{j},'[e]','');
                    addedRxns = union(addedRxns,database.reactions(find(strncmp(database.reactions(:,1),['EX_' met],length(['EX_' met]))),1));
                    else
                    % otherwise, find reversible transporters
                    findTransp=find(contains(database.reactions(:,3),exMets{j}));
                    revRxns=find(strcmp(database.reactions(:,4),'1'));
                    metTrans=database.reactions(intersect(findTransp,revRxns),1);
                    if length(metTrans)>1
                        addedRxns = union(addedRxns,metTrans(1:2));
                    else
                        % try irreversible transporters
                        findTransp=find(contains(database.reactions(:,3),exMets{j}));
                        irrRxns=find(strcmp(database.reactions(:,4),'0'));
                        metTrans=database.reactions(intersect(findTransp,irrRxns),1); 
                    end
                    addedRxns = union(addedRxns,metTrans);
                    end
                end
            end
        end
        
        % add the reactions that were found
        model=modelOrg;
        
        for j=1:length(addedRxns)
            rxnInd=find(strcmp(database.reactions(:,1),addedRxns{j}));
            model = addReaction(model, [database.reactions{rxnInd,1} '_untGF'], database.reactions{rxnInd,3});
        end
    end
end

end