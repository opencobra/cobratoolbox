%checkRankFRdriver.m
%Code to reproduce the results reported in:
%'Conditions for duality between fluxes and concentrations in biochemical networks
%by Ronan M.T. Fleming^{1}ronan.mt.fleming@gmail.com, Nikos Vlassis^{2}, Ines Thiele^{1}, Michael A. Saunders^{3}
%{1} Luxembourg Centre for Systems Biomedicine, University of Luxembourg, 7 avenue des Hauts-Fourneaux, Esch-sur-Alzette, Luxembourg.
%{2} Adobe Research, 345 Park Ave, San Jose, CA, USA.
%{3} Dept of Management Science and Engineering, Stanford University, Stanford, CA, USA.
 
%REQUIRED:
%Install The COBRA toolbox
%1. git clone https://github.com/opencobra/cobratoolbox.git
%2. initCobraToolbox
%Install a linear optimization solver 
% e.g. www.gurobi.com
%Change The COBRA toolbox solver to gurobi
% changeCobraSolver(solver,'LP')

%OPTIONAL:
% It is faster if you have the LU solver 'lusol' compiled and installed
% correctly, otherwise matlab's LU solver is used.
% https://github.com/nwh/lusol

clear
beep on

%parameters
cbPath=which('initCobraToolbox');
cbPath=cbPath(1:end-length('initCobraToolbox.m'));

%choose model & results directories
modelCollectionDirectory=[cbPath 'testing/testModels/modelCollectionFR/'];
resultsDirectory=[cbPath 'papers/Fleming_FR_2015/results/'];

%choose solver
solver='gurobi6';
solverOK = changeCobraSolver(solver,'LP');

%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(resultsDirectory)

%by default, it will run all models in modelCollectionDirectory, but here
%you can set it up to run only one model
if 0
    %load single model
    if 1
        modelID='Ecoli_core.mat';
        load([modelCollectionDirectory modelID])
    end
    if 0
        modelID='iBsu1103.mat';
        load([modelCollectionDirectory modelID])
    end
    if 0
        modelID='iAI549.mat';
        load([modelCollectionDirectory modelID])
    end
    if 0
        modelID='iMM904.mat';
        load([modelCollectionDirectory modelID])
    end
    if 0
        modelID='Recon205_20150128.mat';
        load([modelCollectionDirectory modelID])
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
    %maximum and minimim magnitude stoichiometric coefficient
    FRresults(k).maxSij=norm(model.S,inf);
    FRresults(k).minSij=min(min(abs(model.S)));
                
    FRresults(k).rankS=rankS;
    FRresults(k).rankFR=rankFR;
    FRresults(k).rankFRV=rankFRV;
    FRresults(k).rankFRvanilla=rankFRvanilla;
    FRresults(k).rankFRVvanilla=rankFRVvanilla;
    FRresults(k).model=model;
    FRresults(k).modelID=modelID;
   
   if ~exist('modelMetaData','var')
        modelMetaData={'testModel','testModel',FRresults(k).modelID,'testModel','testModel'};
   end
    [FRresultsTable,FRresults]=makeFRresultsTable(FRresults);
    
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
                
                %maximum and minimim magnitude stoichiometric coefficient
                FRresults(k).maxSij=norm(model.S,inf);
                FRresults(k).minSij=min(min(abs(model.S)));
                
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
                        FRresults(k).FBAsolution=FBAsolution;
                        FRresults(k).modelFilename=matFiles(k).name;
                        FRresults(k).rankFR=rankFR;
                        FRresults(k).rankFRV=rankFRV;
                        FRresults(k).rankS=rankS;
                        FRresults(k).model=model;
                        FRresults(k).rankFRvanilla=rankFRvanilla;
                        FRresults(k).rankFRVvanilla=rankFRVvanilla;
                        FRresults(k).coherenceS=matrixCoherence(model.S);

                        save([resultsDirectory resultsFileName],'FRresults');
                        clear FRresults model;
                    end
                end
            end
        end
    end
    
    %citations about each model
    if ~exist('modelMetaData','var')
        modelMetaData=modelCitations();
    end
    [FRresultsTable,FRresults]=makeFRresultsTable([],resultsDirectory,resultsFileName,modelMetaData);
    %save([resultsDirectory resultsFileName],'FRresults','resultsFileName');
end
fprintf('%s\n',['checkRankFRdriver complete. FRresults saved to ' resultsDirectory resultsFileName]);







