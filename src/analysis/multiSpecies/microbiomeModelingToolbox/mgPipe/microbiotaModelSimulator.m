function [exchanges, netProduction, netUptake, growthRates, infeasModels] = microbiotaModelSimulator(resPath, exMets, sampNames, dietFilePath, hostPath, hostBiomassRxn, hostBiomassRxnFlux, numWorkers, rDiet, pDiet, computeProfiles, lowerBMBound, upperBMBound, includeHumanMets, adaptMedium)

% This function is called from the MgPipe pipeline. Its purpose is to apply
% different diets (according to the user's input) to the microbiota models
% and run simulations computing FVAs on exchanges reactions of the microbiota
% models. The output is saved in multiple .mat objects. Intermediate saving
% checkpoints are present.
%
% USAGE:
%
%   [exchanges, netProduction, netUptake, growthRates, infeasModels] = microbiotaModelSimulator(resPath, exMets, sampNames, dietFilePath, hostPath, hostBiomassRxn, hostBiomassRxnFlux, numWorkers, rDiet, pDiet, computeProfiles, lowerBMBound, upperBMBound, includeHumanMets, adaptMedium)
%
% INPUTS:
%    resPath:            char with path of directory where results are saved
%    exMets:             list of exchanged metabolites present in at least
%                        one microbe model that can carry flux
%    sampNames:          cell array with names of individuals in the study
%    dietFilePath:       path to and name of the text file with dietary information
%                        Can also be a list of the sample names with
%                        individual diet files.
%    hostPath:           char with path to host model, e.g., Recon3D (default: empty)
%    hostBiomassRxn:     char with name of biomass reaction in host (default: empty)
%    hostBiomassRxnFlux: double with the desired upper bound on flux through the host
%                        biomass reaction (default: 1)
%    numWorkers:         integer indicating the number of cores to use for parallelization
%    rDiet:              boolean indicating if to simulate a rich diet
%    pDiet:              boolean indicating if a personalized diet
%                        is available and should be simulated
%    computeProfiles:    boolean defining whether flux variability analysis to
%                        compute the metabolic profiles should be performed.
%    lowerBMBound        Minimal amount of community biomass in mmol/person/day enforced (default=0.4)
%    upperBMBound        Maximal amount of community biomass in mmol/person/day enforced (default=1)
%    includeHumanMets:   boolean indicating if human-derived metabolites
%                        present in the gut should be provexchangesed to the models (default: true)
%    adaptMedium:        boolean indicating if the medium should be adapted through the
%                        adaptVMHDietToAGORA function or used as is (default=true)
%
% OUTPUTS:
%    exchanges:          cell array with list of all unique exchanges to diet/
%                        fecal compartment that were interrogated in simulations
%    netProduction:      cell array containing FVA values for maximal uptake
%                        and secretion for setup lumen / diet exchanges
%    netUptake:          cell array containing FVA values for minimal uptake
%                        and secretion for setup lumen / diet exchanges
%    growthRates:        array containing values of microbiota models
%                        objective function
%    infeasModels:       cell array with names of infeasible microbiota models
%
% .. Author: Federico Baldini, 2017-2018
%            Almut Heinken, 03/2021: simplified inputs

% initialize COBRA Toolbox and parallel pool
global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
end
solver = CBT_LP_SOLVER;

if numWorkers>0 && ~isempty(ver('parallel'))
    % with parallelization
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(numWorkers)
    end
end
environment = getEnvironment();

mkdir([resPath filesep 'Diet'])

for i=1:length(exMets)
    exchanges{i,1} = ['EX_' exMets{i}];
end
exchanges = regexprep(exchanges, '\[e\]', '\[fe\]');
exchanges = setdiff(exchanges, 'EX_biomass[fe]', 'stable');

allFecalExch = exchanges;
allDietExch = exchanges;
allDietExch = regexprep(allDietExch,'EX_','Diet_EX_');
allDietExch = regexprep(allDietExch,'\[fe\]','\[d\]');

% define human-derived metabolites present in the gut: primary bile acids, amines, mucins, host glycans
HumanMets={'gchola','-10';'tdchola','-10';'tchola','-10';'dgchol','-10';'34dhphe','-10';'5htrp','-10';'Lkynr','-10';'f1a','-1';'gncore1','-1';'gncore2','-1';'dsT_antigen','-1';'sTn_antigen','-1';'core8','-1';'core7','-1';'core5','-1';'core4','-1';'ha','-1';'cspg_a','-1';'cspg_b','-1';'cspg_c','-1';'cspg_d','-1';'cspg_e','-1';'hspg','-1'};

%% start the simulations

% define whether simulations should be skipped
skipSim=0;
if isfile(strcat(resPath, 'simRes.mat'))
    load(strcat(resPath, 'simRes.mat'))

    % if any simulations were infeasible, repeat simulations
    if length(infeasModels)>0
        skipSim=0;
    else
        skipSim=1;
        % verify that every simulation result is correct
        for i=1:size(netProduction,2)
            % check for all feasible models that simulations were properly
            % executed
            if isempty(netProduction{2,i})
                % feasible model was skipped, repeat simulations
                skipSim=0;
            else
                vals=netProduction{2,i}(find(~cellfun(@isempty,(netProduction{2,i}(:,2)))),2);
                if abs(sum(cell2mat(vals)))<0.000001
                    % feasible model was skipped, repeat simulations
                    skipSim=0;
                end
            end
        end
     end
end

if skipSim==1
    s = 'simulations already done, file found: loading from resPath';
    disp(s)
else
    % Cell array to store results
    netProduction = cell(3, length(sampNames));
    netUptake = cell(3, length(sampNames));
    infeasModels = {};
    growthRates = {'','Rich medium','Diet'};
    growthRates(2:length(sampNames)+1,1) = sampNames;

    % Auto load for crashed simulations
    mapP = detectOutput(resPath, 'intRes.mat');
    if isempty(mapP)
    else
        s = 'simulation checkpoint file found: recovering crashed simulation';
        disp(s)
        load(strcat(resPath, 'intRes.mat'))
    end

    % if simRes file already exists: some simulations may have been
    % incorrectly executed and need to repeat
    if isfile(strcat(resPath, 'simRes.mat'))
        load(strcat(resPath, 'simRes.mat'))
    end

    % End of Auto load for crashed simulations

    % set parallel pool if no longer active
    if numWorkers > 1
        poolobj = gcp('nocreate');
        if isempty(poolobj)
            parpool(numWorkers)
        end
    end

    growthRatesTmp={};
    infeasModelsTmp={};
    netProductionTmp={};
    netUptakeTmp={};

    if length(sampNames)-1 > 20
        steps=20;
    else
        steps=length(sampNames);
    end

    % Starting personalized simulations
    % proceed in batches for improved effiency
    for s=1:steps:length(sampNames)
        if length(sampNames)-s>=steps-1
            endPnt=steps-1;
        else
            endPnt=length(sampNames)-s;
        end

        parfor k=s:s+endPnt
            restoreEnvironment(environment);
            changeCobraSolver(solver, 'LP', 0, -1);

            % prepare the variables temporarily storing the simulation results
            netProductionTmp{k}{2} = {};
            netProductionTmp{k}{1} = {};
            netUptakeTmp{k}{1} = {};
            netUptakeTmp{k}{2} = {};
            growthRatesTmp{k}{1} = {};
            growthRatesTmp{k}{2} = {};

            doSim=1;
            % check first if simulations already exist and were done properly
            if ~isempty(netProduction{2,k})
                vals=netProduction{2,k}(find(~cellfun(@isempty,(netProduction{2,k}(:,2)))),2);
                if abs(sum(cell2mat(vals)))> 0.1
                    doSim=0;
                end
            end
            if doSim==1
                % simulations either not done yet or done incorrectly -> go
                sampleID = sampNames{k,1};

                % get diet(s) to load
                diet = readInputTableForPipeline(dietFilePath);
                if ~isempty(intersect(sampNames,diet(:,1)))
                    if length(intersect(sampNames,diet(:,1)))~=length(sampNames)
                        error('The number of inoput diets and samples does not agree!')
                    else
                        loadDiet = diet{find(strcmp(diet(:,1),sampleID)),2};
                    end
                else
                    loadDiet = dietFilePath;
                end

                if ~isempty(hostPath)
                    % microbiota_model=readCbModel(strcat('host_microbiota_model_samp_', sampleID,'.mat'));
                    modelStr=load(strcat('host_microbiota_model_samp_', sampleID,'.mat'));
                    modelF=fieldnames(modelStr);
                    microbiota_model=modelStr.(modelF{1});
                else
                    % microbiota_model=readCbModel(strcat('microbiota_model_samp_', sampleID,'.mat'));
                    modelStr=load(strcat('microbiota_model_samp_', sampleID,'.mat'));
                    modelF=fieldnames(modelStr);
                    microbiota_model=modelStr.(modelF{1});
                end
                model = microbiota_model;
                for j = 1:length(model.rxns)
                    if strfind(model.rxns{j}, 'biomass')
                        model.lb(j) = 0;
                    end
                end

                % adapt constraints
                BiomassNumber=find(strcmp(model.rxns,'communityBiomass'));
                Components = model.mets(find(model.S(:, BiomassNumber)));
                Components = strrep(Components,'_biomass[c]','');
                for j=1:length(Components)
                    % remove constraints on demand reactions to prevent infeasibilities
                    findDm= model.rxns(find(strncmp(model.rxns,[Components{j} '_DM_'],length([Components{j} '_DM_']))));
                    model = changeRxnBounds(model, findDm, 0, 'l');
                    % constrain flux through sink reactions
                    findSink= model.rxns(find(strncmp(model.rxns,[Components{j} '_sink_'],length([Components{j} '_sink_']))));
                    model = changeRxnBounds(model, findSink, -1, 'l');
                end

                model = changeObjective(model, 'EX_microbeBiomass[fe]');
                AllRxn = model.rxns;
                RxnInd = find(cellfun(@(x) ~isempty(strfind(x, '[d]')), AllRxn));
                EXrxn = model.rxns(RxnInd);
                EXrxn = regexprep(EXrxn, 'EX_', 'Diet_EX_');
                model.rxns(RxnInd) = EXrxn;
                model = changeRxnBounds(model, 'communityBiomass', lowerBMBound, 'l');
                model = changeRxnBounds(model, 'communityBiomass', upperBMBound, 'u');
                model=changeRxnBounds(model,model.rxns(strmatch('UFEt_',model.rxns)),1000000,'u');
                model=changeRxnBounds(model,model.rxns(strmatch('DUt_',model.rxns)),1000000,'u');
                model=changeRxnBounds(model,model.rxns(strmatch('EX_',model.rxns)),1000000,'u');

                % set constraints on host exchanges if present
                if ~isempty(hostBiomassRxn)
                    hostEXrxns=find(strncmp(model.rxns,'Host_EX_',8));
                    model=changeRxnBounds(model,model.rxns(hostEXrxns),0,'l');
                    % constrain blood exchanges but make exceptions for metabolites that should be taken up from
                    % blood
                    takeupExch={'h2o','hco3','o2'};
                    takeupExch=strcat('Host_EX_', takeupExch, '[e]b');
                    model=changeRxnBounds(model,takeupExch,-100,'l');
                    % close internal exchanges except for human metabolites known
                    % to be found in the intestine
                    hostIEXrxns=find(strncmp(model.rxns,'Host_IEX_',9));
                    model=changeRxnBounds(model,model.rxns(hostIEXrxns),0,'l');
                    takeupExch={'gchola','tdchola','tchola','dgchol','34dhphe','5htrp','Lkynr','f1a','gncore1','gncore2','dsT_antigen','sTn_antigen','core8','core7','core5','core4','ha','cspg_a','cspg_b','cspg_c','cspg_d','cspg_e','hspg'};
                    takeupExch=strcat('Host_IEX_', takeupExch, '[u]tr');
                    model=changeRxnBounds(model,takeupExch,-1000,'l');
                    % set a minimum and a limit for flux through host biomass
                    % reaction
                    model=changeRxnBounds(model,['Host_' hostBiomassRxn],0.001,'l');
                    model=changeRxnBounds(model,['Host_' hostBiomassRxn],hostBiomassRxnFlux,'u');
                end

                solution_allOpen = optimizeCbModel(model);
                % solution_allOpen=solveCobraLPCPLEX(model,2,0,0,[],0);
                if solution_allOpen.stat==0
                    warning('growthRates detected one or more infeasible models. Please check infeasModels object !')
                    infeasModelsTmp{k} = model.name;
                else
                    growthRatesTmp{k}{1} = solution_allOpen.f;
                    AllRxn = model.rxns;
                    FecalInd  = find(cellfun(@(x) ~isempty(strfind(x,'[fe]')),AllRxn));
                    DietInd  = find(cellfun(@(x) ~isempty(strfind(x,'[d]')),AllRxn));
                    FecalRxn = AllRxn(FecalInd);
                    FecalRxn=setdiff(FecalRxn,'EX_microbeBiomass[fe]','stable');
                    DietRxn = AllRxn(DietInd);

                    %% computing fluxes on the rich diet
                    if rDiet==1 && computeProfiles
                        % remove exchanges that cannot carry flux
                        FecalRxn=intersect(FecalRxn,allFecalExch);
                        DietRxn=intersect(DietRxn,allDietExch);

                        [minFlux,maxFlux]=guidedSim(model,FecalRxn);
                        minFluxFecal = minFlux;
                        maxFluxFecal = maxFlux;
                        [minFlux,maxFlux]=guidedSim(model,DietRxn);
                        minFluxDiet = minFlux;
                        maxFluxDiet = maxFlux;
                        netProductionTmp{k}{1}=exchanges;
                        netUptakeTmp{k}{1}=exchanges;
                        for i =1:length(FecalRxn)
                            [truefalse, index] = ismember(FecalRxn(i), exchanges);
                            netProductionTmp{k}{1}{index,2} = minFluxDiet(i,1);
                            netProductionTmp{k}{1}{index,3} = maxFluxFecal(i,1);
                            netUptakeTmp{k}{1}{index,2} = maxFluxDiet(i,1);
                            netUptakeTmp{k}{1}{index,3} = minFluxFecal(i,1);
                        end
                    end

                    %% Computing fluxes on the input diet

                    % remove exchanges that cannot carry flux
                    FecalRxn=intersect(FecalRxn,allFecalExch);
                    DietRxn=intersect(DietRxn,allDietExch);

                    model_sd=model;
                    if adaptMedium
                        [diet] = adaptVMHDietToAGORA(loadDiet,'Microbiota');
                    else
                        diet = readInputTableForPipeline(loadDiet);  % load the text file with the diet
 
                        for j = 2:length(diet)
                            diet{j, 2} = num2str(-(diet{j, 2}));
                        end
                    end
                    [model_sd] = useDiet(model_sd, diet,0);

                    if includeHumanMets
                        % add the human metabolites
                        for l=1:length(HumanMets)
                            model_sd=changeRxnBounds(model_sd,strcat('Diet_EX_',HumanMets{l},'[d]'),str2num(HumanMets{l,2}),'l');
                        end
                    end

                    solution_sDiet=optimizeCbModel(model_sd);
                    % solution_sDiet=solveCobraLPCPLEX(model_sd,2,0,0,[],0);
                    growthRatesTmp{k}{2}=solution_sDiet.f;
                    if solution_sDiet.stat==0
                        warning('growthRates detected one or more infeasible models. Please check infeasModels object !')
                        infeasModelsTmp{k}= model.name;
                        netProductionTmp{k}{2} = {};
                        netUptakeTmp{k}{2} = {};
                    else
                        if computeProfiles
                            [minFlux,maxFlux]=guidedSim(model_sd,FecalRxn);
                            minFluxFecal = minFlux;
                            maxFluxFecal = maxFlux;
                            [minFlux,maxFlux]=guidedSim(model_sd,DietRxn);
                            minFluxDiet = minFlux;
                            maxFluxDiet = maxFlux;
                            netProductionTmp{k}{2}=exchanges;
                            netUptakeTmp{k}{2}=exchanges;
                            for i =1:length(FecalRxn)
                                [truefalse, index] = ismember(FecalRxn(i), exchanges);
                                netProductionTmp{k}{2}{index,2} = minFluxDiet(i,1);
                                netProductionTmp{k}{2}{index,3} = maxFluxFecal(i,1);
                                netUptakeTmp{k}{2}{index,2} = maxFluxDiet(i,1);
                                netUptakeTmp{k}{2}{index,3} = minFluxFecal(i,1);
                            end
                        end

                        microbiota_model=model_sd;
                        parsave([resPath filesep 'Diet' filesep 'microbiota_model_diet_' sampleID '.mat'],microbiota_model)

                        %% Using personalized diet not documented in MgPipe and bug checked yet!!!!

                        if pDiet==1
                            model_pd=model;
                            [Numbers, Strings] = xlsread(strcat(abundancepath,fileNameDiets));
                            % diet exchange reactions
                            DietNames = Strings(2:end,1);
                            % Diet exchanges for all individuals
                            Diets(:,k) = cellstr(num2str((Numbers(1:end,k))));
                            Dietexchanges = {DietNames{:,1} ; Diets{:,k}}';
                            Dietexchanges = regexprep(Dietexchanges,'EX_','Diet_EX_');
                            Dietexchanges = regexprep(Dietexchanges,'\(e\)','\[d\]');

                            model_pd = setDietConstraints(model_pd,Dietexchanges);

                            if includeHumanMets
                                % add the human metabolites
                                for l=1:length(HumanMets)
                                    model_pd=changeRxnBounds(model_pd,strcat('Diet_EX_',HumanMets{l},'[d]'),str2num(HumanMets{l,2}),'l');
                                end
                            end

                            solution_pdiet=optimizeCbModel(model_pd);
                            %solution_pdiet=solveCobraLPCPLEX(model_pd,2,0,0,[],0);
                            growthRatesTmp{k}{3}=solution_pdiet.f;
                            if solution_pdiet.stat==0
                                warning('growthRates detected one or more infeasible models. Please check infeasModels object !')
                                infeasModelsTmp{k} = model.name;
                                netProductionTmp{k}{3} = {};
                                netUptakeTmp{k}{3} = {};
                            else
                                if computeProfiles
                                    [minFlux,maxFlux]=guidedSim(model_pd,FecalRxn);
                                    minFluxFecal = minFlux;
                                    maxFluxFecal = maxFlux;
                                    [minFlux,maxFlux]=guidedSim(model_pd,DietRxn);
                                    minFluxDiet = minFlux;
                                    maxFluxDiet = maxFlux;
                                    netProductionTmp{k}{3}=exchanges;
                                    netUptakeTmp{k}{3}=exchanges;
                                    for i =1:length(FecalRxn)
                                        [truefalse, index] = ismember(FecalRxn(i), exchanges);
                                        netProductionTmp{k}{3}{index,2} = minFluxDiet(i,1);
                                        netProductionTmp{k}{3}{index,3} = maxFluxFecal(i,1);
                                        netUptakeTmp{k}{3}{index,2} = maxFluxDiet(i,1);
                                        netUptakeTmp{k}{3}{index,3} = minFluxFecal(i,1);
                                    end
                                end

                                % save the model with personalized diet
                                microbiota_model=model_pd;
                                mkdir(strcat(resPath,'Personalized'))
                                parsave([resPath filesep 'Personalized' filesep 'microbiota_model_pDiet_' sampleID '.mat'],microbiota_model)
                            end
                        end
                    end
                end
            end
        end
        for k=s:s+endPnt
            if ~isempty(netProductionTmp{k})
                if ~isempty(netProductionTmp{k}{1})
                    netProduction{1,k} = netProductionTmp{k}{1};
                    netUptake{1,k} = netUptakeTmp{k}{1};
                end
                if ~isempty(netProductionTmp{k}{2})
                    netProduction{2,k} = netProductionTmp{k}{2};
                    netUptake{2,k} = netUptakeTmp{k}{2};
                end
                if size(netProductionTmp{k},1)>2
                    netProduction{3,k} = netProductionTmp{k}{3};
                    netUptake{3,k} = netUptakeTmp{k}{3};
                end
            end
            if ~isempty(growthRatesTmp{k})
                 if ~isempty(growthRatesTmp{k}{1})
                    growthRates{k+1,2} = growthRatesTmp{k}{1};
                    growthRates{k+1,3} = growthRatesTmp{k}{2};
                    if length(growthRatesTmp{k})>2
                        growthRates{1,4} = 'Personalized diet';
                        growthRates{k+1,4} = growthRatesTmp{k}{3};
                    end
                 end
            end
            if ~isempty(infeasModelsTmp) && k <= length(infeasModelsTmp)
                infeasModels{k,1} = infeasModelsTmp{k};
            end
        end
        if ~computeProfiles
            save([resPath filesep 'GrowthRates.mat'],'growthRates')
            save([resPath filesep 'infeasModels.mat'],'infeasModels')
        else
            save(strcat(resPath,'intRes.mat'),'netProduction','netUptake','growthRates','infeasModels')
        end
    end
    % Saving all output of simulations
    cell2csv([resPath filesep 'GrowthRates.csv'],growthRates)
    save([resPath filesep 'infeasModels.mat'],'infeasModels')
    if computeProfiles
        save(strcat(resPath,'simRes.mat'),'netProduction','netUptake','growthRates','infeasModels')
    end
end

end
