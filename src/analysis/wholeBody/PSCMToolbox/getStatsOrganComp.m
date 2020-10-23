function [TableProp_female,TableProp_male, TableGRM,TableMetsNum_female,TableMetsNum_male,TableGenes_femaleNum] = getStatsOrganComp(female, male, OrganCompendium_female, OrganCompendium_male, violinPlots)
% This function compiles general statistics on the male and the female
% organ compendia derived from the male and female whole-body metabolic
% models.
%
% [TableProp_female,TableProp_male, TableGRM] = getStatsOrganComp(female, male, OrganCompendium_female, OrganCompendium_male, violinPlots)
%
% INPUT
% female                    model structure, female whole-body metabolic
%                           model
% male                      model structure, male whole-body metabolic
%                           model
% OrganCompendium_female    strucutre containing the different organs
%                           (generated with the function getOrgansFromHarvey
% OrganCompendium_male      strucutre containing the different organs
%                           (generated with the function getOrgansFromHarvey
% violinPlots               plot violin plots (does not work below Matlab
%                           2016) (defaul = 0)
%
% OUTPUT
% TableProp_female          Table containing organ-specific information
% TableProp_male            Table containing organ-specific information
%
% A more comprehensive comparison output is provided in the file:
% Results_StatsOrganComp.mat that is created at the end of this function.
%
% Ines Thiele, 2017

global resultsPath
resultsPath = which('MethodSection3.mlx');
resultsPath = strrep(resultsPath,'MethodSection3.mlx',['Results' filesep]);

if  ~exist('violinPlots','var')
    violinPlots = 0;
end

% load Recon 3D* used for Harvey
load('Recon3D_Harvey_Used_in_Script_120502.mat')
Recon3DHarvey = modelConsistent;

% female
BC_mets = (find(~cellfun(@isempty,strfind(female.mets,'[bc]'))));
SL = (find(~cellfun(@isempty,strfind(female.mets,'slack_'))));
SL_female = SL;
BC_mets_female = setdiff(BC_mets,SL);
U_mets = (find(~cellfun(@isempty,strfind(female.mets,'[u]'))));
U_mets_female = setdiff(U_mets,SL);
BP_mets = (find(~cellfun(@isempty,strfind(female.mets,'[bp]'))));
BP_mets_female = setdiff(BP_mets,SL);
BD_mets = (find(~cellfun(@isempty,strfind(female.mets,'[bd]'))));
BD_mets_female = setdiff(BD_mets,SL);
CSF_mets = (find(~cellfun(@isempty,strfind(female.mets,'[csf]'))));
CSF_mets_female = setdiff(CSF_mets,SL);
D_mets = (find(~cellfun(@isempty,strfind(female.mets,'[d]'))));
D_mets_female = setdiff(D_mets,SL);
FE_mets = (find(~cellfun(@isempty,strfind(female.mets,'[fe]'))));
FE_mets_female = setdiff(FE_mets,SL);
SW_mets = (find(~cellfun(@isempty,strfind(female.mets,'[sw]'))));
SW_mets_female = setdiff(SW_mets,SL);
A_mets = (find(~cellfun(@isempty,strfind(female.mets,'[a]'))));
A_mets_female = setdiff(A_mets,SL);
M_mets = (find(~cellfun(@isempty,strfind(female.mets,'[mi]'))));
M_mets_female = setdiff(M_mets,SL);

% male
BC_mets = (find(~cellfun(@isempty,strfind(male.mets,'[bc]'))));
SL = (find(~cellfun(@isempty,strfind(male.mets,'slack_'))));
SL_male = SL;
BC_mets_male = setdiff(BC_mets,SL);
U_mets = (find(~cellfun(@isempty,strfind(male.mets,'[u]'))));
U_mets_male = setdiff(U_mets,SL);
BP_mets = (find(~cellfun(@isempty,strfind(male.mets,'[bp]'))));
BP_mets_male = setdiff(BP_mets,SL);
BD_mets = (find(~cellfun(@isempty,strfind(male.mets,'[bd]'))));
BD_mets_male = setdiff(BD_mets,SL);
CSF_mets = (find(~cellfun(@isempty,strfind(male.mets,'[csf]'))));
CSF_mets_male = setdiff(CSF_mets,SL);
D_mets = (find(~cellfun(@isempty,strfind(male.mets,'[d]'))));
D_mets_male = setdiff(D_mets,SL);
FE_mets = (find(~cellfun(@isempty,strfind(male.mets,'[fe]'))));
FE_mets_male = setdiff(FE_mets,SL);
SW_mets = (find(~cellfun(@isempty,strfind(male.mets,'[sw]'))));
SW_mets_male = setdiff(SW_mets,SL);
A_mets = (find(~cellfun(@isempty,strfind(male.mets,'[a]'))));
A_mets_male = setdiff(A_mets,SL);
M_mets = (find(~cellfun(@isempty,strfind(male.mets,'[mi]'))));
M_mets_male = setdiff(M_mets,SL);

Table_Met_comp(1,:) ={' ';'Harvetta';'Harvey'};
Table_Met_comp(2,:) ={'Number of Reactions';num2str(length(female.rxns));num2str(length(male.rxns))};
Table_Met_comp(3,:) ={'Number of Metabolites'	num2str(length(female.mets)-length(SL_female))	num2str(length(male.mets)-length(SL_male))};
Table_Met_comp(4,:) ={'Number of Genes (transcripts)'	num2str(length(female.genes))	num2str(length(male.genes))};
Table_Met_comp(5,:) ={'Number of Subsystems'	num2str(length(unique(female.subSystems)))	num2str(length(unique(male.subSystems)))};
Table_Met_comp(6,:) ={'Blood compartment metabolites'	num2str(length(BC_mets_female))	num2str(length(BC_mets_male))};
Table_Met_comp(7,:) ={'Urine metabolites'	num2str(length(U_mets_female))	num2str(length(U_mets_male))};
Table_Met_comp(8,:) ={'Portal vein metabolites'	num2str(length(BP_mets_female))	num2str(length(BP_mets_male))};
Table_Met_comp(9,:) ={'Bile duct metabolites'	num2str(length(BD_mets_female))	num2str(length(BD_mets_male))};
Table_Met_comp(10,:) ={'CSF metabolites'	num2str(length(CSF_mets_female))	num2str(length(CSF_mets_male))};
Table_Met_comp(11,:) ={'Diet metabolites'	num2str(length(D_mets_female))	num2str(length(D_mets_male))};
Table_Met_comp(12,:) ={'Fecal metabolites'	num2str(length(FE_mets_female))	num2str(length(FE_mets_male))};
Table_Met_comp(13,:) ={'Sweat metabolites'	num2str(length(SW_mets_female))	num2str(length(SW_mets_male))};
Table_Met_comp(14,:) ={'Air metabolites'	num2str(length(A_mets_female))	num2str(length(A_mets_male))};
Table_Met_comp(15,:) ={'Milk metabolites'	num2str(length(M_mets_female))	num2str((0))};

BC_male_only = setdiff(male.mets(BC_mets_male),female.mets(BC_mets_female));

CSF_male_only = setdiff(male.mets(CSF_mets_male),female.mets(CSF_mets_female));
CSF_female_only = setdiff(female.mets(CSF_mets_female),male.mets(CSF_mets_male));
CSF_shared = intersect(female.mets(CSF_mets_female),male.mets(CSF_mets_male));


U_male_only = setdiff(male.mets(U_mets_male),female.mets(U_mets_female));
U_female_only = setdiff(female.mets(U_mets_female),male.mets(U_mets_male));
U_shared = intersect(female.mets(U_mets_female),male.mets(U_mets_male));

% reactions unique to each sex
Rxns_male_only = setdiff(male.rxns,female.rxns);
Rxns_female_only = setdiff(female.rxns,male.rxns);


load('microbiota_model_samp_SRS011239.mat');

% unique microbial metabolites [lu] compartment
MyU_rxns = microbiota_model.rxns(find(~cellfun(@isempty,strfind(microbiota_model.rxns,'UFEt'))));
MyU_rxns = unique(regexprep(MyU_rxns,'UFEt_',''));

Omale = fieldnames(OrganCompendium_male);
Ofemale = fieldnames(OrganCompendium_female);

clear TableProp_male
for i = 1 : length(Omale)
    if ~strcmp('sex',Omale{i}) && ~strcmp('gender',Omale{i}) && ~strcmp('Recon3DHarvey',Omale{i})
        clear remR3M
        cm =2;
        TableProp_male{i+1,1} = Omale{i};
        
        TableProp_male{1,cm} = {'Reactions'};
        TableProp_male{i+1,cm} = num2str(length(OrganCompendium_male.(Omale{i}).modelAllComp.rxns)); cm = cm + 1;
        
        TableProp_male{1,cm} = {'Reactions (without exchange/transport reactions)'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'EX_')));
        DM =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'DM_')));
        Sink =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'sink_')));
        EX = [EX;DM;Sink];
        NoEx = length(OrganCompendium_male.(Omale{i}).modelAllComp.rxns)-length(EX);
        TableProp_male{i+1,cm} = num2str(NoEx); cm = cm + 1;
        
        TableProp_male{1,cm} = {'Percentage of all Recon Reactions (without exchange/transport reactions)'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'EX_')));
        DM =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'DM_')));
        Sink =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'sink_')));
        EX = [EX;DM;Sink];
        NoEx = length(OrganCompendium_male.(Omale{i}).modelAllComp.rxns)-length(EX);
        Rxns = length(Recon3DHarvey.rxns);
        TableProp_male{i+1,cm} = num2str(NoEx*100/Rxns); cm = cm + 1;
        
        TableProp_male{1,cm} = {'Metabolites'};
        TableProp_male{i+1,cm} = num2str(length(OrganCompendium_male.(Omale{i}).modelAllComp.mets)); cm = cm + 1;
        
        TableProp_male{1,cm} = {'Percentage of all Recon Metabolites'};
        TableProp_male{i+1,cm} = num2str(length(OrganCompendium_male.(Omale{i}).modelAllComp.mets)*100/length(Recon3DHarvey.mets)); cm = cm + 1;
        
        TableProp_male{1,cm} = {'Metabolites (unique)'};
        [g,remR3M]=strtok(OrganCompendium_male.(Omale{i}).modelAllComp.mets,'[');
        TableProp_male{i+1,cm} = num2str(length(unique(g))); cm = cm + 1;
        
        TableProp_male{1,cm} = {'Percentage of all Metabolites (unique)'};
        [g,remR3M]=strtok(OrganCompendium_male.(Omale{i}).modelAllComp.mets,'[');
        [Mets]=strtok(male.mets,'[');
        TableProp_male{i+1,cm} = num2str(length(unique(g))*100/length(unique(Mets))); cm = cm + 1;
        
        % number of compartments
        TableProp_male{1,cm} = {'Compartments (unique)'};
        TableProp_male{i+1,cm} = num2str(length(unique(remR3M))); cm = cm + 1;
        
        % list of compartments
        TableProp_male{1,cm} = {'Compartment List (unique)'};
        C = unique(remR3M);
        for j= 1 : length(C)
            s= ' ';
            TableProp_male{i+1,cm} = strcat(TableProp_male{i+1,cm},',',s,C{j});
        end
        cm = cm + 1;
        
        %number of exchanges with [bc]
        TableProp_male{1,cm} = {'Number of exchanges with [bc]'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'[bc]')));
        BCK =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'[bcK]')));
        BC = intersect(EX,BC);
        BC = setdiff(BC,BCK);
        TableProp_male{i+1,cm} = num2str(length(BC)); cm = cm + 1;
        
        %percentage of all exchanges with [bc]
        TableProp_male{1,cm} = {'Percentage of all exchanges with [bc]'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'[bc]')));
        BCK =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'[bcK]')));
        BC = intersect(EX,BC);
        BC = setdiff(BC,BCK);
        TableProp_male{i+1,cm} = num2str(length(BC)*100/length(BC_mets_male)); cm = cm + 1;
        
        %number of exchanges with [bp]
        TableProp_male{1,cm} = {'Number of exchanges with [bp]'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'[bp')));
        BC = intersect(EX,BC);
        TableProp_male{i+1,cm} = num2str(length(BC)); cm = cm + 1;
        
        %percentage of all exchanges with [bp]
        TableProp_male{1,cm} = {'Percentage of all exchanges with [bp]'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'[bp')));
        BC = intersect(EX,BC);
        TableProp_male{i+1,cm} = num2str(length(BC)*100/length(BP_mets_male)); cm = cm + 1;
        
        %number of exchanges with [bd]
        TableProp_male{1,cm} = {'Number of exchanges with [bd]'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'[bd')));
        BC = intersect(EX,BC);
        TableProp_male{i+1,cm} = num2str(length(BC)); cm = cm + 1;
        
        
        %percentage of all exchanges with [bd]
        TableProp_male{1,cm} = {'Percentage of all exchanges with [bd]'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'[bd')));
        BC = intersect(EX,BC);
        TableProp_male{i+1,cm} = num2str(length(BC)*100/length(BD_mets_male)); cm = cm + 1;
        
        %number of exchanges with [lu]
        TableProp_male{1,cm} = {'Number of exchanges with [lu]'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'[lu')));
        BC = intersect(EX,BC);
        TableProp_male{i+1,cm} = num2str(length(BC)); cm = cm + 1;
        
        
        %number of exchanges with [csf]
        TableProp_male{1,cm} = {'Number of exchanges with [csf]'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'[csf')));
        BC = intersect(EX,BC);
        TableProp_male{i+1,cm} = num2str(length(BC)); cm = cm + 1;
        
        %percentage of all exchanges with [csf]
        TableProp_male{1,cm} = {'Percentage of all exchanges with [csf]'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'[csf')));
        BC = intersect(EX,BC);
        TableProp_male{i+1,cm} = num2str(length(BC)*100/length(CSF_mets_male)); cm = cm + 1;
        
        %number of exchanges with [sw]
        TableProp_male{1,cm} = {'Number of exchanges with [sw]'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'[sw')));
        BC = intersect(EX,BC);
        TableProp_male{i+1,cm} = num2str(length(BC)); cm = cm + 1;
        
        %number of exchanges with [a]
        TableProp_male{1,cm} = {'Number of exchanges with [a]'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'[a')));
        BC = intersect(EX,BC);
        TableProp_male{i+1,cm} = num2str(length(BC)); cm = cm + 1;
        
        %number of exchanges with [u]
        TableProp_male{1,cm} = {'Number of exchanges with [u]'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'[u]')));
        BC = intersect(EX,BC);
        TableProp_male{i+1,cm} = num2str(length(BC)); cm = cm + 1;
        
        %percentage of all exchanges with [u]
        TableProp_male{1,cm} = {'Percentage of all exchanges with [u]'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'[u]')));
        BC = intersect(EX,BC);
        TableProp_male{i+1,cm} = num2str(length(BC)*100/length(U_mets_male)); cm = cm + 1;
        
        %[bc] overlap with microbiota metabolites
        TableProp_male{1,cm} = {'Percentage of overlap of [bc] with microbiota metabolites'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'[bc')));
        BC = intersect(EX,BC);
        BCM = OrganCompendium_male.(Omale{i}).modelAllComp.rxns(BC);
        BCM = regexprep(BCM,'Tr_EX_','');
        BCM = regexprep(BCM,'\(e.+','');
        BCM_MY = intersect(BCM,MyU_rxns);
        if ~isempty(BC)
            TableProp_male{i+1,cm} = num2str(length(BCM_MY)*100/length(BC)); cm = cm + 1;
        else
            TableProp_male{i+1,cm} = 'NA'; cm = cm + 1;
        end
        
        
        %[bp] overlap with microbiota metabolites
        TableProp_male{1,cm} = {'Percentage of overlap of [bp] with microbiota metabolites'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'[bp')));
        BC = intersect(EX,BC);
        BCM = OrganCompendium_male.(Omale{i}).modelAllComp.rxns(BC);
        BCM = regexprep(BCM,'Tr_EX_','');
        BCM = regexprep(BCM,'\[bp.+','');
        BCM_MY = intersect(BCM,MyU_rxns);
        if ~isempty(BC)
            TableProp_male{i+1,cm} = num2str(length(BCM_MY)*100/length(BC)); cm = cm + 1;
        else
            TableProp_male{i+1,cm} = 'NA'; cm = cm + 1;
        end
        
        %[bd] overlap with microbiota metabolites
        TableProp_male{1,cm} = {'Percentage of overlap of [bd] with microbiota metabolites'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'[bd')));
        BC = intersect(EX,BC);
        BCM = OrganCompendium_male.(Omale{i}).modelAllComp.rxns(BC);
        BCM = regexprep(BCM,'Tr_EX_','');
        BCM = regexprep(BCM,'\[bd.+','');
        BCM_MY = intersect(BCM,MyU_rxns);
        if ~isempty(BC)
            TableProp_male{i+1,cm} = num2str(length(BCM_MY)*100/length(BC)); cm = cm + 1;
        else
            TableProp_male{i+1,cm} = 'NA'; cm = cm + 1;
        end
        
        %[csf] overlap with microbiota metabolites
        TableProp_male{1,cm} = {'Percentage of overlap of [csf] with microbiota metabolites'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'[csf')));
        BC = intersect(EX,BC);
        BCM = OrganCompendium_male.(Omale{i}).modelAllComp.rxns(BC);
        BCM = regexprep(BCM,'Tr_EX_','');
        BCM = regexprep(BCM,'\(e.+','');
        BCM_MY = intersect(BCM,MyU_rxns);
        if ~isempty(BC)
            TableProp_male{i+1,cm} = num2str(length(BCM_MY)*100/length(BC)); cm = cm + 1;
        else
            TableProp_male{i+1,cm} = 'NA'; cm = cm + 1;
        end
        
        %[u] overlap with microbiota metabolites
        TableProp_male{1,cm} = {'Percentage of overlap of [u] with microbiota metabolites'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'[u')));
        BC = intersect(EX,BC);
        BCM = OrganCompendium_male.(Omale{i}).modelAllComp.rxns(BC);
        BCM = regexprep(BCM,'Tr_EX_','');
        BCM = regexprep(BCM,'\(e.+','');
        BCM_MY = intersect(BCM,MyU_rxns);
        if ~isempty(BC)
            TableProp_male{i+1,cm} = num2str(length(BCM_MY)*100/length(BC)); cm = cm + 1;
        else
            TableProp_male{i+1,cm} = 'NA'; cm = cm + 1;
        end
        
        %[u] overlap with microbiota metabolites
        TableProp_male{1,cm} = {'Percentage of overlap of [u] with microbiota metabolites'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'[u')));
        BC = intersect(EX,BC);
        BCM = OrganCompendium_male.(Omale{i}).modelAllComp.rxns(BC);
        BCM = regexprep(BCM,'Tr_EX_','');
        BCM = regexprep(BCM,'\(e.+','');
        BCM_MY = intersect(BCM,MyU_rxns);
        if ~isempty(BC)
            TableProp_male{i+1,cm} = num2str(length(BCM_MY)*100/length(BC)); cm = cm + 1;
        else
            TableProp_male{i+1,cm} = 'NA'; cm = cm + 1;
        end
        
        %[lu] overlap with microbiota metabolites
        TableProp_male{1,cm} = {'Percentage of overlap of [lu] with microbiota metabolites'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_male.(Omale{i}).modelAllComp.rxns,'[lu')));
        BC = intersect(EX,BC);
        BCM = OrganCompendium_male.(Omale{i}).modelAllComp.rxns(BC);
        BCM = regexprep(BCM,'Tr_EX_','');
        BCM = regexprep(BCM,'\[lu.+','');
        BCM_MY = intersect(BCM,MyU_rxns);
        if ~isempty(BC)
            TableProp_male{i+1,cm} = num2str(length(BCM_MY)*100/length(BC)); cm = cm + 1;
        else
            TableProp_male{i+1,cm} = 'NA'; cm = cm + 1;
        end
        
        TableProp_male{1,cm} = {'Transcripts'};
        TableProp_male{i+1,cm} = num2str(length(OrganCompendium_male.(Omale{i}).modelAllComp.genes)); cm = cm + 1;
        
        TableProp_male{1,cm} = {'Genes (unique)'};
        [g,rem]=strtok(OrganCompendium_male.(Omale{i}).modelAllComp.genes,'.');
        TableProp_male{i+1,cm} = num2str(length(unique(g))); cm = cm + 1;
        
        TableProp_male{1,cm} = {'Number Genes Associated Reactions'};
        str = length(find(~cellfun(@isempty,OrganCompendium_male.(Omale{i}).modelAllComp.grRules)));
        TableProp_male{i+1,cm} = num2str(str); cm = cm + 1;
        
        TableProp_male{1,cm} = {'Percentage Genes Associated Reactions (Exchange Rxns excl)'};
        str = length(find(~cellfun(@isempty,OrganCompendium_male.(Omale{i}).modelAllComp.grRules)));
        TableProp_male{i+1,cm} = num2str(str*100/NoEx); cm = cm + 1;
        PercGeneAssRxns_male(i,1) = str*100/NoEx;
        
