function missingDietComponents = getMissingDietModelHM(modelHM,missingDietComponents,testInitialFeasibility)
% This function determines missing dietary compounds in host-microbiome
% WBMs that are infeasible (it assumes that the WBMs and the microbiome
% models individually are feasible). 
% This function first tests whether the model is feasible (which can be
% skipped by setting testInitialFeasibility = 0), if infeasible, all diet
% exchange reactions that are not already active will be opened and the
% feasibility will be tested. If infeasible, the function stops -  then
% there is no dietary solution (of course it could be that active diet
% constraints are limited but they will not be tested with this script). 
% Subsequently, diet exchanges are randomly closed (first in batches of 50,
% then 10, then 5, then 1). If the modelHM remains feasible this batch as
% well as all other 0 diet fluxes in the fba solution will be deemed not
% necessary for feasibility, if infeasible the batch set will be kept and
% tested for in the next step. when the batch set size is 1, each remaining
% diet exchange will be tested for individually. 
% While still being slow, this approach is much faster then testing each
% diet exchange individually.
% As the diet exchanges are selected randomly for each batch, running the
% function twice may not result in the same final set of
% missingDietComponents
%
% INPUT
% modelHM                   Host-microbiome model structure
% missingDietComponents     list of diet exchange reactions that are known
%                           to be missing or that have been identified in a previous run of this
%                           function
% testInitialFeasibility    default 1 

% OUTPUT
% missingDietComponents     list of missingDietComponents. If
%                           missingDietComponents was given as an input then this list is a
%                           combination of the input and the newly discovered missingDietComponents
%
% Ines Thiele, Nov 2023

if ~exist('testInitialFeasibility','var')
    testInitialFeasibility = 1;
end

% not needed anymore 
% if babyModels == 1 
% %     missingDietComponents=  {'Diet_EX_sucr[d]'
% %         'Diet_EX_btn[d]'
% %         'Diet_EX_ach[d]'
% %         'Diet_EX_appnn[d]'
% %         'Diet_EX_5HPET[d]'
% %         'Diet_EX_melib[d]'
% %         'Diet_EX_prostge1[d]'
% %         'Diet_EX_cl[d]'
% %         'Diet_EX_gd1c_hs[d]' };
% else
%     missingDietComponents = [];
% end

% initial parameterisation of modelHM
% enforce microbial growth (i.e., microbal fecal excretion)

modelHM.lb(contains(modelHM.rxns,'Excretion_EX_microbiota_LI_biomass[fe]'))=1;
modelHM.ub(contains(modelHM.rxns,'Excretion_EX_microbiota_LI_biomass[fe]'))=1;


modelHM.lb(contains(modelHM.rxns,'Excretion_EX_microbiota_LI_biomass[fe]'))=0.1;
modelHM.ub(contains(modelHM.rxns,'Excretion_EX_microbiota_LI_biomass[fe]'))=2;

modelHM.lb(contains(modelHM.rxns,'Excretion_EX_microbiota_LI_biomass[fe]'))=1;
modelHM.ub(contains(modelHM.rxns,'Excretion_EX_microbiota_LI_biomass[fe]'))=1;


% enforce body weight maintenance
modelHM.lb(contains(modelHM.rxns,'Whole'))=1;
modelHM.ub(contains(modelHM.rxns,'Whole'))=1;
% open known missingDietComponents
if exist('missingDietComponents','var')
    modelHM.lb(ismember(modelHM.rxns, missingDietComponents))=-10;
    modelHM.ub(ismember(modelHM.rxns, missingDietComponents))=0;
else
    % if unknown, set to empty vector
    missingDietComponents = '';
end
modelHM.osenseStr = 'max';
% check that model is infeasible
if testInitialFeasibility == 1
    tic;fba = optimizeWBModel(modelHM);
    toc
    fba = optimizeWBModel(modelHM);
    toc
else
    fba.f = NaN; % will be set to infeasible
