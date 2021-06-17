function [exch,modelStoragePath,couplingMatrix] = buildModelStorage(microbeNames,modPath,pruneModels,dietFilePath, includeHumanMets, adaptMedium, numWorkers)
% This function builds the internal exchange space and the coupling
% constraints for models to join within mgPipe so they can be merged into
% microbiome models afterwards. Exchanges that can never carry flux on the
% given diet are removed to reduce computation time.
%
% USAGE
% [exch,modelStoragePath,couplingMatrix] = buildModelStorage(microbeNames,modPath,pruneModels,dietFilePath, includeHumanMets, adaptMedium, numWorkers)
%
% INPUTS
%    microbeNames:           list of microbe models included in the microbiome models
%    modPath:                char with path of directory where models are stored
%    adaptMedium:            boolean indicating if the medium should be adapted through the
%                            adaptVMHDietToAGORA function or used as is (default=true)
%    pruneModels:            boolean indicating whether exchanges and reactions that cannot carry flux
%                            under the given constraints should be removed (default=false).
%                            Recommended for large-scale simulation projects.
%    dietFilePath:           char with path of directory where the diet is saved
%    includeHumanMets:       boolean indicating if human-derived metabolites
%                            present in the gut should be provided to the models (default: true)
%    adaptMedium:            boolean indicating if the medium should be adapted through the
%                            adaptVMHDietToAGORA function or used as is (default=true)
%    numWorkers:             integer indicating the number of cores to use for parallelization
%
% OUTPUTS
%    exch:                   list of exchanged metabolites present in at least one microbe model
%    modelStoragePath:       path to the modified models to join afterwards
%    couplingMatrix:         matrix containing coupling constraints for each model to join
%
% AUTHOR:
%   - Almut Heinken, 05/2021

currentDir=pwd;
mkdir('modelStorage')
cd('modelStorage')
modelStoragePath = pwd;

if numWorkers>0 && ~isempty(ver('parallel'))
    % with parallelization
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(numWorkers)
    end
end

% determine human-derived metabolites present in the gut: primary bile
% amines, mucins, host glycans
if includeHumanMets
    HumanMets={'gchola','-10';'tdchola','-10';'tchola','-10';'dgchol','-10';'34dhphe','-10';'5htrp','-10';'Lkynr','-10';'f1a','-1';'gncore1','-1';'gncore2','-1';'dsT_antigen','-1';'sTn_antigen','-1';'core8','-1';'core7','-1';'core5','-1';'core4','-1';'ha','-1';'cspg_a','-1';'cspg_b','-1';'cspg_c','-1';'cspg_d','-1';'cspg_e','-1';'hspg','-1'};
end

% load diet constraints
if adaptMedium
    [diet] = adaptVMHDietToAGORA(dietFilePath,'AGORA');
else
    diet = readtable(dietFilePath, 'Delimiter', '\t');  % load the text file with the diet
    diet = table2cell(diet);
    for i = 1:length(diet)
        diet{i, 2} = num2str(-(diet{i, 2}));
    end
end

% get all exchanges that can carry flux in at least one model on the given
% diet, including metabolites that can be secreted
exch = {};
for i = 1:size(microbeNames, 1)
    model = readCbModel([modPath filesep microbeNames{i,1} '.mat']);

    exMets = model.mets(~cellfun(@isempty, strfind(model.mets, '[e]')));
    ex_rxns = {};
    for j=1:length(exMets)
        ex_rxns{j}=['EX_' exMets{j}];
         ex_rxns{j}=strrep(ex_rxns{j},'[e]','(e)');
    end
    % account for depracated nomenclature
    ex_rxns=intersect(ex_rxns,model.rxns);
    
    if pruneModels
        % Using input diet
        model = useDiet(model, diet,0);
        
        if includeHumanMets
            % add the human metabolites
            for l=1:length(HumanMets)
                model=changeRxnBounds(model,strcat('EX_',HumanMets{l},'(e)'),str2num(HumanMets{l,2}),'l');
            end
        end
        
        % compute which exchanges can carry flux
        try
            [minFlux,maxFlux]=fastFVA(model,0,'max','ibm_cplex',ex_rxns);
        catch
            [minFlux,maxFlux]=fluxVariability(model,0,'max',ex_rxns);
        end
        minflux=find(abs(minFlux) > 0.00000001);
        maxflux=find(abs(maxFlux) > 0.00000001);
        flux=union(minflux,maxflux);
        
        pruned_ex_rxns = ex_rxns(flux);
        pruned_ex_rxns=strrep(pruned_ex_rxns,'EX_','');
        pruned_ex_rxns=strrep(pruned_ex_rxns,'(e)','[e]');
        exch = union(exch,pruned_ex_rxns);
    else
        ex_rxns=strrep(ex_rxns,'EX_','');
        ex_rxns=strrep(ex_rxns,'(e)','[e]');
        exch = union(exch,ex_rxns);
    end
