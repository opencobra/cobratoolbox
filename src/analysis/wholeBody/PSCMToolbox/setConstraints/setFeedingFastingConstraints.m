function model = setFeedingFastingConstraints(model, feedingStatus, fastingValue, storageValue)
% Set feeding or fasting constraints on a whole-body metabolic model. Under
% feeding the organ storage (sink) reactions are enabled to store metabolites
% (lower bound 0, positive upper bound) and diet uptake is opened; under
% fasting the storage reactions are reversed to release stored metabolites
% (negative lower bound, upper bound 0) and diet uptake is closed
%
% USAGE:
%
%    model = setFeedingFastingConstraints(model, feedingStatus, fastingValue, storageValue)
%
% INPUT:
%    model:            whole-body metabolic model structure with fields:
%
%                        * .rxns - `n x 1` reaction identifiers, used to locate
%                          the sink, demand and diet exchange reactions
%                        * .lb - `n x 1` lower bounds (updated)
%                        * .ub - `n x 1` upper bounds (updated)
%                        * .Microbiota - optional flag vector marking microbial
%                          reactions, checked to leave microbe sinks untouched
%                        * .rxnGeneMat - optional reaction-gene mapping, removed
%                          if present
%    feedingStatus:    'feeding' to open diet uptake (using fastingValue) and
%                      turn organ storage on, or 'fasting' to close diet uptake
%                      and turn organ storage release on
%
% OPTIONAL INPUTS:
%    fastingValue:     lower bound applied to diet exchange and storage release
%                      reactions; default is -10
%    storageValue:     upper bound applied to organ storage reactions during
%                      feeding; default is 10
%
% OUTPUT:
%    model:            whole-body metabolic model with the feeding/fasting
%                      constraints applied, updating the fields:
%
%                        * .lb - lower bounds of the affected reactions
%                        * .ub - upper bounds of the affected reactions
%                        * .SetupInfo - structure recording the setup; the
%                          feeding status is stored in `.SetupInfo.FeedingStatus`
%
% .. Author: - Ines Thiele, 2015/2016

if ~exist('fastingValue','var')
    fastingValue = -10;
end
if ~exist('storageValue','var')
    storageValue = 10;
end

% load amino acids that can be stored
AAStorage;
storedInLiver={'nad(c)';'nadp(c)';'fad(c)';...
    'thmtp(c)';'pydam(c)';'pydx(c)';'pydxn(c)';...
    'coa(c)';'thf(c)';'btn(c)';'retinol(c)';'retfa(c)';...
    '11_cis_retfa(c)';'9_cis_retfa(c)';'25hvitd2(c)';'vitd3(c)';...
    'avite1(c)';'avite2(c)';'chol(c)';'fe3(c)';'phyQ(c)';...
    'glygn2(c)'};
StoreInKidney = {'ascb_L(c)';'chol(c)';};
StoreInMuscle ={'thmpp(c)';'25hvitd2(c)';'vitd3(c)';'chol(c)';'glygn2(c)'};

StoreInAdi={'25hvitd2(c)';'vitd3(c)';'avite1(c)';'avite2(c)';'phyQ(c)';...
    'hdca(c)';'tmndnc(c)';'lnlc(c)';'tag_hs(c)';...
    'c226coa(c)';'doco13ecoa(c)';'lnlccoa(c)';'lnlncacoa(c)';'lnlncgcoa(c)';...
    'odecoa(c)';'pmtcoa(c)';'stcoa(c)';'tmndnccoa(c)'
    };
if isfield(model,'rxnGeneMat')
    model = rmfield(model,'rxnGeneMat');
end
% set all sinks to 0
for i = 1 : length(model.rxns)
    if length(strfind(model.rxns{i},'sink_'))==1 ...
            && length(strfind(model.rxns{i},'sink_pre_prot(r)'))==0  ...
            && length(strfind(model.rxns{i},'sink_Ser_Gly_Ala_X_Gly(r)'))==0 ...
            && length(strfind(model.rxns{i},'sink_5hpet(c)'))==0
        %&& length(strfind(model.rxns{i},'sink_Tyr_ggn(c)'))==0 % ...
        %% && length(strfind(model.rxns{i},'sink_citr(c)'))==0
        % && length(strfind(model.rxns{i},'sink_Ser_Gly_Ala_X_Gly(r)'))==0 ...
        if isfield(model,'Microbiota') && model.Microbiota(i) ==0 %no microbe sink
            model.lb(i)=0;
        elseif ~isfield(model,'Microbiota')
            model.lb(i)=0;
        end
    end
end

DMs= (find(~cellfun(@isempty,strfind(model.rxns,'DM_'))));
model.lb(DMs) = 0;

% but not at the beginning of the abbr --> leaves in the
% microbe sinks
if 1
    tmp = strmatch('sink_',model.rxns);
    model.lb(tmp)=-10;
end

for i = 1 : length(model.rxns)
    if strfind(model.rxns{i},'sink_')
        model.rxns{i} = regexprep(model.rxns{i},'\[c\]','(c)');
        model.rxns{i} = regexprep(model.rxns{i},'\[r\]','(r)');
        %    model.rxns{i}
    end
end
modelexchanges1 = strmatch('Diet_EX_',model.rxns);
modelexchanges2 = strmatch('Diet_Ex_',model.rxns);
modelexchanges = [modelexchanges1;modelexchanges2];

if strcmp(feedingStatus,'feeding') % storage no sinks
    model.lb(modelexchanges)=fastingValue;
    model.ub(modelexchanges)=0;
