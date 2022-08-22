function [metabolite_structure] = assignAGORAReconPresence(metabolite_structure, reaction)
% this function assigns whether a metabolite occurs in AGORA_X and ReconX
%
% INPUT
% metabolite_structure  metabolite structure
% reaction              default: false (0). Set to true (1) if input is a reaction
%                       structure
% OUTPUT
% metabolite_structure  Updated metabolite structure
%
%
% Ines Thiele, 09/2021
if ~exist('reaction','var')
    reaction =0;
end
annotationType = 'automatic';

[VMH2IDmappingAll]=getIDfromMetStructure(metabolite_structure,'VMHId');

if reaction == 0
    [NUM,TXT,AGORA]=xlsread('Metabolites_AGORA2_refined.xlsx');
    annotationSource = 'Metabolites_AGORA2_refined.xlsx';
    
else
    [NUM,TXT,AGORA]=xlsread('Reactions_AGORA2_refined.xlsx');
    annotationSource = 'Reactions_AGORA2_refined.xlsx';
end

for i = 1 : size(AGORA,1)
    hit = find(ismember(VMH2IDmappingAll(:,2),AGORA{i,1}));
    if ~isempty(hit)
        field = VMH2IDmappingAll{hit,1};
        if isfield(metabolite_structure,field)
            metabolite_structure.(field).Agora2 = 1;
            metabolite_structure.(field).Agora2_source = [annotationSource,':',annotationType,':',datestr(now)];
        end
    end
end

% use the published Recon 3D
metaboAnnotatorPath =  fileparts(which('tutorial_MetaboAnnotator'));
if exist([metaboAnnotatorPath filesep 'data' filesep 'Recon3D_Dec2017.mat'],'file')
    load([metaboAnnotatorPath filesep 'data' filesep 'Recon3D_Dec2017.mat']);
else
    load('Recon3D_Dec2017.mat');
end
annotationSource = 'Recon3D_Dec2017.mat';

if reaction == 0
    mets = Recon3D.mets; % metabolites have compartments and hence are not unique
    metN = Recon3D.metNames; % metabolites have compartments and hence are not unique
else
    mets = Recon3D.rxns;
    metN = Recon3D.rxnNames; % metabolites have compartments and hence are not unique
end
for i = 1 : length(mets)
    clear metID
    if reaction == 0
        metID = strtok(mets{i},'[');
    else
        metID = mets{i};
    end
    hit = find(ismember(VMH2IDmappingAll(:,2),metID));
    if ~isempty(hit)
        field = VMH2IDmappingAll{hit,1};
        if  isfield(metabolite_structure,field)
            metabolite_structure.(field).Recon3D = 1;
            metabolite_structure.(field).Recon3D_source = [annotationSource,':',annotationType,':',datestr(now)];
        else
            % add any missing metabolites, the other fields will be populated
            % through the api of the VMH
            % add metabolite to structure
            % add fields to structure
            if reaction == 0
                metabolite_structure.(['VMH_' metID]) = struct();
                metabolite_structure.(['VMH_' metID]).VMHId = metID;
                metabolite_structure.(['VMH_' metID]).metNames = metN{i};
                metabolite_structure.(['VMH_' metID]).metNames_source = [annotationSource,':',annotationType,':',datestr(now)];
                
                metabolite_structure.(['VMH_' metID]).Recon3D = 1;
                metabolite_structure.(['VMH_' metID]).Recon3D_source = [annotationSource,':',annotationType,':',datestr(now)];
                metabolite_structure= addField2MetStructure(metabolite_structure,strcat('VMH_', metID));
            elseif isempty(strfind(metID,'EX_')) && isempty(strfind(metID,'DM_'))  && isempty(strfind(metID,'sink_'))
                metIDOri = metID;
                metID = regexprep(metID,'-','_minus_');
                metID = regexprep(metID,'(','_parentO_');
                metID = regexprep(metID,')','_parentC_');
                metID = regexprep(metID,'[','_parentO_');
                metID = regexprep(metID,']','_parentC_');
                metID = regexprep(metID,':','_colon_');
                metabolite_structure.(['VMH_' metID]) = struct();
                metabolite_structure.(['VMH_' metID]).VMHId = metIDOri;
                %       metabolite_structure.(['VMH_' metID]).rxnName = metN{i};
                %        metabolite_structure.(['VMH_' metID]).rxnName_source = [annotationSource,':',annotationType,':',datestr(now)];
                
                metabolite_structure.(['VMH_' metID]).Recon3D = 1;
                metabolite_structure.(['VMH_' metID]).Recon3D_source = [annotationSource,':',annotationType,':',datestr(now)];
                metabolite_structure= addField2RxnStructure(metabolite_structure,strcat('VMH_', metID));
            end
            
        end
    elseif 0
        % add any missing metabolites, the other fields will be populated
        % through the api of the VMH
        % add metabolite to structure
        
        % add fields to structure
        if reaction == 0
            metabolite_structure.(['VMH_' metID]) = struct();
            metabolite_structure.(['VMH_' metID]).VMHId = metID;
            metabolite_structure.(['VMH_' metID]).metNames = metN{i};
            metabolite_structure.(['VMH_' metID]).metNames_source = [annotationSource,':',annotationType,':',datestr(now)];
            metabolite_structure.(['VMH_' metID]).Recon3D = 1;
            metabolite_structure.(['VMH_' metID]).Recon3D_source = [annotationSource,':',annotationType,':',datestr(now)];
            metabolite_structure= addField2MetStructure(metabolite_structure,strcat('VMH_', metID));
            
        elseif isempty(strfind(metID,'EX_')) && isempty(strfind(metID,'DM_'))  && isempty(strfind(metID,'sink_'))
            metIDOri = metID;
            metID = regexprep(metID,'-','_minus_');
            metID = regexprep(metID,'(','_parentO_');
            metID = regexprep(metID,')','_parentC_');
            metID = regexprep(metID,'[','_parentO_');
            metID = regexprep(metID,']','_parentC_');
            metID = regexprep(metID,':','_colon_');
            metabolite_structure.(['VMH_' metID]) = struct();
            metabolite_structure.(['VMH_' metID]).VMHId = metIDOri;
            %       metabolite_structure.(['VMH_' metID]).rxnName = metN{i};
            %    metabolite_structure.(['VMH_' metID]).rxnName_source = [annotationSource,':',annotationType,':',datestr(now)];
            metabolite_structure.(['VMH_' metID]).Recon3D = 1;
            metabolite_structure.(['VMH_' metID]).Recon3D_source = [annotationSource,':',annotationType,':',datestr(now)];
            metabolite_structure= addField2RxnStructure(metabolite_structure,strcat('VMH_', metID));
            
        end
        
    end
end

