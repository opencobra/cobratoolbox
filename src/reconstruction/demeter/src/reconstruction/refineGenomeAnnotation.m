function [model,addAnnRxns,updateGPRCnt]=refineGenomeAnnotation(model,microbeID,database,inputDataFolder)

if isfile([inputDataFolder filesep 'gapfilledGenomeAnnotation.txt'])
    genomeAnnotation = readtable([inputDataFolder filesep 'gapfilledGenomeAnnotation.txt'], 'ReadVariableNames', false, 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011']);
    genomeAnnotation = table2cell(genomeAnnotation);
    
    addAnnRxns={};
    annRxns={};
    updateGPRCnt=0;
    
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