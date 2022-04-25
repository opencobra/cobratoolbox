function [OrganCompendium,TableCSources] = getOrgansFromHarvey(modelWBM,runTestsOnly,OrganCompendium, printLevel)
% This function cuts the organs from the whole-body metabolic model. Note that the different
% biofluid compartments are retained but all constraints on the exchange and transport reactions are overwritten
% Once the organs are extracted, the function runs the sanity check on each
% organ. This step can be also done independently by setting runTestsOnly
% to 1. In this case,  the OrganCompendium must be provided as input.
% The function also loads Recon 3* so that the test results can be compared
% with the organ test results.
%
% [OrganCompendium,TableCSources] = getOrgansFromHarvey(modelWBM, runTestsOnly, OrganCompendium)
%
% INPUT
% modelWBM                  model structure of whole-body metabolic model
% runTestsOnly
%
% OUTPUT
% OrganCompendium           Structure containing the individal organs as
%                           well as the basic tests that this organ passed
% TableCSources             Overview table of ATP yield per carbon source
%                           under aerobic and anaerobic conditions for each organ in the model
%                           structrure
%
% The organ compendium for each sex will be saved as
% OrganAtlas_Harvetta.mat and OrganAtlas_Harvey.mat along with the test
% results.
%
% Ines Thiele, 2017 - 2019

global resultsPath
resultsPath = which('MethodSection3.mlx');
resultsPath = strrep(resultsPath,'MethodSection3.mlx',['Results' filesep]);

if ~exist('printLevel','var')
    printLevel=0;
end

if ~exist('runTestsOnly','var')
    runTestsOnly=0;
end

% turn off warnings
warning('off','all')

