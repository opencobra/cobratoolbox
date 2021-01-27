function [createdModels] = createPersonalizedModel(abunFilePath, resPath, model, sampName, orglist, patNumb, host, hostBiomassRxn)
% This function creates personalized models from integration of given
% organisms abundances into the previously built global setup. Coupling
% constraints are also added for each organism. All the operations are
% parallelized and the generated personalized models directly saved in .mat
% format.
%
% USAGE:
%
%    [createdModels] = createPersonalizedModel(abunFilePath, resPath, model, sampName, orglist, patNumb)
%
% INPUTS:
%   infoPath:           char with path of directory and file name from where to retrieve abundance information
%   resPath:            char with path of directory where results are saved
%   model:              "global setup" model in COBRA model structure format
%   sampName:           cell array with names of individuals in the study
%   orglist:            cell array with names of organisms in the study
%   patNumb:            number (double) of individuals in the study
%   host:               Contains the host model if path to host modle was
%                       defined. Otherwise empty.
%   hostBiomassRxn:     char with name of biomass reaction in host (default: empty)
%
% OUTPUT:
%   createdModels:   created personalized models
%
% .. Author: Federico Baldini 2017-2018

[ab] = readtable(abunFilePath);
fcol=table2cell(ab(:,1));
if size(fcol,1)>1
    if  ~isa(fcol{2,1},'char')
        fcol=cellstr(num2str(cell2mat(fcol)));
    end
end
spaceColInd=strmatch(' ',fcol);
if length(spaceColInd)>0
    fcol(spaceColInd)=strrep(fcol(spaceColInd),' ','');
end
pIndex=cellstr(num2str((1:height(ab))'));
spaceInd=strmatch(' ',pIndex);
pIndexN=pIndex;
if length(spaceInd)>0
    pIndexN(spaceInd)=strrep(pIndex(spaceInd),' ','');
end
% Adding index column if needed
if isequal(fcol,pIndexN)
    disp('Index fashion input file detected');
else
    disp('Plain csv input format: adding index for internal purposes');
    addIndex=pIndexN;
    ab=horzcat((cell2table(addIndex)),ab);
end
createdModels = {};

% use the setup model containing every strain in every sample
parfor k = 2:(patNumb + 1)
    mgmodel = model
    %   [abundance] = readtable(abunFilePath);
    abundance=ab
    abundance = table2array(abundance(:, k + 1));
    % retrieving current model ID
    id = sampName((k - 1), 1)
    createdModels(k, 1) = id
    mId = strcat('microbiota_model_samp_', id, '.mat');
    
    % Autoload for already created models
    mapP = detectOutput(resPath, mId)
    if isempty(mapP)
        % end of trigger
        idInfo = cell2mat(sampName((k - 1), 1))
        % parsave(sprintf(strcat(idInfo,'%d.mat')),id)
        % code lines to find which  bacteria has abundance of 0
        noab = {};
        abcel = num2cell(abundance);
        abtab = [orglist, abcel];
        cnt = 1;
        for i = 1:length(orglist)
            celabtab = cell2mat(abtab(i, 2));
            if celabtab == 0
                noab(cnt) = abtab(i, 1);
                cnt = cnt + 1;
            end
        end
        noab = noab';
        % Setting to 0 the Exchange reactions of a bacteria whose abundance is 0 in
        % the individual and in the biomass
        for i = 1:length(noab)
            IndRxns = strmatch(noab(i, 1), mgmodel.rxns);  % finding indixes of specific reactions
            RmRxns = mgmodel.rxns(IndRxns);
            mgmodel = removeRxns(mgmodel, RmRxns);
        end
        % Preparing vectors with abundances and bacteria in a way to eliminate the
        % ones not present (abundance =0)
        presBac=setdiff(orglist,noab,'stable');
        abval={};
        index=1;
        for i = 1:length(abundance)
            if ~abundance(i)== 0
                abval(index) = num2cell(abundance(i));
                index=index+1;
            end
        end
        abval=abval';
        abval=cell2mat(abval);
        mgmodel=addMicrobeCommunityBiomass(mgmodel,presBac,abval);
        
        % Coupling constraints for bacteria
        for i = 1:length(presBac)
            IndRxns=strmatch(presBac(i,1),mgmodel.rxns);%finding indixes of specific reactions
            % find the name of biomass reacion in the microbe model
            bioRxn=mgmodel.rxns(find(strncmp(mgmodel.rxns,strcat(presBac(i,1),'_bio'),length(char(strcat(presBac(i,1),'_bio'))))));
            mgmodel=coupleRxnList2Rxn(mgmodel,mgmodel.rxns(IndRxns(1:length(mgmodel.rxns(IndRxns(:,1)))-1,1)),bioRxn,400,0); %couple the specific reactions
        end
        % Coupling constraints for host (optional but recommended)
        if ~isempty(host) && ~isempty(hostBiomassRxn)
            IndRxns=strmatch('Host_',mgmodel.rxns);%finding indixes of specific reactions
            mgmodel=coupleRxnList2Rxn(mgmodel,mgmodel.rxns(IndRxns(1:length(mgmodel.rxns(IndRxns(:,1)))-1,1)),['Host_' hostBiomassRxn],400,0); %couple the specific reactions
        end
        
        % finam.name=sampname((k-1),1);
        % allmod(k,1)={finam};
        microbiota_model=mgmodel;
        microbiota_model.name=sampName((k-1),1);
        idInfo=cell2mat(sampName((k-1),1));
        lw=length(resPath);
        sresPath=resPath(1:(length(resPath)-1));
        cd(sresPath)
        % give a different name if host is present
        if ~isempty(host)
            parsave(sprintf(strcat('host_microbiota_model_samp_',idInfo,'%d.mat')),microbiota_model)
        else
            parsave(sprintf(strcat('microbiota_model_samp_',idInfo,'%d.mat')),microbiota_model)
        end
    else
        s= 'microbiota model file found: skipping model creation for this sample';
        disp(s)
        
    end
end

end
