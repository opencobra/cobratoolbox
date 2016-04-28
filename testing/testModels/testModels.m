function results = testModels()
%test a set of models for the feasibility of a nonzero objective(>1e-4)
if 1 %by default, do not run this script with testAll
    clear
    
    %select solver to use
    %gurobi (http://www.gurobi.com/) gurboi versions 5 and 6 are supported
    solvers={'gurobi6'};
    %optionally also test with quadMINOS (a quadruple precision solver by Michael Saunders, Stanford Systems Optimization Laboratory)
    %solvers={'gurobi6','quadMINOS'};
    
    %optionally: path to quadMinos solver
    pathContainingQuadMinos='/usr/local/bin/quadLP/matlab';
    
    %test if cobra toolbox is installed
    if ~exist('initCobraToolbox','file')
        %Set and navigate to the path to contain repositories cloned from opencobra. e.g.
        %pathContainingOpencobra='/usr/local/bin/';
        pathContainingOpencobra='/home/rfleming/work/sbg-code/';
        cd(pathContainingOpencobra)
        
        %path to gurobi solver
        %pathContainingGurobi='/usr/local/bin/gurobi600/linux64/matlab/';
        pathContainingGurobi='/usr/local/bin/gurobi650/linux64/matlab/';
        addpath(pathContainingGurobi)
        
        %clone opencobra code into pathContainingOpencobra
        system('git clone https://github.com/opencobra/cobratoolbox.git cobratoolbox')
        %system('git clone https://github.com/opencobra/m_model_collection.git')
        cd(['pathContainingOpencobra' cobratoolbox])
        %initialise cobra toolbox
        initCobraToolbox
        
        %gurobi
        QPsolverOK = changeCobraSolver('gurobi6','QP');
        LPsolverOK = changeCobraSolver('gurobi6','LP');
    end
    
    % set the folder within the folder 'testModels' where the .xml files are located
    global CBTDIR
    matFolder=[CBTDIR '/testing/testModels/m_model_collection_mat']; %selection of mat files already parsed from https://github.com/opencobra/m_model_collection.git'
    matFolder=['/usr/local/bin/cobratoolbox_master' '/testing/testModels/m_model_collection_mat'];
    matFolder=[CBTDIR '/testing/testModels/testedModels'];
    %optionally convert the batch of .xml files into .mat files
    if 0
        %the folder where the SBML .xml files are located
        xmlFolder='m_model_collection';
        
        %folder where he .mat files are to be located
        matFolder=[pathContainingOpencobra 'cobratoolbox_master/testing/testModels/m_model_collection_mat'];
        
        %parsing via cobra toolbox and sbml toolbox and libsbml with matlab bindings
        sbmlTestModelToMat(xmlFolder,matFolder);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %The remainder of this code should run uninterupted,
    
    if any(strcmp(solvers,'quadMINOS')) & isunix
        %quadMinos
        addpath(pathContainingQuadMinos)
        %try to find the minos solver
        [status,cmdout]=system('which minos');
        if isempty(cmdout)
            [status,cmdout]=system('echo $PATH');
            disp(cmdout);
            warning('Minos not installed or not on system path.');
        end
    end
    
    %choose the amount to be printed to screen
    printLevel=0;
    
    %choose the minimum magnitude considered a nonzero objective
    tol=1e-4;
    
    solvers={'gurobi5'};
    if ~isunix || ismac
        solvers={'gurobi5'};
    else
        [status,cmdout]=system('which minos');
        if isempty(cmdout)
            [status,cmdout]=system('echo $PATH');
            disp(cmdout);
            warning('Minos not installed or not on system path.');
        else
            solvers={'gurobi5','quadMinos'};
        end
    end
    %choose the set of mat files to look for, the second column contains a
    %unique abbreviation for each model
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
        'Homo sapiens','Recon 1';
        'Saccharomyces pombe','SpoMBEL1693';
        'Salmonella typhimurium','STM_v1.0';
        'Escherichia coli','textbook';
        'Vibrio vulnificus','VvuMBEL943';
        'Zymomonas mobilis','ZmobMBEL601'};
    
    %in some xml files, the objective is not specified
    curated_objectives = {...
        'VvuMBEL943';
        'R806';
        'iAI549';
        'BIO_CBDB1_DM_855';
        'mus_musculus';
        'BIO028';
        'iRsp1095';
        'RXN1391';
        'iLC915';
        'r1133';
        'PpaMBEL1254';
        'R01288';
        'AbyMBEL891';
        'R761';
        'Biomass';
        'RXNBiomass';
        'BIOMASS_LM3';
        'BIOMASS';
        'biomass_mm_1_no_glygln';
        'Biomass_Chlamy_auto';
        'biomass_target';
        'biomass';
        'Ec_biomass_iAF1260_core_59p81M'};
    
    %in some models, the bounds on exchange reactions are closed by default so
    %open them
    open_boundaries = {...
        'iRsp1095';
        'AORYZAE_COBRA';
        'iFF708'};
    
    maxBound=1000;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % batch of mat files models the destFolder directory
    cd(matFolder)
    %list of mat files
    matFiles=dir(matFolder);
    nModels=length(matFiles)-2;
    results=cell(nModels,4);
    j=1;
    for k=3:length(matFiles) %loop through the mat files in the directory
        if strcmp(matFiles(k).name(end-2:end),'mat')
            
            if printLevel>0
                %disp(j)
                disp(matFiles(k).name)
            end
            
            %name of the model from the filename
            whosFile=whos('-file',matFiles(k).name);
            modelID=matFiles(k).name(1:end-4);
            results{j,1}=modelID;
            fprintf('%20s%s',modelID,': ');
            load(matFiles(k).name);
            model=eval(whosFile.name);
            
            %find the exchange reactions
            [m,n]=size(model.S);
            try
                if length(find(model.c~=0))~=1 % if more than one objectiive vector are defined in the model, only the one of the them is chosen for the testing.
                    ind=find(model.c~=0);
                    if isempty(ind); % if no objective vector is defined, set the first reaction as the objective for the testing.
                        model.c(1)=1;
                    else
                        
                        model.c(ind)=0;
                        model.c(ind(1))=1; % by default, the first objective vector is used for the testing
                    end
                end
            model=findSExRxnInd(model,m,1);
            
            catch
                disp('good');
            end
            
            
            for ind=1:length(curated_objectives)
                bool=strcmp(model.rxns,curated_objectives{ind});
                if any(bool)
                    if nnz(bool)>1
                        error('Should be only one biomass reaction')
                    else
                        curated_objectives{ind,2}=matFiles(ind).name;
                        model.c(bool)=1;
                        fprintf('%20s%s%s\n',matFiles(ind).name(1:end-4),': Added biomass coefficient for ',model.rxns{bool});
                    end
                end
            end
            
            %add biomass reaction to some models
            if ~any(model.c)
                [m,n]=size(model.S);
                bool=false(m,1);
                for i=1:m
                    bool(i)=~isempty(strfind(lower(model.mets{i}),'biomass'));
                end
                if any(bool)
                    model.S(bool,n+1)=-1;
                    model.c(:)=0;
                    model.c(n+1)=1;
                    model.lb(n+1)=-maxBound;
                    model.ub(n+1)=maxBound;
                    model.rxns{n+1,1}='Added_biomass_rxn';
                    model.osense=1;
                    fprintf('%20s%s\n',matFiles(k).name,': Added biomass exchange reaction.');
                end
            end
            
            if 0
                %ensure the biomass reaction is unconstrained
                if strcmp(matFiles(k).name(1:end-4),open_boundaries)
                    fprintf('%s%s\n','Open boundaries for :',matFiles(k).name(1:end-4))
                    model.lb(model.c~=0)=-maxBound;
                    model.ub(model.c~=0)=maxBound;
                end
            else
                if strcmp(matFiles(k).name(1:end-4),open_boundaries)
                    fprintf('%20s%s\n',matFiles(k).name(1:end-4),': Opening all exchange reactions')
                    for j=1:n
                        if ~model.SIntRxnBool(j)
                            model.ub(j)=maxBound;
                            model.lb(j)=-maxBound;
                            %                             if sum(model.S(:,j))>0
                            %                                 model.ub(j)=10;
                            %                             else
                            %                                 model.lb(j)=-10;
                            %                             end
                        end
                    end
                end
            end
            
            %record the reaction to be optimized
            if any(model.c~=0)
                results{j,2}=model.rxns{model.c~=0};
            else
                results{j,2}='?';
            end
            
            if strcmp(matFiles(k).name(1:end-4),open_boundaries)
                fprintf('%s%s\n','Open boundaries for :',matFiles(k).name(1:end-4))
                for j=1:n
                    if model.SIntRxnBool(j)
                        if sum(model.S(:,j))>0
                            model.ub(j)=10;
                        else
                            model.lb(j)=-10;
                        end
                    end
                end
            end
            if 0
                %save out models for individual debugging
                save([matFolder(1:end-length('m_model_collection_mat')) 'testedModels/' modelID '.mat'],'model')
            end
            [out,solutions{j}]=testDifferentLPSolvers(model,solvers,printLevel);
            for z=1:length(solvers)
                results{j,k+2}=solutions{j}{z}.obj;
            end
            j=j+1;
        end
    end
    results2=results(1:j-1,1:4);
    clear results;
    
    if any(strcmp(solvers,'quadMINOS')) & isunix
        results=cell(size(modelNames,1)+1,7);
    else
        results=cell(size(modelNames,1)+1,5);
    end
    results{1,1}='Species';
    results{1,2}='Model';
    results{1,3}='Rxn optimised';
    results{1,4}=['true if quadMinos objective greater than ' num2str(tol)];
    results{1,5}='gurobi objective';
    if any(strcmp(solvers,'quadMINOS')) & isunix
        results{1,6}='quadMinos objective';
        results{1,7}='difference between objectives';
    end
    
    for k=1:size(modelNames,1)
        %Abbreviation of model
        results{k+1,1}=modelNames{k,1};
        results{k+1,2}=modelNames{k,2};
        bool=strcmp(modelNames{k,2},results2(:,1));
        if any(bool)
            %Abbreviation of reaction optimised'
            results{k+1,3}=results2{bool,2};
            %true if quadMinos objective greater than tol
            results{k+1,4}=abs(results2{bool,4})>tol;
            %gurobi objective
            results{k+1,5}=results2{bool,3};
            if any(strcmp(solvers,'quadMINOS')) & isunix
                %quadMinos objective
                results{k+1,6}=results2{bool,4};
                %difference between objectives
                results{k+1,7}=abs(results2{bool,3}-results2{bool,4});
            end
        end
    end
    clear results2;
