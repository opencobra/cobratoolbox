function [createdModels] = createPersonalizedModel(abundance, resPath, model, sampNames, orglist, couplingMatrix, host, hostBiomassRxn, hostBiomassRxnFlux)
% This function creates personalized models from integration of given
% organisms abundances into the previously built global setup. Coupling
% constraints are also added for each organism. All the operations are
% parallelized and the generated personalized models directly saved in .mat
% format.
%
% USAGE:
%
%    [createdModels] = createPersonalizedModel(abundance, resPath, model, sampNames, orglist, host, hostBiomassRxn, hostBiomassRxnFlux)
%
% INPUTS:
%   abundance:          table with abundance information
%   resPath:            char with path of directory where results are saved
%   model:              model in COBRA model structure format
%   sampNames:          cell array with names of individuals in the study
%   orglist:            cell array with names of organisms in the study
%   couplingMatrix:     cell array containing pre-created coupling matrices for
%                       each organism to be joined (created by
%                       buildModelStorage function)
%   host:               Contains the host model if path to host model was
%                       defined. Otherwise empty.
%   hostBiomassRxn:     char with name of biomass reaction in host (default: empty)
%   hostBiomassRxnFlux: double with the desired upper bound on flux through the host
%                       biomass reaction (default: 1)
%
% OUTPUT:
%   createdModels:      created personalized models
%
% .. Author: Federico Baldini 2017-2018
%            Almut Heinken, 05/2021: changed to creating coupling matrix by
%            merging pre-created matrices for improved speed

createdModels = {};

% use the setup model containing every strain in every sample
pruned_model = model;
abunRed = abundance(:,2);
couplingMatrixRed = couplingMatrix;

% retrieving current model ID
if ~isempty(host)
    mId = strcat('host_microbiota_model_samp_', sampNames{1,1}, '.mat');
else
    mId = strcat('microbiota_model_samp_', sampNames{1,1}, '.mat');
end

