clear
beep on

%parameters
cbPath=which('initCobraToolbox');
cbPath=cbPath(1:end-length('initCobraToolbox.m'));

%model directory
%modelCollectionDirectory=[cbPath 'SystemsPhysiologyGroup/modelCollection/'];
%modelCollectionDirectory=[cbPath 'testing/testModels/AliEbrahim/'];
modelCollectionDirectory='/home/rfleming/Dropbox/graphStoich/data/modelCollectionFR';

%results directory
resultsDirectory='/home/rfleming/Dropbox/graphStoich/results/FRresults/';
cd(resultsDirectory)

if 0
    %single model
    if 0
        load ecoli_core_xls2model.mat
        model=findSExRxnInd(model);
    end
    if 0
        load Ecoli_core.mat
        model=findSExRxnInd(model);
    end
    if 0
        load TLR_Maike_20110616Recon.mat
        model=TLR_Maike_20110616Recon;
    end
    if 0
        load iAF1260.mat
        model=iAF1;
    end
    if 0
        load K_pneumonieae_rBioNet.mat
        model=K_pneumonieae_rBioNet;
    end
    if 0
        load cardiac_mit_glcuptake_atpmax.mat
        model=modelCardioMito;
    end
    if 0
        addpath(genpath('~/Dropbox/graphStoich/data/modelCollectionBig'));
        load ME_matrix_GlcAer_WT.mat
        model=modelGlcOAer_WT;
    end
    if 0
        load iexGF_MM_BT.mat
        model=modelJointLU;
    end
    if 0
        load iRS1563.mat
    end
    if 0
        load Recon2betaModel_121114.mat
        model=modelRecon2beta121114;
    end
    if 1
        load Recon205_20150128.mat
    end
    if 0
        load Recon2.v03.mat
        model=modelRecon2beta121114_fixed_updatedID;
    end
    if 0
        load iMM904.mat
    end
    if 0
        load iND750.mat
    end
    if 1
        load iNJ661.mat
    end
    if 0
        load L_lactis_MG1363.mat
        model=L_lactis_MG1363;
    end
        
    %%%%%%%%%%%
    printLevel=2;
    [rankFR,rankFRV,rankFRvanilla,rankFRVvanilla,model] = checkRankFR(model,printLevel);
    if printLevel>0 && model.FRrowRankDeficiency>0
        if 0
            filePathName=[resultsDirectory  'FRrowDependencies.txt'];
            printFRdependencies(model,filePathName);
        else
            printFRdependencies(model);
        end
    end
    %%%%%%%%%%%%%
    
    %rank of S
    [rankS,p,q]= getRankLUSOL(model.S);
    
    k=1;
    results(k).rankS=rankS;
    results(k).rankFR=rankFR;
    results(k).rankFRV=rankFRV;
    results(k).rankFRvanilla=rankFRvanilla;
    results(k).rankFRVvanilla=rankFRVvanilla;
    results(k).model=model;
    results(k).modelID='testModel';
    
    %results filename timestamped
    resultsFileName=['FRresults_' datestr(now,30) '.mat'];
    save([resultsDirectory resultsFileName],'FRresults');
else
    %batch of models in .mat format in a directory
    %assumes that each .mat file is a model
    matFiles=dir(modelCollectionDirectory);
    matFiles.name;
    
    %get rid of entries that do not have a .mat suffix
    bool=false(length(matFiles),1);
    for k=3:length(matFiles)
        if strcmp(matFiles(k).name(end-3:end),'.mat')
            bool(k)=1;
        end
    end
    matFiles=matFiles(bool);
    %     matFiles.name
    
    %results filename timestamped
    resultsFileName=['FRresults_' datestr(now,30) '.mat'];
    
    if 0
        %checks if the models can be loaded and if some exchange reactions
        %can be identified
        for k=1:length(matFiles)
            disp(k)
            disp(matFiles(k).name)
            whosFile=whos('-file',matFiles(k).name);
            if ~strcmp(matFiles(k).name,'clone1.log')
                load(matFiles(k).name);
                model=eval(whosFile.name);
                model=findSExRxnInd(model);
                printLevel=1;
            end
        end
    end
    
    if 1
        cd(modelCollectionDirectory)
        FRresults=struct();
        %FRresults.matFiles=matFiles;
        save([resultsDirectory resultsFileName],'FRresults');
        for k=1:length(matFiles)
            FRresults(k).matFile=matFiles(k);
            fprintf('%u\t%s\n',k,matFiles(k).name)
            whosFile=whos('-file',matFiles(k).name);
            if ~strcmp(matFiles(k).name,'clone1.log')
                load(matFiles(k).name);
                model=eval(whosFile.name);
                printLevel=1;
                %%%%
                [rankFR,rankFRV,rankFRvanilla,rankFRVvanilla,model] = checkRankFR(model,printLevel);
                if printLevel>0 && model.FRrowRankDeficiency>0
                    filePathName=[resultsDirectory  resultsFileName(1:end-4) '_rowDependencies.txt'];
                    fileID = fopen(filePathName,'a');
                    fprintf(fileID,'%s\n',matFiles(k).name)
                    fclose(fileID);
                    printFRdependencies(model,filePathName);
                    fileID = fopen(filePathName,'a');
                    fprintf(fileID,'%s\n','-------------------------------')
                    fclose(fileID);
                end
                %%%%
                [rankS,p,q]= getRankLUSOL(model.S);
                
                load([resultsDirectory resultsFileName])
                FRresults(k).modelFilename=matFiles(k).name;
                tmp=FRresults(k).modelFilename;
                FRresults(k).modelID=tmp(1:end-4);%take off .mat
                FRresults(k).rankFR=rankFR;
                FRresults(k).rankFRV=rankFRV;
                FRresults(k).rankS=rankS;
                FRresults(k).model=model;
                FRresults(k).rankFRvanilla=rankFRvanilla;
                FRresults(k).rankFRVvanilla=rankFRVvanilla;
                save([resultsDirectory resultsFileName],'FRresults');
                clear FRresults model;
                if strcmp(matFiles(k).name(end-2:end),'mat')
                    fprintf('%u\t%s\n',k,matFiles(k).name)
                    whosFile=whos('-file',matFiles(k).name);
                    if ~strcmp(matFiles(k).name,'clone1.log')
                        load(matFiles(k).name);
                        model=eval(whosFile.name);
                        printLevel=1;
                        %%%%
                        [rankFR,rankFRV,rankFRvanilla,rankFRVvanilla,model] = checkRankFR(model,printLevel);
                        %%%%
                        [rankS,p,q]= getRankLUSOL(model.S);
                        
                        load([resultsDirectory resultsFileName])
                        FRresults(k).modelFilename=matFiles(k).name;
                        FRresults(k).rankFR=rankFR;
                        FRresults(k).rankFRV=rankFRV;
                        FRresults(k).rankS=rankS;
                        FRresults(k).model=model;
                        FRresults(k).rankFRvanilla=rankFRvanilla;
                        FRresults(k).rankFRVvanilla=rankFRVvanilla;
                        save([resultsDirectory resultsFileName],'FRresults');
                        clear FRresults model;
                    end
                end
            end
        end
    end
    save([resultsDirectory resultsFileName],'FRresults','resultsFileName');
end
fprintf(['%s\n','checkRankFRdriver complete. FRresults saved to ' resultsDirectory resultsFileName]);