%         TableProp_male{1,cm} = {'Subsystems'};
%         if isempty(OrganCompendium_male.(Omale{i}).modelAllComp.subSystems{1})
%             TableProp_male{i+1,cm}=NaN;
%         else
%             TableProp_male{i+1,cm} = num2str(length(unique(OrganCompendium_male.(Omale{i}).modelAllComp.subSystems))); 
%         end
%         cm = cm + 1;
        
        TableProp_male{1,cm} = {'Size of S'};
        TableProp_male{i+1,cm} = strcat(num2str(size(OrganCompendium_male.(Omale{i}).modelAllComp.S,1)),'; ',num2str(size(OrganCompendium_male.(Omale{i}).modelAllComp.S,2))); cm = cm + 1;
        
        % rank of S
        TableProp_male{1,cm} = {'Rank of S'};
        %   TableProp_male{i+1,cm} = strcat(num2str(rank(full(OrganCompendium_male.(Omale{i}).modelAllComp.S)))); cm = cm + 1;
        
    end
end
TableProp_male=TableProp_male';

%% compare reaction content
clear TableRxns TableRxnsNum
%Rxns = Recon3DHarvey.rxns;

Rxns = [];
% get set of unique reactions
for i = 1 : length(Omale)
    if ~strcmp('sex',Omale{i}) && ~strcmp('gender',Omale{i}) && ~strcmp('Recon3DHarvey',Omale{i})
        % grab reactions
        ORxns = OrganCompendium_male.(Omale{i}).modelAllComp.rxns;
        ORxns = regexprep(ORxns,'Tr_','');
        ORxns = regexprep(ORxns,'_\[\w+\]','');
        ORxns = regexprep(ORxns,'\[\w\w\w\]','');
        ORxns = regexprep(ORxns,'\[\w\w\]','');
        ORxns = regexprep(ORxns,'\(','\[');
        ORxns = regexprep(ORxns,'\)','\]');
        ORxns = regexprep(ORxns,'_c_','\[c\]');
        ORxns = regexprep(ORxns,'_g_','\[g\]');
        ORxns = regexprep(ORxns,'_n_','\[n\]');
        ORxns = regexprep(ORxns,'_m_','\[m\]');
        ORxns = regexprep(ORxns,'_r_','\[r\]');
        ORxns = regexprep(ORxns,'_x_','\[x\]');
        ORxns = regexprep(ORxns,'\[u\]','');
        ORxns = regexprep(ORxns,'\[e\]','');
        ORxns = regexprep(ORxns,'\[mi\w\]','');
        ORxns = regexprep(ORxns,'\[sw\w\]','');
        ORxns = regexprep(ORxns,'\[lu\w\w\]','');
        Rxns = [Rxns;ORxns];
        
    end
