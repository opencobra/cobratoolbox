function [exch,modelStoragePath,couplingMatrix] = buildModelStorage(microbeNames,modPath,numWorkers)
% This function builds the internal exchange space and the coupling
% constraints for models to join within mgPipe so they can be merged into
% microbiome models afterwards.
%
% USAGE
% [exch,modelStoragePath,couplingMatrix] = buildModelStorage(microbeNames,modPath,numWorkers)
%
% INPUTS
%    modPath:                char with path of directory where models are stored
%    microbeNames:           list of microbe models included in the microbiome models
%    numWorkers:             integer indicating the number of cores to use for parallelization
%
% OUTPUTS
%    exch:                   list of exchanges present in at least one microbe model
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

exch = {};
for j = 1:size(microbeNames, 1)
    model = readCbModel([modPath filesep microbeNames{j,1} '.mat']);
    %exch = union(exch, model.mets(find(sum(model.S(:, strncmp('EX_', model.rxns, 3)), 2) ~= 0)));
    exStruct = findSExRxnInd(model);
    new_exch = findMetsFromRxns(model,model.rxns(exStruct.ExchRxnBool & ~exStruct.biomassBool));
    exch = union(exch,new_exch);
end

% get already built reconstructions
dInfo = dir(modelStoragePath);
modelList={dInfo.name};
modelList=modelList';
modelList=strrep(modelList,'.mat','');
microbesNames=setdiff(microbeNames,modelList);

if length(microbesNames)>0
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
        
        % removing blocked reactions from the bacs
        %BlockedRxns = identifyFastBlockedRxns(model,model.rxns, printLevel);
        %model= removeRxns(model, BlockedRxns);
        %BlockedReaction = findBlockedReaction(model,'L2')
        
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
        
        writeCbModel(model,'format','mat','fileName',[microbeNames{j,1} '.mat']);  % store model
        
        % add coupling constraints and store them
        IndRxns=find(strncmp(model.rxns,[microbeNames{j,1} '_'],length(microbeNames{i,1})+1));%finding indixes of specific reactions
        % find the name of biomass reaction in the microbe model
        bioRxn=model.rxns{find(strncmp(model.rxns,strcat(microbeNames{j,1},'_bio'),length(char(strcat(microbeNames{i,1},'_bio')))))};
        model=coupleRxnList2Rxn(model,model.rxns(IndRxns(1:length(model.rxns(IndRxns(:,1)))-1,1)),bioRxn,400,0); %couple the specific reactions
        couplingMatrix{j,1}=model.C;
        couplingMatrix{j,2}=model.d;
        couplingMatrix{j,3}=model.dsense;
        couplingMatrix{j,4}=model.ctrs;
    end
end

cd(currentDir)

end