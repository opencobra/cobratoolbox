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
finalFolder='/modelCollectionFR';

%choose model & results directories
resultsDirectory=[cbPath 'papers/Fleming_FR_2015/results/'];

%citations data for models tested
modelMetaData=modelCitations();

%Choose the printLevel
printLevel=0;

%input data
modelCollectionDirectory=[cbPath 'testing/testModels/modelCollectionFR/'];
%modelCollectionDirectory=['~/work/ownCloud/programReconstruction/projects/AGORA/data' finalFolder];
%temporary results location
tempResultsDirectory=['~/work' finalFolder];
%final results location
finalResultsDirectory=['~/work/ownCloud/programReconstruction/projects/AGORA/results' finalFolder];

resultsFileName=[finalResultsDirectory finalFolder '_FRresults_' datestr(now,30) '.mat'];

%choose solver
solver='gurobi6';
solverOK = changeCobraSolver(solver,'LP');

%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(tempResultsDirectory)

if ~exist(tempResultsDirectory,'dir')
    mkdir(tempResultsDirectory)
end
if ~exist(finalResultsDirectory,'dir')
    mkdir(finalResultsDirectory)
end

%by default, it will run all models in modelCollectionDirectory, but here
%you can set it up to run only one model
if 1
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
    
    %save results individually for each model
    cd(modelCollectionDirectory);
    
    for k=1:length(matFiles)
        resultsFileNamePrefix='FRresults_';
        %create the results structure
        FRresult=struct();
        FRresult.matFile=matFiles(k);
        fprintf('%u\t%s\n',k,matFiles(k).name)
        whosFile=whos('-file',matFiles(k).name);
        FRresult.modelFilename=matFiles(k).name;
        tmp=FRresult.modelFilename;
        FRresult.modelID=tmp(1:end-4);%take off .mat
        
        %load the input data
        load(matFiles(k).name);
        model=eval(whosFile.name);
        
        %maximum and minimim magnitude stoichiometric coefficient
        FRresult.maxSij=norm(model.S,inf);
        FRresult.minSij=min(min(abs(model.S)));
        
        %%%%
        [rankFR,rankFRV,rankFRvanilla,rankFRVvanilla,model] = checkRankFR(model,printLevel);
        if printLevel>0 && model.FRrowRankDeficiency>0
            filePathName=[tempResultsDirectory  filesep resultsFileNamePrefix FRresult.modelID '_rowDependencies.txt'];
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
        FRresult.rankFR=rankFR;
        FRresult.rankFRV=rankFRV;
        FRresult.rankS=rankS;
        FRresult.model=model;
        FRresult.rankFRvanilla=rankFRvanilla;
        FRresult.rankFRVvanilla=rankFRVvanilla;
        save([tempResultsDirectory filesep resultsFileNamePrefix FRresult.modelID '.mat'],'FRresult');
        clear FRresult model;
    end
    
end

%find the names of each FRresult .mat file
FRmatFiles=dir(tempResultsDirectory);
FRmatFiles.name;
%get rid of entries that do not have a .mat suffix
bool=false(length(FRmatFiles),1);
for k=3:length(FRmatFiles)
    if strcmp(FRmatFiles(k).name(end-3:end),'.mat')
        bool(k)=1;
    end
end
FRmatFiles=FRmatFiles(bool);

%FR results structure
FRresults=struct();
for k=1:length(FRmatFiles)
    load([tempResultsDirectory filesep FRmatFiles(k).name])
    tmp=strrep(FRmatFiles(k).name,'FRresult_','');
    fprintf('%u\t%s\n',k,tmp(1:end-4))
    FRresults(k).matFile=FRresult.matFile;
    FRresults(k).modelFilename=FRresult.modelFilename;
    FRresults(k).modelID=FRresults(k).modelFilename(1:end-4);%take off .mat
    FRresults(k).rankFR=FRresult.rankFR;
    FRresults(k).rankFRV=FRresult.rankFRV;
    FRresults(k).rankS=FRresult.rankS;
    FRresults(k).model=FRresult.model;
    FRresults(k).rankFRvanilla=FRresult.rankFRvanilla;
    FRresults(k).rankFRVvanilla=FRresult.rankFRVvanilla;
    FRresults(k).maxSij=FRresult.maxSij;
    FRresults(k).minSij=FRresult.minSij;
end

save(resultsFileName,'FRresults');
fprintf('%s\n',['checkRankFRdriver complete. FRresults saved to ' resultsFileName]);

%citations about each model
if exist('modelMetaData','var')
    [FRresultsTable,FRresults]=makeFRresultsTable([],resultsDirectory,resultsFileName,modelMetaData);
else
    [FRresultsTable,FRresults]=makeFRresultsTable([],resultsDirectory,resultsFileName);
end
%save([resultsDirectory resultsFileName],'FRresults','resultsFileName');

fprintf('%s\n',['checkRankFRdriver complete. FRresults saved to ' resultsDirectory resultsFileName]);