end
Rxns = unique(Rxns);

TableRxns_male(1:length(Rxns),1) = (Rxns);
for i = 1 : length(Omale)
    if ~strcmp('sex',Omale{i}) && ~strcmp('gender',Omale{i}) && ~strcmp('Recon3DHarvey',Omale{i})
        % grab reactions
        ORxns = OrganCompendium_male.(Omale{i}).modelAllComp.rxns;
        ORxns = regexprep(ORxns,'Tr_','');
        ORxns = regexprep(ORxns,'_\[\w+\]','');
        ORxns = regexprep(ORxns,'\[\w\w\w\]','');
        ORxns = regexprep(ORxns,'\[\w\w\]','');
        ORxns = regexprep(ORxns,'\(','\[');
        ORxns = regexprep(ORxns,'\)','\]');
        ORxns = regexprep(ORxns,'_c_','\[c\]');
        ORxns = regexprep(ORxns,'_g_','\[g\]');
        ORxns = regexprep(ORxns,'_n_','\[n\]');
        ORxns = regexprep(ORxns,'_m_','\[m\]');
        ORxns = regexprep(ORxns,'_r_','\[r\]');
        ORxns = regexprep(ORxns,'_x_','\[x\]');
        ORxns = regexprep(ORxns,'\[u\]','');
        ORxns = regexprep(ORxns,'\[e\]','');
        ORxns = regexprep(ORxns,'\[mi\w\]','');
        ORxns = regexprep(ORxns,'\[sw\w\]','');
        ORxns = regexprep(ORxns,'\[lu\w\w\]','');
        ORxns = regexprep(ORxns,'_DIFF\[c\]','_DIFF');
        TableRxns_male(:,i+1)=num2cell(0);
        TableRxns_maleO{1,i+1} = Omale{i};
        TableRxns_male(find(ismember(Rxns,ORxns)),i+1)=num2cell(1);
        TableRxnsNum_male(find(ismember(Rxns,ORxns)),i)=1;
    end
end

TableRxns_male = [TableRxns_maleO;TableRxns_male];
% correlation
TableRxnsNumCorr_male = corrcoef(TableRxnsNum_male);

% shared reactions
TableRxns_maleNumInOrgans = TableRxnsNum_male*TableRxnsNum_male';
RxnsInOrgans_male = diag(TableRxns_maleNumInOrgans);
HousekeepingRxns_male = Rxns(find(RxnsInOrgans_male>=length(Omale)-2));%2 entries of Omale are no organs
OrganSpecRxns_male = Rxns(find(RxnsInOrgans_male==1));%at most in 2 organs
NoOrgaRxns_male = Rxns(find(RxnsInOrgans_male==0));%at most in 2 organs
OtherOrganRxns_male = Rxns(find(RxnsInOrgans_male>1 & RxnsInOrgans_male<length(Omale)-2));%at most in 2 organs
s = {' '};
sumRxns = length(NoOrgaRxns_male)+length(OtherOrganRxns_male)+length(OrganSpecRxns_male)+length(HousekeepingRxns_male);
TableGRM{1,1} = 'male';
TableGRM{1,4} = 'Reactions';
TableGRM{2,1} = 'core';
TableGRM{2,4} = strcat(num2str(length(HousekeepingRxns_male)),s,'(',num2str(round(length(HousekeepingRxns_male)*100/sumRxns,1)),'%)');
TableGRM{3,1} = 'organ-specific';
TableGRM{3,4} = strcat(num2str(length(OrganSpecRxns_male)),s,'(',num2str(round(length(OrganSpecRxns_male)*100/sumRxns,1)),'%)');
TableGRM{4,1} = 'others';
TableGRM{4,4} = strcat(num2str(length(OtherOrganRxns_male)),s,'(',num2str(round(length(OtherOrganRxns_male)*100/sumRxns,1)),'%)');
TableGRM{5,1} = 'absent';
TableGRM{5,4} = strcat(num2str(length(NoOrgaRxns_male)),s,'(',num2str(round(length(NoOrgaRxns_male)*100/sumRxns,1)),'%)');
TableGRM{6,1} = 'sum';
TableGRM{6,4} = num2str(sumRxns);


for i = 1 : length(Omale)
    if ~strcmp('sex',Omale{i}) && ~strcmp('gender',Omale{i}) && ~strcmp('Recon3DHarvey',Omale{i})
        % grab reactions
        ORxns = OrganCompendium_male.(Omale{i}).modelAllComp.rxns;
        HouseCoreORxns_male(i,1) = length(intersect(HousekeepingRxns_male ,ORxns))*100/length(ORxns);
        HouseCoreORxns_male(i,2) = length(intersect(OrganSpecRxns_male ,ORxns))*100/length(ORxns);
        CoreOrganRxns_male(i,1) = length(intersect(OrganSpecRxns_male ,ORxns));
        
    end
end


if 0
    figure;
    bar([HouseCoreORxns_male(:,1) HouseCoreORxns_male(:,2)],'stacked');
end

clear TableMets_male TableMetsNum_male
%Mets = Recon3DHarvey.mets;

Mets = [];
% get set of unique metablites
for i = 1 : length(Omale)
    if ~strcmp('sex',Omale{i}) && ~strcmp('gender',Omale{i}) && ~strcmp('Recon3DHarvey',Omale{i})
        % grab reactions
        OMets = OrganCompendium_male.(Omale{i}).modelAllComp.mets;
        OMets = regexprep(OMets,'\[b\w\w\]','\[e\]');
        OMets = regexprep(OMets,'\[b\w\]','\[e\]');
        OMets = regexprep(OMets,'\[u\]','\[e\]');
        OMets = regexprep(OMets,'\[u\]','\[e\]');
        OMets = regexprep(OMets,'\[lu\]','\[e\]');
        OMets = regexprep(OMets,'\[lu\w+\]','\[e\]');
        OMets = regexprep(OMets,'\[csf\]','\[e\]');
        OMets = regexprep(OMets,'\[s\w+\]','\[e\]');
        OMets = regexprep(OMets,'\[fe\]','\[e\]');
        OMets = regexprep(OMets,'\[a\]','\[e\]');
        OMets = regexprep(OMets,'\[e\]','');
        OMets = regexprep(OMets,'\[c\]','');
        OMets = regexprep(OMets,'\[m\]','');
        OMets = regexprep(OMets,'\[r\]','');
        OMets = regexprep(OMets,'\[g\]','');
        OMets = regexprep(OMets,'\[x\]','');
        OMets = regexprep(OMets,'\[n\]','');
        OMets = regexprep(OMets,'\[l\]','');
        Mets = [Mets;OMets];
    end
end
Mets = unique(Mets);

