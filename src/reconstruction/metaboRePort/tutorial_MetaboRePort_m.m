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


evalc('generateMemoteLikeReport(modelProperties,reportDir)');

%%