function [OptSolKO, OptSolWT, OptSolRatio, RescuedGenes, fluxesKO] = computeRescuedGenes(varargin)
% Part of the Microbiome Modeling Toolbox. This function determines the
% effect of the presence of another species on gene deletions in a species.
% A joint model consisting of two species is entered. For each gene
% deletion that has an effect in each single model, the function conputes
% whether the presence of the other species can rescue the flux through the
% objective function (e.g., biomass).
%
% USAGE:
%
%     [OptSolKO,OptSolWT,OptSolRatio,fluxesKO]=computeRescuedGenes(varargin)
%
% INPUTS:
%     modelJoint:    Joint model structure consisting of two COBRA models
%     Rxn1:          Reaction in the first joined COBRA model for which the
%                    effect of gene deletions is calculated
%     Rxn2:          Reaction in the second joined COBRA model for the effect
%                    of gene deletions is calculated
%     nameTag1:      Species identifier for reactions of the first model
%     nameTag2:      Species identifier for reactions of the second model
%     OriModel1:     Original COBRA model structure of first model
%                    (needed to determine reactions to be constrained)
%     OriModel2:     Original COBRA model structure of second model
%                    (needed to determine reactions to be constrained)
%
% OUTPUTS:
%     OptSolKO:      Matlab structure containing the computed optimal solutions
%                    for the gene deletions that had an effect on the two
%                    reactions
%     OptSolRatio:   Matlab structure containing all knockout to wildtype
%                    optimal solution ratios for the gene deletions that had
%                    an effect on the two reactions
%     OptSolWT:      Matlab structure containing wildtype flux values for both
%                    reactions in the two models
%     RescuedGenes:  List of genes for which deletion is lethal or causes >50%
%                    growth reduction in single but not pairwise model
%     fluxesKO:      Matlab structure containing all solutions for all gene
%                    deletions and for both reactions in the two models. Can be
%                    used to identify mechanisms for rescued genes.
%
% .. Author:
%        - Almut Heinken 2012-2018. Last modified 03/2018.

parser = inputParser();  % Parse input parameters
parser.addParameter('modelJoint', @isstruct);
parser.addParameter('OriModel1', @isstruct);
parser.addParameter('OriModel2', @isstruct);
parser.addParameter('Rxn1', @ischar);
parser.addParameter('Rxn2', @ischar);
parser.addParameter('nameTag1', @ischar);
parser.addParameter('nameTag2', @ischar);

parser.parse(varargin{:});

modelJoint = parser.Results.modelJoint;
OriModel1 = parser.Results.OriModel1;
OriModel2 = parser.Results.OriModel2;
Rxn1 = parser.Results.Rxn1;
Rxn2 = parser.Results.Rxn2;
nameTag1 = parser.Results.nameTag1;
nameTag2 = parser.Results.nameTag2;

%rxnGeneMat is a required field for this function, so if it does not exist,
%build it.
if ~isfield(OriModel1,'rxnGeneMat')
    OriModel1 = buildRxnGeneMat(OriModel1);
end

%rxnGeneMat is a required field for this function, so if it does not exist,
%build it.
if ~isfield(OriModel2,'rxnGeneMat')
    OriModel2 = buildRxnGeneMat(OriModel2);
end

% set a solver if not done yet
global CBT_LP_SOLVER
solver = CBT_LP_SOLVER;
if isempty(solver)
    initCobraToolbox(false); %Don't update the toolbox automatically
end

% Start the gene deletion analysis.

% Relax any constraints on ATP maintenance reactions
modelJoint = changeRxnBounds(modelJoint, strcat(nameTag1, 'ATPM'), 0, 'l');
modelJoint = changeRxnBounds(modelJoint, strcat(nameTag2, 'ATPM'), 0, 'l');
modelJoint = changeRxnBounds(modelJoint, strcat(nameTag1, 'DM_atp_c_'), 0, 'l');
modelJoint = changeRxnBounds(modelJoint, strcat(nameTag2, 'DM_atp_c_'), 0, 'l');