clear TableMets_male
TableMets_male(1:length(Mets),1) = (Mets);
for i = 1 : length(Omale)
    if ~strcmp('sex',Omale{i}) && ~strcmp('gender',Omale{i}) && ~strcmp('Recon3DHarvey',Omale{i})
        % grab reactions
        OMets = OrganCompendium_male.(Omale{i}).modelAllComp.mets;
        OMets = regexprep(OMets,'\[b\w\w\]','\[e\]');
        OMets = regexprep(OMets,'\[b\w\]','\[e\]');
        OMets = regexprep(OMets,'\[u\]','\[e\]');
        OMets = regexprep(OMets,'\[u\]','\[e\]');
        OMets = regexprep(OMets,'\[lu\]','\[e\]');
        OMets = regexprep(OMets,'\[lu\w+\]','\[e\]');
        OMets = regexprep(OMets,'\[csf\]','\[e\]');
        OMets = regexprep(OMets,'\[s\w+\]','\[e\]');
        OMets = regexprep(OMets,'\[fe\]','\[e\]');
        OMets = regexprep(OMets,'\[a\]','\[e\]');
        OMets = regexprep(OMets,'\[e\]','');
        OMets = regexprep(OMets,'\[c\]','');
        OMets = regexprep(OMets,'\[m\]','');
        OMets = regexprep(OMets,'\[r\]','');
        OMets = regexprep(OMets,'\[g\]','');
        OMets = regexprep(OMets,'\[x\]','');
        OMets = regexprep(OMets,'\[n\]','');
        OMets = regexprep(OMets,'\[l\]','');
        TableMets_male(:,i+1)=num2cell(0);
        TableMets_maleO{1,i+1}=Omale{i};
        TableMets_male(find(ismember(Mets,OMets)),i+1)=num2cell(1);
        TableMetsNum_male(find(ismember(Mets,OMets)),i)=1;
    end
end
TableMets_male_unique = [TableMets_maleO;TableMets_male];


Mets = [];
% get set of unique metablites
for i = 1 : length(Omale)
    if ~strcmp('sex',Omale{i}) && ~strcmp('gender',Omale{i}) && ~strcmp('Recon3DHarvey',Omale{i})
        % grab reactions
        OMets = OrganCompendium_male.(Omale{i}).modelAllComp.mets;
        OMets = regexprep(OMets,'\[b\w\w\]','\[e\]');
        OMets = regexprep(OMets,'\[b\w\]','\[e\]');
        OMets = regexprep(OMets,'\[u\]','\[e\]');
        OMets = regexprep(OMets,'\[u\]','\[e\]');
        OMets = regexprep(OMets,'\[lu\]','\[e\]');
        OMets = regexprep(OMets,'\[lu\w+\]','\[e\]');
        OMets = regexprep(OMets,'\[csf\]','\[e\]');
        OMets = regexprep(OMets,'\[s\w+\]','\[e\]');
        OMets = regexprep(OMets,'\[fe\]','\[e\]');
        OMets = regexprep(OMets,'\[a\]','\[e\]');
        Mets = [Mets;OMets];
    end
end
Mets = unique(Mets);

clear TableMets_male
TableMets_male(1:length(Mets),1) = (Mets);
for i = 1 : length(Omale)
    if ~strcmp('sex',Omale{i}) && ~strcmp('gender',Omale{i}) && ~strcmp('Recon3DHarvey',Omale{i})
        % grab reactions
        OMets = OrganCompendium_male.(Omale{i}).modelAllComp.mets;
        OMets = regexprep(OMets,'\[b\w\w\]','\[e\]');
        OMets = regexprep(OMets,'\[b\w\]','\[e\]');
        OMets = regexprep(OMets,'\[u\]','\[e\]');
        OMets = regexprep(OMets,'\[u\]','\[e\]');
        OMets = regexprep(OMets,'\[lu\]','\[e\]');
        OMets = regexprep(OMets,'\[lu\w+\]','\[e\]');
        OMets = regexprep(OMets,'\[csf\]','\[e\]');
        OMets = regexprep(OMets,'\[s\w+\]','\[e\]');
        OMets = regexprep(OMets,'\[fe\]','\[e\]');
        OMets = regexprep(OMets,'\[a\]','\[e\]');
        TableMets_male(:,i+1)=num2cell(0);
        TableMets_maleO{1,i+1}=Omale{i};
        TableMets_male(find(ismember(Mets,OMets)),i+1)=num2cell(1);
        TableMetsNum_male(find(ismember(Mets,OMets)),i)=1;
    end
end
TableMets_male = [TableMets_maleO;TableMets_male];
% correlation
TableMetsNum_maleCorr = corrcoef(TableMetsNum_male);

% shared metabolites
TableMets_maleNumInOrgans = TableMetsNum_male*TableMetsNum_male';
MetsInOrgans_male = diag(TableMets_maleNumInOrgans);
HousekeepingMets_male = Mets(find(MetsInOrgans_male>=length(Omale)-2));%2 entries of Omale are no organs
OrganSpecMets_male = Mets(find(MetsInOrgans_male==1));%at most in 2 organs
NoOrgaMets_male = Mets(find(MetsInOrgans_male==0));%at most in 2 organs
OtherOrganMets_male = Mets(find(MetsInOrgans_male>1 & MetsInOrgans_male<length(Omale)-2));%at most in 2 organs
sumMets = length(NoOrgaMets_male)+length(OtherOrganMets_male)+length(OrganSpecMets_male)+length(HousekeepingMets_male);
s = {' '};
TableGRM{1,3} = 'Metabolites';
TableGRM{2,1} = 'core';
TableGRM{2,3} = strcat(num2str(length(HousekeepingMets_male)),s,'(',num2str(round(length(HousekeepingMets_male)*100/sumMets,1)),'%)');
TableGRM{3,1} = 'organ-specific';
TableGRM{3,3} = strcat(num2str(length(OrganSpecMets_male)),s,'(',num2str(round(length(OrganSpecMets_male)*100/sumMets,1)),'%)');
TableGRM{4,1} = 'others';
TableGRM{4,3} = strcat(num2str(length(OtherOrganMets_male)),s,'(',num2str(round(length(OtherOrganMets_male)*100/sumMets,1)),'%)');
TableGRM{5,1} = 'absent';
TableGRM{5,3} = strcat(num2str(length(NoOrgaMets_male)),s,'(',num2str(round(length(NoOrgaMets_male)*100/sumMets,1)),'%)');
TableGRM{6,1} = 'sum';
TableGRM{6,3} = num2str(sumMets);

% get number of organ specific and core rxns per organ

for i = 1 : length(Omale)
    if ~strcmp('sex',Omale{i}) && ~strcmp('gender',Omale{i}) && ~strcmp('Recon3DHarvey',Omale{i})
        % grab reactions
        OMets = OrganCompendium_male.(Omale{i}).modelAllComp.mets;
        HouseCoreOMets_male(i,1) = length(intersect(HousekeepingMets_male ,OMets))*100/length(OMets);
        HouseCoreOMets_male(i,2) = length(intersect(OrganSpecMets_male ,OMets))*100/length(OMets);
        CoreOrganMets_male(i,1) = length(intersect(OrganSpecMets_male ,ORxns));
        
    end
end

if 0
    figure
    bar([HouseCoreOMets_male(:,1) HouseCoreOMets_male(:,2)],'stacked');
end

clear TableGenes_male TableGenes_maleNum
%[Genes,rem]=strtok(Recon3DHarvey.genes,'.');

Genes = [];
% get set of unique reactions
for i = 1 : length(Omale)
    if ~strcmp('sex',Omale{i}) && ~strcmp('gender',Omale{i}) && ~strcmp('Recon3DHarvey',Omale{i})
        % grab reactions
        OGenes = OrganCompendium_male.(Omale{i}).modelAllComp.genes;
        Genes = [Genes;OGenes];
    end
end
%[Genes,rem]=strtok(Genes,'.');
Genes = unique(Genes);

Genes = unique(Genes);
TableGenes_male(1:length(Genes),1) = (Genes);
for i = 1 : length(Omale)
    if ~strcmp('sex',Omale{i}) && ~strcmp('gender',Omale{i}) && ~strcmp('Recon3DHarvey',Omale{i})
        % grab reactions
      %  [OGenes,rem]=strtok(OrganCompendium_male.(Omale{i}).modelAllComp.genes,'.');
     %   OGenes = unique(OGenes);
        OGenes = OrganCompendium_male.(Omale{i}).modelAllComp.genes;
        TableGenes_male(:,i+1)=num2cell(0);
        TableGenes_male(find(ismember(Genes,OGenes)),i+1)=num2cell(1);
        TableGenes_maleNum(find(ismember(Genes,OGenes)),i)=1;
        Organs{1,i+1} = Omale{i};
    end
end
TableGenes_male = [Organs;TableGenes_male];

% correlation
TableGenes_maleNumCorr = corrcoef(TableGenes_maleNum);
% get stats

% shared genes
TableGenes_maleNumInOrgans = TableGenes_maleNum*TableGenes_maleNum';
GenesInOrgans_male = diag(TableGenes_maleNumInOrgans);
HousekeepingGenes_male = Genes(find(GenesInOrgans_male>=length(Omale)-2));%2 entries of Omale are no organs
OrganSpecGenes_male = Genes(find(GenesInOrgans_male==1));%at most in 2 organs
NoOrganGenes_male = Genes(find(GenesInOrgans_male==0));%at most in 2 organs
OtherOrganGenes_male = Genes(find(GenesInOrgans_male>1 & GenesInOrgans_male<length(Omale)-2));%at most in 2 organs
sumGenes = length(NoOrganGenes_male)+length(OtherOrganGenes_male)+length(OrganSpecGenes_male)+length(HousekeepingGenes_male);
s = {' '};
TableGRM{1,2} = 'Genes';
TableGRM{2,1} = 'core';
TableGRM{2,2} = strcat(num2str(length(HousekeepingGenes_male)),s,'(',num2str(round(length(HousekeepingGenes_male)*100/sumGenes,1)),'%)');
TableGRM{3,1} = 'organ-specific';
TableGRM{3,2} = strcat(num2str(length(OrganSpecGenes_male)),s,'(',num2str(round(length(OrganSpecGenes_male)*100/sumGenes,1)),'%)');
TableGRM{4,1} = 'others';
TableGRM{4,2} = strcat(num2str(length(OtherOrganGenes_male)),s,'(',num2str(round(length(OtherOrganGenes_male)*100/sumGenes,1)),'%)');
TableGRM{5,1} = 'absent';
TableGRM{5,2} = strcat(num2str(length(NoOrganGenes_male)),s,'(',num2str(round(length(NoOrganGenes_male)*100/sumGenes,1)),'%)');
TableGRM{6,1} = 'sum';
TableGRM{6,2} = num2str(sumGenes);


