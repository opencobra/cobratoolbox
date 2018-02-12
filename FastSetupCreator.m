function model = FastSetupCreator(models,microbeNames,host)
%creates a microbiota model (min 1 microbe) that can be coupled with a host
%model. Microbes and host are connected with a lumen compartment [u], host
%can secrete metabolites into body fluids [b]. Diet is simulated as uptake
%through the compartment [d], transporters are unidirectional from [d] to
%[u]. Secretion goes through the fecal compartment [fe], transporters are
%unidirectional from [u] to [fe].
%Reaction types
% Diet exchange: 'EX_met[d]': 'met[d] <=>'
% Diet transporter: 'DUt_met': 'met[d] -> met[u]'
% Fecal transporter: 'UFEt_met': 'met[u] -> met[fe]'
% Fecal exchanges: 'EX_met[fe]': 'met[fe] <=>'
% Microbe uptake/secretion: 'Microbe_IEX_met[c]tr': 'Microbe_met[c] <=> met[u]'
% Host uptake/secretion lumen: 'Host_IEX_met[c]tr': 'Host_met[c] <=> met[u]'
% Host exchange body fluids: 'Host_EX_met(e)b': 'Host_met[b] <=>'
%
%INPUT
% models         nx1 cell array that contains n microbe models in
%                       COBRA model structure format
% microbeNames          nx1 cell array of n unique strings that represent
%                       each microbe model. Reactions and metabolites of
%                       each microbe will get the corresponding
%                       microbeNames (e.g., 'Ecoli') prefix. Reactions
%                       will be named 'Ecoli_RxnAbbr' and metabolites 
%                       'Ecoli_MetAbbr[c]').
% host             Host COBRA model structure, can be left empty if
%                       there is no host model
%
%OUTPUT
% model                 COBRA model structure with all models combined
%
% Stefania Magnusdottir and Federico Baldini 07/02/18

%% Get list of all exchanged metabolites
if ~isempty(host)
    exch=host.mets(find(sum(host.S(:,strncmp('EX_',host.rxns,3)),2)~=0));
else
    exch={};
end
for j=1:size(models,1)
    model=models{j,1};
    exch=union(exch,model.mets(find(sum(model.S(:,strncmp('EX_',model.rxns,3)),2)~=0)));
end

%% Create additional compartments for dietary compartment and fecal secretion.

% Create dummy model with [d], [u], and [fe] rxns
dummy=makeDummyModel(3*size(exch,1),4*size(exch,1));
dummy.mets=unique([strrep(exch,'[e]','[d]');strrep(exch,'[e]','[u]');strrep(exch,'[e]','[fe]')]);
cnt=0;
for j=1:size(exch,1)
    mdInd=find(ismember(dummy.mets,strrep(exch{j,1},'[e]','[d]')));
    muInd=find(ismember(dummy.mets,strrep(exch{j,1},'[e]','[u]'))); %finding indexes for elements of all ecxhange 
    mfeInd=find(ismember(dummy.mets,strrep(exch{j,1},'[e]','[fe]')));
    %diet exchange
    cnt=cnt+1;
    dummy.rxns{cnt,1}=strcat('EX_',strrep(exch{j,1},'[e]','[d]'));
    dummy.S(mdInd,cnt)=-1;
    dummy.rev(cnt,1)=1;
    dummy.lb(cnt,1)=-1000;
    dummy.ub(cnt,1)=1000;
    %diet-lumen transport
    cnt=cnt+1;%counts rxns
    dummy.rxns{cnt,1}=strcat('DUt_',strrep(exch{j,1},'[e]',''));
    dummy.S(mdInd,cnt)=-1;%taken up from diet
    dummy.S(muInd,cnt)=1;%secreted into lumen
    dummy.ub(cnt,1)=1000;
    %lumen-feces transport
    cnt=cnt+1;%counts rxns
    dummy.rxns{cnt,1}=strcat('UFEt_',strrep(exch{j,1},'[e]',''));
    dummy.S(muInd,cnt)=-1;%taken up from lumen
    dummy.S(mfeInd,cnt)=1;%secreted into feces
    dummy.ub(cnt,1)=1000;
    %feces exchange
    cnt=cnt+1;%counts rxns
    dummy.rxns{cnt,1}=strcat('EX_',strrep(exch{j,1},'[e]','[fe]'));
    dummy.S(mfeInd,cnt)=-1;
    dummy.rev(cnt,1)=1;
    dummy.lb(cnt,1)=-1000;
    dummy.ub(cnt,1)=1000;
