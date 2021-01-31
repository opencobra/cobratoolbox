function [model,addAnnRxns,updateGPRCnt]=refineGenomeAnnotation(model,microbeID,database,inputDataFolder)
% Part of the DEMETER pipeline. Refines a reconstruction based on
% comparative genomics data retrieved from PubSEED spreadsheets.
%
% USAGE
%       [model,addAnnRxns,updateGPRCnt]=refineGenomeAnnotation(model,microbeID,database,inputDataFolder)
%
%
% INPUTS
% model:               COBRA model structure
% microbeID:           ID of the reconstructed microbe that serves as the
%                      reconstruction name and to identify it in input tables
% database:            rBioNet reaction database containing min. 3 columns:
%                      Column 1: reaction abbreviation, Column 2: reaction
%                      name, Column 3: reaction formula.
% inputDataFolder:     Folder with experimental data and database files to 
%                      load
%
% OUTPUTS
% model:               COBRA model structure
% addAnnRxns:          Reactions newly added based on comparative genomics
%                      data
% updateGPRCnt:        Reactions for which GPRs were updated based on 
%                      comparative genomics data 
%
% .. Authors:
%       - Almut Heinken, 06/2020


addAnnRxns={};
annRxns={};
updateGPRCnt=0;
    
if isfile([inputDataFolder filesep 'gapfilledGenomeAnnotation.txt'])
    genomeAnnotation = readtable([inputDataFolder filesep 'gapfilledGenomeAnnotation.txt'], 'ReadVariableNames', false, 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011']);
    genomeAnnotation = table2cell(genomeAnnotation);
    
    findRxns=find(strcmp(microbeID,genomeAnnotation(:,1)));
    if ~isempty(findRxns)
        annRxns(:,1)=genomeAnnotation(findRxns(:,1),2);
        annRxns(:,2)=genomeAnnotation(findRxns(:,1),3);
        cnt=1;
        for i=1:size(annRxns,1)
            if ~isempty(find(ismember(model.rxns,annRxns{i,1})))
                rxnID=find(ismember(model.rxns,annRxns{i,1}));
                model.grRules{rxnID,1}=annRxns{i,2};
                model.comments{rxnID,1}='Refined reaction based on comparative genomic analysis.';
                model.citations{rxnID,1}='';
                model.rxnECNumbers{rxnID,1}='';
                model.rxnKEGGID{rxnID,1}='';
                %         model.rxnConfidenceScores(rxnID,1)=0;
                updateGPRCnt=updateGPRCnt+1;
            else
                % add the reaction with the GPR
                annRxForm = database.reactions(find(ismember(database.reactions(:,1),annRxns{i,1})),3);
                model=addReaction(model,annRxns{i,1},annRxForm{1,1});
                rxnID=find(ismember(model.rxns,annRxns{i,1}));
                model.grRules{rxnID,1}=annRxns{i,2};
                model.comments{rxnID,1}='Refined reaction based on comparative genomic analysis.';
                model.citations{rxnID,1}='';
                model.rxnECNumbers{rxnID,1}='';
                model.rxnKEGGID{rxnID,1}='';
                % %         model.rxnConfidenceScores(rxnID,1)=0;
                addAnnRxns{cnt,1}=annRxns{i,1};
                cnt=cnt+1;
            end
        end
    end
end

end