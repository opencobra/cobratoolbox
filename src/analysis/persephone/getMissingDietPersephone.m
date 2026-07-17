function missingDietComponents = getMissingDietPersephone(inputModel, missingDietComponents, testInitialFeasibility)
% Identify dietary components that are missing for an infeasible WBM or microbiome model
%
% Determines missing dietary compounds in host-microbiome WBMs (or in
% microbiome community models) that are infeasible, assuming the WBM and
% microbiome models are individually feasible. The model is first tested for
% feasibility (this can be skipped). If infeasible, all inactive diet exchange
% reactions are opened; if still infeasible the function stops. Otherwise diet
% exchanges are randomly closed in decreasing batch sizes (50, 10, 5, then 1)
% and reactions not required for feasibility are discarded, leaving the set of
% components that are needed. Because the batches are drawn at random, repeated
% runs may return slightly different sets.
%
% USAGE:
%
%    missingDietComponents = getMissingDietPersephone(inputModel, missingDietComponents, testInitialFeasibility)
%
% INPUTS:
%    inputModel:               host-microbiome or microbiome community model
%                              structure. Fields used:
%
%                                * .rxns - reaction identifiers, searched for
%                                  diet and biomass exchange reactions
%                                * .osenseStr - objective sense, set to 'max'
%                                  before optimisation
%    missingDietComponents:    list of diet exchange reactions already known to
%                              be missing (e.g. from a previous run); pass ''
%                              or omit if none are known
%
% OPTIONAL INPUT:
%    testInitialFeasibility:    logical/double, whether the initial
%                               feasibility test is performed (default 1)
%
% OUTPUT:
%    missingDietComponents:    list of missing diet components. When a list was
%                              supplied as input, the output combines it with
%                              the newly discovered components
%
% .. Author: - Ines Thiele, Nov 2023
%            - Tim Hensen, September 2025 (support for microbiome community models)

if ~exist('testInitialFeasibility','var')
    testInitialFeasibility = 1;
end

% Check if the input model is a microbiome or host-microbiome model
host = matches('Excretion_EX_microbiota_LI_biomass[fe]',inputModel.rxns);


if host % Parameterise host-microbiome model
    inputModel.lb(contains(inputModel.rxns,'Excretion_EX_microbiota_LI_biomass[fe]'))=1;
    inputModel.ub(contains(inputModel.rxns,'Excretion_EX_microbiota_LI_biomass[fe]'))=1;
    
    
    inputModel.lb(contains(inputModel.rxns,'Excretion_EX_microbiota_LI_biomass[fe]'))=0.1;
    inputModel.ub(contains(inputModel.rxns,'Excretion_EX_microbiota_LI_biomass[fe]'))=2;
    
    inputModel.lb(contains(inputModel.rxns,'Excretion_EX_microbiota_LI_biomass[fe]'))=1;
    inputModel.ub(contains(inputModel.rxns,'Excretion_EX_microbiota_LI_biomass[fe]'))=1;
    
    
    % enforce body weight maintenance
    inputModel.lb(contains(inputModel.rxns,'Whole'))=1;
    inputModel.ub(contains(inputModel.rxns,'Whole'))=1;
end

% open known missingDietComponents
if exist('missingDietComponents','var')
    inputModel.lb(ismember(inputModel.rxns, missingDietComponents))=-10;
    inputModel.ub(ismember(inputModel.rxns, missingDietComponents))=0;
else
    % if unknown, set to empty vector
    missingDietComponents = '';
end



% check that model is infeasible
inputModel.osenseStr = 'max';
if testInitialFeasibility == 1
    toc
    if host
        fba = optimizeWBModel(inputModel);
    else
        fba = optimizeCbModel(inputModel);    
    end
    toc
else
    fba.f = NaN; % will be set to infeasible
end


if isnan(fba.f)
    % check if model is feasible if all Diet components are allowed
    model =inputModel;
    diet = model.rxns(contains(model.rxns, 'Diet_EX'));
    lb = model.rxns(find(model.lb==0));
    dietlb = intersect(diet, lb);
    model.lb(ismember(model.rxns, dietlb))=-10;
    model.ub(ismember(model.rxns, dietlb))=0;
    tic;
    if host
        fba = optimizeWBModel(model);
    else
        fba = optimizeCbModel(model);
    end
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
        while ~isempty(dietlb)
            length(dietlb)
            modelTmp = model;
            r = randi([1 length(dietlb)],maxNum,1);
            
            modelTmp.lb(ismember(modelTmp.rxns,dietlb(r))) = 0;
            modelTmp.ub(ismember(modelTmp.rxns,dietlb(r))) = 0;
            
            if host
                fba = optimizeWBModel(modelTmp);
            else
                fba = optimizeCbModel(modelTmp);
            end

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
        
        while ~isempty(dietlb)
            length(dietlb)
            modelTmp = model;
            r = randi([1 length(dietlb)],maxNum,1);
            
            modelTmp.lb(ismember(modelTmp.rxns,dietlb(r))) = 0;
            modelTmp.ub(ismember(modelTmp.rxns,dietlb(r))) = 0;
            
            if host
                fba = optimizeWBModel(modelTmp);
            else
                fba = optimizeCbModel(modelTmp);
            end
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
        
        
        while ~isempty(dietlb)
            length(dietlb)
            modelTmp = model;
            r = randi([1 length(dietlb)],maxNum,1);
            
            modelTmp.lb(ismember(modelTmp.rxns,dietlb(r))) = 0;
            modelTmp.ub(ismember(modelTmp.rxns,dietlb(r))) = 0;
            
            if host
                fba = optimizeWBModel(modelTmp);
            else
                fba = optimizeCbModel(modelTmp);
            end
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
        while ~isempty(dietlb)
            length(dietlb)
            modelTmp = model;
            r = randi([1 length(dietlb)],maxNum,1);
            
            modelTmp.lb(ismember(modelTmp.rxns,dietlb(r))) = 0;
            modelTmp.ub(ismember(modelTmp.rxns,dietlb(r))) = 0;
            
            if host
                fba = optimizeWBModel(modelTmp);
            else
                fba = optimizeCbModel(modelTmp);
            end

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
        model =inputModel;
        model.lb(ismember(model.rxns, missingDietComponents))=-10;
        model.ub(ismember(model.rxns, missingDietComponents))=0;
        if host
            fba = optimizeWBModel(model);
        else
            fba = optimizeCbModel(model);
        end
    end
end