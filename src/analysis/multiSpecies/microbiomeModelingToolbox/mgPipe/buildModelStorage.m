function [exch,modelStoragePath] = buildModelStorage(microbeNames,modPath)

currentDir=pwd;
mkdir('modelStorage')
cd('modelStorage')
modelStoragePath = pwd;

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
    for j = 1:size(microbeNames, 1)
        model = readCbModel([modPath filesep microbeNames{j,1} '.mat']);
        % temp fix
        if isfield(model,'C')
            model=rmfield(model,'C');
            model=rmfield(model,'d');
        end
        %
        
        % removing possible constraints of the bacs
        selExc = findExcRxns(model);
        Reactions2 = model.rxns(find(selExc));
        allex = Reactions2(strmatch('EX', Reactions2));
        biomass = allex(find(strncmp(allex,'bio',3)));
        finrex = setdiff(allex, biomass);
        model = changeRxnBounds(model, finrex, -1000, 'l');
        model = changeRxnBounds(model, finrex, 1000, 'u');
        
        % removing blocked reactions from the bacs
        %BlockedRxns = identifyFastBlockedRxns(model,model.rxns, printLevel);
        %model= removeRxns(model, BlockedRxns);
        %BlockedReaction = findBlockedReaction(model,'L2')
        
        model = convertOldStyleModel(model);
        exmod = model.rxns(strncmp('EX_', model.rxns, 3));  % find exchange reactions
        eMets = model.mets(~cellfun(@isempty, strfind(model.mets, '[e]')));  % exchanged metabolites
        dummyMicEU = createModel();
        %dummyMicEU = makeDummyModel(2 * size(eMets, 1), size(eMets, 1));
        dummyMicEUmets = [strcat(strcat(microbeNames{j, 1}, '_'), regexprep(eMets, '\[e\]', '\[u\]')); regexprep(eMets, '\[e\]', '\[u\]')];
        dummyMicEU = addMultipleMetabolites(dummyMicEU,dummyMicEUmets);
        nMets = numel(eMets);
        S = [speye(nMets);-speye(nMets)];
        lbs = repmat(-1000,nMets,1);
        ubs = repmat(1000,nMets,1);
        names = strcat(strcat(microbeNames{j, 1}, '_'), 'IEX_', regexprep(eMets, '\[e\]', '\[u\]'), 'tr');
        dummyMicEU = addMultipleReactions(dummyMicEU,names,dummyMicEUmets,S,'lb',lbs,'ub',ubs);
        model = removeRxns(model, exmod);
        model.rxns = strcat(strcat(microbeNames{j, 1}, '_'), model.rxns);
        model.mets = strcat(strcat(microbeNames{j, 1}, '_'), regexprep(model.mets, '\[e\]', '\[u\]'));  % replace [e] with [u]
        [model] = mergeTwoModels(dummyMicEU, model, 2, false, false);
        
        %finish up by A: removing duplicate reactions
        %We will lose information here, but we will just remove the duplicates.
        [model,rxnToRemove,rxnToKeep]= checkDuplicateRxn(model,'S',1,0,1);
        
        writeCbModel(model,'format','mat','fileName',[microbeNames{j,1} '.mat']);  % store model
    end
end

cd(currentDir)

end