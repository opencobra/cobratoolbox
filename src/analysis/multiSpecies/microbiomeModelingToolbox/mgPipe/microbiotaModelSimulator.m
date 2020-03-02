function [ID, fvaCt, nsCt, presol, inFesMat] = microbiotaModelSimulator(resPath, setup, sampName, dietFilePath, rDiet, pDiet, extSolve, patNumb, fvaType)
% This function is called from the MgPipe pipeline. Its purpose is to apply
% different diets (according to the user?s input) to the microbiota models
% and run simulations computing FVAs on exchanges reactions of the microbiota
% models. The output is saved in multiple .mat objects. Intermediate saving
% checkpoints are present.
%
% USAGE:
%
%   [ID, fvaCt, nsCt, presol, inFesMat] = microbiotaModelSimulator(resPath, setup, sampName, dietFilePath, rDiet, pDiet, extSolve, patNumb, fvaType)
%
% INPUTS:
%    resPath:            char with path of directory where results are saved
%    setup:              "global setup" model in COBRA model structure format
%    sampName:           cell array with names of individuals in the study
%    dietFilePath:       path to and name of the text file with dietary information
%    rDiet:              number (double) indicating if to simulate a rich diet
%    pDiet:              number (double) indicating if a personalized diet
%                        is available and should be simulated
%    extSolve:           number (double) indicating if simulations will be
%                        not run in matlab but externally (models with imposed
%                        constraints are saved)
%    patNumb:            number (double) of individuals in the study
%    fvaType:            number (double) which FVA function to use(fastFVA =1)
%
% OUTPUTS:
%    ID:                 cell array with list of all unique Exchanges to diet/
%                        fecal compartment
%    fvaCt:              cell array containing FVA values for maximal uptake
%                        and secretion for setup lumen / diet exchanges
%    nsCt:               cell array containing FVA values for minimal uptake
%                        and secretion for setup lumen / diet exchanges
%    presol              array containing values of microbiota models
%                        objective function
%    inFesMat            cell array with names of infeasible microbiota models
%
% .. Author: Federico Baldini, 2017-2018

allex = setup.rxns(strmatch('EX', setup.rxns));  % Creating list of all unique Exchanges to diet/fecal compartment
ID = regexprep(allex, '\[d\]', '\[fe\]');
ID = unique(ID, 'stable');
ID = setdiff(ID, 'EX_biomass[fe]', 'stable');


mapP = detectOutput(resPath, 'simRes.mat');
if ~isempty(mapP)
    s = 'simulations already done, file found: loading from resPath';
    disp(s)
    load(strcat(resPath, 'simRes.mat'))
else
% Cell array to store results
fvaCt = cell(3, patNumb);
nsCt = cell(3, patNumb);
inFesMat = {}
presol = {}

% Auto load for crashed simulations
mapP = detectOutput(resPath, 'intRes.mat')
if isempty(mapP)
    startIter = 2
else
    s = 'simulation checkpoint file found: recovering crashed simulation';
    disp(s)
    load(strcat(resPath, 'intRes.mat'))

% Detecting when execution halted
    for o = 1:length(fvaCt(2, :))
        if isempty(fvaCt{2, o}) == 0
            t = o
        end
    end
    startIter = t + 2
end
% End of Auto load for crashed simulations