end 
dummy.S=sparse(dummy.S);

%% create a new extracellular space [b] for host
if ~isempty(host)
exMets=find(~cellfun(@isempty,strfind(host.mets,'[e]')));%find all mets that appear in [e]
exRxns=host.rxns(strncmp('EX_',host.rxns,3));%find exchanges in host
exMetRxns=find(sum(abs(host.S(exMets,:)),1)~=0);%find reactions that contain mets from [e]
exMetRxns=exMetRxns';
exMetRxnsMets=find(sum(abs(host.S(:,exMetRxns)),2)~=0);%get all metabolites of [e] containing rxns
dummyHostB=makeDummyModel(size(exMetRxnsMets,1),size(exMetRxns,1));
dummyHostB.rxns=strcat({'Host_'},host.rxns(exMetRxns),{'b'}); 
dummyHostB.mets=strcat({'Host_'},regexprep(host.mets(exMetRxnsMets),'\[e\]','\[b\]'));%replace [e] with [b]
dummyHostB.S=host.S(exMetRxnsMets,exMetRxns);
dummyHostB.c=host.c(exMetRxns);
dummyHostB.lb=host.lb(exMetRxns);
dummyHostB.ub=host.ub(exMetRxns);
dummyHostB.rev=host.rev(exMetRxns);

% remove exchange reactions from host while leaving demand and sink
% reactions
host = removeRxns(host, exRxns);
host.mets=strcat({'Host_'},host.mets);
host.rxns=strcat({'Host_'},host.rxns);

% use mergeToModels without combining genes-AH 02.06.17
[host] = mergeTwoModels(dummyHostB,host,2,false);

%Change remaining [e] (transporters) to [u] to transport diet metabolites
exMets2=find(~cellfun(@isempty,strfind(host.mets,'[e]')));%again, find all mets that appear in [e]
% exMetRxns2=find(sum(host.S(exMets2,:),1)~=0);%find reactions that contain mets from [e]
% exMetRxns2=exMetRxns2';
% exMetRxnsMets2=find(sum(host.S(:,exMetRxns2),2)~=0);%get all metabolites of [e] containing rxns
% host.mets=regexprep(host.mets,'\[e\]','\[u\]');%replace [e] with [u]
dummyHostEU=makeDummyModel(2*size(exMets2,1),size(exMets2,1));
dummyHostEU.mets=[strrep(strrep(host.mets(exMets2),'Host_',''),'[e]','[u]');host.mets(exMets2)];
for j=1:size(exMets2,1)
    dummyHostEU.rxns{j,1}=strrep(strcat('Host_IEX_',strrep(host.mets{exMets2(j),1},'Host_',''),'tr'),'[e]','[u]');
    metU=find(ismember(dummyHostEU.mets,strrep(strrep(host.mets{exMets2(j)},'Host_',''),'[e]','[u]')));
    metE=find(ismember(dummyHostEU.mets,host.mets{exMets2(j)}));
    dummyHostEU.S(metU,j)=1;
    dummyHostEU.S(metE,j)=-1;
    dummyHostEU.rev(j)=1;
    dummyHostEU.lb(j)=-1000;
    dummyHostEU.ub(j)=1000;
end

% use mergeToModels without combining genes-AH 02.06.17
[host] = mergeTwoModels(dummyHostEU,host,2,false);

% [host] = mergeTwoModels_AH_f(dummyHostEU,host,2);%FEDELINE
end



