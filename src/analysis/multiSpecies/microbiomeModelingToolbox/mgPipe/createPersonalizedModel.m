function [createdModels] = createPersonalizedModel(abundance, resPath, model, sampNames, orglist, host, hostBiomassRxn)
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
%   host:               Contains the host model if path to host model was
%                       defined. Otherwise empty.
%   hostBiomassRxn:     char with name of biomass reaction in host (default: empty)
%
% OUTPUT:
%   createdModels:   created personalized models
%
% .. Author: Federico Baldini 2017-2018
%            Almut Heinken, 03/2021: simplified function

createdModels = {};

% use the setup model containing every strain in every sample
for k = 1:length(sampNames)
    mgmodel = model;
    abunRed = abundance(:,k+1);
    
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
        abunRed(cell2mat(abunRed(:,1))<0.00000001,:)=[];
        
        % Setting to 0 the Exchange reactions of a bacteria whose abundance is 0 in
        % the individual and in the biomass
        for i = 1:length(noab)
            IndRxns = find(strncmp(mgmodel.rxns,[noab{i,1} '_'],length(noab{i,1})+1));% finding indixes of specific reactions
            RmRxns = mgmodel.rxns(IndRxns);
            mgmodel = removeRxns(mgmodel, RmRxns);
        end
        % Preparing vectors with abundances and bacteria in a way to eliminate the
        % ones not present (abundance =0)
        presBac=setdiff(orglist,noab,'stable');
        
        mgmodel=addMicrobeCommunityBiomass(mgmodel,presBac,cell2mat(abunRed));
        
        % Coupling constraints for bacteria
        for i = 1:length(presBac)
            IndRxns=find(strncmp(mgmodel.rxns,[presBac{i,1} '_'],length(presBac{i,1})+1));%finding indixes of specific reactions
            % find the name of biomass reaction in the microbe model
            bioRxn=mgmodel.rxns{find(strncmp(mgmodel.rxns,strcat(presBac{i,1},'_bio'),length(char(strcat(presBac{i,1},'_bio')))))};
            mgmodel=coupleRxnList2Rxn(mgmodel,mgmodel.rxns(IndRxns(1:length(mgmodel.rxns(IndRxns(:,1)))-1,1)),bioRxn,400,0); %couple the specific reactions
        end
        % Coupling constraints for host (optional but recommended)
        if ~isempty(host) && ~isempty(hostBiomassRxn)
            IndRxns=find(strncmp(mgmodel.rxns,'Host_',length('Host_')));%finding indixes of specific reactions
            mgmodel=coupleRxnList2Rxn(mgmodel,mgmodel.rxns(IndRxns(1:length(mgmodel.rxns(IndRxns(:,1)))-1,1)),['Host_' hostBiomassRxn],400,0); %couple the specific reactions
        end
        
        % finam.name=sampNames{k,1};
        % allmod(k,1)={finam};
        microbiota_model=mgmodel;
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