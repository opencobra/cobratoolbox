function [activeExMets,modelStoragePath,couplingMatrix] = buildModelStorage(microbeNames,modPath,numWorkers,removeBlockedRxns)
% This function builds the internal exchange space and the coupling
% constraints for models to join within mgPipe so they can be merged into
% microbiome models afterwards. exchanges that can never carry flux on the
% given diet are removed to reduce computation time.
%
% USAGE
%    [activeExMets,modelStoragePath,couplingMatrix] = buildModelStorage(microbeNames,modPath,numWorkers)
%
% INPUTS
%    microbeNames:           list of microbe models included in the microbiome models
%    modPath:                char with path of directory where models are stored
%    numWorkers:             integer indicating the number of cores to use for parallelization
%    removeBlockedRxns:      Remove reactions blocked on the input diet to
%                            reduce computation time (default=false)
%
% OUTPUTS
%    activeExMets:           list of exchanged metabolites present in at
%                            least one microbe model that can carry flux
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

% get all exchanges that can carry flux in at least one model on the given
% diet, including metabolites that can be secreted
activeExMets = {};
for i = 1:size(microbeNames, 1)
    model = readCbModel([modPath filesep microbeNames{i,1} '.mat']);

    ex_mets = model.mets(~cellfun(@isempty, strfind(model.mets, '[e]')));
    ex_rxns = {};
    for j=1:length(ex_mets)
        ex_rxns{j}=['EX_' ex_mets{j}];
         ex_rxns{j}=strrep(ex_rxns{j},'[e]','(e)');
    end
    % account for depracated nomenclature
    ex_rxns=intersect(ex_rxns,model.rxns);

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
        activeExMets = union(activeExMets,pruned_ex_rxns);
end

%% create a new extracellular space [u] for microbes
for i = 1:size(microbeNames, 1)
    model = readCbModel([modPath filesep microbeNames{i,1} '.mat']);
    % temp fix
    if isfield(model,'C')
        model=rmfield(model,'C');
        model=rmfield(model,'d');
    end
    %
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
    
    if removeBlockedRxns
        % remove blocked reactions from the models
        tic
        BlockedRxns = identifyFastBlockedRxns(model,model.rxns, 1,1e-8);
        toc
        model= removeRxns(model, BlockedRxns);
        BlockedReaction = findBlockedReaction(model,'L2');
        model=removeRxns(model,BlockedReaction);
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
    
    writeCbModel(model,'format','mat','fileName',[modelStoragePath filesep microbeNames{i,1} '.mat']);  % store model
    
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

cd(currentDir)
end