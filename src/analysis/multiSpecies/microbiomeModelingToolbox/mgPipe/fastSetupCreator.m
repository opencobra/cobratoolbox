function model = fastSetupCreator(models, microbeNames, host, objre)
% creates a microbiota model (min 1 microbe) that can be coupled with a host
% model. Microbes and host are connected with a lumen compartment [u], host
% can secrete metabolites into body fluids [b]. Diet is simulated as uptake
% through the compartment [d], transporters are unidirectional from [d] to
% [u]. Secretion goes through the fecal compartment [fe], transporters are
% unidirectional from [u] to [fe].
% Reaction types
% Diet exchange: 'EX_met[d]': 'met[d] <=>'
% Diet transporter: 'DUt_met': 'met[d] -> met[u]'
% Fecal transporter: 'UFEt_met': 'met[u] -> met[fe]'
% Fecal exchanges: 'EX_met[fe]': 'met[fe] <=>'
% Microbe uptake/secretion: 'Microbe_IEX_met[c]tr': 'Microbe_met[c] <=> met[u]'
% Host uptake/secretion lumen: 'Host_IEX_met[c]tr': 'Host_met[c] <=> met[u]'
% Host exchange body fluids: 'Host_EX_met(e)b': 'Host_met[b] <=>'
%
% INPUTS:
%    models:              nx1 cell array that contains n microbe models in
%                         COBRA model structure format
%    microbeNames:        nx1 cell array of n unique strings that represent
%                         each microbe model. Reactions and metabolites of
%                         each microbe will get the corresponding
%                         microbeNames (e.g., 'Ecoli') prefix. Reactions
%                         will be named 'Ecoli_RxnAbbr' and metabolites
%                         'Ecoli_MetAbbr[c]').
%    host:                Host COBRA model structure, can be left empty if
%                         there is no host model
%    objre:               char with reaction name of objective function of organisms
%
% OUTPUT:
%    model:               COBRA model structure with all models combined
%
% .. Author: Stefania Magnusdottir and Federico Baldini 2016-2018

if ~isempty(host)  % Get list of all exchanged metabolites
    %exch = host.mets(find(sum(host.S(:, strncmp('EX_', host.rxns, 3)), 2) ~= 0));
    exStruct = findSExRxnInd(host);
    exch = findMetsFromRxns(host,host.rxns(exStruct.ExchRxnBool & ~exStruct.biomassBool));
else
    exch = {};
end
 for j = 1:size(models, 1)
    model = models{j, 1};
    %exch = union(exch, model.mets(find(sum(model.S(:, strncmp('EX_', model.rxns, 3)), 2) ~= 0)));
    exStruct = findSExRxnInd(model);
    new_exch = findMetsFromRxns(model,model.rxns(exStruct.ExchRxnBool & ~exStruct.biomassBool));
    exch = union(exch,new_exch);
 end

% The biomass 'biomass[c]' should not be inserted in the list of exchanges.
% Hence it will be removed.
rmBio=strrep(objre, 'EX_', '');
rmBio=strrep(rmBio, '(e)', '[c]');
exch = setdiff(exch, rmBio);
%% Create additional compartments for dietary compartment and fecal secretion.

% Create dummy model with [d], [u], and [fe] rxns
dummy = createModel();
umets = unique(exch);
orderedMets = unique([strrep(exch, '[e]', '[d]'); strrep(exch, '[e]', '[u]'); strrep(exch, '[e]', '[fe]')]);
mets = [strrep(umets, '[e]', '[d]'); strrep(umets, '[e]', '[u]'); strrep(umets, '[e]', '[fe]')];
dummy = addMultipleMetabolites(dummy,orderedMets);

nMets = numel(umets);
stoich = [-speye(nMets),-speye(nMets),sparse(nMets,nMets),sparse(nMets,nMets);...
          sparse(nMets,nMets),speye(nMets),-speye(nMets),sparse(nMets,nMets);...
          sparse(nMets,nMets),sparse(nMets,nMets),speye(nMets),-speye(nMets)];
lbs = [repmat(-1000,nMets,1);zeros(nMets,1);zeros(nMets,1);repmat(-1000,nMets,1)];
ubs = repmat(1000,4*nMets,1);
rxnNames = [strcat('EX_',mets(1:nMets));...
            strcat('DUt_',strrep(umets,'[e]',''));...
            strcat('UFEt_',strrep(umets,'[e]',''));...
            strcat('EX_',strrep(umets, '[e]', '[fe]'))];
