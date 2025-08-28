function [activeExMets,couplingMatrix] = buildModelStorage(microbeNames,modPath, numWorkers,pruneModels,biomasses)
% This function builds the internal exchange space and the coupling
% constraints for models to join within mgPipe so they can be merged into
% microbiome models afterwards. exchanges that can never carry flux on the
% given diet are removed to reduce computation time.
%
% USAGE
%    [activeExMets,couplingMatrix] = buildModelStorage(microbeNames,modPath,numWorkers,pruneModels)
%
% INPUTS
%    microbeNames:           list of microbe models included in the microbiome models
%    modPath:                char with path of directory where models are stored
%    numWorkers:             integer indicating the number of cores to use for parallelization
%    pruneModels:            boolean indicating whether reactions that do not carry flux on the
%                            input diet should be removed from the microbe models. 
%                            Recommended for large datasets (default: false)
%    biomasses:              Cell array containing names of biomass objective functions
%                            of models to join. Needs to be the same length as 
%                            the length of models in the abundance file.
%
% OUTPUTS
%    activeExMets:           list of exchanged metabolites present in at
%                            least one microbe model that can carry flux
%    couplingMatrix:         matrix containing coupling constraints for each model to join

%
% AUTHOR:
%   - Almut Heinken, 05/2021
%                    06/2022: added option to remove blocked reactions
%                    12/2022: Added an optional input to manually 
%                             define biomass objective functions 
%                             for non-AGORA reconstructions     


mkdir('modelStorage')

if numWorkers>0 && ~isempty(ver('parallel'))
    % with parallelization
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(numWorkers)
    end
end

% get all exchanges that can carry flux in at least one model
activeExMets = {};
for i = 1:size(microbeNames, 1)
    model = readCbModel([modPath filesep microbeNames{i,1} '.mat']);

    % rename biomass objective functions if they are manually provided
    if ~isempty(biomasses)
        findBM = find(strcmp(model.rxns,biomasses{i}));
        if isempty(findBM)
            error('Defined biomass objective functions are not correct!')
        end
        model.rxns{findBM,1} = ['biomass' num2str(i)];
    end

    ex_mets = model.mets(~cellfun(@isempty, strfind(model.mets, '[e]')));
    ex_rxns = {};
    for j=1:length(ex_mets)
        ex_rxns{j}=['EX_' ex_mets{j}];
        ex_rxns{j}=strrep(ex_rxns{j},'[e]','(e)');
    end
    % account for depracated nomenclature
    ex_rxns=intersect(ex_rxns,model.rxns);

    % compute which exchanges can carry flux.
    % To avoid bugs, do this with coupling constraints implemented

    % find the name of biomass reaction in the microbe model
    bioRxn=model.rxns{find(strncmp(model.rxns,'bio',3))};
    if isempty(bioRxn)
        error('Please define the biomass objective functions for each model manually through the biomasses input parameter.')
    end
    model=coupleRxnList2Rxn(model,model.rxns,bioRxn,400,0); %couple the specific reactions

    currentDir = pwd;
    try
        [minFlux,maxFlux]=fastFVA(model,0,'max','ibm_cplex',ex_rxns);
    catch
        cd(currentDir)
        [minFlux,maxFlux]=fluxVariability(model,0,'max',ex_rxns);
    end
    
    % get all exchange reactions that can carry minimal and/or maximal
    % flux
    minflux=ex_rxns(find(abs(minFlux) > 0.00000001));
    maxflux=ex_rxns(find(abs(maxFlux) > 0.00000001));
    pruned_ex_rxns=union(minflux,maxflux);
    pruned_ex_rxns=strrep(pruned_ex_rxns,'EX_','');
    pruned_ex_rxns=strrep(pruned_ex_rxns,'(e)','[e]');
    activeExMets = union(activeExMets,pruned_ex_rxns);
end

%% create a new extracellular space [u] for microbes
couplingMatrixTmp = {};
modelsTmp{i} = {};

parfor i = 1:size(microbeNames, 1)
    model = readCbModel([modPath filesep microbeNames{i,1} '.mat']);

    % rename biomass objective functions if they are manually provided
    if ~isempty(biomasses)
        findBM = find(strcmp(model.rxns,biomasses{i}));
        model.rxns{findBM,1} = ['biomass' num2str(i)];
    end

    % make sure biomass reaction is the objective function
    bio=model.rxns{find(strncmp(model.rxns,'bio',3)),1};
    model=changeObjective(model,bio);

    % removing possible constraints of the bacs
    selExc = findExcRxns(model);
    Reactions2 = model.rxns(find(selExc));
    allex = Reactions2(strmatch('EX', Reactions2));
    biomass = allex(find(strncmp(allex,'bio',3)));
    finrex = setdiff(allex, biomass);
    model = changeRxnBounds(model, finrex, -1000, 'l');
    model = changeRxnBounds(model, finrex, 1000, 'u');

    if pruneModels
        % remove blocked reactions from the models
        % To avoid bugs, do this with coupling constraints implemented
        
        modelPrevious = model;
        
        % find the name of biomass reaction in the microbe model
        bioRxn=model.rxns{find(strncmp(model.rxns,'bio',3))};
        model=coupleRxnList2Rxn(model,model.rxns,bioRxn,400,0); %couple the specific reactions
        
        % findBlockedReaction may sometimes fail due to infeasiblity
        try
            BlockedReaction = findBlockedReaction(model,'L2');
            model = modelPrevious;
            model=removeRxns(model,BlockedReaction);
        catch
            [~,BlockedRxns] = identifyBlockedRxns(model);
            model = modelPrevious;
            model=removeRxns(model,BlockedRxns.allRxns);
        end
    end
    
    % temp fix
    if isfield(model,'C')
        model=rmfield(model,'C');
        model=rmfield(model,'d');
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

    modelsTmp{i} = model;
    % add coupling constraints and store them
    IndRxns=find(strncmp(model.rxns,[microbeNames{i,1} '_'],length(microbeNames{i,1})+1));%finding indixes of specific reactions
    % find the name of biomass reaction in the microbe model
    bioRxn=model.rxns{find(strncmp(model.rxns,strcat(microbeNames{i,1},'_bio'),length(char(strcat(microbeNames{i,1},'_bio')))))};
    model=coupleRxnList2Rxn(model,model.rxns(IndRxns(1:length(model.rxns(IndRxns(:,1)))-1,1)),bioRxn,400,0); %couple the specific reactions
    couplingMatrixTmp{i}{1}=model.C;
    couplingMatrixTmp{i}{2}=model.d;
    couplingMatrixTmp{i}{3}=model.dsense;
    couplingMatrixTmp{i}{4}=model.ctrs;
end
for i = 1:size(microbeNames, 1)
    couplingMatrix{i,1}=couplingMatrixTmp{i}{1};
    couplingMatrix{i,2}=couplingMatrixTmp{i}{2};
    couplingMatrix{i,3}=couplingMatrixTmp{i}{3};
    couplingMatrix{i,4}=couplingMatrixTmp{i}{4};
    model = modelsTmp{i};
    writeCbModel(model,'format','mat','fileName',[pwd filesep 'modelStorage' filesep microbeNames{i,1} '.mat']);  % store model
end

end