sex = modelWBM.sex;
OrganLists;
if runTestsOnly ~= 1
    if isfield(modelWBM,'A')
        % remove all slack variables
        modelWBM.S = modelWBM.A;
        SL = strmatch('slack_',modelWBM.mets);
        modelWBM.mets(SL) = [];
        modelWBM.b(SL) = [];
        modelWBM.S(SL,:) = [];
    end
    modelWBM.mets(strmatch('RBC_o2[bc]',modelWBM.mets,'exact'))={'o2[bc]'};
    modelWBM.mets(strmatch('RBC_co2[bc]',modelWBM.mets,'exact'))={'co2[bc]'};
    sex = modelWBM.sex;
    clear OrganCompendium
    for i = 1 : length(OrgansListShort)
        
        % metabolic reactions
        modelTmp = modelWBM;
        
        progress = i/length(OrgansListShort);
        fprintf([num2str(progress*100) ' percent ... Extracting organs from WBM ... \n']);
        
        R1 = strmatch(OrgansListShort{i},modelTmp.rxns);
        if ~isempty(R1)
            % modelTmp.rxns(R1) = regexprep(modelTmp.rxns(R1),strcat(OrgansListShort{i},'_'),'');
            M1 = strmatch(OrgansListShort{i},modelTmp.mets(1:size(modelTmp.S,1)));
            %modelTmp.mets = regexprep(modelTmp.mets,strcat(OrgansListShort{i},'_'),'');
            model = struct();
            model.mets=cell(0,1);model.metNames=cell(0,1);model.metFormulas=cell(0,1);
            model.rxns=cell(0,1);model.rxnNames=cell(0,1);model.subSystems=cell(0,1);
            model.lb=zeros(0,1);model.ub=zeros(0,1);model.rev=zeros(0,1);
            model.c=zeros(0,1);model.b=zeros(0,1);
            model.S=sparse(0,0);
            % get organs
            % grap the corresponding Recon reactions
            for j =1 : length(R1)
                %a= printRxnFormulaOri(modelTmp,modelTmp.rxns(R1(j)),0,1,0,1,0);
                a = printRxnFormula(modelTmp,'rxnAbbrList',modelTmp.rxns(R1(j)),'printFlag',0,'lineChangeFlag',1,'metNameFlag',0,'fid',1,'directionFlag',0);
                
                model = addReaction(model,modelTmp.rxns{R1(j)},a{1});
                % same constraints as in coupled model!
                model.lb(end) = modelTmp.lb(R1(j));
                model.ub(end) = modelTmp.ub(R1(j));
            end
            
            % remove dummy's from model
            Dummy = (find(~cellfun(@isempty,strfind(model.mets,'dummy'))));
            model.mets(Dummy) = [];
            model.metNames(Dummy) = [];
            model.metFormulas(Dummy) = [];
            model.S(Dummy,:)= [];
            model.c = modelTmp.c(R1);
            model.grRules = [modelTmp.grRules(R1)];
            [a,b] = ismember( modelTmp.mets(M1),model.mets);
            model.b = zeros(length(model.mets),1);
            model.rev = zeros(length(model.lb),1);
            model.rev(find(model.lb<0))=1;
            
            model.genes = cell(0,1);
            % keep all model compartments
            modelAllComp = model;
            % find all exchange metabolites
            for j = 1 : length(modelAllComp.mets)
                if ~isempty(strfind(modelAllComp.mets{j},'[bd]'))||~isempty(strfind(modelAllComp.mets{j},'[luLI]'))...
                        ||~isempty(strfind(modelAllComp.mets{j},'[luSI]'))||~isempty(strfind(modelAllComp.mets{j},'[bc]'))...
                        ||~isempty(strfind(modelAllComp.mets{j},'[fe]'))||~isempty(strfind(modelAllComp.mets{j},'[u]'))...
                        ||~isempty(strfind(modelAllComp.mets{j},'[bp]'))||~isempty(strfind(modelAllComp.mets{j},'[a]'))...
                        ||~isempty(strfind(modelAllComp.mets{j},'[sw]'))||~isempty(strfind(modelAllComp.mets{j},'[csf]'))...
                        ||~isempty(strfind(modelAllComp.mets{j},'[lu]'))
                    modelAllComp = addExchangeRxn(modelAllComp,modelAllComp.mets(j),-1000,1000);
                end
            end
            modelAllComp.rxns=regexprep(modelAllComp.rxns,strcat(OrgansListShort(i),'_'),'');
            modelAllComp.mets=regexprep(modelAllComp.mets,strcat(OrgansListShort(i),'_'),'');
            %a = printRxnFormulaOri(modelAllComp,modelAllComp.rxns,0,0,0,'',0);
            a = printRxnFormula(modelAllComp,'rxnAbbrList',modelAllComp.rxns,'printFlag',0,'lineChangeFlag',0,'metNameFlag',0,'fid',0,'directionFlag',0);
            modelAllComp.reactions =a;
            modelAllComp.genes = [];
            modelAllComp.rxnGeneMat = [];
            % rewrite GPRs
            modelAllCompgrRule = modelAllComp.grRules;
            for j = 1 : length(modelAllCompgrRule)
                %modelAllComp = changeGeneAssociationOri(modelAllComp,modelAllComp.rxns{j},char(modelAllCompgrRule{j}));
                modelAllComp = changeGeneAssociation(modelAllComp,modelAllComp.rxns{j},char(modelAllCompgrRule{j}),0);%do
            end
            % rename all EX_ reactions that have 2 entries, e.g., 'EX_2m3hbu(e)_[bc]'	'2m3hbu[e]  <=> 2m3hbu[bc] ' but keeps
            % 'EX_2m3hbu[bc]'	'2m3hbu[bc]  <=> ' as is
            % find all reactions starting with EX_ in abbr
            EXAll = strmatch('EX_',modelAllComp.rxns);
            % find all reactions that have only one non-zero entry in the S matrizx
            selExc = (find( full((sum(abs(modelAllComp.S)==1,1) ==1) & (sum(modelAllComp.S~=0) == 1))))';
            EX2Rename = setdiff(EXAll,selExc);
            modelAllComp.rxns(EX2Rename) = strcat('Tr_',modelAllComp.rxns(EX2Rename));
            modelAllComp.rxns(strmatch('biomass_reactionIEC01b_trtr',modelAllComp.rxns)) = {'biomass_reaction_trtr'};
            modelAllComp.rxns(strmatch('biomass_reactionIEC01b',modelAllComp.rxns)) ={ 'biomass_maintenance'};
            OrganCompendium.(OrgansListShort{i}).modelAllComp = modelAllComp;
        end
        
    end
    % annotate organ compendium with Recon 3D data
    annotateRxns = 1;
    annotateMets = 1;
    O = fieldnames(OrganCompendium);
    for i = 1 : length(O)
        if ~(strcmp(O{i},'sex')) && ~(strcmp(O{i},'Recon3DHarvey'))
            OrganCompendium.(O{i}).modelAllComp = annotateModel(OrganCompendium.(O{i}).modelAllComp, annotateRxns,annotateMets);
        end
    end
    if strcmp(sex,'female')
        OrganCompendium.sex = 'female';
        %save OrganAtlas_Harvetta OrganCompendium  modelWBM
        mkdir(resultsPath);
        save([resultsPath 'OrganAtlas_Harvetta'],'OrganCompendium','modelWBM')
    else
        OrganCompendium.sex = 'male';
        mkdir(resultsPath);
        save([resultsPath 'OrganAtlas_Harvey'],'OrganCompendium','modelWBM')
    end
