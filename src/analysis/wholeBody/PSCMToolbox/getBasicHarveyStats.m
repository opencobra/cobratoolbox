function [TableHHStats] = getBasicHarveyStats(male,female)
% This function compiles basic statistics on the male and female whole-body
% metabolic model
%
% function [TableHHStats] = getBasicHarveyStats(male,female)
%
% INPUT
% male          Model structure containing the male model
% female        Model structure containing the female model
%
% OUTPUT
% TableHHStats  Table containing the statistics
% 
% Ines Thiele 2016- 2019

% build table
clear TableHHStats
c = 1;

SL = (find(~cellfun(@isempty,strfind(female.mets,'slack_'))));
SL_female = SL;
SL = (find(~cellfun(@isempty,strfind(male.mets,'slack_'))));
SL_male = SL;

TableHHStats{c , 1} = '';
TableHHStats{c , 2} = 'Harvetta'; 
TableHHStats{c , 3} = 'Harvey'; c = c+1;


TableHHStats{c , 1} = 'Number of Reactions';      

TableHHStats{c , 2} = num2str(length(female.rxns));
TableHHStats{c , 3} = num2str(length(male.rxns)); c = c+1;


TableHHStats{c , 1} = 'Number of Metabolites';      

TableHHStats{c , 2} = num2str(length(female.mets)-length(SL_female));
TableHHStats{c , 3} = num2str(length(male.mets)-length(SL_male)); c = c+1;

TableHHStats{c , 1} = 'Number of Genes (transcripts)';      
TableHHStats{c , 2} = num2str(length(female.genes));
TableHHStats{c , 3} = num2str(length(male.genes)); c = c+1;

TableHHStats{c , 1} = 'Number of Genes (unique)';     
[a,b]=strtok(female.genes,'.');

TableHHStats{c , 2} = num2str(length(unique(a)));
[a,b]=strtok(male.genes,'.');
TableHHStats{c , 3} = num2str(length(unique(a))); c = c+1;

TableHHStats{c , 1} = 'Number of Subsystems';      

% Feb 2020, moved this to loadPSCMfile
% Oct 2017 % clean up final remaining subsystem names
% female.subSystems(strmatch('Transport, endoplasmic reticular',female.subSystems,'exact'))={'Transport, endoplasmic reticulum'};
% female.subSystems(strmatch('Arginine and Proline Metabolism',female.subSystems,'exact'))={'Arginine and proline Metabolism'};
% female.subSystems(strmatch(' ',female.subSystems,'exact'))={'Miscellaneous'};
% 
% male.subSystems(strmatch('Transport, endoplasmic reticular',male.subSystems,'exact'))={'Transport, endoplasmic reticulum'};
% male.subSystems(strmatch('Arginine and Proline Metabolism',male.subSystems,'exact'))={'Arginine and proline Metabolism'};
% male.subSystems(strmatch(' ',male.subSystems,'exact'))={'Miscellaneous'};

TableHHStats{c , 2} = num2str(length(unique(female.subSystems))-1);%do not count dummy reactions
TableHHStats{c , 3} = num2str(length(unique(male.subSystems))-1); c = c+1;%do not count dummy reactions

TableHHStats{c , 1} = 'Blood compartment metabolites';
BC_mets = (find(~cellfun(@isempty,strfind(female.mets,'[bc]'))));
SL_female = (find(~cellfun(@isempty,strfind(female.mets,'slack_'))));
BC_mets_female = setdiff(BC_mets,SL_female);

BC_mets = (find(~cellfun(@isempty,strfind(male.mets,'[bc]'))));
SL_male = (find(~cellfun(@isempty,strfind(male.mets,'slack_'))));
BC_mets_male = setdiff(BC_mets,SL_male);

TableHHStats{c , 2} = num2str(length(BC_mets_female));
TableHHStats{c , 3} = num2str(length(BC_mets_male)); c = c+1;

TableHHStats{c , 1} = 'Urine metabolites';
U_mets = (find(~cellfun(@isempty,strfind(female.mets,'[u]'))));
U_mets_female = setdiff(U_mets,SL_female);

U_mets = (find(~cellfun(@isempty,strfind(male.mets,'[u]'))));
U_mets_male = setdiff(U_mets,SL_male);

TableHHStats{c , 2} = num2str(length(U_mets_female));
TableHHStats{c , 3} = num2str(length(U_mets_male)); c = c+1;