end
% %old version, cobrapy parsing
% %load the test set of models parsed with cobrapy
% load all_models.mat
% modelsFound=true(length(modelNames),1);
% j=1;
% for k=1:length(modelNames)
%     %name of the model from the cell
%     if exist(modelNames{k})
%         if printLevel>0
%             fprintf('%s%s\n','    Model found: ',modelNames{k})
%         end
%
%         model=eval(modelNames{k});
%
%         %select solvers to try
%         solvers={'gurobi5','quadMinos'};
%
%         [out,solutions{k}]=testDifferentLPSolvers(model,solvers,printLevel);
%
%         results{k,1}=modelNames{k};
%         results{k,2}=solutions{k}{1}.obj;
%         results{k,3}=solutions{k}{2}.obj;
%         results{k,4}=results{k,2}-results{k,3};
%         j=j+1;
%     else
%         if printLevel>0
%             fprintf('%s%s\n','Model not found: ',modelNames{k})
%         end
%         modelsFound(k)=0;
%     end
%
%
% end
% fprintf('\n')
% fprintf('%s%s%s%s\n','        \solver','          gurobi','       quadMinos',...
%     '      difference')
% fprintf('%s%s%s%s\n','model\precision','          double','       quadruple',...
%     '      difference')
% for k=1:length(modelNames)
%     if modelsFound(k)
%         fprintf('%15s\t%15d\t%15d\t%15d\n',results{k,1},results{k,2},results{k,3},results{k,4})
%     end
% end