elseif strcmp(feedingStatus,'fasting') % storage no sinks
    model.lb(modelexchanges)=0;
    model.ub(modelexchanges)=0;
    % exception for water
    
end

if strcmp(feedingStatus,'feeding') % storage no sinks
    for i = 1 : length(storedInLiver)
        storedInLiver{i};
        rxnName = strcat('Liver_sink_',storedInLiver{i});
        %   rxnName
        model = changeRxnBounds(model,rxnName,0,'l');
        model = changeRxnBounds(model,rxnName, storageValue,'u');
    end
    for i = 1 : length(StoreInKidney)
        StoreInKidney{i};
        rxnName = strcat('Kidney_sink_',StoreInKidney{i});
        %  rxnName
        model = changeRxnBounds(model,rxnName,0,'l');
        model = changeRxnBounds(model,rxnName, storageValue,'u');
    end
    for i = 1 : length(StoreInMuscle)
        rxnName = strcat('Muscle_sink_',StoreInMuscle{i});
        %  rxnName
        model = changeRxnBounds(model,rxnName,0,'l');
        model = changeRxnBounds(model,rxnName, storageValue,'u');
    end
    for i = 1 : length(storageAA)
        rxnName = strcat('Muscle_',storageAA{i});
        %    rxnName
        model = changeRxnBounds(model,rxnName,0,'l');
        model = changeRxnBounds(model,rxnName, storageValue,'u');
    end
    for i = 1 : length(StoreInAdi)
        rxnName = strcat('Adipocytes_sink_',StoreInAdi{i});
        %   rxnName
        StoreInAdi{i};
        model = changeRxnBounds(model,rxnName,0,'l');
        model = changeRxnBounds(model,rxnName, storageValue,'u');
    end
    rxnName = 'Retina_sink_crvnc(c)';
    model = changeRxnBounds(model,rxnName,0,'l');
    model = changeRxnBounds(model,rxnName, storageValue,'u');
    rxnName = 'Heart_sink_chol(c)';
    model = changeRxnBounds(model,rxnName,0,'l');
    model = changeRxnBounds(model,rxnName, storageValue,'u');
    rxnName = 'Brain_sink_crvnc(c)';
    model = changeRxnBounds(model,rxnName,0,'l');
    model = changeRxnBounds(model,rxnName, storageValue,'u');
    rxnName = 'Brain_sink_chol(c)';
    model = changeRxnBounds(model,rxnName,0,'l');
    model = changeRxnBounds(model,rxnName, storageValue,'u');
    rxnName = 'RBC_sink_glygn2(c)';
    model = changeRxnBounds(model,rxnName,0,'l');
    model = changeRxnBounds(model,rxnName, storageValue,'u');
    rxnName = 'Skin_sink_vitd3(c)';
    model = changeRxnBounds(model,rxnName,0,'l');
    model = changeRxnBounds(model,rxnName, storageValue,'u');
elseif strcmp(feedingStatus,'fasting')
    for i = 1 : length(storedInLiver)
        rxnName = strcat('Liver_sink_',storedInLiver{i});
        model = changeRxnBounds(model,rxnName,fastingValue,'l');
        model = changeRxnBounds(model,rxnName,0,'u');
    end
    for i = 1 : length(StoreInKidney)
        rxnName = strcat('Kidney_sink_',StoreInKidney{i});
        model = changeRxnBounds(model,rxnName,fastingValue,'l');
        model = changeRxnBounds(model,rxnName,0,'u');
    end
    for i = 1 : length(StoreInMuscle)
        rxnName = strcat('Muscle_sink_',StoreInMuscle{i});
        model = changeRxnBounds(model,rxnName,fastingValue,'l');
        model = changeRxnBounds(model,rxnName,0,'u');
    end
    for i = 1 : length(storageAA)
        rxnName = strcat('Muscle_',storageAA{i});
        model = changeRxnBounds(model,rxnName,fastingValue,'l');
        model = changeRxnBounds(model,rxnName,0,'u');
    end
    for i = 1 : length(StoreInAdi)
        rxnName = strcat('Adipocytes_sink_',StoreInAdi{i});
        model = changeRxnBounds(model,rxnName,fastingValue,'l');
        model = changeRxnBounds(model,rxnName,0,'u');
    end
    rxnName = 'Retina_sink_crvnc(c)';
    model = changeRxnBounds(model,rxnName,fastingValue,'l');
    model = changeRxnBounds(model,rxnName,0,'u');
    rxnName = 'Heart_sink_chol(c)';
    model = changeRxnBounds(model,rxnName,fastingValue,'l');
    model = changeRxnBounds(model,rxnName,0,'u');
    rxnName = 'Brain_sink_crvnc(c)';
    model = changeRxnBounds(model,rxnName,fastingValue,'l');
    model = changeRxnBounds(model,rxnName,0,'u');
    rxnName = 'Brain_sink_chol(c)';
    model = changeRxnBounds(model,rxnName,fastingValue,'l');
    model = changeRxnBounds(model,rxnName,0,'u');
    rxnName = 'RBC_sink_glygn2(c)';
    model = changeRxnBounds(model,rxnName,fastingValue,'l');
    model = changeRxnBounds(model,rxnName,0,'u');
    rxnName = 'Skin_sink_vitd3(c)';
    model = changeRxnBounds(model,rxnName,fastingValue,'l');
    model = changeRxnBounds(model,rxnName,0,'u');
end

model.SetupInfo.FeedingStatus = feedingStatus;