% Autoload for already created models
mapP = detectOutput(resPath, mId);
if isempty(mapP)
    % end of trigger
    % parsave(sprintf(strcat(idInfo,'%d.mat')),id)
    % code lines to find which  bacteria has abundance of 0
    if contains(version,'(R202') % for Matlab R2020a and newer
        noab=orglist(cell2mat(abunRed(:,1))<0.00000001);
        couplingMatrixRed(cell2mat(abunRed(:,1))<0.00000001,:)=[];
        abunRed(cell2mat(abunRed(:,1))<0.00000001,:)=[];
    else
        noab=orglist(str2double(abunRed(:,1))<0.00000001);
        couplingMatrixRed(str2double(abunRed(:,1))<0.00000001,:)=[];
        abunRed(str2double(abunRed(:,1))<0.00000001,:)=[];
    end
    % Setting to 0 the Exchange reactions of a bacteria whose abundance is 0 in
    % the individual and in the biomass
    for i = 1:length(noab)
        IndRxns = find(strncmp(pruned_model.rxns,[noab{i,1} '_'],length(noab{i,1})+1));% finding indixes of specific reactions
        RmRxns = pruned_model.rxns(IndRxns);
        pruned_model = removeRxns(pruned_model, RmRxns);
    end
    % Preparing vectors with abundances and bacteria in a way to eliminate the
    % ones not present (abundance =0)
    presBac=setdiff(orglist,noab,'stable');
    
    pruned_model=addMicrobeCommunityBiomass(pruned_model,presBac,cell2mat(abunRed));
    
    % determine total length of matrices
    matSize=0;
    for i=1:size(couplingMatrixRed,1)
        matSize=matSize+size(couplingMatrixRed{i,1},1);
    end
    
    pruned_model.C=sparse(matSize,length(pruned_model.rxns));
    pruned_model.d=zeros(matSize,1);
    pruned_model.dsense=char(matSize,1);
    pruned_model.ctrs=cell(matSize,1);
    
    % Coupling constraints for bacteria-merge matrices
    matStart=0;
    cnt=1;
    for i = 1:length(presBac)
        % find the indices of where there merged matrices are on the C
        % matrix
        matInd1=[];
        for j=1:size(couplingMatrixRed{i,1},1)
            matInd1(size(matInd1,1)+1,1)=j+matStart;
            % merge the fields
            pruned_model.d(cnt,1)=couplingMatrixRed{i,2}(j,1);
            pruned_model.dsense(cnt,1)=char(couplingMatrixRed{i,3}(j,1));
            pruned_model.ctrs{cnt,1}=couplingMatrixRed{i,4}{j,1};
            cnt=cnt+1;
        end
        matInd2=find(strncmp(pruned_model.rxns,[presBac{i,1} '_'],length(presBac{i,1})+1));%finding indixes of specific reactions
        % merge the C matrix
        pruned_model.C(matInd1,matInd2) = couplingMatrixRed{i,1};
        
        matStart=matStart+size(couplingMatrixRed{i,1},1);
    end
    
    % set constraints on host exchanges if present
    if ~isempty(host)
        hostEXrxns=find(strncmp(pruned_model.rxns,'Host_EX_',8));
        pruned_model=changeRxnBounds(pruned_model,pruned_model.rxns(hostEXrxns),0,'l');
        % constrain blood exchanges but make exceptions for metabolites that should be taken up from
        % blood
        takeupExch={'h2o','hco3','o2','co2'};
        takeupExch=strcat('Host_EX_', takeupExch, '_eb');
        pruned_model=changeRxnBounds(pruned_model,takeupExch,-100,'l');
        % close internal exchanges except for human metabolites known
        % to be found in the intestine
        hostIEXrxns=find(strncmp(pruned_model.rxns,'Host_IEX_',9));
        pruned_model=changeRxnBounds(pruned_model,pruned_model.rxns(hostIEXrxns),0,'l');
        takeupExch={'gchola','tdchola','tchola','dgchol','34dhphe','5htrp','Lkynr','f1a','gncore1','gncore2','dsT_antigen','sTn_antigen','core8','core7','core5','core4','ha','cspg_a','cspg_b','cspg_c','cspg_d','cspg_e','hspg'};
        takeupExch=strcat('Host_IEX_', takeupExch, '[u]tr');
        pruned_model=changeRxnBounds(pruned_model,takeupExch,-1000,'l');
        % close host sink and demand reactions
        if ~isempty(find(contains(pruned_model.rxns,'Host_sink_')))
            hostSinkRxns=find(strncmp(pruned_model.rxns,'Host_sink_',10));
        elseif ~isempty(find(contains(pruned_model.rxns,'Host_SK_')))
            hostSinkRxns=find(strncmp(pruned_model.rxns,'Host_SK_',8));
        end
        pruned_model=changeRxnBounds(pruned_model,pruned_model.rxns(hostSinkRxns),0,'b');
        hostDMRxns=find(strncmp(pruned_model.rxns,'Host_DM_',8));
        pruned_model=changeRxnBounds(pruned_model,pruned_model.rxns(hostDMRxns),0,'l');
        % set a minimum and a limit for flux through host biomass
        % reaction
        pruned_model=changeRxnBounds(pruned_model,['Host_' hostBiomassRxn],0.001,'l');
        pruned_model=changeRxnBounds(pruned_model,['Host_' hostBiomassRxn],hostBiomassRxnFlux,'u');
    end
    
    % Coupling constraints for host (optional but recommended)
    if ~isempty(host) && ~isempty(hostBiomassRxn)
        IndRxns=find(strncmp(pruned_model.rxns,'Host_',length('Host_')));%finding indixes of specific reactions
        pruned_model=coupleRxnList2Rxn(pruned_model,pruned_model.rxns(IndRxns(1:length(pruned_model.rxns(IndRxns(:,1)))-1,1)),['Host_' hostBiomassRxn],400,0); %couple the specific reactions
    end
    
    % finam.name=sampNames{1,1};
    % allmod(1,1)={finam};
    microbiota_model=pruned_model;
    microbiota_model.name=sampNames{1,1};
    
    % remove unnecessary fields
    toRemove={'citations';'comments';'grRules';'rxnConfidenceScores';'rxnECNumbers';'rxnKEGGID';'metHMDBID';'metInChIString';'metKEGGID';'metPubChemID';'metSmiles';'genes'};
    microbiota_model = rmfield(microbiota_model,toRemove);
    
    microbiota_model = changeObjective(microbiota_model, 'EX_microbeBiomass[fe]');
    
    sresPath=resPath(1:(length(resPath)-1));
    cd(sresPath)
    % give a different name if host is present
    if ~isempty(host)
        parsave(sprintf(strcat('host_microbiota_model_samp_',sampNames{1,1},'%d.mat')),microbiota_model)
    else
        parsave(sprintf(strcat('microbiota_model_samp_',sampNames{1,1},'%d.mat')),microbiota_model)
    end
    
    createdModels{1} = microbiota_model;
else
    s= 'microbiota model file found: skipping model creation for this sample';
    disp(s)
end

end