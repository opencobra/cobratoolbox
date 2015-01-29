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
%resultsDirectory=[cbPath 'papers/Fleming_FR_2015/results/'];

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
    if 0
        load Recon2.v03.mat
        model=modelRecon2beta121114_fixed_updatedID;
    end
    if 1
        load iMM904.mat
    end
    if 0
        load iND750.mat
    end
    if 0
        load iJN746.mat
    end
    if 0
        load L_lactis_MG1363.mat
        model=L_lactis_MG1363;
    end
    
%     [F,R] does not have full row rank for:
%     Model           Rows([F,R]) Rank([F,R])
%     PpaMBEL1254.mat	77	76
%     Recon2betaModel_121114.mat	3157	3154
%     iCac802.mat	521	520
%     iLC915.mat	720	719
%     iMM904.mat	888	886
%     iND750.mat	740	738
%     iRS1563.mat	213	212
%     iSS884.mat	679	678
%     mus_musculus.mat	186	184

    %%%%%%%%%%%
    printLevel=2;
    [rankFR,rankFRV,rankFRvanilla,rankFRVvanilla,model] = checkRankFR(model,printLevel);
    if printLevel>0 && model.FRrowRankDeficiency>0
        if 0
            filePathName=[resultsDirectory filesep 'FRrowDependencies.txt'];
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
    if 1
        %table with summary of results
        %headings
        FRtable=cell(13,2);
        i=1;
        %model
        FRtable{i,1}='';
        i=i+1;
        FRtable{i,1}='# Rank S';
        i=i+1;
        
        %rows
        FRtable{i,1}='# Reactants';
        i=i+1;
        FRtable{i,1}='# Exchange rows';
        i=i+1;
        FRtable{i,1}='# Elementally balanced rows';
        i=i+1;
        FRtable{i,1}='# Stoichiometrially consistent rows';
        i=i+1;
        FRtable{i,1}='# Unique and stoichiometrially consistent rows';
        i=i+1;
        FRtable{i,1}='# Unique stoich. and flux consistent rows of [F,R]';
        i=i+1;
        FRtable{i,1}='# Unique stoich. and flux consistent nonzero rows of [F,R]';
        i=i+1;
        FRtable{i,1}='# Largest connected rows of [F,R]';
        i=i+1;
        FRtable{i,1}='# Rows of proper [F,R]';
        i=i+1;
        FRtable{i,1}='# Rank of proper [F,R]';
        i=i+1;
        FRtable{i,1}='# Rank of vanilla [F,R]';
        i=i+1;
        FRtable{i,1}='# Rows of [Fb,Rb]';
        i=i+1;
        FRtable{i,1}='# Rank of [Fb,Rb]';
        i=i+1;
        
        %cols
        FRtable{i,1}='# Reactions';
        i=i+1;
        FRtable{i,1}='# Exchange cols';
        i=i+1;
        FRtable{i,1}='# Elementally balanced cols';
        i=i+1;
        FRtable{i,1}='# Stoichiometrially consistent cols';
        i=i+1;
        FRtable{i,1}='# Unique and stoichiometrially consistent cols';
        i=i+1;
        FRtable{i,1}='# Unique stoich. and flux consistent cols of [F;R]';
        i=i+1;
        FRtable{i,1}='# Unique stoich. and flux consistent nonzero rows of [F;R]';
        i=i+1;
        FRtable{i,1}='# Largest connected cols of [F;R]';
        i=i+1;
        FRtable{i,1}='# Cols of proper [F;R]';
        i=i+1;
        FRtable{i,1}='# Rank of proper [F;R]';
        i=i+1;
        FRtable{i,1}='# Rank of vanilla [F;R]';
        i=i+1;
        
        i=1;
        %model
        FRtable{i,k+1}='testModel';
        i=i+1;
        FRtable{i,k+1}=results(k).rankS;
        i=i+1;
        
        %rows
        FRtable{i,k+1}=size(results(k).model.S,1);
        i=i+1;
        FRtable{i,k+1}=nnz(~results(k).model.SIntMetBool);
        i=i+1;
        if isfield(results(k).model,'balancedMetBool')
            FRtable{i,k+1}=nnz(results(k).model.balancedMetBool);
        else
            FRtable{i,k+1}=NaN;
        end
        i=i+1;
        FRtable{i,k+1}=nnz(results(k).model.SConsistentMetBool);
        i=i+1;
        FRtable{i,k+1}=nnz((results(k).model.SConsistentMetBool | ~results(k).model.SIntMetBool) & results(k).model.FRuniqueRowBool);
        i=i+1;
        FRtable{i,k+1}=nnz((results(k).model.SConsistentMetBool | ~results(k).model.SIntMetBool) & results(k).model.FRuniqueRowBool & results(k).model.fluxConsistentMetBool);
        i=i+1;
        FRtable{i,k+1}=nnz((results(k).model.SConsistentMetBool | ~results(k).model.SIntMetBool) & results(k).model.FRuniqueRowBool & results(k).model.fluxConsistentMetBool & results(k).model.FRnonZeroRowBool);
        i=i+1;
        FRtable{i,k+1}=nnz(results(k).model.largestConnectedRowsFRBool);
        i=i+1;
        FRtable{i,k+1}=nnz(results(k).model.FRrows);
        i=i+1;
        FRtable{i,k+1}=results(k).rankFR;
        i=i+1;
        FRtable{i,k+1}=results(k).rankFRvanilla;
        i=i+1;
        FRtable{i,k+1}=size(results(k).model.Frb,1);
        i=i+1;
        FRtable{i,k+1}=results(k).model.rankBilinearFrRr;
        i=i+1;
        
        %columns
        FRtable{i,k+1}=size(results(k).model.S,2);
        i=i+1;
        FRtable{i,k+1}=nnz(~results(k).model.SIntRxnBool);
        i=i+1;
        if isfield(results(k).model,'balancedRxnBool')
            FRtable{i,k+1}=nnz(results(k).model.balancedRxnBool);
        else
            FRtable{i,k+1}=NaN;
        end
        i=i+1;
        FRtable{i,k+1}=nnz(results(k).model.SConsistentRxnBool);
        i=i+1;
        FRtable{i,k+1}=nnz((results(k).model.SConsistentRxnBool | ~results(k).model.SIntRxnBool) & results(k).model.FRuniqueColBool);
        i=i+1;
        FRtable{i,k+1}=nnz((results(k).model.SConsistentRxnBool | ~results(k).model.SIntRxnBool) & results(k).model.FRuniqueColBool & results(k).model.fluxConsistentRxnBool);
        i=i+1;
        FRtable{i,k+1}=nnz((results(k).model.SConsistentRxnBool | ~results(k).model.SIntRxnBool) & results(k).model.FRuniqueColBool & results(k).model.fluxConsistentRxnBool & results(k).model.FRnonZeroColBool);
        i=i+1;
        FRtable{i,k+1}=nnz(results(k).model.largestConnectedColsFRVBool);
        i=i+1;
        FRtable{i,k+1}=nnz(results(k).model.FRVcols);
        i=i+1;
        FRtable{i,k+1}=results(k).rankFRV;
        i=i+1;
        FRtable{i,k+1}=results(k).rankFRVvanilla;
        i=i+1;
    end
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
        results=struct();
        save([resultsDirectory resultsFileName],'results');
        for k=1:length(matFiles)
            fprintf('%u\t%s\n',k,matFiles(k).name)
            whosFile=whos('-file',matFiles(k).name);
            if ~strcmp(matFiles(k).name,'clone1.log')
                load(matFiles(k).name);
                model=eval(whosFile.name);
                printLevel=1;
                %%%%
                [rankFR,rankFRV,rankFRvanilla,rankFRVvanilla,model] = checkRankFR(model,printLevel);
                if printLevel>0 && model.FRrowRankDeficiency>0
                    filePathName=[resultsDirectory filesep resultsFileName(1:end-4) '_rowDependencies.txt'];
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
                results(k).modelFilename=matFiles(k).name;
                results(k).rankFR=rankFR;
                results(k).rankFRV=rankFRV;
                results(k).rankS=rankS;
                results(k).model=model;
                results(k).rankFRvanilla=rankFRvanilla;
                results(k).rankFRVvanilla=rankFRVvanilla;
                save([resultsDirectory resultsFileName],'results');
                clear results model;
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
                        
                        load(['~/Dropbox/graphStoich/results/FRresults/' resultsFileName])
                        results(k).modelFilename=matFiles(k).name;
                        results(k).rankFR=rankFR;
                        results(k).rankFRV=rankFRV;
                        results(k).rankS=rankS;
                        results(k).model=model;
                        results(k).rankFRvanilla=rankFRvanilla;
                        results(k).rankFRVvanilla=rankFRVvanilla;
                        save(['~/Dropbox/graphStoich/results/FRresults/' resultsFileName],'results');
                        clear results model;
                    end
                end
            end
        end
    end
    
    if 1
        load([resultsDirectory resultsFileName])
        %table with summary of results
        matFiles=dir(modelCollectionDirectory);
        cd (modelCollectionDirectory)
        
        %extra column and extra row for headings
        FRtable=cell(13,length(results)+1);
        
        i=1;
        %model
        FRtable{i,1}='ModelID';
        i=i+1;
        FRtable{i,1}='# Rank [S S_e]';
        i=i+1;
        
        %rows
        FRtable{i,1}='# Reactants = # Rows of [S S_e]';
        i=i+1;
        FRtable{i,1}='# Exchange reactions = # Rows exclusive to S_e';
        i=i+1;
        FRtable{i,1}='# Elementally balanced rows (given formulae)';
        i=i+1;
        FRtable{i,1}='# Stoich. consistent rows';
        i=i+1;
        FRtable{i,1}='# Unique, stoich. consistent or exchange rows';
        i=i+1;
        FRtable{i,1}='# Unique stoich. and flux consistent rows of [F,R]';
        i=i+1;
        FRtable{i,1}='# Unique stoich. and flux consistent nonzero rows of [F,R]';
        i=i+1;
        FRtable{i,1}='# Largest connected rows of [F,R]';
        i=i+1;
        FRtable{i,1}='# Rows of proper [F,R]';
        i=i+1;
        FRtable{i,1}='# Rank of proper [F,R]';
        i=i+1;
        FRtable{i,1}='# Rank of vanilla [F,R]';
        i=i+1;
        FRtable{i,1}='# Rows of [Fb,Rb]';
        i=i+1;
        FRtable{i,1}='# Rank of [Fb,Rb]';
        i=i+1;
        %cols
        FRtable{i,1}='# Reactions = # Cols of [S S_e]';
        i=i+1;
        FRtable{i,1}='# Exchange cols = # Cols of S_e';
        i=i+1;
        FRtable{i,1}='# Elementally balanced cols';
        i=i+1;
        FRtable{i,1}='# Stoichiometrially consistent cols';
        i=i+1;
        FRtable{i,1}='# Unique and stoichiometrially consistent cols';
        i=i+1;
        FRtable{i,1}='# Unique stoich. and flux consistent cols of [F;R]';
        i=i+1;
        FRtable{i,1}='# Unique stoich. and flux consistent nonzero rows of [F;R]';
        i=i+1;
        FRtable{i,1}='# Largest connected cols of [F;R]';
        i=i+1;
        FRtable{i,1}='# Cols of proper [F;R]';
        i=i+1;
        FRtable{i,1}='# Rank of proper [F;R]';
        i=i+1;
        FRtable{i,1}='# Rank of vanilla [F;R]';
        i=i+1;
        
        for k=1:length(results)
            i=1;
            %model
            if 0
                FRtable{i,k+1}=whos('-file',matFiles(k).name);
            else
                FRtable{i,k+1}=results(k).modelFilename;
            end
            i=i+1;
            FRtable{i,k+1}=results(k).rankS;
            i=i+1;
            
            %rows
            FRtable{i,k+1}=size(results(k).model.S,1);
            i=i+1;
            FRtable{i,k+1}=nnz(~results(k).model.SIntMetBool);
            i=i+1;
            if isfield(results(k).model,'balancedMetBool')
                FRtable{i,k+1}=nnz(results(k).model.balancedMetBool);
            else
                FRtable{i,k+1}=NaN;
            end
            i=i+1;
            FRtable{i,k+1}=nnz(results(k).model.SConsistentMetBool);
            i=i+1;
            FRtable{i,k+1}=nnz((results(k).model.SConsistentMetBool | ~results(k).model.SIntMetBool) & results(k).model.FRuniqueRowBool);
            i=i+1;
            FRtable{i,k+1}=nnz((results(k).model.SConsistentMetBool | ~results(k).model.SIntMetBool) & results(k).model.FRuniqueRowBool & results(k).model.fluxConsistentMetBool);
            i=i+1;
            FRtable{i,k+1}=nnz((results(k).model.SConsistentMetBool | ~results(k).model.SIntMetBool) & results(k).model.FRuniqueRowBool & results(k).model.fluxConsistentMetBool & results(k).model.FRnonZeroRowBool);
            i=i+1;
            FRtable{i,k+1}=nnz(results(k).model.largestConnectedRowsFRBool);
            i=i+1;
            FRtable{i,k+1}=nnz(results(k).model.FRrows);
            i=i+1;
            FRtable{i,k+1}=results(k).rankFR;
            i=i+1;
            FRtable{i,k+1}=results(k).rankFRvanilla;
            i=i+1;
            FRtable{i,k+1}=size(results(k).model.Frb,1);
            i=i+1;
            FRtable{i,k+1}=results(k).model.rankBilinearFrRr;
            i=i+1;
            %columns
            FRtable{i,k+1}=size(results(k).model.S,2);
            i=i+1;
            FRtable{i,k+1}=nnz(~results(k).model.SIntRxnBool);
            i=i+1;
            if isfield(results(k).model,'balancedRxnBool')
                FRtable{i,k+1}=nnz(results(k).model.balancedRxnBool);
            else
                FRtable{i,k+1}=NaN;
            end
            i=i+1;
            FRtable{i,k+1}=nnz(results(k).model.SConsistentRxnBool);
            i=i+1;
            FRtable{i,k+1}=nnz(results(k).model.fluxConsistentRxnBool);
            i=i+1;
            FRtable{i,k+1}=nnz(results(k).model.FRnonZeroColBool);
            i=i+1;
            FRtable{i,k+1}=nnz(results(k).model.FRuniqueColBool);
            i=i+1;
            FRtable{i,k+1}=nnz(results(k).model.largestConnectedColsFRVBool);
            i=i+1;
            FRtable{i,k+1}=nnz(results(k).model.FRVcols);
            i=i+1;
            FRtable{i,k+1}=results(k).rankFRV;
            i=i+1;
            FRtable{i,k+1}=results(k).rankFRVvanilla;
            i=i+1;
        end
        save([resultsDirectory resultsFileName],'results','resultsFileName','FRtable');
    end
    fprintf(['%s\n','checkRankFRdriver complete. Results saved to ' resultsDirectory resultsFileName])
end


