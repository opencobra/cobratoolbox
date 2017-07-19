function results = testModelsAlgorithmically(solvers,matFolder,modelNames,printLevel)
%test a set of models for the feasibility of a nonzero objective(>1e-4)
%by default, do not run this script with testAll
%
%OPTIONAL INPUT
% solvers       z x 1 cell array of solvers to test e.g. {'gurobi5','quadMinos'}
% matFolder     absolute path to the folder where k model .mat files are
% modelNames    k x 2 cell array of {Species, modelFilename} setting order
%               of results structure when returned
%               e.g. modelNames={...
%                    'Lactococcus lactis','LLACTIS';
%                    'Mus musculus','iMM302'};
%
%printLevel    {(0),1} choose the amount to be printed to screen
%
%OUTPUT
% results      k x (2 + z) cell array of results

% 39 Jan 2016 Ronan M.T. Fleming

global CBT_LP_SOLVER
if 1
    %%parameters
    
    %select solver to use
    if ~exist('solvers','var')
        if ~isunix || ismac
            solvers={CBT_LP_SOLVER};
        else
            [status,cmdout]=system('which minos');
            if isempty(cmdout)
                [status,cmdout]=system('echo $PATH');
                disp(cmdout);
                warning('Minos not installed or not on system path.');
            else
                solvers={CBT_LP_SOLVER,'dqqMinos'};
            end
        end
        
        %gurobi (http://www.gurobi.com/) gurboi versions 5 and 6 are supported
        %solvers={'gurobi6'};
        %optionally also test with quadMinos (a quadruple precision solver by Michael Saunders, Stanford Systems Optimization Laboratory)
        %solvers={'gurobi6','dqqMinos'};
        solvers={'dqqMinos'};
    end
        
    pth=which('initCobraToolbox.m');
    global CBTDIR
    CBTDIR = pth(1:end-(length('initCobraToolbox.m')+1));
    
    if ~exist('matFolder','var')
        matFolder=pwd;
        % set the folder within the folder 'testModels' where the .xml files are located
        %matFolder=[CBTDIR '/testing/testModels/m_model_collection_mat']; %selection of mat files already parsed from https://github.com/opencobra/m_model_collection.git'
        %matFolder=['/usr/local/bin/cobratoolbox_master' '/testing/testModels/m_model_collection_mat'];
        %matFolder=[CBTDIR '/testing/testModels/testedModels'];
        %matFolder=[CBTDIR '/testing/testModels/testBiGG'];
        %matFolder='~/Dropbox/modelling/natureComm/source/BiGG_Models/mat';
        matFolder='~/Dropbox/modelling/natureComm/source/MSP_ME';
        matFolder='~/Dropbox/modelling/natureComm/source/MSP_ReconX/';
    end
    
    %modelNameStructure='MSP_ReconX';
    if ~exist('modelNames','var')
        modelNames=[];
    else
        if ~isempty(modelNames)
        if ~isstruct(modelNames)
            
        %choose the ordering of the table of results, the second column contains a
        %unique abbreviation for each model
        switch modelNames
            case ''
                %use the filenames
                modelNames=[];
            case 'MSP_ME'
                modelNames={...
                    'E. coli ME (Thiele et al)','ME_matrix_GlcAer_WT'};
            case 'MSP_ReconX'
                modelNames={...
                    'Homo sapiens','121114_Recon2betaModel';
                    'Homo sapiens','Recon2.v04'};
            case 'mongoose'
                modelNames={...
                    'Lactococcus lactis','LLACTIS';
                    'Halobacterium salinarum','';
                    'Mus musculus','';
                    'Streptomyces coelicolor','S_coilicolor';
                    'Mus musculus ','';
                    'Thermotoga maritima','T_Maritima';
                    'Clostridium acetobutylicum ','';
                    'Clostridium acetobutylicum ','';
                    'Corynebacterium glutamicum ','';
                    'Corynebacterium glutamicum ','';
                    'Geobacter metallireducens ','';
                    'Geobacter sulfurreducens ','';
                    'Mus musculus','mus_musculus';
                    'Lactobacillus plantarum','';
                    'Mannheimia succiniciproducens','';
                    'Mannheimia succiniciproducens','';
                    'Neisseria meningitidis','';
                    'Rhodoferax ferrireducens','';
                    'Staphylococcus aureus','';
                    'Streptococcus thermophilus','';
                    'Streptomyces coelicolor','';
                    'Natronomonas pharaonis','Natronomonas_pharaonis';
                    'Synechocystis sp. PCC6803 ','';
                    'Plasmodium falciparum','PlasmoNet';
                    'Acinetobacter baumannii','AbyMBEL891';
                    'Aspergillus oryzae','AORYZAE_COBRA';
                    'Arabidopsis thaliana','AraGEM';
                    'Mycobacterium tuberculosis','GSMN-TB';
                    'Acinetobacter baylyi','iAbaylyiV4';
                    'Acinetobacter baylyi','iAbaylyiV4';
                    'Acinetobacter baylyi','iAbaylyiV4';
                    'Acinetobacter baylyi ','iAbaylyiV4';
                    'Leishmania major','iAC560';
                    'Escherichia coli ','iAF1260';
                    'Methanosarcina barkeri','iAF692';
                    'Dehalococcoides ethenogenes','iAI549';
                    'Yersinia pestis','iAN818m';
                    'Bacillus subtilis','iBsu1103';
                    'Escherichia coli','iCA1273';
                    'Clostridium beijerinckii','iCB925';
                    'Helicobacter pylori','iCS291';
                    'Haemophilus influenzae','iCS400';
                    'Saccharomyces cerevisiae','iFF708';
                    'Buchnera aphidicola','iGT196';
                    'Aspergillus nidulans','iHD666 ';
                    'Saccharomyces cerevisiae','iIN800';
                    'Helicobacter pylori','iIT341';
                    'Synechocystis sp. PCC6803','iJN678';
                    'Escherichia coli','iJO1366';
                    'Pseudomonas putida','iJP815';
                    'Escherichia coli','iJR904';
                    'Burkholderia cenocepacia','iKF1028';
                    'Pichia pastoris','iLC915';
                    'Saccharomyces cerevisiae','iLL672';
                    'Aspergillus niger','iMA871';
                    'Salmonella typhimurium','iMA945';
                    'Methanosarcina acetivorans','iMB745';
                    'Staphylococcus aureus','iMH551';
                    'Saccharomyces cerevisiae','iMH805/775';
                    'Mus musculus','iMM1415';
                    'Saccharomyces cerevisiae','iMM904';
                    'Pseudomonas aeruginosa','iMO1056';
                    'Saccharomyces cerevisiae','iND750';
                    'Mycobacterium tuberculosis','iNJ661';
                    'Mycobacterium tuberculosis','iNJ661m';
                    'Pseudomonas putida','iNJ746';
                    'Cryptosporidium hominis','iNV213';
                    'Chromohalobacter salexigens','iOA584';
                    'Rhizobium etli','iOR363';
                    'Pichia pastoris','iPP668';
                    'Mycoplasma genitalium','iPS189';
                    'Chlamydomonas reinhardtii','iRC1080';
                    'Salmonella typhimurium','iRR1083';
                    'Zea mays','iRS1563';
                    'Arabidopsis thaliana','iRS1597';
                    'Francisella tularensis','iRS605';
                    'Rhodobacter sphaeroides','iRsp1095';
                    'Staphylococcus aureus','iSB619';
                    'Shewanella oneidensis','iSO783';
                    'Clostridium thermocellum','iSR432';
                    'Pichia stipitis','iSS884';
                    'Synechocystis sp. PCC6803','iSyn669';
                    'Plasmodium falciparum','iTH366';
                    'Scheffersomyces stipitis','iTL885';
                    'Porphyromonas gingivalis','iVM679';
                    'Methanosarcina acetivorans','iVS941';
                    'Ketogulonicigenium vulgare','iWZ663';
                    'Klebsiella pneumoniae','iYL1228';
                    'Zymomonas mobilis','iZM363';
                    'Bacillus subtilis ','model_v3';
                    'Pichia pastoris','PpaMBEL1254 ';
                    'Pseudomonas putida','PpuMBEL1071';
                    'Homo sapiens','121114_Recon2betaModel';
                    'Saccharomyces pombe','SpoMBEL1693';
                    'Salmonella typhimurium','STM_v1.0';
                    'Escherichia coli','textbook';
                    'Vibrio vulnificus','VvuMBEL943';
                    'Zymomonas mobilis','ZmobMBEL601'};
        end
        end
        end
    end
    %optionally convert the batch of .xml files into .mat files
    if 0
        %the folder where the SBML .xml files are located
        xmlFolder='m_model_collection';
        
        %folder where he .mat files are to be located
        matFolder=[pathContainingOpencobra 'cobratoolbox_master/testing/testModels/m_model_collection_mat'];
        
        %parsing via cobra toolbox and sbml toolbox and libsbml with matlab bindings
        sbmlTestModelToMat(xmlFolder,matFolder);
    end
    
    if ~exist('printLevel','var')
        printLevel=0;
    end    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%
    
    %The remainder of this code should run uninterupted,
    if any(strcmp(solvers,'quadMinos')) && isunix
        %quadMinos
        %addpath(pathContainingQuadMinos)
        %try to find the minos solver
        [status,cmdout]=system('which minos');
        if isempty(cmdout)
            [status,cmdout]=system('echo $PATH');
            disp(cmdout);
            warning('Minos not installed or not on system path.');
        end
    end
    

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % batch of mat files models the matFolder directory
    cd(matFolder)
    
    %batch of models in .mat format in a directory
    %assumes that each .mat file is a model
    matFiles=dir(matFolder);
    nModels=length(matFiles)-2;
    
    modelResults=cell(nModels,2+length(solvers));
    j=1;
    for k=3:length(matFiles) %loop through the mat files in the directory
        if strcmp(matFiles(k).name(end-2:end),'mat')
            
            if printLevel>0
                %disp(j)
                disp(matFiles(k).name)
            end
            
            %get the id of the model from the filename
            whosFile=whos('-file',matFiles(k).name);
            modelID=matFiles(k).name(1:end-4);
            modelResults{j,1}=modelID;
            if printLevel>-1
                fprintf('%20s\n',modelID);
            end
            load(matFiles(k).name);
            model=eval(whosFile.name);
            %stamp the model with the ID of the file
            model.modelID=modelID;
            model.description=modelID;
            
            %find the exchange reactions
            [m,n]=size(model.S);
            try
                if length(find(model.c~=0))~=1 % if more than one objective vector are defined in the model, only the one of the them is chosen for the testing.
                    ind=find(model.c~=0);
                    if isempty(ind); % if no objective vector is defined, set the first reaction as the objective for the testing.
                        warning('all zero entries in model.c')
                        model.c(1)=1;
                    else
                        warning('multiple nonzero entries in model.c')
                        model.c(ind)=0;
                        model.c(ind(1))=1; % by default, the first objective vector is used for the testing
                    end
                end
                model=findSExRxnInd(model,m,printLevel-1);
            catch
                disp('good');
            end
            
            if 0
                %check if stoichiometrically consistent
                [inform,m,model]=checkStoichiometricConsistency(model,printLevel-1);
            end
            
            %record the reaction to be optimized
            if any(model.c~=0) && isfield(model,'rxns')
                modelResults{j,2}=model.rxns{model.c~=0};
            else
                modelResults{j,2}='?';
            end
                        
            %test with different solvers
            [out,solutions{j}]=testDifferentLPSolvers(model,solvers,printLevel);
            %save results
            for z=1:length(solvers)
                modelResults{j,2+z}=solutions{j}{z}.obj;
            end
            j=j+1;%used below
        end
    end
    

    %depending how the data is to be ordered, results structure is
    %different
    if isempty(modelNames)
        %create results structure
        results=cell(j,2+length(solvers));
        %add results in the order given by modelNames
        for k=1:j-1
            %Abbreviation of model
            results{k+1,1}=modelResults{k,1};
            results{k+1,2}=modelResults{k,2};
            %Abbreviation of reaction optimised'
            %solver objectives
            for z=1:length(solvers)
                results{k+1,2+z}=modelResults{k,2+z};
            end
        end
        %add headings to the results structure
        results{1,1}='Model';
        results{1,2}='Rxn maximised';
        for z=1:length(solvers)
            results{1,2+z}=solvers{z};
        end
    else
        %create results structure
        results=cell(size(modelNames,1)+1,3+length(solvers));
        %add results in the order given by modelNames
        for k=1:size(modelNames,1)
            %Abbreviation of model
            results{k+1,1}=modelNames{k,1};
            results{k+1,2}=modelNames{k,2};
            bool=strcmp(modelNames{k,2},modelResults(:,1));
            if any(bool)
                %Abbreviation of reaction optimised'
                results{k+1,3}=modelResults{bool,2};
                %solver objectives
                for z=1:length(solvers)
                    results{k+1,3+z}=modelResults{bool,2+z};
                end
            end
        end
        %add headings to the results structure
        results{1,1}='Species';
        results{1,2}='Model';
        results{1,3}='Rxn maximised';
        for z=1:length(solvers)
            results{1,3+z}=solvers{z};
        end
    end
end