% Starting personalized simulations
for k = startIter:(patNumb + 1)
    idInfo = cell2mat(sampName((k - 1), 1));
    microbiota_model=readCbModel(strcat('microbiota_model_samp_', idInfo,'.mat'))
    model = microbiota_model;
    for j = 1:length(model.rxns)
        if strfind(model.rxns{j}, 'biomass')
            model.lb(j) = 0;
        end
    end
    model = changeObjective(model, 'EX_microbeBiomass[fe]');
    AllRxn = model.rxns;
    RxnInd = find(cellfun(@(x) ~isempty(strfind(x, '[d]')), AllRxn));
    EXrxn = model.rxns(RxnInd);
    EXrxn = regexprep(EXrxn, 'EX_', 'Diet_EX_');
    model.rxns(RxnInd) = EXrxn;
    %model = changeRxnBounds(model, 'communityBiomass', 0.1, 'l');
    model = changeRxnBounds(model, 'communityBiomass', 0.4, 'l');
    model = changeRxnBounds(model, 'communityBiomass', 1, 'u');
    model=changeRxnBounds(model,model.rxns(strmatch('UFEt_',model.rxns)),1000000,'u');
    model=changeRxnBounds(model,model.rxns(strmatch('DUt_',model.rxns)),1000000,'u');
    model=changeRxnBounds(model,model.rxns(strmatch('EX_',model.rxns)),1000000,'u');
    % set a solver if not done yet
    global CBT_LP_SOLVER
    solver = CBT_LP_SOLVER;
    if isempty(solver)
        initCobraToolbox(false); %Don't update the toolbox automatically
    end
    solution_allOpen = solveCobraLP(buildLPproblemFromModel(model));
    % solution_allOpen=solveCobraLPCPLEX(model,2,0,0,[],0);
    if solution_allOpen.stat==0
        warning('Presolve detected one or more infeasible models. Please check InFesMat object !')
        inFesMat{k, 1} = model.name
    else
        presol{k, 1} = solution_allOpen.obj;
        if extSolve==0
            AllRxn = model.rxns;
            FecalInd  = find(cellfun(@(x) ~isempty(strfind(x,'[fe]')),AllRxn));
            DietInd  = find(cellfun(@(x) ~isempty(strfind(x,'[d]')),AllRxn));
            FecalRxn = AllRxn(FecalInd);
            FecalRxn=setdiff(FecalRxn,'EX_microbeBiomass[fe]','stable');
            DietRxn = AllRxn(DietInd);
            if rDiet==1
                [minFlux,maxFlux]=guidedSim(model,fvaType,FecalRxn);
                sma=maxFlux;
                sma2=minFlux;
                [minFlux,maxFlux]=guidedSim(model,fvaType,DietRxn);
                smi=minFlux;
                smi2=maxFlux;
                maxFlux=sma;
                minFlux=smi;
                fvaCt{1,(k-1)}=ID;
                nsCt{1,(k-1)}=ID;
                for i =1:length(FecalRxn)
                    [truefalse, index] = ismember(FecalRxn(i), ID);
                    fvaCt{1,(k-1)}{index,2}=minFlux(i,1);
                    fvaCt{1,(k-1)}{index,3}=maxFlux(i,1);
                    nsCt{1,(k-1)}{index,2}=smi2(i,1);
                    nsCt{1,(k-1)}{index,3}=sma2(i,1);
                end
            end
        else
            microbiota_model=model;
            mkdir(strcat(resPath,'Rich'))
            save([resPath 'Rich' filesep 'microbiota_model_richD_' idInfo '.mat'],'microbiota_model')
        end
        
        
        % Using standard diet
        
        model_sd=model;
        [adaptedDiet] = adaptVMHDietToAGORA(dietFilePath,'Microbiota');
        [model_sd] = useDiet(model_sd, adaptedDiet,0);
        if exist('unfre') ==1 %option to directly add other essential nutrients
            warning('Feasibility forced with addition of essential nutrients')
            model_sd=changeRxnBounds(model_sd, unfre,-0.1,'l');
        end
        solution_sDiet=solveCobraLP(buildLPproblemFromModel(model_sd));
        % solution_sDiet=solveCobraLPCPLEX(model_sd,2,0,0,[],0);
        presol{k,2}=solution_sDiet.obj;
        if solution_sDiet.stat==0
            warning('Presolve detected one or more infeasible models. Please check InFesMat object !')
            inFesMat{k,2}= model.name;
        else
            
            if extSolve==0
                [minFlux,maxFlux]=guidedSim(model_sd,fvaType,FecalRxn);
                sma=maxFlux;
                sma2=minFlux;
                [minFlux,maxFlux]=guidedSim(model_sd,fvaType,DietRxn);
                smi=minFlux;
                smi2=maxFlux;
                maxFlux=sma;
                minFlux=smi;
                
                fvaCt{2,(k-1)}=ID;
                nsCt{2,(k-1)}=ID;
                for i =1:length(FecalRxn)
                    [truefalse, index] = ismember(FecalRxn(i), ID);
                    fvaCt{2,(k-1)}{index,2}=minFlux(i,1);
                    fvaCt{2,(k-1)}{index,3}=maxFlux(i,1);
                    nsCt{2,(k-1)}{index,2}=smi2(i,1);
                    nsCt{2,(k-1)}{index,3}=sma2(i,1);
                end
            else
                microbiota_model=model_sd;
                mkdir(strcat(resPath,'Standard'))
                save([resPath 'Standard' filesep 'microbiota_model_richD_' idInfo '.mat'],'microbiota_model')
            end
            
            if extSolve==0
                save(strcat(resPath,'intRes.mat'),'fvaCt','presol','inFesMat', 'nsCt')
                
            end
            
            
            % Using personalized diet not documented in MgPipe and bug checked yet!!!!
            
            if pDiet==1
                model_pd=model;
                [Numbers, Strings] = xlsread(strcat(abundancepath,fileNameDiets));
                usedIDs = Strings(1,2:end)';
                % diet exchange reactions
                DietNames = Strings(2:end,1);
                % Diet exchanges for all individuals
                Diets(:,k-1) = cellstr(num2str((Numbers(1:end,k-1))));
                DietID = {DietNames{:,1} ; Diets{:,k-1}}';
                DietID = regexprep(DietID,'EX_','Diet_EX_');
                DietID = regexprep(DietID,'\(e\)','\[d\]');
                
                model_pd = setDietConstraints(model_pd,DietID);
                solution_pdiet=solveCobraLP(buildLPproblemFromModel(model_pd))
                %solution_pdiet=solveCobraLPCPLEX(model_pd,2,0,0,[],0);
                presol{k,3}=solution_pdiet.obj;
                if isnan(solution_pdiet.obj)
                    warning('Presolve detected one or more infeasible models. Please check InFesMat object !')
                    inFesMat{k,3}= model.name;
                else
                    
                    if extSolve==0
                        [minFlux,maxFlux]=guidedSim(model_pd,fvaType,FecalRxn);
                        sma=maxFlux;
                        [minFlux,maxFlux]=guidedSim(model_pd,fvaType,DietRxn);
                        smi=minFlux;
                        maxFlux=sma;
                        minFlux=smi;
                        fvaCt{3,(k-1)}=ID;
                        for i =1:length(FecalRxn)
                            [truefalse, index] = ismember(FecalRxn(i), ID);
                            fvaCt{3,(k-1)}{index,2}=minFlux(i,1);
                            fvaCt{3,(k-1)}{index,3}=maxFlux(i,1);
                        end
                    else
                        microbiota_model=model_pd;
                        mkdir(strcat(resPath,'Personalized'))
                        save([resPath 'Standard' filesep 'microbiota_model_richD_' idInfo '.mat'],'microbiota_model')
                    end
                    
                    
                end
            end
        end
    end
end

% Saving all output of simulations
if extSolve==0
  save(strcat(resPath,'simRes.mat'),'fvaCt','presol','inFesMat', 'nsCt')
end
end
end
