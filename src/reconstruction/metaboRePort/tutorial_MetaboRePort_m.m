%%
% MetaboRePort:

%% correct CheBI ID's in rBionet metabolite_structure
if 0
    load('C:\Users\0123322S\Desktop\X\met_strc_rBioNet_new_30_06_2022.mat')
    F = fieldnames(metabolite_structure_rBioNet);
    % reset chebiid
    for i = 1 : length(F)
        if strcmp(metabolite_structure_rBioNet.(F{i}).cheBIId,'1')
            metabolite_structure_rBioNet.(F{i}).cheBIId = NaN;
        end
    end
    % search hmdb for all chebi ids missing
    metabolite_structure_rBioNet2 = metabolite_structure_rBioNet;
    for i = 1 : length(F)
        if isnan(metabolite_structure_rBioNet2.(F{i}).cheBIId)
            [metabolite_structure_rBioNet2,IDsAddedHMDB,IDsMismatchHMDB] = parseHmdbWebPage(metabolite_structure_rBioNet2,i,i);
            i
            metabolite_structure_rBioNet2.(F{i}).cheBIId
        end
    end
    metabolite_structure_rBioNet = metabolite_structure_rBioNet2;
    save('C:\Users\0123322S\Desktop\X\met_strc_rBioNet_new_18_10_22.mat','metabolite_structure_rBioNet')
end

%% creating the files from scratch
load('C:\Users\0123322S\Desktop\X\met_strc_rBioNet_new_18_10_22.mat')
%folder = 'C:\Users\0123322S\Downloads\AGORA2_mat_files\AGORA2_mat_files\AGORA2_mat_files_1\';
folder = 'C:\Users\0123322S\Dropbox\MY PAPERS\SUBMITTED\Submitted\AGORA2\NatureBiotech\resubmission\AGORA2_recreated\';
%folderUpdated = 'C:\Users\0123322S\Downloads\AGORA2_mat_files\AGORA2_mat_files\AGORA2_mat_files_1\';
folderUpdated = 'C:\Users\0123322S\Dropbox\MY PAPERS\SUBMITTED\Submitted\AGORA2\NatureBiotech\resubmission\AGORA2_recreated\AGORA2_annotated\';
%reportDir = 'C:\Users\0123322S\Documents\GitHub\MetaboRePort\reports';
reportDir = 'C:\Users\0123322S\Dropbox\MY PAPERS\SUBMITTED\Submitted\AGORA2\NatureBiotech\resubmission\AGORA2_recreated\AGORA2_annotated\metaboRePorts\';

dInfo=dir(folder);
modelList={dInfo.name};
modelList=modelList';
modelList(~contains(modelList(:,1),'.mat'),:)=[];

dInfoUpdated=dir(folderUpdated);
modelListUpdated={dInfoUpdated.name};
modelListUpdated=modelListUpdated';

dInfoReport=dir(reportDir);
modelListReport={dInfoReport.name};
modelListReport=modelListReport';

if 0
    tic;
    cnt = 1
    for i = s : e%length(modelList)
        i
        if isempty(find(ismember(modelListUpdated,modelList{i})))
            load(strcat(folder, modelList{i}));
            %[modelProp1,ScoresOverall1] = generateMemoteLikeScore(model);
            [modelUpdated] = populateModelMetStr(model, metabolite_structure_rBioNet,1);
            [modelUpdated] = annotateSBOTerms(modelUpdated);
            modelUpdated = rmfield(modelUpdated,'metInChIString'); % wrongly in microbe models
            
            [modelUpdated] = populateModelwithRxnIDs(modelUpdated);
            try
                [modelProp2,ScoresOverall2] = generateMetaboScore(modelUpdated);
                
                modelProperties.(regexprep(modelList{i},'.mat','')).ScoresOverall = ScoresOverall2;
                modelProperties.(regexprep(modelList{i},'.mat','')).modelUpdated = modelUpdated;
                modelProperties.(regexprep(modelList{i},'.mat','')).modelProp2 = modelProp2;
                ScoresOverall{i,1} = regexprep(modelList{i},'.mat','');
                ScoresOverall{i,2} = num2str(ScoresOverall2);
                % if mod(i,10)
                save(strcat(reportDir,'AGORA2_MetaboRePorts_',modelList{i}),'modelProperties','ScoresOverall');
                clear modelProperties
                %  end
                %% save updated mat file
            catch
                modelList{i}
                missing{cnt,1} = modelList{i};
                cnt = cnt + 1;
            end
            model =modelUpdated;
            save(strcat(folderUpdated,modelList{i}),'model');
            %     %%generate sbml file
            %     %remove description from model structure as this causes issues
            %
            %     modelUpdated = rmfield(modelUpdated,'description');
            %     fileName = regexprep(modelList{i},'.mat','');
            %     if isempty(find(ismember(modelListUpdated,strcat(fileName,'.xml'))))
            %         outmodel = writeCbModel(modelUpdated, 'format','sbml', 'fileName', strcat(folderUpdated,'',fileName));
            %     end
        end
    end
    toc;
    save('AGORA2_MetaboRePorts_ScoresOverall.mat','ScoresOverall');
    