% store the original joint model to go back to it after changing constraints
modelJointOri = modelJoint;

% Determine the wild-type solutions in joint model.
% First reaction
modelJoint = modelJointOri;
modelJoint = changeObjective(modelJoint, Rxn1);
solutionWT = solveCobraLP(buildLPproblemFromModel(modelJoint));
OptSolWT.(strcat('JoinedModel_', Rxn1)) = solutionWT.obj;
% Second reaction
modelJoint = modelJointOri;
modelJoint = changeObjective(modelJoint, Rxn2);
solutionWT = solveCobraLP(buildLPproblemFromModel(modelJoint));
OptSolWT.(strcat('JoinedModel_', Rxn2)) = solutionWT.obj;

% Define the different model scenarios that will be tested.
modelJointRxn1 = changeObjective(modelJointOri, Rxn1);
FirstModelSingle = changeRxnBounds(modelJointRxn1, modelJointRxn1.rxns(strmatch(nameTag2, modelJointRxn1.rxns)), 0, 'b');
modelJointRxn2 = changeObjective(modelJointOri, Rxn2);
SecondModelSingle = changeRxnBounds(modelJointRxn2, modelJointRxn2.rxns(strmatch(nameTag1, modelJointRxn2.rxns)), 0, 'b');

% Determine the wild-type solutions in single models.
% First reaction
solutionWT_Rxn1 = solveCobraLP(buildLPproblemFromModel(FirstModelSingle));
OptSolWT.(strcat('SingleModel_', Rxn1)) = solutionWT_Rxn1.obj;
% Second reaction
solutionWT_Rxn2 = solveCobraLP(buildLPproblemFromModel(SecondModelSingle));
OptSolWT.(strcat('SingleModel_', Rxn2)) = solutionWT_Rxn2.obj;




% Perform gene deletion for all genes in the first original model structure
% to find the ones that have an effect.
% Find the gene deletions that result in reduced or no flux in the first
% model.
reducedGenesRxn1 = {};
cnt = 1;
for i = 1:length(OriModel1.genes)
    model = OriModel1;
    [model, hasEffect, constrRxnNames, deletedGenes] = deleteModelGenes(model, model.genes(i));
    if hasEffect
        constrRxnNames = strcat(nameTag1, constrRxnNames);
        modelDel = FirstModelSingle;
        modelDel = changeRxnBounds(modelDel, constrRxnNames, 0, 'b');
        sol = solveCobraLP(buildLPproblemFromModel(modelDel));
        if sol.obj < solutionWT_Rxn1.obj
            reducedGenesRxn1{cnt, 1} = OriModel1.genes(i);
            cnt = cnt + 1;
        end
    end
