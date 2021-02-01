function [model,rmUnannRxns]=removeUnannotatedReactions(model,microbeID,biomassReaction,growsOnDefinedMedium,inputDataFolder)
% Part of the DEMETER pipeline. Refines a reconstruction based on
% comparative genomics data retrieved from PubSEED spreadsheets. Removes
% reactions that were present in the reconstruction before refinement but
% that are not annotated in the organism according to manually performed
% comparative genomic analyses.
%
% USAGE
%       [model,rmUnannRxns]=removeUnannotatedReactions(model,microbeID,biomassReaction,growsOnDefinedMedium,inputDataFolder)
%
%
% INPUTS
% model:                    COBRA model structure
% microbeID:                ID of the reconstructed microbe that serves as 
%                           the reconstruction name and to identify it in
%                           input tables
% definedMediumGrowthOK:    If 1, defined medium is available for the
%                           organism and the model can grow on it
% inputDataFolder:          Folder with experimental data and database 
%                           files to load
%
% OUTPUTS
% model:                    COBRA model structure
% rmUnannRxns:              Removed reactions based on comparative genomics
%                           data
%
% .. Authors:
%       - Almut Heinken, 06/2020

rmUnannRxns={};

if isfile([inputDataFolder filesep 'unannotatedGenomeAnnotation.txt'])
    unannotatedGenomeAnnotation = readtable([inputDataFolder filesep 'unannotatedGenomeAnnotation.txt'], 'ReadVariableNames', false, 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011']);
    unannotatedGenomeAnnotation = table2cell(unannotatedGenomeAnnotation);
    
    tol=0.0000001;
    
    findRxns=find(strcmp(microbeID,unannotatedGenomeAnnotation(:,1)));
    if ~isempty(findRxns)
        unannRxns=unannotatedGenomeAnnotation(findRxns(:,1),2);
        model_old=model;
        
        % if growth on a defined medium was achieved, make sure this is not
        % abolished through removal of reactions.
        if growsOnDefinedMedium==1
            [~,modelDM] = testGrowthOnDefinedMedia(model, microbeID, biomassReaction, inputDataFolder);
            modelTest=changeRxnBounds(modelDM,'EX_o2(e)',0,'l');
            FBA=optimizeCbModel(modelTest,'max');
            if FBA.f > tol
                modelDM=modelTest;
            end
        end
        % ensure that anaerobic growth on Western diet is not abolished
        WesternDiet = readtable('WesternDietAGORA2.txt', 'Delimiter', 'tab');
        WesternDiet=table2cell(WesternDiet);
        WesternDiet=cellstr(string(WesternDiet));
        model=useDiet(model,WesternDiet);
        
        cnt=1;
        for i=1:size(unannRxns,1)
            if ~isempty(find(ismember(model.rxns,unannRxns{i,1})))
                % ensure that the model can still grow afterwards
                modelTest=removeRxns(model,unannRxns{i,1});
                FBAwd=optimizeCbModel(modelTest,'max');
                if exist('modelDM','var') == 1
                    modelTestDM=removeRxns(modelDM,unannRxns{i,1});
                    FBAdm=optimizeCbModel(modelTestDM,'max');
                else
                    FBAdm=FBAwd;
                end
                if FBAwd.f > tol && FBAdm.f > tol
                    model=modelTest;
                    if exist('modelDM','var') == 1
                        modelDM=modelTestDM;
                    end
                    rmUnannRxns{cnt,1}=unannRxns{i,1};
                    cnt=cnt+1;
                end
            end
        end
        
        model=model_old;
        model=removeRxns(model,rmUnannRxns);
    end
end

end