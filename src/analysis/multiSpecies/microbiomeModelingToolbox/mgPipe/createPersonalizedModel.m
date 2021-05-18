function [createdModels] = createPersonalizedModel(abundance, resPath, model, sampNames, orglist, couplingMatrix, host, hostBiomassRxn)
% This function creates personalized models from integration of given
% organisms abundances into the previously built global setup. Coupling
% constraints are also added for each organism. All the operations are
% parallelized and the generated personalized models directly saved in .mat
% format.
%
% USAGE:
%
%    [createdModels] = createPersonalizedModel(abundance, resPath, model, sampNames, orglist, host, hostBiomassRxn)
%
% INPUTS:
%   abundance:          table with abundance information
%   resPath:            char with path of directory where results are saved
%   model:              "global setup" model in COBRA model structure format
%   sampNames:          cell array with names of individuals in the study
%   orglist:            cell array with names of organisms in the study
%   couplingMatrix:     cell array containing pre-created coupling matrices for
%                       each organism to be joined (created by
%                       buildModelStorage function)
%   host:               Contains the host model if path to host model was
%                       defined. Otherwise empty.
%   hostBiomassRxn:     char with name of biomass reaction in host (default: empty)
%
% OUTPUT:
%   createdModels:      created personalized models
%
% .. Author: Federico Baldini 2017-2018
%            Almut Heinken, 05/2021: changed to creating coupling matrix by
%            merging pre-created matrices for improved speed

createdModels = {};

% use the setup model containing every strain in every sample
for k = 1:length(sampNames)
    pruned_model = model;
    abunRed = abundance(:,k+1);
    couplingMatrixRed = couplingMatrix;
    
    % retrieving current model ID
    if ~isempty(host)
        mId = strcat('host_microbiota_model_samp_', sampNames{k,1}, '.mat');
    else
        mId = strcat('microbiota_model_samp_', sampNames{k,1}, '.mat');
    end
    
    % Autoload for already created models
    mapP = detectOutput(resPath, mId);
    if isempty(mapP)
        % end of trigger
        % parsave(sprintf(strcat(idInfo,'%d.mat')),id)
        % code lines to find which  bacteria has abundance of 0
        noab=orglist(cell2mat(abunRed(:,1))<0.00000001);
        couplingMatrixRed(cell2mat(abunRed(:,1))<0.00000001,:)=[];
        abunRed(cell2mat(abunRed(:,1))<0.00000001,:)=[];
        
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
        pruned_model.d=zeros(length(pruned_model.rxns),1);
        pruned_model.dsense=char(length(pruned_model.rxns),1);
        pruned_model.ctrs=cell(length(pruned_model.rxns),1);
        
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
        
        % Coupling constraints for host (optional but recommended)
        if ~isempty(host) && ~isempty(hostBiomassRxn)
            IndRxns=find(strncmp(pruned_model.rxns,'Host_',length('Host_')));%finding indixes of specific reactions
            pruned_model=coupleRxnList2Rxn(pruned_model,pruned_model.rxns(IndRxns(1:length(pruned_model.rxns(IndRxns(:,1)))-1,1)),['Host_' hostBiomassRxn],400,0); %couple the specific reactions
        end
        
        % finam.name=sampNames{k,1};
        % allmod(k,1)={finam};
        microbiota_model=pruned_model;
        microbiota_model.name=sampNames{k,1};
        sresPath=resPath(1:(length(resPath)-1));
        cd(sresPath)
        % give a different name if host is present
        if ~isempty(host)
            parsave(sprintf(strcat('host_microbiota_model_samp_',sampNames{k,1},'%d.mat')),microbiota_model)
        else
            parsave(sprintf(strcat('microbiota_model_samp_',sampNames{k,1},'%d.mat')),microbiota_model)
        end
    else
        s= 'microbiota model file found: skipping model creation for this sample';
        disp(s)
    end
end

end