dummy = addMultipleReactions(dummy,rxnNames,mets,stoich,'lb',lbs,'ub',ubs');
order = [1:nMets;nMets+1:2*nMets;2*nMets+1:3*nMets;3*nMets+1:4*nMets];
order = order(:);
dummy = updateFieldOrderForType(dummy,'rxns',order);
%Now, we could 'reorder' this reaction list but I'm not sure its necessary.
% 
% cnt = 0;
% for j = 1:size(exch, 1)
%     mdInd = find(ismember(dummy.mets, strrep(exch{j, 1}, '[e]', '[d]')));
%     muInd = find(ismember(dummy.mets, strrep(exch{j, 1}, '[e]', '[u]')));  % finding indexes for elements of all exchange
%     mfeInd = find(ismember(dummy.mets, strrep(exch{j, 1}, '[e]', '[fe]')));
%     % diet exchange
%     cnt = cnt + 1;
%     dummy.rxns{cnt, 1} = strcat('EX_', strrep(exch{j, 1}, '[e]', '[d]'));
%     dummy.S(mdInd, cnt) = -1;
%     dummy.lb(cnt, 1) = -1000;
%     dummy.ub(cnt, 1) = 1000;
%     % diet-lumen transport
%     cnt = cnt + 1;  % counts rxns
%     dummy.rxns{cnt, 1} = strcat('DUt_', strrep(exch{j, 1}, '[e]', ''));
%     dummy.S(mdInd, cnt) = -1;  % taken up from diet
%     dummy.S(muInd, cnt) = 1;  % secreted into lumen
%     dummy.ub(cnt, 1) = 1000;
%     % lumen-feces transport
%     cnt = cnt + 1;  % counts rxns
%     dummy.rxns{cnt, 1} = strcat('UFEt_', strrep(exch{j, 1}, '[e]', ''));
%     dummy.S(muInd, cnt) = -1;  % taken up from lumen
%     dummy.S(mfeInd, cnt) = 1;  % secreted into feces
%     dummy.ub(cnt, 1) = 1000;
%     % feces exchange
%     cnt = cnt + 1;  % counts rxns
%     dummy.rxns{cnt, 1} = strcat('EX_', strrep(exch{j, 1}, '[e]', '[fe]'));
%     dummy.S(mfeInd, cnt) = -1;
%     dummy.lb(cnt, 1) = -1000;
%     dummy.ub(cnt, 1) = 1000;
% end
% dummy.S = sparse(dummy.S);

%% create a new extracellular space [b] for host
if ~isempty(host)
exMets = find(~cellfun(@isempty, strfind(host.mets, '[e]')));  % find all mets that appear in [e]
exRxns = host.rxns(strncmp('EX_', host.rxns, 3));  % find exchanges in host
exMetRxns = find(sum(abs(host.S(exMets, :)), 1) ~= 0);  % find reactions that contain mets from [e]
exMetRxns = exMetRxns';
exMetRxnsMets = find(sum(abs(host.S(:, exMetRxns)), 2) ~= 0);  % get all metabolites of [e] containing rxns
dummyHostB = createModel(); %makeDummyModel(size(exMetRxnsMets, 1), size(exMetRxns, 1));
dummyHostB = addMultipleMetabolites(dummyHostB,strcat({'Host_'}, regexprep(host.mets(exMetRxnsMets), '\[e\]', '\[b\]')));
dummyHostB = addMultipleReactions(dummyHostB,strcat({'Host_'}, host.rxns(exMetRxns), {'b'}),host.S(exMetRxnsMets, exMetRxns),'c',host.c(exMetRxns),'lb',host.lb(exMetRxns),'ub',host.ub(exMetRxns));
%dummyHostB.rxns = ;
%dummyHostB.mets = strcat({'Host_'}, regexprep(host.mets(exMetRxnsMets), '\[e\]', '\[b\]'));  % replace [e] with [b]
%dummyHostB.S = host.S(exMetRxnsMets, exMetRxns);
%dummyHostB.c = host.c(exMetRxns);
%dummyHostB.lb = host.lb(exMetRxns);
%dummyHostB.ub = host.ub(exMetRxns);


% remove exchange reactions from host while leaving demand and sink
% reactions
host = removeRxns(host, exRxns);
host.mets = strcat({'Host_'}, host.mets);
host.rxns = strcat({'Host_'}, host.rxns);

% use mergeToModels without combining genes
[host] = mergeTwoModels(dummyHostB, host, 2, false);

% Change remaining [e] (transporters) to [u] to transport diet metabolites
exMets2 = ~cellfun(@isempty, strfind(host.mets, '[e]'));  % again, find all mets that appear in [e]
% exMetRxns2=find(sum(host.S(exMets2,:),1)~=0);%find reactions that contain mets from [e]
% exMetRxns2=exMetRxns2';
% exMetRxnsMets2=find(sum(host.S(:,exMetRxns2),2)~=0);%get all metabolites of [e] containing rxns
% host.mets=regexprep(host.mets,'\[e\]','\[u\]');%replace [e] with [u]
dummyHostEU = createModel();
%makeDummyModel(2 * size(exMets2, 1), size(exMets2, 1));
hostmets = host.mets(exMets2);
dummyHostEUmets = [strrep(strrep(hostmets, 'Host_', ''), '[e]', '[u]'); hostmets];
dummyHostEU = addMultipleMetabolites(dummyHostEU,dummyHostEUmets);
nMets = numel(hostmets);
S = [-speye(nMets),speye(nMets)];
lbs = repmat(-1000,nMets,1);
ubs = repmat(1000,nMets,1);
names = strrep(strcat('Host_IEX_', strrep(hostmets, 'Host_', ''), 'tr'), '[e]', '[u]');
dummyHostEU = addMultipleReactions(dummyHostEU,names,dummyHostEUmets,S,'lb',lbs,'ub',ubs);
% for j = 1:size(exMets2, 1)
%     dummyHostEU.rxns{j, 1} = strrep(strcat('Host_IEX_', strrep(host.mets{exMets2(j), 1}, 'Host_', ''), 'tr'), '[e]', '[u]');
%     metU = find(ismember(dummyHostEU.mets, strrep(strrep(host.mets{exMets2(j)}, 'Host_', ''), '[e]', '[u]')));
%     metE = find(ismember(dummyHostEU.mets, host.mets{exMets2(j)}));
%     dummyHostEU.S(metU, j) = 1;
%     dummyHostEU.S(metE, j) = -1;
%     dummyHostEU.lb(j) = -1000;
%     dummyHostEU.ub(j) = 1000;
% end
[host] = mergeTwoModels(dummyHostEU, host, 2, false);
end


%% create a new extracellular space [u] for microbes, code runs in parallel
modelStorage = cell(size(models));
% MexGJoined=MexGHost;
parfor j = 1:size(models, 1)
    % for j=1:size(models,1)%to enable sequential mode
    model = models{j, 1};
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
    [model] = mergeTwoModels(dummyMicEU, model, 2, false);
    modelStorage{j, 1} = model;  % store model
end

%% Merge the models in a parallel way

% Find the base 2 log of the number of models (how many branches are needed), and merge the models two by two:
% In each column of model storage the number of models decreases of half
%(because they have been pairwise merged) till the last column where only
% one big model is contained. The models that are not pairwise merged
%(because number of rows is not even ) are stored and then merged
% sequentially to the big model.


pos = {}  % array where the position of models that cannot be merged pairwise (because their number in that iter is not
% even) in the original modelStorage vector is stored
dim = size(models, 1);
for j = 2:(floor(log2(size(models, 1))) + 1)  % +1 because it starts with one column shifted
	if mod(dim, 2) == 1  % check if number is even or not
		halfdim = dim - 1;  % approximated half dimension (needed to find how many iters to do
        % for the pairwise merging
		pos{1, j} = halfdim + 1;  % find index of extramodel
		halfdim = halfdim / 2;
	else
		halfdim = dim / 2;  % no need for approximation
    end
    FirstSaveStore=modelStorage(:,(j-1));
    % SecondSaveStore=modelStorage(:,(j-1)); %changes 010318
    modelStorage(1:(dim-1),(j-1))={[]}; %this line will erase all the models from the container 
    %with the only exception of the last one that might be needed to be
    %merged separately. This prevents a dramatic increase in ram usage in
    %each iteration as result of stoaring all the merging three. 
    
    parfor k=1:halfdim
        parind = k;	
        parind=parind+(k-1);
        FirstMod=FirstSaveStore(parind);
        % SecondMod=SecondSaveStore(parind+1);%changes 010318
        SecondMod=FirstSaveStore(parind+1);%changes 010318
        % modelStorage{k,j} = mergeTwoModels(FirstMod{1},SecondMod{1},1,false)%changes 010318
        modelStorage{k,j} = mergeTwoModels(FirstMod{1},SecondMod{1},1,false)	
    end
	dim = halfdim;
end

% Merging the models remained alone and non-pairwise matched
if isempty(pos)== 1 %all the models were pairwise-merged
[model] = modelStorage{1,(floor(log2(size(models,1)))+1)};
else
    position = pos(1,:); %finding positions of non merged models
    nexmod = find(~cellfun(@isempty,pos(1,:)));
    toMerge = cell2mat(position(nexmod));%list of models still to merge 
    if (length(toMerge)) > 1 %more than 1 model was not pairwise merged
        for k=2:(length(toMerge)+1)
            if k==2
               [model] = mergeTwoModels(modelStorage{toMerge(1,k-1),(nexmod(k-1))-1},modelStorage{toMerge(1,k),(nexmod(k))-1},1,false);                   
            elseif k > 3       
               [model] = mergeTwoModels(modelStorage{toMerge(1,k-1),(nexmod(k-1))-1},model,1,false);
            end
        end
      [model] = mergeTwoModels(modelStorage{1,(floor(log2(size(models,1)))+1)},model,1,false);
    end
    if (length(toMerge)) == 1 %1 model was not pairwise merged
        [model] = mergeTwoModels(modelStorage{1,(floor(log2(size(models,1)))+1)},modelStorage{toMerge(1,1),(nexmod-1)},1,false);
    end
end


% Merging with host if present 
if ~isempty(host)
    [model] = mergeTwoModels(host,model,1,false);
end
[model] = mergeTwoModels(dummy,model,2,false);
end