TableHHStats{c , 1} = 'Portal vein metabolites';
BP_mets = (find(~cellfun(@isempty,strfind(female.mets,'[bp]'))));
BP_mets_female = setdiff(BP_mets,SL_female);

BP_mets = (find(~cellfun(@isempty,strfind(male.mets,'[bp]'))));
BP_mets_male = setdiff(BP_mets,SL_male);

TableHHStats{c , 2} = num2str(length(BP_mets_female));
TableHHStats{c , 3} = num2str(length(BP_mets_male)); c = c+1;

TableHHStats{c , 1} = 'Bile duct metabolites';

BD_mets = (find(~cellfun(@isempty,strfind(female.mets,'[bd]'))));
BD_mets_female = setdiff(BD_mets,SL_female);

BD_mets = (find(~cellfun(@isempty,strfind(male.mets,'[bd]'))));
BD_mets_male = setdiff(BD_mets,SL_male);

TableHHStats{c , 2} = num2str(length(BD_mets_female));
TableHHStats{c , 3} = num2str(length(BD_mets_male)); c = c+1;

TableHHStats{c , 1} = 'CSF metabolites';

CSF_mets = (find(~cellfun(@isempty,strfind(female.mets,'[csf]'))));
CSF_mets_female = setdiff(CSF_mets,SL_female);

CSF_mets = (find(~cellfun(@isempty,strfind(male.mets,'[csf]'))));
CSF_mets_male = setdiff(CSF_mets,SL_male);

TableHHStats{c , 2} = num2str(length(CSF_mets_female));
TableHHStats{c , 3} = num2str(length(CSF_mets_male)); c = c+1;

TableHHStats{c , 1} = 'Diet metabolites';

D_mets = (find(~cellfun(@isempty,strfind(female.mets,'[d]'))));
D_mets_female = setdiff(D_mets,SL_female);
D_mets = (find(~cellfun(@isempty,strfind(male.mets,'[d]'))));
D_mets_male = setdiff(D_mets,SL_male);

TableHHStats{c , 2} = num2str(length(D_mets_female));
TableHHStats{c , 3} = num2str(length(D_mets_male)); c = c+1;

TableHHStats{c , 1} = 'Fecal metabolites';

Fe_mets = (find(~cellfun(@isempty,strfind(female.mets,'[fe]'))));
Fe_mets_female = setdiff(Fe_mets,SL_female);

Fe_mets = (find(~cellfun(@isempty,strfind(male.mets,'[fe]'))));
Fe_mets_male = setdiff(Fe_mets,SL_male);

TableHHStats{c , 2} = num2str(length(Fe_mets_female));
TableHHStats{c , 3} = num2str(length(Fe_mets_male)); c = c+1;


TableHHStats{c , 1} = 'Sweat metabolites';

Fe_mets = (find(~cellfun(@isempty,strfind(female.mets,'[sw]'))));
Fe_mets_female = setdiff(Fe_mets,SL_female);

Fe_mets = (find(~cellfun(@isempty,strfind(male.mets,'[sw]'))));
Fe_mets_male = setdiff(Fe_mets,SL_male);

TableHHStats{c , 2} = num2str(length(Fe_mets_female));
TableHHStats{c , 3} = num2str(length(Fe_mets_male)); c = c+1;


TableHHStats{c , 1} = 'Air metabolites';

A_mets = (find(~cellfun(@isempty,strfind(female.mets,'[a]'))));
A_mets_female = setdiff(A_mets,SL_female);

A_mets = (find(~cellfun(@isempty,strfind(male.mets,'[a]'))));
A_mets_male = setdiff(A_mets,SL_male);

TableHHStats{c , 2} = num2str(length(A_mets_female));
TableHHStats{c , 3} = num2str(length(A_mets_male)); c = c+1;


TableHHStats{c , 1} = 'Milk metabolites';

Fe_mets = (find(~cellfun(@isempty,strfind(female.mets,'[mi]'))));
Fe_mets_female = setdiff(Fe_mets,SL_female);

Fe_mets = (find(~cellfun(@isempty,strfind(male.mets,'[mi]'))));
Fe_mets_male = setdiff(Fe_mets,SL_male);

TableHHStats{c , 2} = num2str(length(Fe_mets_female));
TableHHStats{c , 3} = num2str(length(Fe_mets_male)); c = c+1;