if 0
    figure
    imagesc(TableRxnsNumCorr_male)
    figure
    imagesc(TableRxnsNum_male)
    figure
    imagesc(TableMetsNum_maleCorr)
    figure
    imagesc(TableMetsNum_male)
    figure
    imagesc(TableGenes_maleNumCorr)
    figure
    imagesc(TableGenes_maleNum)
end

% get stats table
clear TableAverage_male
c = 1;
TableAverage_male{c,1} = {'Average number of reactions'};
Sum = sum(TableRxnsNum_male);
SumR_male = Sum;
TableAverage_male{c,2} = num2str(mean(Sum));c= c+1;
TableAverage_male{c,1} = {'Std number of reactions'};
TableAverage_male{c,2} = num2str(std(Sum));c= c+1;
TableAverage_male{c,1} = {'Min number of reactions'};
TableAverage_male{c,2} = num2str(min(Sum));c= c+1;
TableAverage_male{c,1} = {'Max number of reactions'};
TableAverage_male{c,2} = num2str(max(Sum));c= c+1;

TableAverage_male{c,1} = {'Average number of metabolites'};
Sum = sum(TableMetsNum_male);
SumM_male = Sum;
TableAverage_male{c,2} = num2str(mean(Sum));c= c+1;
TableAverage_male{c,1} = {'Std number of metabolites'};
TableAverage_male{c,2} = num2str(std(Sum));c= c+1;
TableAverage_male{c,1} = {'Min number of metabolites'};
TableAverage_male{c,2} = num2str(min(Sum));c= c+1;
TableAverage_male{c,1} = {'Max number of metabolites'};
TableAverage_male{c,2} = num2str(max(Sum));c= c+1;

TableAverage_male{c,1} = {'Average number of genes'};
Sum = sum(TableGenes_maleNum);
SumG_male = Sum;
TableAverage_male{c,2} = num2str(mean(Sum));c= c+1;
TableAverage_male{c,1} = {'Std number of genes'};
TableAverage_male{c,2} = num2str(std(Sum));c= c+1;
TableAverage_male{c,1} = {'Min number of genes'};
TableAverage_male{c,2} = num2str(min(Sum));c= c+1;
TableAverage_male{c,1} = {'Max number of genes'};
TableAverage_male{c,2} = num2str(max(Sum));c= c+1;


% does not work on 2013
if violinPlots == 1
    figure;
    vs = violinplot([SumR_male' SumM_male' SumG_male'], {'Reactions';'Metabolites';'Genes (unique)'});
end

%% female

Ofemale = fieldnames(OrganCompendium_female);

clear TableProp_female
for i = 1 : length(Ofemale)
    if ~strcmp('sex',Ofemale{i}) && ~strcmp('gender',Ofemale{i}) && ~strcmp('Recon3DHarvey',Ofemale{i})
        cm =2;
        TableProp_female{i+1,1} = Ofemale{i};
        
        TableProp_female{1,cm} = {'Reactions'};
        TableProp_female{i+1,cm} = num2str(length(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns)); cm = cm + 1;
        
        TableProp_female{1,cm} = {'Reactions (without exchange/transport reactions)'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'EX_')));
        DM =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'DM_')));
        Sink =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'sink_')));
        EX = [EX;DM;Sink];
        NoEx = length(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns)-length(EX);
        TableProp_female{i+1,cm} = num2str(NoEx); cm = cm + 1;
        
        TableProp_female{1,cm} = {'Percentage of all Recon Reactions (without exchange/transport reactions)'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'EX_')));
        DM =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'DM_')));
        Sink =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'sink_')));
        EX = [EX;DM;Sink];
        NoEx = length(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns)-length(EX);
        Rxns = length(Recon3DHarvey.rxns);
        TableProp_female{i+1,cm} = num2str(NoEx*100/Rxns); cm = cm + 1;
        
        TableProp_female{1,cm} = {'Metabolites'};
        TableProp_female{i+1,cm} = num2str(length(OrganCompendium_female.(Ofemale{i}).modelAllComp.mets)); cm = cm + 1;
        
        TableProp_female{1,cm} = {'Percentage of all Recon Metabolites'};
        TableProp_female{i+1,cm} = num2str(length(OrganCompendium_female.(Ofemale{i}).modelAllComp.mets)*100/length(Recon3DHarvey.mets)); cm = cm + 1;
        
        TableProp_female{1,cm} = {'Metabolites (unique)'};
        [g,remR3M]=strtok(OrganCompendium_female.(Ofemale{i}).modelAllComp.mets,'[');
        TableProp_female{i+1,cm} = num2str(length(unique(g))); cm = cm + 1;
        
        TableProp_female{1,cm} = {'Percentage of all Metabolites (unique)'};
        [g,remR3M]=strtok(OrganCompendium_female.(Ofemale{i}).modelAllComp.mets,'[');
        [Mets]=strtok(female.mets,'[');
        TableProp_female{i+1,cm} = num2str(length(unique(g))*100/length(unique(Mets))); cm = cm + 1;
        
        % number of compartments
        TableProp_female{1,cm} = {'Compartments (unique)'};
        TableProp_female{i+1,cm} = num2str(length(unique(remR3M))); cm = cm + 1;
        
        % list of compartments
        TableProp_female{1,cm} = {'Compartment List (unique)'};
        C = unique(remR3M);
        for j= 1 : length(C)
            s= ' ';
            TableProp_female{i+1,cm} = strcat(TableProp_female{i+1,cm},',',s,C{j});
        end
        cm = cm + 1;
        
        %number of exchanges with [bc]
        TableProp_female{1,cm} = {'Number of exchanges with [bc]'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'[bc]')));
        BCK =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'[bcK]')));
        BC = intersect(EX,BC);
        BC = setdiff(BC,BCK);
        TableProp_female{i+1,cm} = num2str(length(BC)); cm = cm + 1;
        
        %percentage of all exchanges with [bc]
        TableProp_female{1,cm} = {'Percentage of all exchanges with [bc]'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'[bc]')));
        BCK =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'[bcK]')));
        BC = intersect(EX,BC);
        BC = setdiff(BC,BCK);
        TableProp_female{i+1,cm} = num2str(length(BC)*100/length(BC_mets_female)); cm = cm + 1;
        
        %number of exchanges with [bp]
        TableProp_female{1,cm} = {'Number of exchanges with [bp]'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'[bp')));
        BC = intersect(EX,BC);
        TableProp_female{i+1,cm} = num2str(length(BC)); cm = cm + 1;
        
        %percentage of all exchanges with [bp]
        TableProp_female{1,cm} = {'Percentage of all exchanges with [bp]'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'[bp')));
        BC = intersect(EX,BC);
        TableProp_female{i+1,cm} = num2str(length(BC)*100/length(BP_mets_female)); cm = cm + 1;
        
        %number of exchanges with [bd]
        TableProp_female{1,cm} = {'Number of exchanges with [bd]'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'[bd')));
        BC = intersect(EX,BC);
        TableProp_female{i+1,cm} = num2str(length(BC)); cm = cm + 1;
        
        
        %percentage of all exchanges with [bd]
        TableProp_female{1,cm} = {'Percentage of all exchanges with [bd]'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'[bd')));
        BC = intersect(EX,BC);
        TableProp_female{i+1,cm} = num2str(length(BC)*100/length(BD_mets_female)); cm = cm + 1;
        
        %number of exchanges with [lu]
        TableProp_female{1,cm} = {'Number of exchanges with [lu]'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'[lu')));
        BC = intersect(EX,BC);
        TableProp_female{i+1,cm} = num2str(length(BC)); cm = cm + 1;
        
        
        %number of exchanges with [csf]
        TableProp_female{1,cm} = {'Number of exchanges with [csf]'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'[csf')));
        BC = intersect(EX,BC);
        TableProp_female{i+1,cm} = num2str(length(BC)); cm = cm + 1;
        
        %percentage of all exchanges with [csf]
        TableProp_female{1,cm} = {'Percentage of all exchanges with [csf]'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'[csf')));
        BC = intersect(EX,BC);
        TableProp_female{i+1,cm} = num2str(length(BC)*100/length(CSF_mets_female)); cm = cm + 1;
        
        %number of exchanges with [sw]
        TableProp_female{1,cm} = {'Number of exchanges with [sw]'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'[sw')));
        BC = intersect(EX,BC);
        TableProp_female{i+1,cm} = num2str(length(BC)); cm = cm + 1;
        
        %number of exchanges with [a]
        TableProp_female{1,cm} = {'Number of exchanges with [a]'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'[a')));
        BC = intersect(EX,BC);
        TableProp_female{i+1,cm} = num2str(length(BC)); cm = cm + 1;
        
        %number of exchanges with [u]
        TableProp_female{1,cm} = {'Number of exchanges with [u]'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'[u]')));
        BC = intersect(EX,BC);
        TableProp_female{i+1,cm} = num2str(length(BC)); cm = cm + 1;
        
        %percentage of all exchanges with [u]
        TableProp_female{1,cm} = {'Percentage of all exchanges with [u]'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'[u]')));
        BC = intersect(EX,BC);
        TableProp_female{i+1,cm} = num2str(length(BC)*100/length(U_mets_female)); cm = cm + 1;
        
        %[bc] overlap with microbiota metabolites
        TableProp_female{1,cm} = {'Percentage of overlap of [bc] with microbiota metabolites'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'[bc')));
        BC = intersect(EX,BC);
        BCM = OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns(BC);
        BCM = regexprep(BCM,'Tr_EX_','');
        BCM = regexprep(BCM,'\(e.+','');
        BCM_MY = intersect(BCM,MyU_rxns);
        if ~isempty(BC)
            TableProp_female{i+1,cm} = num2str(length(BCM_MY)*100/length(BC)); cm = cm + 1;
        else
            TableProp_female{i+1,cm} = 'NA'; cm = cm + 1;
        end
        
        %[bp] overlap with microbiota metabolites
        TableProp_female{1,cm} = {'Percentage of overlap of [bp] with microbiota metabolites'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'[bp')));
        BC = intersect(EX,BC);
        BCM = OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns(BC);
        BCM = regexprep(BCM,'Tr_EX_','');
        BCM = regexprep(BCM,'\[bp.+','');
        BCM_MY = intersect(BCM,MyU_rxns);
        if ~isempty(BC)
            TableProp_female{i+1,cm} = num2str(length(BCM_MY)*100/length(BC)); cm = cm + 1;
        else
            TableProp_female{i+1,cm} = 'NA'; cm = cm + 1;
        end
        
        %[bd] overlap with microbiota metabolites
        TableProp_female{1,cm} = {'Percentage of overlap of [bd] with microbiota metabolites'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'[bd')));
        BC = intersect(EX,BC);
        BCM = OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns(BC);
        BCM = regexprep(BCM,'Tr_EX_','');
        BCM = regexprep(BCM,'\[bd.+','');
        BCM_MY = intersect(BCM,MyU_rxns);
        if ~isempty(BC)
            TableProp_female{i+1,cm} = num2str(length(BCM_MY)*100/length(BC)); cm = cm + 1;
        else
            TableProp_female{i+1,cm} = 'NA'; cm = cm + 1;
        end
        
        %[csf] overlap with microbiota metabolites
        TableProp_female{1,cm} = {'Percentage of overlap of [csf] with microbiota metabolites'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'[csf')));
        BC = intersect(EX,BC);
        BCM = OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns(BC);
        BCM = regexprep(BCM,'Tr_EX_','');
        BCM = regexprep(BCM,'\(e.+','');
        BCM_MY = intersect(BCM,MyU_rxns);
        if ~isempty(BC)
            TableProp_female{i+1,cm} = num2str(length(BCM_MY)*100/length(BC)); cm = cm + 1;
        else
            TableProp_female{i+1,cm} = 'NA'; cm = cm + 1;
        end
        
        %[u] overlap with microbiota metabolites
        TableProp_female{1,cm} = {'Percentage of overlap of [u] with microbiota metabolites'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'[u')));
        BC = intersect(EX,BC);
        BCM = OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns(BC);
        BCM = regexprep(BCM,'Tr_EX_','');
        BCM = regexprep(BCM,'\(e.+','');
        BCM_MY = intersect(BCM,MyU_rxns);
        if ~isempty(BC)
            TableProp_female{i+1,cm} = num2str(length(BCM_MY)*100/length(BC)); cm = cm + 1;
        else
            TableProp_female{i+1,cm} = 'NA'; cm = cm + 1;
        end
        
        %[u] overlap with microbiota metabolites
        TableProp_female{1,cm} = {'Percentage of overlap of [u] with microbiota metabolites'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'[u')));
        BC = intersect(EX,BC);
        BCM = OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns(BC);
        BCM = regexprep(BCM,'Tr_EX_','');
        BCM = regexprep(BCM,'\(e.+','');
        BCM_MY = intersect(BCM,MyU_rxns);
        if ~isempty(BC)
            TableProp_female{i+1,cm} = num2str(length(BCM_MY)*100/length(BC)); cm = cm + 1;
        else
            TableProp_female{i+1,cm} = 'NA'; cm = cm + 1;
        end
        
        %[lu] overlap with microbiota metabolites
        TableProp_female{1,cm} = {'Percentage of overlap of [lu] with microbiota metabolites'};
        EX =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'_EX_')));
        BC =find(~cellfun(@isempty,strfind(OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns,'[lu')));
        BC = intersect(EX,BC);
        BCM = OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns(BC);
        BCM = regexprep(BCM,'Tr_EX_','');
        BCM = regexprep(BCM,'\[lu.+','');
        BCM_MY = intersect(BCM,MyU_rxns);
        if ~isempty(BC)
            TableProp_female{i+1,cm} = num2str(length(BCM_MY)*100/length(BC)); cm = cm + 1;
        else
            TableProp_female{i+1,cm} = 'NA'; cm = cm + 1;
        end
        
        TableProp_female{1,cm} = {'Transcripts'};
        TableProp_female{i+1,cm} = num2str(length(OrganCompendium_female.(Ofemale{i}).modelAllComp.genes)); cm = cm + 1;
        
        TableProp_female{1,cm} = {'Genes (unique)'};
        [g,rem]=strtok(OrganCompendium_female.(Ofemale{i}).modelAllComp.genes,'.');
        TableProp_female{i+1,cm} = num2str(length(unique(g))); cm = cm + 1;
        
        TableProp_female{1,cm} = {'Number Genes Associated Reactions'};
        str = length(find(~cellfun(@isempty,OrganCompendium_female.(Ofemale{i}).modelAllComp.grRules)));
        TableProp_female{i+1,cm} = num2str(str); cm = cm + 1;
        
        TableProp_female{1,cm} = {'Percentage Genes Associated Reactions (Exchange Rxns excl)'};
        str = length(find(~cellfun(@isempty,OrganCompendium_female.(Ofemale{i}).modelAllComp.grRules)));
        TableProp_female{i+1,cm} = num2str(str*100/NoEx); cm = cm + 1;
        PercGeneAssRxns_female(i,1) = str*100/NoEx;
        