end
if isnan(fba.f)
    % check if model is feasible if all Diet components are allowed
    model =modelHM;
    diet = model.rxns(contains(model.rxns, 'Diet_EX'));
    lb = model.rxns(find(model.lb==0));
    dietlb = intersect(diet, lb);
    model.lb(ismember(model.rxns, dietlb))=-10;
    model.ub(ismember(model.rxns, dietlb))=0;
    tic;fba = optimizeWBModel(model);
    toc
    if ~isnan(fba.f) % model is feasible like this
        
        % remove previously identified missing diet components from search list
        if exist('missingDietComponents','var')
            dietlb = setdiff(dietlb,missingDietComponents);
        end
        % set model obj to 1 to accelerate computation
        modelO = model;
        tol = 1e-6;
        a = 1;
        maxNum = 50;
        potentialMissing = '';
        while length(dietlb)>0
            length(dietlb)
            modelTmp = model;
            r = randi([1 length(dietlb)],maxNum,1);
            
            modelTmp.lb(ismember(modelTmp.rxns,dietlb(r))) = 0;
            modelTmp.ub(ismember(modelTmp.rxns,dietlb(r))) = 0;
            
            fba = optimizeWBModel(modelTmp);
            if ~isnan(fba.f)
                
                nnzf = find(abs(fba.v) <= tol);
                dietlbnnzf = intersect(model.rxns(nnzf),dietlb);
                
                model.lb(ismember(model.rxns,dietlbnnzf)) = 0;
                model.ub(ismember(model.rxns,dietlbnnzf)) = 0;
                dietlb(contains(dietlb,dietlbnnzf)) = '';
            else
                % exclude random numbers
                potentialMissing = [potentialMissing; dietlb(r) ];
                dietlb(r) = '';
            end
            a = a +1;
        end
        
        % start next iteration with smaller step size
        potentialMissing2 = [];
        for i = 1 :size(potentialMissing,2)
            potentialMissing2 = [potentialMissing2;potentialMissing(:,i)];
        end
        potentialMissing2 = unique(potentialMissing2);
        dietlb = potentialMissing2;
        modelO2 = model;
        tol = 1e-6;
        a = 1;
        maxNum = 10;
        
        potentialMissing = '';
        
        while length(dietlb)>0
            length(dietlb)
            modelTmp = model;
            r = randi([1 length(dietlb)],maxNum,1);
            
            modelTmp.lb(ismember(modelTmp.rxns,dietlb(r))) = 0;
            modelTmp.ub(ismember(modelTmp.rxns,dietlb(r))) = 0;
            
            fba = optimizeWBModel(modelTmp);
            if ~isnan(fba.f)
                fba.f
                nnzf = find(abs(fba.v) <= tol);
                dietlbnnzf = intersect(model.rxns(nnzf),dietlb);
                
                model.lb(ismember(model.rxns,dietlbnnzf)) = 0;
                model.ub(ismember(model.rxns,dietlbnnzf)) = 0;
                dietlb(contains(dietlb,dietlbnnzf)) = '';
            else
                % exclude random numbers
                potentialMissing = [potentialMissing; dietlb(r) ];
                potentialMissing
                dietlb(r) = '';
            end
            a = a +1;
        end
        
        % start next iteration with smaller step size
        potentialMissing2 = [];
        for i = 1 :size(potentialMissing,2)
            potentialMissing2 = [potentialMissing2;potentialMissing(:,i)];
        end
        potentialMissing2 = unique(potentialMissing2);
        dietlb = potentialMissing2;
        modelO2 = model;
        tol = 1e-6;
        a = 1;
        maxNum = 5;
        
        
        while length(dietlb)>0
            length(dietlb)
            modelTmp = model;
            r = randi([1 length(dietlb)],maxNum,1);
            
            modelTmp.lb(ismember(modelTmp.rxns,dietlb(r))) = 0;
            modelTmp.ub(ismember(modelTmp.rxns,dietlb(r))) = 0;
            
            fba = optimizeWBModel(modelTmp);
            if ~isnan(fba.f)
                fba.f
                nnzf = find(abs(fba.v) <= tol);
                dietlbnnzf = intersect(model.rxns(nnzf),dietlb);
                
                model.lb(ismember(model.rxns,dietlbnnzf)) = 0;
                model.ub(ismember(model.rxns,dietlbnnzf)) = 0;
                dietlb(contains(dietlb,dietlbnnzf)) = '';
            else
                % exclude random numbers
                potentialMissing = [potentialMissing; dietlb(r) ];
                potentialMissing
                dietlb(r) = '';
            end
            a = a +1;
        end
        
        potentialMissing = unique(potentialMissing);
        dietlb = potentialMissing;
        modelO2 = model;
        tol = 1e-6;
        a = 1;
        maxNum = 1;
        potentialMissing4 =potentialMissing;
        potentialMissing = '';
        %dietlb = setdiff(dietlb,potentialMissing3);
        while length(dietlb)>0
            length(dietlb)
            modelTmp = model;
            r = randi([1 length(dietlb)],maxNum,1);
            
            modelTmp.lb(ismember(modelTmp.rxns,dietlb(r))) = 0;
            modelTmp.ub(ismember(modelTmp.rxns,dietlb(r))) = 0;
            
            fba = optimizeWBModel(modelTmp);
            if ~isnan(fba.f)
                fba.f
                nnzf = find(abs(fba.v) <= tol);
                dietlbnnzf = intersect(model.rxns(nnzf),dietlb);
                
                model.lb(ismember(model.rxns,dietlbnnzf)) = 0;
                model.ub(ismember(model.rxns,dietlbnnzf)) = 0;
                dietlb(contains(dietlb,dietlbnnzf)) = '';
            else
                % exclude random numbers
                potentialMissing = [potentialMissing; dietlb(r)];
                potentialMissing
                dietlb(r) = '';
            end
            a = a +1;
        end
        
        missingDietComponents =[potentialMissing;missingDietComponents];
        missingDietComponents = unique(missingDietComponents);
        model =modelHM;
        model.lb(ismember(model.rxns, missingDietComponents))=-10;
        model.ub(ismember(model.rxns, missingDietComponents))=0;
        fba = optimizeWBModel(model);
    end
end