end

%% generate missing metaboReports for existing updated annotated models
if 0
    tic;
    cnt = 1
    for i = s : e%length(modelList)
        i
        modelListReport = regexprep(modelListReport,'AGORA2_MetaboRePorts_','');
        if isempty(find(ismember(modelListReport,modelList{i})))
            load(strcat(folderUpdated, modelList{i}));
            try
                [modelProp2,ScoresOverall2] = generateMetaboScore(model);
                
                modelProperties.(regexprep(modelList{i},'.mat','')).ScoresOverall = ScoresOverall2;
                modelProperties.(regexprep(modelList{i},'.mat','')).modelUpdated = model;
                modelProperties.(regexprep(modelList{i},'.mat','')).modelProp2 = modelProp2;
                ScoresOverall{i,1} = regexprep(modelList{i},'.mat','');
                ScoresOverall{i,2} = num2str(ScoresOverall2);
                % if mod(i,10)
                save(strcat(reportDir,'AGORA2_MetaboRePorts_',modelList{i}),'modelProperties','ScoresOverall');
                clear modelProperties
                %  end
                %% save updated mat file
            catch
                modelList{i}
                missing{cnt,1} = modelList{i};
                cnt = cnt + 1;
            end
            
            %     %%generate sbml file
            %     %remove description from model structure as this causes issues
            %
            %     modelUpdated = rmfield(modelUpdated,'description');
            %     fileName = regexprep(modelList{i},'.mat','');
            %     if isempty(find(ismember(modelListUpdated,strcat(fileName,'.xml'))))
            %         outmodel = writeCbModel(modelUpdated, 'format','sbml', 'fileName', strcat(folderUpdated,'',fileName));
            %     end
        end
    end
    toc;
end

if 0
    % get all the report m files
    dInfoReport=dir(reportDir);
    modelListReport={dInfoReport.name};
    modelListReport=modelListReport';
    
    cnt = 1;
    for i = s :e% length(modelListReport)
        report = regexprep(modelListReport{i},'\.mat','\.html');
        report = regexprep(report,'AGORA2_MetaboRePorts_','modelreport_');
        i
        if ~isempty(strfind(modelListReport{i},'.mat')) && isempty(find(ismember(modelListReport,report)))
            load(strcat(reportDir,filesep,modelListReport{i}))
            orgName{1} = regexprep(modelListReport{i},'\.html','');
            orgName{1} = regexprep(orgName{1},'AGORA2_MetaboRePorts_','');
            evalc('generateMetaboReport(modelProperties,reportDir,orgName)');
            % get scores
            report
            F = fieldnames(modelProperties);
            ScoresAll(cnt,1) = modelProperties.(F{1}).modelProp2.Scores.Consistency;
            ScoresAll(cnt,2) = modelProperties.(F{1}).modelProp2.Scores.AnnotationMetabolites;
            ScoresAll(cnt,3) = modelProperties.(F{1}).modelProp2.Scores.AnnotationReactions;
            ScoresAll(cnt,4) = modelProperties.(F{1}).modelProp2.Scores.AnnotationGenes;
            ScoresAll(cnt,5) = modelProperties.(F{1}).modelProp2.Scores.AnnotationSBO;
            ScoresAll(cnt,6) = modelProperties.(F{1}).modelProp2.Scores.Overall;
            cnt = cnt +1;
        end
    end
end
%% updating only Chebii id's in the files
load('C:\Users\0123322S\Desktop\X\met_strc_rBioNet_new_18_10_22.mat')