%% create a new extracellular space [u] for microbes, code runs in parallel
modelStorage=cell(size(models)); 
%MexGJoined=MexGHost;
parfor j=1:size(models,1)
    %for j=1:size(models,1)
    model=models{j,1};
    exmod = model.rxns(strncmp('EX_', model.rxns,3));%find exchange reactions
    eMets=model.mets(~cellfun(@isempty,strfind(model.mets,'[e]')));%exchanged metabolites
    dummyMicEU=makeDummyModel(2*size(eMets,1),size(eMets,1));
    dummyMicEU.mets=[strcat(strcat(microbeNames{j,1},'_'),regexprep(eMets,'\[e\]','\[u\]'));regexprep(eMets,'\[e\]','\[u\]')];
    for k=1:size(eMets,1)
        dummyMicEU.rxns{k,1}=strcat(strcat(microbeNames{j,1},'_'),'IEX_',regexprep(eMets{k},'\[e\]','\[u\]'),'tr');
        metU=find(ismember(dummyMicEU.mets,strcat(strcat(microbeNames{j,1},'_'),regexprep(eMets{k},'\[e\]','\[u\]'))));
        metE=find(ismember(dummyMicEU.mets,regexprep(eMets{k},'\[e\]','\[u\]')));
        dummyMicEU.S(metU,k)=1;
        dummyMicEU.S(metE,k)=-1;
        dummyMicEU.rev(k)=1;
        dummyMicEU.lb(k)=-1000;
        dummyMicEU.ub(k)=1000;
    end
    model = removeRxns(model, exmod, false, false);%remove exchange reactions% to avoid extra metabolite problem
    model.rxns=strcat(strcat(microbeNames{j,1},'_'),model.rxns);
    model.mets=strcat(strcat(microbeNames{j,1},'_'),regexprep(model.mets,'\[e\]','\[u\]'));%replace [e] with [u]
    [model] = mergeTwoModels(dummyMicEU,model,2,false);
    modelStorage{j,1}=model;%store model
end

%% Merge the models in a parralel way

%Find the base 2 log of the number of models (how many branches are needed), and merge the models two by two  
pos={} 
dim = size(models,1);
for j=2:(floor(log2(size(models,1)))+1)  %+1 because it starts with one column shifted
	if mod(dim,2) == 1 %check if nuber is even or not
		nit = dim - 1;
		pos{1,j}= nit + 1; 
		nit=nit/2;
	else
		nit = dim/2;
    end
    a=modelStorage(:,(j-1));
    b=modelStorage(:,(j-1));
    parfor k=1:nit
    f = k;	
	f=f+(k-1);
    y=a(f);
    z=b(f+1);
    modelStorage{k,j} = mergeTwoModels(y{1},z{1},1,false)	
    end
	dim = nit;
end

%Merging the models remained alone and non pairwise matched
if isempty(pos)== 1 %all the models were pairwise merged
[model] = modelStorage{1,(floor(log2(size(models,1)))+1)};
else
    aa = pos(1,:);
    nexmod = find(~cellfun(@isempty,pos(1,:)));
    xmod = cell2mat(aa(nexmod)); 
    if (length(xmod)) > 1 %more then 1 model was not pairwise merged
        xmod;
        (length(xmod)+1);
        for k=2:(length(xmod)+1)
            if k==2
               [model] = mergeTwoModels(modelStorage{xmod(1,k-1),(nexmod(k-1))-1},modelStorage{xmod(1,k),(nexmod(k))-1},1,false);                   
            elseif k > 3       
               [model] = mergeTwoModels(modelStorage{xmod(1,k-1),(nexmod(k-1))-1},model,1,false);
            end
        end
      [model] = mergeTwoModels(modelStorage{1,(floor(log2(size(models,1)))+1)},model,1,false);
    end
    if (length(xmod)) == 1 %1 model was not pairwise merged
        [model] = mergeTwoModels(modelStorage{1,(floor(log2(size(models,1)))+1)},modelStorage{xmod(1,1),(nexmod-1)},1,false);
    end
end

%Merging with host if present 
if ~isempty(host)
    [model] = mergeTwoModels(host,model,1,false);
end
[model] = mergeTwoModels(dummy,model,2,false);
end


