%test a set of models for the feasibility of a nonzero objective (>1e-4)
%using gurobi5 and quadMinos
clear 

%Set and navigate to the path containing (or to contain)
%repositories cloned from opencobra. e.g.
pathContainingOpencobra='/usr/local/bin/';
%path to gurobi solver
pathContainingGurobi='/usr/local/bin/gurobi600/linux64/matlab/';
%path to quadMinos solver
pathContainingQuadMinos='/usr/local/bin/quadLP/matlab';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The remainder of this code should run uninterupted, 
%Optionally clone opencobra code into pathContainingOpencobra, if not already
%there or if out of date, then initialise cobratoobox
if 0
    cd(pathContainingOpencobra)
    system('git clone https://github.com/opencobra/cobratoolbox.git cobratoolbox_master')
    system('git clone https://github.com/opencobra/m_model_collection.git')
    cd(['pathContainingOpencobra' cobratoolbox_master])
    initCobraToolbox
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%gurobi
addpath(pathContainingGurobi)
QPsolverOK = changeCobraSolver('gurobi6','QP');
LPsolverOK = changeCobraSolver('gurobi6','LP');
        
%quadMinos
addpath(pathContainingQuadMinos)

%the folder where the SBML .xml files are located
originFolder=[pathContainingOpencobra 'm_model_collection'];

%folder where 
destFolder=[pathContainingOpencobra 'cobratoolbox_master/testing/testModels/m_model_collection'];

if 1
    %parsing via cobra toolbox and sbml toolbox and libsbml with matlab bindings
    sbmlTestModelToMat(originFolder,destFolder);
end

%chose the amount to be printed to screen
printLevel=1;

%choose the minimum magnitude considered a nonzero objective
tol=1e-4;

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
'R761'};
    
%in some models, the bounds on exchange reactions are closed by default so
%open them
open_boundaries = {...
'iRsp1095';
'AORYZAE_COBRA';
'iFF708'};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 1
    % batch of mat files models the destFolder directory
    cd(destFolder)
    %list of mat files
    matFiles=dir(destFolder);
    nModels=length(matFiles)-2;
    results=cell(nModels,4);
    j=1;
    for k=3:length(matFiles)
        if strcmp(matFiles(k).name(end-2:end),'mat')
            
            if printLevel>0
                %disp(j)
                disp(matFiles(k).name)
            end
            
            %name of the model from the filename
            whosFile=whos('-file',matFiles(k).name);
            results{j,1}=matFiles(k).name(1:end-4);
            
            load(matFiles(k).name);
            model=eval(whosFile.name);
            
            %find the exchange reactions
            [m,n]=size(model.S);
            model=findSExRxnInd(model,m,1);
            
            for k=1:length(curated_objectives)
                bool=strcmp(model.rxns,curated_objectives{k});
                if any(bool)>0
                    if nnz(bool)>1
                        error('Should be only one biomass reaction')
                    else
                        model.c(bool)=1;
                        fprintf('%s%s%s%s\n','Model ',matFiles(k).name,' added biomass coefficient for ',model.rxns{bool});
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
            %
            solvers={'gurobi5','quadMinos'};
            [out,solutions{j}]=testDifferentLPSolvers(model,solvers,printLevel);
            
            results{j,3}=solutions{j}{1}.obj;
            results{j,4}=solutions{j}{2}.obj;
            j=j+1;
        end
    end
    results2=results(1:j-1,1:4);
    clear results;
    
    results=cell(size(modelNames,1)+1,6);
    results{1,1}='Species';
    results{1,2}='Model';
    results{1,3}='Rxn optimised';
    results{1,4}=['true if quadMinos objective greater than ' num2str(tol)];
    results{1,5}='quadMinos objective';
    results{1,6}='gurobi objective';
    results{1,7}='difference between objectives';
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
            %quadMinos objective
            results{k+1,5}=results2{bool,4};
            %gurobi objective
            results{k+1,6}=results2{bool,3};
            %difference between objectives
            results{k+1,7}=abs(results2{bool,3}-results2{bool,4});
        end
    end
    clear results2;
else
    %old version, cobrapy parsing
    %load the test set of models parsed with cobrapy
    load all_models.mat
    modelsFound=true(length(modelNames),1);
    j=1;
    for k=1:length(modelNames)
        %name of the model from the cell
        if exist(modelNames{k})
            if printLevel>0
                fprintf('%s%s\n','    Model found: ',modelNames{k})
            end
            
            model=eval(modelNames{k});
            
            %select solvers to try
            solvers={'gurobi5','quadMinos'};
            
            [out,solutions{k}]=testDifferentLPSolvers(model,solvers,printLevel);
            
            results{k,1}=modelNames{k};
            results{k,2}=solutions{k}{1}.obj;
            results{k,3}=solutions{k}{2}.obj;
            results{k,4}=results{k,2}-results{k,3};
            j=j+1;
        else
            if printLevel>0
                fprintf('%s%s\n','Model not found: ',modelNames{k})
            end
            modelsFound(k)=0;
        end
        
        
    end
    fprintf('\n')
    fprintf('%s%s%s%s\n','        \solver','          gurobi','       quadMinos',...
        '      difference')
    fprintf('%s%s%s%s\n','model\precision','          double','       quadruple',...
        '      difference')
    for k=1:length(modelNames)
        if modelsFound(k)
            fprintf('%15s\t%15d\t%15d\t%15d\n',results{k,1},results{k,2},results{k,3},results{k,4})
        end
    end
    
end