end
% Compare the gene deletions that had an effect in the single and in the
% joined model.
for i = 1:length(reducedGenesRxn1)
     model = OriModel1;
    [model,hasEffect,constrRxnNames,deletedGenes] = deleteModelGenes(model,reducedGenesRxn1{i});
    constrRxnNames = strcat(nameTag1,constrRxnNames);
    % For joined model, reaction 1
    modelDel = modelJointRxn1;
    modelDel = changeRxnBounds(modelDel,constrRxnNames,0,'b');
    sol=solveCobraLP(buildLPproblemFromModel(modelDel));
    fluxesKO.(strcat('JoinedModel_',Rxn1))(i) =sol;
        OptSolKO.(strcat('JoinedModel_',Rxn1)){i,1} = char(reducedGenesRxn1{i});
    OptSolRatio.(strcat('JoinedModel_',Rxn1)){i,1} = char(reducedGenesRxn1{i});
    if sol.stat ==1
        OptSolKO.(strcat('JoinedModel_',Rxn1)){i,2} = fluxesKO.(strcat('JoinedModel_',Rxn1))(i).obj;
        OptSolRatio.(strcat('JoinedModel_',Rxn1)){i,2} = OptSolKO.(strcat('JoinedModel_',Rxn1)){i,2}/ OptSolWT.(strcat('JoinedModel_',Rxn1));
    else
        OptSolKO.(strcat('JoinedModel_',Rxn1)){i,2} = 'Infeasible';
        OptSolRatio.(strcat('JoinedModel_',Rxn1)){i,2} = 'Infeasible';
    end

    % For first model single
    modelDel=FirstModelSingle;
    modelDel = changeRxnBounds(modelDel,constrRxnNames,0,'b');
    sol=solveCobraLP(buildLPproblemFromModel(modelDel));
    fluxesKO.(strcat('SingleModel_',Rxn1))(i) =sol;
        OptSolKO.(strcat('SingleModel_',Rxn1)){i,1} = char(reducedGenesRxn1{i});
    OptSolRatio.(strcat('SingleModel_',Rxn1)){i,1} = char(reducedGenesRxn1{i});
    if sol.stat ==1
        OptSolKO.(strcat('SingleModel_',Rxn1)){i,2} = fluxesKO.(strcat('SingleModel_',Rxn1))(i).obj;
        OptSolRatio.(strcat('SingleModel_',Rxn1)){i,2} = OptSolKO.(strcat('SingleModel_',Rxn1)){i,2}/ OptSolWT.(strcat('SingleModel_',Rxn1));
    else
        OptSolKO.(strcat('SingleModel_',Rxn1)){i,2} = 'Infeasible';
        OptSolRatio.(strcat('SingleModel_',Rxn1)){i,2} = 'Infeasible';
    end
end

% Perform gene deletion for all genes in the second original model structure
% to find the ones that have an effect.
% Find the gene deletions that result in reduced or no flux in the first
% model.
reducedGenesRxn2={};
cnt=1;
for i = 1:length(OriModel2.genes)
    model=OriModel2;
    [model,hasEffect,constrRxnNames,deletedGenes] = deleteModelGenes(model,model.genes(i));
    if hasEffect
        constrRxnNames = strcat(nameTag2,constrRxnNames);
        modelDel=SecondModelSingle;
        modelDel = changeRxnBounds(modelDel,constrRxnNames,0,'b');
        sol=solveCobraLP(buildLPproblemFromModel(modelDel));
        if sol.obj<solutionWT_Rxn2.obj
            reducedGenesRxn2{cnt,1}=OriModel2.genes(i);
            cnt=cnt+1;
        end
    end
end

% Compare the gene deletions that had an effect in the single and in the
% joined model.
for i=1:length(reducedGenesRxn2)
         model=OriModel2;
    [model,hasEffect,constrRxnNames,deletedGenes] = deleteModelGenes(model,reducedGenesRxn2{i});
    constrRxnNames = strcat(nameTag2,constrRxnNames);
    % For joined model, reaction 2
    modelDel = modelJointRxn2;
    modelDel = changeRxnBounds(modelDel,constrRxnNames,0,'b');
    sol=solveCobraLP(buildLPproblemFromModel(modelDel));
    fluxesKO.(strcat('JoinedModel_',Rxn2))(i) =sol;
        OptSolKO.(strcat('JoinedModel_',Rxn2)){i,1} = char(reducedGenesRxn2{i});
    OptSolRatio.(strcat('JoinedModel_',Rxn2)){i,1} = char(reducedGenesRxn2{i});
    if sol.stat ==1
        OptSolKO.(strcat('JoinedModel_',Rxn2)){i,2} = fluxesKO.(strcat('JoinedModel_',Rxn2))(i).obj;
        OptSolRatio.(strcat('JoinedModel_',Rxn2)){i,2} = OptSolKO.(strcat('JoinedModel_',Rxn2)){i,2}/ OptSolWT.(strcat('JoinedModel_',Rxn2));
    else
        OptSolKO.(strcat('JoinedModel_',Rxn2)){i,2} = 'Infeasible';
        OptSolRatio.(strcat('JoinedModel_',Rxn2)){i,2} = 'Infeasible';
    end

    % For second model single
    modelDel=SecondModelSingle;
    modelDel = changeRxnBounds(modelDel,constrRxnNames,0,'b');
    sol=solveCobraLP(buildLPproblemFromModel(modelDel));
    fluxesKO.(strcat('SingleModel_',Rxn2))(i) =sol;
            OptSolKO.(strcat('SingleModel_',Rxn2)){i,1} = char(reducedGenesRxn2{i});
    OptSolRatio.(strcat('SingleModel_',Rxn2)){i,1} = char(reducedGenesRxn2{i});
    if sol.stat ==1
        OptSolKO.(strcat('SingleModel_',Rxn2)){i,2} = fluxesKO.(strcat('SingleModel_',Rxn2))(i).obj;
        OptSolRatio.(strcat('SingleModel_',Rxn2)){i,2} = OptSolKO.(strcat('SingleModel_',Rxn2)){i,2}/ OptSolWT.(strcat('SingleModel_',Rxn2));
    else
        OptSolKO.(strcat('SingleModel_',Rxn2)){i,2} = 'Infeasible';
        OptSolRatio.(strcat('SingleModel_',Rxn2)){i,2} = 'Infeasible';
    end