end
%% run Metabolic function tests and quality assurance/quality control tests.

organ = fieldnames(OrganCompendium);
clear TestSolutionName TestSolution OR FBA_OR R
for i =1 :length(organ)
    progress = i/length(organ);
    fprintf([num2str(progress) ' ... Running metabolic functional tests on each organ ... \n']);
    
    if ~strcmp('sex',organ{i}) &&  ~strcmp('Recon3DHarvey',organ{i})
        model = OrganCompendium.(organ{i}).modelAllComp;
        model.lb(find(model.lb<0))=-1000;
        model.ub(find(model.ub<0))=0;
        model.ub(find(model.ub>0))=1000;
        model.lb(find(model.lb>0))=0;
        % [X,TestSolutionName] = Test4HumanFctExtv4(model,'Harvey');
        resultsFileName = strcat(sex,organ{i});
        if strcmp('Brain',organ{i}) || strcmp('Scord',organ{i})
            extraCellCompIn = '[csf]';
            extraCellCompOut = '[csf]';
        elseif ~isempty(find(~cellfun(@isempty,strfind(model.rxns,'[bp]')))) && ~strcmp('Liver',organ{i})
            extraCellCompIn = '[bc]';
            % the out compartment does not matter as all out are anyway open
            extraCellCompOut = '[bp]';
        elseif ~isempty(find(~cellfun(@isempty,strfind(model.rxns,'[bd]')))) && ~strcmp('Liver',organ{i})
            extraCellCompIn = '[bc]';
            % the out compartment does not matter as all out are anyway open
            extraCellCompOut = '[bd]';
        else
            extraCellCompIn = '[bc]';
            % the out compartment does not matter as all out are anyway open
            extraCellCompOut = '[bc]';
        end
        %NOTE I have to test also Liver with bp input
        
        % revert the direction of sinks
        SI = strmatch('sink_',model.rxns);
        for k = 1 : length(SI)
            if ~isempty(find(model.S(:,SI(k))==1))% positive entry
                % flip it
                model.S(find(model.S(:,SI(k))==1),SI(k)) = -1;
                model.lb(SI(k)) = min(model.lb(SI(k)),model.ub(SI(k)));
                model.ub(SI(k)) = max(model.lb(SI(k)),model.ub(SI(k)));
            end
        end
        % revert the direction of demands
        SI = strmatch('DM_',model.rxns);
        for k = 1 : length(SI)
            if ~isempty(find(model.S(:,SI(k))==1)) && length(find(model.S(:,SI(k))==1))==1% positive entry
                % flip it
                model.S(find(model.S(:,SI(k))==1),SI(k)) = -1;
                model.lb(SI(k)) = 0%min(model.lb(SI(k)),model.ub(SI(k)));
                model.lb(SI(k)) = max(model.lb(SI(k)),model.ub(SI(k)));
            end
        end
        
        modelClosed = model;
        % prepare models for test - these changes are needed for the different
        % recon versions to match the rxn abbr definitions in this script
        modelClosed.rxns = regexprep(modelClosed.rxns,'\(','\[');
        modelClosed.rxns = regexprep(modelClosed.rxns,'\)','\]');
        modelClosed.mets = regexprep(modelClosed.mets,'\(','\[');
        modelClosed.mets = regexprep(modelClosed.mets,'\)','\]');
        modelClosed.rxns = regexprep(modelClosed.rxns,'ATPS4mi','ATPS4m');
        
        % replace older abbreviation of glucose exchange reaction with the one used
        % in this script
        if length(strmatch(strcat('EX_glc',extraCellCompIn),modelClosed.rxns))>0
            modelClosed.rxns{find(ismember(modelClosed.rxns,strcat('EX_glc',extraCellCompIn)))} = strcat('EX_glc_D',extraCellCompIn);
        end
        if length(strmatch(strcat('EX_glc',extraCellCompOut),modelClosed.rxns))>0
            modelClosed.rxns{find(ismember(modelClosed.rxns,strcat('EX_glc',extraCellCompOut)))} = strcat('EX_glc_D',extraCellCompOut);
        end
        
        % add reaction if it does not exist
        [modelClosed, rxnIDexists] = addReaction(modelClosed,'DM_atp_c_','reactionFormula','h2o[c] + atp[c] -> adp[c] + h[c] + pi[c] ','printLevel',0);
        if length(rxnIDexists)>0
            modelClosed.rxns{rxnIDexists} = 'DM_atp_c_'; % rename reaction in case that it exists already
        end
        
        modelClosed.lb(find(ismember(modelClosed.rxns, 'Tr_EX_o2[e]_[bc]')))=-1000;
        modelClosed.lb(find(ismember(modelClosed.rxns, 'Tr_EX_co2[e]_[bc]')))=-1000;
        modelClosed = changeRxnBounds(modelClosed, 'DCMPtm',-1000,'l');
        
        OrganCompendium.(organ{i}).modelAllComp = modelClosed;
        [OrganCompendium.(organ{i}).Sanity.TableChecks,...
            OrganCompendium.(organ{i}).Sanity.Table_csources,...
            OrganCompendium.(organ{i}).Sanity.CSourcesTestedRxns,...
            OrganCompendium.(organ{i}).Sanity.TestSolutionNameOpenSinks,...
            OrganCompendium.(organ{i}).Sanity.TestSolutionNameClosedSinks]...
            = performSanityChecksonRecon(modelClosed,resultsFileName,extraCellCompIn,extraCellCompOut);
    end
