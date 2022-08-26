%%
% MetaboRePort:



load('C:\Users\0123322S\Desktop\X\met_strc_rBioNet_new_30_06_2022.mat')
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

% generate missing metaboReports for existing updated annotated models
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

if 1
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
%%