%         TableProp_female{1,cm} = {'Subsystems'};
%         if isempty(OrganCompendium_female.(Ofemale{i}).modelAllComp.subSystems{1})
%             TableProp_female{i+1,cm}=NaN;
%         else
%             TableProp_female{i+1,cm} = num2str(length(unique(OrganCompendium_female.(Ofemale{i}).modelAllComp.subSystems))); cm = cm + 1;
%         end
        
        TableProp_female{1,cm} = {'Size of S'};
        TableProp_female{i+1,cm} = strcat(num2str(size(OrganCompendium_female.(Ofemale{i}).modelAllComp.S,1)),'; ',num2str(size(OrganCompendium_female.(Ofemale{i}).modelAllComp.S,2))); cm = cm + 1;
        
        % rank of S
        TableProp_female{1,cm} = {'Rank of S'};
        %     TableProp_female{i+1,cm} = strcat(num2str(rank(full(OrganCompendium_female.(Ofemale{i}).modelAllComp.S)))); cm = cm + 1;
        
    end
end
TableProp_female=TableProp_female';


%% compare reaction content
clear TableRxns TableRxnsNum
%Rxns = Recon3DHarvey.rxns;

Rxns = [];
% get set of unique reactions
for i = 1 : length(Ofemale)
    if ~strcmp('sex',Ofemale{i}) && ~strcmp('gender',Ofemale{i}) && ~strcmp('Recon3DHarvey',Ofemale{i})
        % grab reactions
        ORxns = OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns;
        ORxns = regexprep(ORxns,'Tr_','');
        ORxns = regexprep(ORxns,'_\[\w+\]','');
        ORxns = regexprep(ORxns,'\[\w\w\w\]','');
        ORxns = regexprep(ORxns,'\[\w\w\]','');
        ORxns = regexprep(ORxns,'\(','\[');
        ORxns = regexprep(ORxns,'\)','\]');
        ORxns = regexprep(ORxns,'_c_','\[c\]');
        ORxns = regexprep(ORxns,'_g_','\[g\]');
        ORxns = regexprep(ORxns,'_n_','\[n\]');
        ORxns = regexprep(ORxns,'_m_','\[m\]');
        ORxns = regexprep(ORxns,'_r_','\[r\]');
        ORxns = regexprep(ORxns,'_x_','\[x\]');
        ORxns = regexprep(ORxns,'\[u\]','');
        ORxns = regexprep(ORxns,'\[e\]','');
        ORxns = regexprep(ORxns,'\[mi\w\]','');
        ORxns = regexprep(ORxns,'\[sw\w\]','');
        ORxns = regexprep(ORxns,'\[lu\w\w\]','');
        Rxns = [Rxns;ORxns];
    end
end
Rxns = unique(Rxns);

TableRxns_female(1:length(Rxns),1) = (Rxns);
for i = 1 : length(Ofemale)
    if ~strcmp('sex',Ofemale{i}) && ~strcmp('gender',Ofemale{i}) && ~strcmp('Recon3DHarvey',Ofemale{i})
        % grab reactions
        ORxns = OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns;
        ORxns = regexprep(ORxns,'Tr_','');
        ORxns = regexprep(ORxns,'_\[\w+\]','');
        ORxns = regexprep(ORxns,'\[\w\w\w\]','');
        ORxns = regexprep(ORxns,'\[\w\w\]','');
        ORxns = regexprep(ORxns,'\(','\[');
        ORxns = regexprep(ORxns,'\)','\]');
        ORxns = regexprep(ORxns,'_c_','\[c\]');
        ORxns = regexprep(ORxns,'_g_','\[g\]');
        ORxns = regexprep(ORxns,'_n_','\[n\]');
        ORxns = regexprep(ORxns,'_m_','\[m\]');
        ORxns = regexprep(ORxns,'_r_','\[r\]');
        ORxns = regexprep(ORxns,'_x_','\[x\]');
        ORxns = regexprep(ORxns,'\[u\]','');
        ORxns = regexprep(ORxns,'\[e\]','');
        ORxns = regexprep(ORxns,'\[mi\w\]','');
        ORxns = regexprep(ORxns,'\[sw\w\]','');
        ORxns = regexprep(ORxns,'\[lu\w\w\]','');
        ORxns = regexprep(ORxns,'_DIFF\[c\]','_DIFF');
        TableRxns_female(:,i+1)=num2cell(0);
        TableRxns_femaleO{1,i+1} = Ofemale{i};
        TableRxns_female(find(ismember(Rxns,ORxns)),i+1)=num2cell(1);
        TableRxnsNum_female(find(ismember(Rxns,ORxns)),i)=1;
    end
end
TableRxns_female = [TableRxns_femaleO;TableRxns_female];
% correlation
TableRxnsNumCorr_female = corrcoef(TableRxnsNum_female);

% shared reactions
TableRxns_femaleNumInOrgans = TableRxnsNum_female*TableRxnsNum_female';
RxnsInOrgans_female = diag(TableRxns_femaleNumInOrgans);
HousekeepingRxns_female = Rxns(find(RxnsInOrgans_female>=length(Ofemale)-2));%2 entries of Ofemale are no organs
OrganSpecRxns_female = Rxns(find(RxnsInOrgans_female==1));%at most in 2 organs
NoOrgaRxns_female = Rxns(find(RxnsInOrgans_female==0));%at most in 2 organs
OtherOrganRxns_female = Rxns(find(RxnsInOrgans_female>1 & RxnsInOrgans_female<length(Ofemale)-2));%at most in 2 organs
s = {' '};
sumRxns = length(NoOrgaRxns_female)+length(OtherOrganRxns_female)+length(OrganSpecRxns_female)+length(HousekeepingRxns_female);
TableGRM{1,5} = 'Female';
TableGRM{1,8} = 'Reactions';
TableGRM{2,5} = 'core';
TableGRM{2,8} = strcat(num2str(length(HousekeepingRxns_female)),s,'(',num2str(round(length(HousekeepingRxns_female)*100/sumRxns,1)),'%)');
TableGRM{3,5} = 'organ-specific';
TableGRM{3,8} = strcat(num2str(length(OrganSpecRxns_female)),s,'(',num2str(round(length(OrganSpecRxns_female)*100/sumRxns,1)),'%)');
TableGRM{4,5} = 'others';
TableGRM{4,8} = strcat(num2str(length(OtherOrganRxns_female)),s,'(',num2str(round(length(OtherOrganRxns_female)*100/sumRxns,1)),'%)');
TableGRM{5,5} = 'absent';
TableGRM{5,8} = strcat(num2str(length(NoOrgaRxns_female)),s,'(',num2str(round(length(NoOrgaRxns_female)*100/sumRxns,1)),'%)');
TableGRM{6,5} = 'sum';
TableGRM{6,8} = num2str(sumRxns);