folder = 'C:\Users\0123322S\Dropbox\MY PAPERS\SUBMITTED\Submitted\AGORA2\NatureBiotech\resubmission\AGORA2_recreated\';
%folderUpdated = 'C:\Users\0123322S\Downloads\AGORA2_mat_files\AGORA2_mat_files\AGORA2_mat_files_1\';
folderUpdated = 'C:\Users\0123322S\Dropbox\MY PAPERS\SUBMITTED\Submitted\AGORA2\NatureBiotech\resubmission\AGORA2_recreated\AGORA2_annotated\';
folderUpdatedNew = 'C:\Users\0123322S\Dropbox\MY PAPERS\SUBMITTED\Submitted\AGORA2\NatureBiotech\resubmission\AGORA2_recreated\AGORA2_annotatedNew\';
folderUpdatedNewSBML = 'C:\Users\0123322S\Dropbox\MY PAPERS\SUBMITTED\Submitted\AGORA2\NatureBiotech\resubmission\AGORA2_recreated\AGORA2_annotatedNewSBML\';

%reportDir = 'C:\Users\0123322S\Documents\GitHub\MetaboRePort\reports';
reportDir = 'C:\Users\0123322S\Dropbox\MY PAPERS\SUBMITTED\Submitted\AGORA2\NatureBiotech\resubmission\AGORA2_recreated\AGORA2_annotated\metaboRePorts\';

dInfo=dir(folder);
modelList={dInfo.name};
modelList=modelList';
modelList(~contains(modelList(:,1),'.mat'),:)=[];

dInfoUpdated=dir(folderUpdated);
modelListUpdated={dInfoUpdated.name};
modelListUpdated=modelListUpdated';


dInfoUpdatedSBML=dir(folderUpdatedNewSBML);
modelListUpdatedSBML={dInfoUpdatedSBML.name};
modelListUpdatedSBML=modelListUpdatedSBML';

dInfoReport=dir(reportDir);
modelListReport={dInfoReport.name};
modelListReport=modelListReport';

if 1
    tic;
    Fori = fieldnames(metabolite_structure_rBioNet);
    F = regexprep(Fori,'VMH_','');
    for i =  s: e%length(modelListUpdated)
        i
        
        dInfoUpdatedSBML=dir(folderUpdatedNewSBML);
        modelListUpdatedSBML={dInfoUpdatedSBML.name};
        modelListUpdatedSBML=modelListUpdatedSBML';
        modelName = regexprep(modelListUpdated{i},'.mat','');
        
        if ~isempty(strfind(strcat(folderUpdated, modelListUpdated{i}),'.mat')) && isempty(strmatch(strcat(modelName,'.xml'),modelListUpdatedSBML))
            i
            % load annotated model
            load(strcat(folderUpdated, modelListUpdated{i}));
            for k = 1 : length(model.mets)
                % replace metChEBIID
                met = split(model.mets{k},'[');
                if strcmp('sertrna(sec)',met{1}) % replace the abbr of this metabolite
                    met{1} = 'sertrna';
                end
                match = strmatch(met{1},F,'exact');
                if length(find(isnan(metabolite_structure_rBioNet.(Fori{match}).cheBIId)))==0 && ~isempty(metabolite_structure_rBioNet.(Fori{match}).cheBIId)
                    model.metChEBIID{k} = strcat('CHEBI:',metabolite_structure_rBioNet.(Fori{match}).cheBIId);
                end
            end
            % annotate model properties correctly

            model.modelName = regexprep(modelName,'_',' ');
            model.modelID = modelName;
            model.modelAnnotation = {model.modelID;...
                'version 2.0';...
                strcat('Created: ',model.description.date)
                'Molecular Systems Physiology Group, University of Galway, Ireland. https://thielelab.eu';...
                strcat('This is a metabolism reconstruction of:', model.modelName);...
                'The draft reconstruction was created using Kbase/ModelSeed and refined with the DEMETER pipeline from the COBRA toolbox v3';...
                'When using or adapting this reconstruction, please cite:';...
                'Heinken, A., Hertel, J., Acharya, G., Ravcheev, D.A., Nyga, M., Okpala, O.E., Hogan, M., Magnusdottir, S., Martinelli, F., Nap, B., Preciat, G., Edirisinghe, J.N., Henry, C.S., Fleming, R.M.T., Thiele, I., "AGORA2: Knowledge-driven genome-scale reconstruction of 7,302 human microbes for personalised medicine", Nat Biotech, accepted (2022), https://doi.org/10.1101/2020.11.09.375451.';...
                'Obtained from https://vmh.life/';...
                };
            model = rmfield(model,'description');
            model.description = modelName;
            
            save(strcat(folderUpdatedNew, modelListUpdated{i}),'model');
            
            %%generate sbml file
            %remove description from model structure as this causes issues
            
            if isempty(find(ismember(modelListUpdatedSBML,strcat(modelName,'.xml'))))
                outmodel = writeCbModel(model, 'format','sbml', 'fileName', strcat(folderUpdatedNewSBML,'',modelName));
            end
            clear outmodel model 
        end
    end
end