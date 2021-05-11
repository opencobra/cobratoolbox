function [model,addedRxns] = untargetedGapFilling(model,osenseStr,database,excludeDMs,excludeSinks,excludeExchanges)
% This script is part of the DEMETER pipeline and attemps to find a
% reaction from the complete reaction database through the use of
% relaxedFBA that could enable flux through the objective function. This
% function will be performed only if targeted gap-filling failed.
%
% USAGE:
%
%   [model,addedRxns] = untargetedGapFilling(model,osenseStr,database)
%
% INPUTS
% model:              COBRA model structure
% osenseStr:          Maximize ('max')/minimize ('min')linear part of the
%                     objective.
% database:           rBioNet reaction database containing min. 3 columns:
%                     Column 1: reaction abbreviation, Column 2: reaction
%                     name, Column 3: reaction formula.
% excludeDMs          boolean indicating if demand reactions should be
%                     excluded from gap-filling reactions (default: true)
% excludeSinks        boolean indicating if sink reactions should be
%                     excluded from gap-filling reactions (default: true)
% excludeExchanges    boolean indicating if exchanges reactions should be
%                     excluded from gap-filling reactions (default: false)
%
% OUTPUT
% model:              Gapfilled COBRA model structure
% addedRxns:          Added gapfilled reactions
%
% .. Authors:
%       - Ines Thiele and Almut Heinken, 02/2021

addedRxns = {};

% remove human reactions from database
humanComp = {'[m]','[l]','[x]','[r]','[g]','[u]','[ev]','[eb]','[ep]'};
database.reactions(contains(database.reactions(:,3),humanComp),:)=[];

% remove periplasm compartment from database
ppComp = {'[p]'};
database.reactions(contains(database.reactions(:,3),ppComp),:)=[];

% define reactions that should not be considered
ExcludeRxns = {'DTTPte','COAt','COAti','DPCOAt','DPCOAti','AMPt2','AMPt2r','NADPt','NADPti','DGTPt','DGTPti','CMPt2i','CMPt2','GMPt2','GMPt2r','UMPt2','UMPt2i','GTPt','GTPti','DATPt','DATPti'};

if nargin < 4
    excludeDMs=1;
end

if nargin < 5
    excludeSinks=1;
end

if nargin < 6
    excludeExchanges=0;
end


tol=0.1;

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

% check if the model cannot produce biomass

if FBA.stat ==3 || FBA.stat ==0
    
    % remove reactions already in model
    [C]=intersect(rBioNetDB.rxns,model.rxns);
    rBioNetDB=removeRxns(rBioNetDB,C);
    
    % try if adding rBioNetDB would fix the problem of not being able to
    % produce biomass
    [modelExpanded] = mergeTwoModels(rBioNetDB,model,1,0);
    modelExpanded = changeObjective(modelExpanded,targetRxn);
    FBA2 = optimizeCbModel(modelExpanded);
    
    if FBA2.stat == 1 && abs(FBA2.f) > 0  % feasible non-zero solution found
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
        param.theta=0.5;
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
        if excludeExchanges
            % exclude sink reactions to have relaxed bounds
            ExR = contains(modelExpanded.rxns,'EX_');
            param.excludedReactions(ExR)=1;
        end
        if exist('ExcludeRxns','var') && ~isempty(ExcludeRxns)
            param.excludedReactions(ismember(modelExpanded.rxns,ExcludeRxns)) = 1;
        end
        % run relaxed FBA
        try
            [solution, relaxedModel] = relaxedFBA(modelExpanded, param);
            %             FBA2 = optimizeCbModel(relaxedModel);
            %         while FBA2.origStat ==3 % cannot produce biomass
            %             % repeat relaxFBA this time with the relaxed model
            %             [solution, relaxedModel] = relaxedFBA(relaxedModel, param);
            %             FBA2 = optimizeCbModel(relaxedModel);
            %         end
            
            %% get solutions for relaxation
            LBsol = relaxedModel.rxns(abs(relaxedModel.lb)>0);
            LBsol=setdiff(LBsol,model.rxns);
            UBsol = relaxedModel.rxns(abs(relaxedModel.ub)>0);
            UBsol=setdiff(UBsol,model.rxns);
            
            model=modelOrg;
            
            addedRxns=union(LBsol,UBsol);
            
            for j=1:length(addedRxns)
                rxnInd=find(strcmp(database.reactions(:,1),addedRxns{j}));
                model = addReaction(model, [database.reactions{rxnInd,1} '_untGF'], database.reactions{rxnInd,3});
            end
            
        catch
            warning('relaxFBA could not find a solution!')
        end
    end
end

end