end

load('Recon3D_Harvey_Used_in_Script_120502.mat')
%load('Y:\SemiAutomated_Organ_Models\_InesProteomeMapData\Recon2.1\Recon3_and_alike\2017_05_18_Recon3d_consistencyCheckHarvey.mat');
annotateRxns = 1;
annotateMets = 1;
modelConsistent = annotateModel(modelConsistent, annotateRxns,annotateMets);
OrganCompendium.Recon3DHarvey.model = modelConsistent;

[OrganCompendium.Recon3DHarvey.Sanity.TableChecks, OrganCompendium.Recon3DHarvey.Sanity.Table_csources,OrganCompendium.Recon3DHarvey.Sanity.CSourcesTestedRxns,  OrganCompendium.Recon3DHarvey.Sanity.TestSolutionNameOpenSinks,OrganCompendium.Recon3DHarvey.Sanity.TestSolutionNameClosedSinks] = performSanityChecksonRecon(modelConsistent,'Recon3DHarvey');

% get results from all Csources
organ = fieldnames(OrganCompendium);
TableCSources(:,1) = OrganCompendium.(organ{1}).Sanity.Table_csources(:,1);
% theoretical
TableCSources(:,2) = OrganCompendium.(organ{1}).Sanity.Table_csources(:,4);
% Recon2.2
TableCSources(:,3) = OrganCompendium.(organ{1}).Sanity.Table_csources(:,5);

for i = 1 : length(organ)
    if ~strcmp('sex',organ{i})
        TableCSources(:,i+3) = OrganCompendium.(organ{i}).Sanity.Table_csources(:,2);
        TableCSources(1,i+3) = organ(i);
    end
end