end

% get already built reconstructions
dInfo = dir(modelStoragePath);
modelList={dInfo.name};
modelList=modelList';
modelList=strrep(modelList,'.mat','');

if length(setdiff(microbeNames,modelList))>0
    %% create a new extracellular space [u] for microbes
    for i = 1:size(microbeNames, 1)
        model = readCbModel([modPath filesep microbeNames{i,1} '.mat']);
        % temp fix
        if isfield(model,'C')
            model=rmfield(model,'C');
            model=rmfield(model,'d');
        end
        
        % removing possible constraints of the bacs
        selExc = findExcRxns(model);
        Reactions2 = model.rxns(find(selExc));
        allex = Reactions2(strmatch('EX', Reactions2));
        biomass = allex(find(strncmp(allex,'EX_bio',6)));
        finrex = setdiff(allex, biomass);
        model = changeRxnBounds(model, finrex, -1000, 'l');
        model = changeRxnBounds(model, finrex, 1000, 'u');
        
        if pruneModels
            % remove exchange reactions that cannot carry flux
            try
                [minFlux,maxFlux]=fastFVA(model,0,'max','ibm_cplex',finrex);
            catch
                [minFlux,maxFlux]=fluxVariability(model,0,'max',finrex);
            end
            nominflux=find(abs(minFlux) < 0.00000001);
            nomaxflux=find(abs(maxFlux) < 0.00000001);
            noflux=intersect(nominflux,nomaxflux);
            model=removeRxns(model,finrex(noflux));
            
            % additionally, remove exchanges that are neither consumed or
            % secreted by any microbe on this diet
            selExc = findExcRxns(model);
            Reactions2 = model.rxns(find(selExc));
            allex = Reactions2(strmatch('EX', Reactions2));
            [C]=setdiff(allex,exch);
            model=removeRxns(model,C);
            
%             % removing blocked reactions from the bacs
%             BlockedRxns = identifyFastBlockedRxns(model,model.rxns);
%             model= removeRxns(model, BlockedRxns);
        end
        
        model = convertOldStyleModel(model);
        exmod = model.rxns(strncmp('EX_', model.rxns, 3));  % find exchange reactions
        eMets = model.mets(~cellfun(@isempty, strfind(model.mets, '[e]')));  % exchanged metabolites
        dummyMicEU = createModel();
        %dummyMicEU = makeDummyModel(2 * size(eMets, 1), size(eMets, 1));
        dummyMicEUmets = [strcat(strcat(microbeNames{i, 1}, '_'), regexprep(eMets, '\[e\]', '\[u\]')); regexprep(eMets, '\[e\]', '\[u\]')];
        dummyMicEU = addMultipleMetabolites(dummyMicEU,dummyMicEUmets);
        nMets = numel(eMets);
        S = [speye(nMets);-speye(nMets)];
        lbs = repmat(-1000,nMets,1);
        ubs = repmat(1000,nMets,1);
        names = strcat(strcat(microbeNames{i, 1}, '_'), 'IEX_', regexprep(eMets, '\[e\]', '\[u\]'), 'tr');
        dummyMicEU = addMultipleReactions(dummyMicEU,names,dummyMicEUmets,S,'lb',lbs,'ub',ubs);
        model = removeRxns(model, exmod);
        model.rxns = strcat(strcat(microbeNames{i, 1}, '_'), model.rxns);
        model.mets = strcat(strcat(microbeNames{i, 1}, '_'), regexprep(model.mets, '\[e\]', '\[u\]'));  % replace [e] with [u]
        [model] = mergeTwoModels(dummyMicEU, model, 2, false, false);
        
        %finish up by A: removing duplicate reactions
        %We will lose information here, but we will just remove the duplicates.
        [model,rxnToRemove,rxnToKeep]= checkDuplicateRxn(model,'S',1,0,1);
        
        writeCbModel(model,'format','mat','fileName',[microbeNames{i,1} '.mat']);  % store model
        
        % add coupling constraints and store them
        IndRxns=find(strncmp(model.rxns,[microbeNames{i,1} '_'],length(microbeNames{i,1})+1));%finding indixes of specific reactions
        % find the name of biomass reaction in the microbe model
        bioRxn=model.rxns{find(strncmp(model.rxns,strcat(microbeNames{i,1},'_bio'),length(char(strcat(microbeNames{i,1},'_bio')))))};
        model=coupleRxnList2Rxn(model,model.rxns(IndRxns(1:length(model.rxns(IndRxns(:,1)))-1,1)),bioRxn,400,0); %couple the specific reactions
        couplingMatrix{i,1}=model.C;
        couplingMatrix{i,2}=model.d;
        couplingMatrix{i,3}=model.dsense;
        couplingMatrix{i,4}=model.ctrs;
    end
end

cd(currentDir)

end