for i = 1 : length(Ofemale)
    if ~strcmp('sex',Ofemale{i}) && ~strcmp('gender',Ofemale{i}) && ~strcmp('Recon3DHarvey',Ofemale{i})
        % grab reactions
        ORxns = OrganCompendium_female.(Ofemale{i}).modelAllComp.rxns;
        HouseCoreORxns_female(i,1) = length(intersect(HousekeepingRxns_female ,ORxns))*100/length(ORxns);
        HouseCoreORxns_female(i,2) = length(intersect(OrganSpecRxns_female ,ORxns))*100/length(ORxns);
        CoreOrganRxns_female(i,1) = length(intersect(OrganSpecRxns_female ,ORxns));
    end
end


if 0
    % Create figure
    figure1 = figure;
    
    % Create axes
    axes1 = axes('Parent',figure1);
    hold(axes1,'on');
    % Create multiple lines using matrix input to bar
    %bar1 = bar(ymatrix1,'BarLayout','stacked','Parent',axes1);
    bar1 = bar(-1*[[HouseCoreORxns_female(1:24,1);0;0;HouseCoreORxns_female(25:end,1)] [HouseCoreORxns_female(1:24,2);0;0;HouseCoreORxns_female(25:end,2)]],'stacked','Parent',axes1);
    hold on
    bar2 =   bar(1*[[HouseCoreORxns_male(1:20,1);0;0;0;0;HouseCoreORxns_male(21:end,1)] [HouseCoreORxns_male(1:20,2);0;0;0;0;HouseCoreORxns_male(21:end,2)]],'stacked','Parent',axes1);
    
    set(bar2(2),'FaceColor',[0 0.447058826684952 0.74117648601532]);
    set(bar2(1),'FaceColor',[0.678431391716003 0.921568632125854 1]);
    set(bar1(2),'FaceColor',[1 0.600000023841858 0.7843137383461]);
    set(bar1(1),'FaceColor',[1 0.843137264251709 0]);
    
    box(axes1,'on');
    % Set the remaining axes properties
    set(axes1,'FontSize',16,'XAxisLocation','top','XDir','reverse','XTick',[1:32],'XTickLabel',...
        [Omale(1:20);Ofemale(21:24);Omale(21:end)],'XTickLabelRotation',270);
    
end

clear TableMets_female TableMetsNum_female
%Mets = Recon3DHarvey.mets;
Mets = [];
% get set of unique reactions
for i = 1 : length(Ofemale)
    if ~strcmp('sex',Ofemale{i}) && ~strcmp('gender',Ofemale{i}) && ~strcmp('Recon3DHarvey',Ofemale{i})
        % grab reactions
        OMets = OrganCompendium_female.(Ofemale{i}).modelAllComp.mets;
        OMets = regexprep(OMets,'\[b\w\w\]','\[e\]');
        OMets = regexprep(OMets,'\[b\w\]','\[e\]');
        OMets = regexprep(OMets,'\[u\]','\[e\]');
        OMets = regexprep(OMets,'\[u\]','\[e\]');
        OMets = regexprep(OMets,'\[lu\]','\[e\]');
        OMets = regexprep(OMets,'\[lu\w+\]','\[e\]');
        OMets = regexprep(OMets,'\[csf\]','\[e\]');
        OMets = regexprep(OMets,'\[s\w+\]','\[e\]');
        OMets = regexprep(OMets,'\[fe\]','\[e\]');
        OMets = regexprep(OMets,'\[mi\w]','\[e\]');
        OMets = regexprep(OMets,'\[mi]','\[e\]');
        OMets = regexprep(OMets,'\[a\]','\[e\]');
        OMets = regexprep(OMets,'\[e\]','');
        OMets = regexprep(OMets,'\[c\]','');
        OMets = regexprep(OMets,'\[m\]','');
        OMets = regexprep(OMets,'\[r\]','');
        OMets = regexprep(OMets,'\[g\]','');
        OMets = regexprep(OMets,'\[x\]','');
        OMets = regexprep(OMets,'\[n\]','');
        OMets = regexprep(OMets,'\[l\]','');
        Mets = [Mets;OMets];
    end
end
Mets = unique(Mets);

TableMets_female(1:length(Mets),1) = (Mets);
for i = 1 : length(Ofemale)
    if ~strcmp('sex',Ofemale{i}) && ~strcmp('gender',Ofemale{i}) && ~strcmp('Recon3DHarvey',Ofemale{i})
        % grab reactions
        OMets = OrganCompendium_female.(Ofemale{i}).modelAllComp.mets;
        OMets = regexprep(OMets,'\[b\w\w\]','\[e\]');
        OMets = regexprep(OMets,'\[b\w\]','\[e\]');
        OMets = regexprep(OMets,'\[u\]','\[e\]');
        OMets = regexprep(OMets,'\[u\]','\[e\]');
        OMets = regexprep(OMets,'\[lu\]','\[e\]');
        OMets = regexprep(OMets,'\[lu\w+\]','\[e\]');
        OMets = regexprep(OMets,'\[csf\]','\[e\]');
        OMets = regexprep(OMets,'\[s\w+\]','\[e\]');
        OMets = regexprep(OMets,'\[fe\]','\[e\]');
        OMets = regexprep(OMets,'\[mi\w]','\[e\]');
        OMets = regexprep(OMets,'\[mi]','\[e\]');
        OMets = regexprep(OMets,'\[a\]','\[e\]');
        OMets = regexprep(OMets,'\[e\]','');
        OMets = regexprep(OMets,'\[c\]','');
        OMets = regexprep(OMets,'\[m\]','');
        OMets = regexprep(OMets,'\[r\]','');
        OMets = regexprep(OMets,'\[g\]','');
        OMets = regexprep(OMets,'\[x\]','');
        OMets = regexprep(OMets,'\[n\]','');
        OMets = regexprep(OMets,'\[l\]','');
        TableMets_female(:,i+1)=num2cell(0);
        TableMets_female(find(ismember(Mets,OMets)),i+1)=num2cell(1);
        TableMets_femaleO{1,i+1}=Ofemale{i};
        TableMetsNum_female(find(ismember(Mets,OMets)),i)=1;
    end
end
TableMets_female_unique = [TableMets_femaleO;TableMets_female];



Mets = [];
% get set of unique reactions
for i = 1 : length(Ofemale)
    if ~strcmp('sex',Ofemale{i}) && ~strcmp('gender',Ofemale{i}) && ~strcmp('Recon3DHarvey',Ofemale{i})
        % grab reactions
        OMets = OrganCompendium_female.(Ofemale{i}).modelAllComp.mets;
        OMets = regexprep(OMets,'\[b\w\w\]','\[e\]');
        OMets = regexprep(OMets,'\[b\w\]','\[e\]');
        OMets = regexprep(OMets,'\[u\]','\[e\]');
        OMets = regexprep(OMets,'\[u\]','\[e\]');
        OMets = regexprep(OMets,'\[lu\]','\[e\]');
        OMets = regexprep(OMets,'\[lu\w+\]','\[e\]');
        OMets = regexprep(OMets,'\[csf\]','\[e\]');
        OMets = regexprep(OMets,'\[s\w+\]','\[e\]');
        OMets = regexprep(OMets,'\[fe\]','\[e\]');
        OMets = regexprep(OMets,'\[mi\w]','\[e\]');
        OMets = regexprep(OMets,'\[mi]','\[e\]');
        OMets = regexprep(OMets,'\[a\]','\[e\]');
        Mets = [Mets;OMets];
    end
end
Mets = unique(Mets);

TableMets_female(1:length(Mets),1) = (Mets);
for i = 1 : length(Ofemale)
    if ~strcmp('sex',Ofemale{i}) && ~strcmp('gender',Ofemale{i}) && ~strcmp('Recon3DHarvey',Ofemale{i})
        % grab reactions
        OMets = OrganCompendium_female.(Ofemale{i}).modelAllComp.mets;
        OMets = regexprep(OMets,'\[b\w\w\]','\[e\]');
        OMets = regexprep(OMets,'\[b\w\]','\[e\]');
        OMets = regexprep(OMets,'\[u\]','\[e\]');
        OMets = regexprep(OMets,'\[u\]','\[e\]');
        OMets = regexprep(OMets,'\[lu\]','\[e\]');
        OMets = regexprep(OMets,'\[lu\w+\]','\[e\]');
        OMets = regexprep(OMets,'\[csf\]','\[e\]');
        OMets = regexprep(OMets,'\[s\w+\]','\[e\]');
        OMets = regexprep(OMets,'\[fe\]','\[e\]');
        OMets = regexprep(OMets,'\[mi\w]','\[e\]');
        OMets = regexprep(OMets,'\[mi]','\[e\]');
        OMets = regexprep(OMets,'\[a\]','\[e\]');
        TableMets_female(:,i+1)=num2cell(0);
        TableMets_female(find(ismember(Mets,OMets)),i+1)=num2cell(1);
        TableMets_femaleO{1,i+1}=Ofemale{i};
        TableMetsNum_female(find(ismember(Mets,OMets)),i)=1;
    end
end
TableMets_female = [TableMets_femaleO;TableMets_female];

% correlation
TableMetsNum_femaleCorr = corrcoef(TableMetsNum_female);

