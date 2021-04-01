function modelHM = combineHarveyMicrotiota(modelH, modelM, couplingConstraint)
% This function combines harvey and a microbial community model
%
% function modelHM = combineHarveyMicrotiota(modelH, modelM, couplingConstraint)
%
% INPUT
% modelH                Whole-body metabolic model structure
% modelM                Microbiota model structure
% couplingConstraint    coupling constraint for microbiome model (default:
%                       20000, as used in the whole-body metabolic model
%
% OUTPUT
% modelHM               Model structure containing both Whole-body metabolic model and microbiota in one
%                       matrix
%
% Ines Thiele May 2016
% replace Ex_AA[u] with an artificial transport reaction [luM] -- > [luLI]
% updated to new structure we use ([d],[fe],[u]) for microbes - Nov 2017 IT

%TODO make this code COBRA v3 compatible
if ~isfield(modelM,'A')
    modelM.A = [modelM.S;modelM.C];
    modelM.b = [modelM.b;modelM.d];
    modelM.b(1:end) = 0;
    modelM.csense = [modelM.csense;modelM.dsense];
    modelM.mets = [modelM.mets;modelM.ctrs];
    modelM = rmfield(modelM,'C');
    modelM = rmfield(modelM,'d');
    modelM = rmfield(modelM,'ctrs');
    modelM = rmfield(modelM,'dsense');
    modelM = rmfield(modelM,'S');
end
if ~isfield(modelH,'A')
    modelH.A = [modelH.S;modelH.C];
    modelH.b = [modelH.b;modelH.d];
    modelH.b(1:end) = 0;
    modelH.mets = [modelH.mets;modelH.ctrs];
    modelH.csense = [modelH.csense;modelH.dsense];
    modelH = rmfield(modelH,'C');
    modelH = rmfield(modelH,'d');
    modelH = rmfield(modelH,'ctrs');
    modelH = rmfield(modelH,'dsense');
    modelH = rmfield(modelH,'S');
end
modelM.b(1:end) = 0;

% fix csense
for i=1 :length(modelM.csense)
    tmp(i,1)=modelM.csense(i);
end
modelM.csense = tmp;
% fix model.met
if length(modelM.mets)<size(modelM.A,1)
    tmp1 = size(modelM.A,1)-length(modelM.mets);
    tmp2=length(modelM.mets);
    for i =1 : tmp1
        modelM.mets{tmp2+i}=num2str(i);
    end
end
if ~exist('couplingConstraint','var')
    couplingConstraint = 20000; % same as Harvey
end

factor = 1000; % to adjust to mmol
modelH.S=modelH.A;
modelM.S=modelM.A;
% % remove a few reactions
modelMO=modelM;

% check whether the model contains [d] compartment
if ~isempty(find(~cellfun(@isempty,strfind(modelM.rxns,'[d]'))))
    % remove exchange reactions
    % Diet exchange: 'EX_met[d]': 'met[d] <=>' and
    % Fecal exchanges: 'EX_met[fe]': 'met[fe] <=>'
    ExR = modelM.rxns(strmatch('EX_',modelM.rxns));
    % if isempty(ExR)
    %     ExR = (find(~cellfun(@isempty,strfind(modelM.rxns,'EX_'))));
    % end
    modelM.rev = zeros(length(modelM.rxns),1);
    modelM.rev(modelM.lb<0)=1;
    modelM = removeRxns(modelM,ExR);
    % convert Diet transport reactions
    % Diet transporter: 'DUt_met': 'met[d] -> met[u]'
    ExR = strmatch('DUt_',modelM.rxns);
    % get all [d] metabolites
    EXMD = modelM.mets(strmatch('\[d\]',modelM.mets));
    % rename those reactions
    modelM.rxns = regexprep(modelM.rxns, 'DUt_','Micro_EX_');
    modelM.rxns(ExR) = strcat(modelM.rxns(ExR), '[luLI]_[luM]');
    % make those reactions reversible
    modelM.mets = regexprep(modelM.mets, '\[d\]','\[luLI\]');
    modelM.mets = regexprep(modelM.mets, '\[u\]','\[luM\]');
elseif ~isempty(find(~cellfun(@isempty,strfind(modelM.rxns,'[u]')))) % contains only [u] compartment
    % convert Ex_met[u] reactions into transport reactions
    [modelM] = createModelNewCompartment(modelM,'u','luLI','large intestinal lumen',-1000,1000,1);
    modelM.rxns = regexprep(modelM.rxns,'\[u\]_\[luLI\]','\[luLI\]_\[luM\]');
    modelM.rxns = regexprep(modelM.rxns,'^EX_','Micro_EX_');
    modelM.mets = regexprep(modelM.mets, '\[u\]','\[luM\]');
    ExR = strmatch('Micro_EX_',modelM.rxns);    
    EXMD = modelM.mets(strmatch('\[luM\]',modelM.mets));
    %  it seems that these models do not have a community biomass
    % I add it for the moment but 
end
modelM.lb(ExR) = -1000;
modelM.ub(ExR) = 1000;
% remove fecal transport reactions
% Fecal transporter: 'UFEt_met': 'met[u] -> met[fe]'
ExR = strmatch('UFEt_',modelM.rxns);
modelM = removeRxns(modelM,modelM.rxns(ExR));

% remove slacks from exchanges
ExR = strmatch('Micro_EX_',modelM.rxns);
SL = strmatch('slack_',modelM.mets);
modelM.S(SL,ExR)=0;

% adjust further constraints on modelM
for i = 1 : length(modelM.rxns)
    if ~isempty(strfind(modelM.rxns{i},'biomass[c]tr'))
        %    RM(i,1)=1;
        modelM=changeRxnBounds(modelM,modelM.rxns{i},0,'b');%Make sure microbes cannot share biomass between each other
    end
end

% add community biomass
% rename biomass[c] to microbiota_LI_biomass
if ~isempty(strmatch('microbeBiomass[luM]',modelM.mets))
    modelM.mets{strmatch('microbeBiomass[luM]',modelM.mets)} = 'microbiota_LI_biomass[luM]';
elseif isempty(find(modelM.S(:,strmatch('communityBiomass',modelM.mets))>0))
    % it seems that in the newer version no product side has been defined
    modelM.mets{end+1}= 'microbiota_LI_biomass[luM]';
    modelM.S(end+1,strmatch('communityBiomass',modelM.rxns,'exact'))=1;
    modelM.b(end+1)=0;
    modelM.csense(end+1,1)='E';
else
    error
end

% remove the constraints on some of the microbial demands
modelM.lb(find(modelM.lb>=0))=0;
modelM=changeRxnBounds(modelM,'EX_biomass[c]',0,'b');%make sure biomass isn't being taken up or secreted

modelM2=modelM;
% add a reaction to modelM that transports the biomass to luLI and then the
% fe and an excretion reaction
[modelM2,rxnIDexists] = addReaction(modelM2,'LI_EX_microbiota_LI_biomass[luLI]_[fe]',{'microbiota_LI_biomass[luM]','microbiota_LI_biomass[fe]'},[-1 1],false);
modelM2.subSystems{end}='Transport, biofluid';
[modelM2,rxnIDexists] = addReaction(modelM2,'Excretion_EX_microbiota_LI_biomass[fe]',{'microbiota_LI_biomass[fe]'},[-1],false);
modelM2.subSystems{end}='Exchange/demand reaction';
a = length(modelM2.csense);
for i = 1 : (length(modelM2.mets)-length(modelM2.csense))
    modelM2.csense(a+i,1)='E';
end
modelM2.lb(find(modelM2.lb<0))=-1000*1000;
modelM2.ub(find(modelM2.ub>0))=1000*1000;

modelM2.S(find(modelM2.S==400))=couplingConstraint;% change coupling constraint
modelM2.S(find(modelM2.S==-400))=-couplingConstraint;% change coupling constraint
modelM2.S(find(modelM2.S==200000))=couplingConstraint;% change coupling constraint - seems to be an error in Federico's scripts
modelM2.S(find(modelM2.S==-200000))=-couplingConstraint;% change coupling constraint - seems to be an error in Federico's scripts

modelH = rmfield(modelH,'A');
modelM2 = rmfield(modelM2,'A');

% check that both models do not have overlapping reactions
Rem = intersect(modelH.rxns,modelM2.rxns);
if ~isempty(Rem)
    % remove reactions from modelM2
    modelM2 = removeRxns(modelM2,Rem);
end

[modelHM] = mergeTwoModels(modelH,modelM2,1,1,0);
modelHM.A = modelHM.S;
% make sure that all new metabolites in luLI compartment can be excreted

% EXMD = modelHM.mets(strmatch('\[d\]',modelHM.mets));
for i = 1 : length(EXMD)
    Fe = regexrep(EXMD{i},'\[luLI\]','\[fe\]');
    if isempty(strmatch(strcat('LI_EX_',EXMD{i},'_[fe]'),modelHM.rxns))
        [modelHM,rxnIDexists] = addReaction(modelHM,strcat('LI_EX_',EXMD{i},'_[fe]'),{EXMD{i},Fe},[-1 1],false);
        modelHM.subSystems{end}='Transport, biofluid';
    end
    if isempty(strmatch(strcat('Excretion_EX_',fe),modelHM.rxns))
        [modelHM,rxnIDexists] = addReaction(modelHM,strcat('Excretion_EX_',fe),{fe},[-1],false);
        modelHM.subSystems{end}='Exchange/demand reaction';
    end
end
a = length(modelHM.csense);
for i = 1 : (length(modelHM.mets)-length(modelHM.csense))
    modelHM.csense(a+i,1)='E';
end

% flag microbial reactions
modelHM.Microbiota = ones(length(modelHM.rxns),1);
modelHM.Microbiota(1:length(modelH.rxns))=0;

% adjust communityBiomass to percentage rather than fraction, in accordance
% to whole-body objective
modelHM.S(:,strmatch('communityBiomass',modelHM.rxns)) = 100*modelHM.S(:,strmatch('communityBiomass',modelHM.rxns)) ;
modelHM.A=modelHM.S;
modelHM = rmfield(modelHM,'rules');
modelHM = rmfield(modelHM,'grRules');
modelHM = convertOldStyleModel(modelHM);

for i = 1 : length(modelHM.rxns)
    modelHM.rules(i,1) = {''};
end

modelHM.genes = {''};