end

% Analyze the effect of the presence of the pairwise models on gene
% lethality.
RescuedGenes=struct;
% Original model 1
rescue100cnt=1;
rescuecnt=1;
for i=1:length(reducedGenesRxn1)
    if ~strcmp(OptSolRatio.(strcat('JoinedModel_',Rxn1)){i,2},'Infeasible') && ~strcmp(OptSolRatio.(strcat('SingleModel_',Rxn1)){i,2},'Infeasible')
        % get the KO to WT ratio with paired species present
        grRatioPaired=OptSolRatio.(strcat('JoinedModel_',Rxn1)){i,2};
        % get the KO to WT ratio without paired species present
        grRatioSingle=OptSolRatio.(strcat('SingleModel_',Rxn1)){i,2};
        % find the genes for which deletion was lethal in single but not in
        % pairwise model
        if grRatioSingle<0.00001 && grRatioPaired>0.00001
            RescuedGenes.(Rxn1).('RescuedLethalGenes'){rescue100cnt,1}=char(reducedGenesRxn1{i});
            rescue100cnt=rescue100cnt+1;
        elseif grRatioSingle<0.9 && grRatioSingle>0 && grRatioPaired>0.99
            % find the genes for which growth was reduced in single but
            % not in pairwise model
            RescuedGenes.(Rxn1).('RescuedGrowthImpairedGenes'){rescuecnt,1}=char(reducedGenesRxn1{i});
            rescuecnt=rescuecnt+1;
        end
    end
end
% Original model 2
rescue100cnt=1;
rescuecnt=1;
for i=1:length(reducedGenesRxn2)
    if ~strcmp(OptSolRatio.(strcat('JoinedModel_',Rxn2)){i,2},'Infeasible') && ~strcmp(OptSolRatio.(strcat('SingleModel_',Rxn2)){i,2},'Infeasible')
        % get the KO to WT ratio with paired species present
        grRatioPaired=OptSolRatio.(strcat('JoinedModel_',Rxn2)){i,2};
        % get the KO to WT ratio without paired species present
        grRatioSingle=OptSolRatio.(strcat('SingleModel_',Rxn2)){i,2};
        % find the genes for which deletion was lethal in single but not in
        % pairwise model
        if grRatioSingle<0.00001 && grRatioPaired>0.00001
            RescuedGenes.(Rxn2).('RescuedLethalGenes'){rescue100cnt,1}=char(reducedGenesRxn2{i});
            rescue100cnt=rescue100cnt+1;
        elseif grRatioSingle<0.9 && grRatioSingle>0 && grRatioPaired>0.99
            % find the genes for which growth was reduced in single but
            % not in pairwise model
            RescuedGenes.(Rxn2).('RescuedGrowthImpairedGenes'){rescuecnt,1}=char(reducedGenesRxn2{i});
            rescuecnt=rescuecnt+1;
        end
    end
end
end