% shared metabolites
TableMets_femaleNumInOrgans = TableMetsNum_female*TableMetsNum_female';
MetsInOrgans_female = diag(TableMets_femaleNumInOrgans);
HousekeepingMets_female = Mets(find(MetsInOrgans_female>=length(Ofemale)-2));%2 entries of Ofemale are no organs
OrganSpecMets_female = Mets(find(MetsInOrgans_female==1));%at most in 2 organs
NoOrgaMets_female = Mets(find(MetsInOrgans_female==0));%at most in 2 organs
OtherOrganMets_female = Mets(find(MetsInOrgans_female>1 & MetsInOrgans_female<length(Ofemale)-2));%at most in 2 organs
sumMets = length(NoOrgaMets_female)+length(OtherOrganMets_female)+length(OrganSpecMets_female)+length(HousekeepingMets_female);
s = {' '};
TableGRM{1,7} = 'Metabolites';
TableGRM{2,5} = 'core';
TableGRM{2,7} = strcat(num2str(length(HousekeepingMets_female)),s,'(',num2str(round(length(HousekeepingMets_female)*100/sumMets,1)),'%)');
TableGRM{3,5} = 'organ-specific';
TableGRM{3,7} = strcat(num2str(length(OrganSpecMets_female)),s,'(',num2str(round(length(OrganSpecMets_female)*100/sumMets,1)),'%)');
TableGRM{4,5} = 'others';
TableGRM{4,7} = strcat(num2str(length(OtherOrganMets_female)),s,'(',num2str(round(length(OtherOrganMets_female)*100/sumMets,1)),'%)');
TableGRM{5,5} = 'absent';
TableGRM{5,7} = strcat(num2str(length(NoOrgaMets_female)),s,'(',num2str(round(length(NoOrgaMets_female)*100/sumMets,1)),'%)');
TableGRM{6,5} = 'sum';
TableGRM{6,7} = num2str(sumMets);

clear TableGenes_female TableGenes_femaleNum
%[Genes,rem]=strtok(Recon3DHarvey.genes,'.');
Genes = [];
% get set of unique reactions
for i = 1 : length(Ofemale)
    if ~strcmp('sex',Ofemale{i}) && ~strcmp('gender',Ofemale{i}) && ~strcmp('Recon3DHarvey',Ofemale{i})
        % grab reactions
        OGenes = OrganCompendium_female.(Ofemale{i}).modelAllComp.genes;
        Genes = [Genes;OGenes];
    end
end
%[Genes,rem]=strtok(Genes,'.');
Genes = unique(Genes);

TableGenes_female(1:length(Genes),1) = (Genes);
for i = 1 : length(Ofemale)
    if ~strcmp('sex',Ofemale{i}) && ~strcmp('gender',Ofemale{i}) && ~strcmp('Recon3DHarvey',Ofemale{i})
        % grab reactions
        %[OGenes,rem]=strtok(OrganCompendium_female.(Ofemale{i}).modelAllComp.genes,'.');
      %  OGenes = unique(OGenes);
          OGenes = OrganCompendium_female.(Ofemale{i}).modelAllComp.genes;
        TableGenes_female(:,i+1)=num2cell(0);
        TableGenes_female(find(ismember(Genes,OGenes)),i+1)=num2cell(1);
        TableGenes_femaleO{1,i+1} = Ofemale{i};
        TableGenes_femaleNum(find(ismember(Genes,OGenes)),i)=1;
    end
end
TableGenes_female = [TableGenes_femaleO;TableGenes_female];
% correlation
TableGenes_femaleNumCorr = corrcoef(TableGenes_femaleNum);
% get stats

% shared genes
TableGenes_femaleNumInOrgans = TableGenes_femaleNum*TableGenes_femaleNum';
GenesInOrgans_female = diag(TableGenes_femaleNumInOrgans);
HousekeepingGenes_female = Genes(find(GenesInOrgans_female>=length(Ofemale)-2));%2 entries of Ofemale are no organs
OrganSpecGenes_female = Genes(find(GenesInOrgans_female==1));%at most in 2 organs
NoOrganGenes_female = Genes(find(GenesInOrgans_female==0));%at most in 2 organs
OtherOrganGenes_female = Genes(find(GenesInOrgans_female>1 & GenesInOrgans_female<length(Ofemale)-2));%at most in 2 organs
sumGenes = length(NoOrganGenes_female)+length(OtherOrganGenes_female)+length(OrganSpecGenes_female)+length(HousekeepingGenes_female);
s = {' '};
TableGRM{1,6} = 'Genes';
TableGRM{2,5} = 'core';
TableGRM{2,6} = strcat(num2str(length(HousekeepingGenes_female)),s,'(',num2str(round(length(HousekeepingGenes_female)*100/sumGenes,1)),'%)');
TableGRM{3,5} = 'organ-specific';
TableGRM{3,6} = strcat(num2str(length(OrganSpecGenes_female)),s,'(',num2str(round(length(OrganSpecGenes_female)*100/sumGenes,1)),'%)');
TableGRM{4,5} = 'others';
TableGRM{4,6} = strcat(num2str(length(OtherOrganGenes_female)),s,'(',num2str(round(length(OtherOrganGenes_female)*100/sumGenes,1)),'%)');
TableGRM{5,5} = 'absent';
TableGRM{5,6} = strcat(num2str(length(NoOrganGenes_female)),s,'(',num2str(round(length(NoOrganGenes_female)*100/sumGenes,1)),'%)');
TableGRM{6,5} = 'sum';
TableGRM{6,6} = num2str(sumGenes);

if 0
    figure
    imagesc(TableRxnsNumCorr_female)
    figure
    imagesc(TableRxnsNum_female)
    figure
    imagesc(TableGenes_femaleNumCorr)
    figure
    imagesc(TableGenes_femaleNum)
    
    figure
    imagesc(TableMetsNum_femaleCorr)
    figure
    imagesc(TableMetsNum_female)
end

% get stats table
clear TableAverage_female
c = 1;
TableAverage_female{c,1} = {'Average number of reactions'};
Sum = sum(TableRxnsNum_female);
SumR_female = Sum;
TableAverage_female{c,2} = num2str(mean(Sum));c= c+1;
TableAverage_female{c,1} = {'Std number of reactions'};
TableAverage_female{c,2} = num2str(std(Sum));c= c+1;
TableAverage_female{c,1} = {'Min number of reactions'};
TableAverage_female{c,2} = num2str(min(Sum));c= c+1;
TableAverage_female{c,1} = {'Max number of reactions'};
TableAverage_female{c,2} = num2str(max(Sum));c= c+1;

TableAverage_female{c,1} = {'Average number of metabolites'};
Sum = sum(TableMetsNum_female);
SumM_female = Sum;
TableAverage_female{c,2} = num2str(mean(Sum));c= c+1;
TableAverage_female{c,1} = {'Std number of metabolites'};
TableAverage_female{c,2} = num2str(std(Sum));c= c+1;
TableAverage_female{c,1} = {'Min number of metabolites'};
TableAverage_female{c,2} = num2str(min(Sum));c= c+1;
TableAverage_female{c,1} = {'Max number of metabolites'};
TableAverage_female{c,2} = num2str(max(Sum));c= c+1;

TableAverage_female{c,1} = {'Average number of genes'};
Sum = sum(TableGenes_femaleNum);
SumG_female = Sum;
TableAverage_female{c,2} = num2str(mean(Sum));c= c+1;
TableAverage_female{c,1} = {'Std number of genes'};
TableAverage_female{c,2} = num2str(std(Sum));c= c+1;
TableAverage_female{c,1} = {'Min number of genes'};
TableAverage_female{c,2} = num2str(min(Sum));c= c+1;
TableAverage_female{c,1} = {'Max number of genes'};
TableAverage_female{c,2} = num2str(max(Sum));c= c+1;

% does not work on 2013
if violinPlots == 1
    figure
    vs = violinplot([SumR_female' SumM_female' SumG_female'], {'Reactions';'Metabolites';'Genes (unique)'});
    
    
    figure;
    subplot(2,4,1);
    vs = violinplot([SumR_male'  ], {'Male'});
    title('Reactions');
    subplot(2,4,2);
    vs = violinplot([SumM_male'  ], {'Male'});
    title('Metabolites');
    subplot(2,4,3);
    vs = violinplot([SumG_male'  ], {'Male'});
    title('Genes');
    subplot(2,4,4);
    vs = violinplot(PercGeneAssRxns_male , {'Male'});
    title('Gene-associated Reactions');
    subplot(2,4,5);
    vs = violinplot([SumR_female' ], {'Female'});
    title('Reactions');
    subplot(2,4,6);
    vs = violinplot([ SumM_female' ], {'Female'});
    title('Metabolites');
    subplot(2,4,7);
    vs = violinplot([ SumG_female' ], {'Female'});
    title('Genes');
    subplot(2,4,8);
    vs = violinplot(PercGeneAssRxns_female , {'Female'});
    title('Gene-associated Reactions');
    
end

%figures
genesPerOrganFigure(GenesInOrgans_male, GenesInOrgans_female);

if 0
    if 0 %Ronan
        clear s SL str Sum Sink rem* ans c C cm DM EX Exc* g i j vs BC BCK BCM
        save Results_StatsOrganComp
    else
        save([resultsPath 'Results_StatsOrganComp'],'Results_StatsOrganComp')
    end
end

function genesPerOrganFigure(data1, data2)
%CREATEFIGURE(DATA1, DATA2)
%  DATA1:  histogram data
%  DATA2:  histogram data

%  Auto-generated by MATLAB on 01-Nov-2017 13:29:33

% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1,...
    'Position',[0.13 0.441422594142259 0.84158081705151 0.48357740585774]);
hold(axes1,'on');

% Create histogram
histogram(data1,'DisplayName','Male','Parent',axes1,'BinMethod','auto');

% Create histogram
histogram(data2,'DisplayName','Female','Parent',axes1,'BinMethod','auto');

% Create xlabel
xlabel('Number of organs','FontWeight','bold');

% Create ylabel
ylabel('Number of genes','FontWeight','bold');

% Uncomment the following line to preserve the X-limits of the axes
% xlim(axes1,[-1 31]);
% Uncomment the following line to preserve the Y-limits of the axes
% ylim(axes1,[0 320]);
box(axes1,'on');
% Set the remaining axes properties
set(axes1,'FontSize',16,'YGrid','on');
% Create legend
legend1 = legend(axes1,'show');
set(legend1,...
    'Position',[0.199638917453492 0.822951332005227 0.0776315789473684 0.0538881309686221]);

title('Genes per organ')


