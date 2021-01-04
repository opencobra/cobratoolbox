function [model] = createPeriplasmaticSpace(model,microbeID,infoFile)
% This function creates a periplasmatic space for the refined
% reconstructions by retrieving all extracellular metabolites and adding
% a third compartment.

% get the information on taxonomy and gram staining to find out if a periplasmatic space
% should be added
phylCol=find(strcmp(infoFile(1,:),'Phylum'));
if ~isempty(find(strcmp(infoFile(:,1),microbeID)))
    phylum=infoFile{find(strcmp(infoFile(:,1),microbeID)),phylCol};
    genCol=find(strcmp(infoFile(1,:),'Genus'));
    genus=infoFile{find(strcmp(infoFile(:,1),microbeID)),genCol};
    
    gramCol=find(strcmp(infoFile(1,:),'Gram Staining'));
    gramStatus=infoFile(find(strcmp(infoFile(:,1),microbeID)),gramCol);
    
    if (strcmp(gramStatus,'Gram-') || strcmp(phylum,'Deinococcus-Thermus')) && ~any(strcmp(phylum,{'Euryarchaeota','Crenarchaeota','Thaumarchaeota','Tenericutes'})) && ~any(strcmp(genus,{'Acidaminobacter','Gracilibacter'}))
        
        % get all extracellular metabolites
        exMets=model.mets(find(contains(model.mets,'[e]')));
        
        % Add periplasmatic metabolites, metNames and metFormulas
        metNames = {};
        metFormulas = {};
        metCharges = [];
        
        for i=1:length(exMets)
            pMets{i} = strrep(exMets{i},'[e]','[p]');
            metNames{i} = model.metNames{find(strcmp(model.mets,exMets{i}))};
            metFormulas{i} = model.metFormulas{find(strcmp(model.mets,exMets{i}))};
            metCharges(i) = model.metCharges(find(strcmp(model.mets,exMets{i})));
        end
        
        modelNew=model;
        % Add all new periplasmatic metabolites
        for i=1:length(pMets)
            modelNew = addMetabolite(modelNew, pMets{i}, 'metName', metNames{i}, 'metFormula', metFormulas{i}, 'Charge', metCharges(i));
        end
        
        % Get all transport reactions associated with the exchange metabolites
        rxnsToAdd = {};
        rxnNames = {};
        rxnFormulas = {};
        rxnLB = [];
        rxnUB = [];
        rxnSubsystem = {};
        
        % convert extracellular transport reactions to transport reactions from
        % periplasmatic space to cytosol
        for i=1:length(exMets)
            transpRxns = findRxnsFromMets(model,exMets{i});
            % remove exchange reactions
            transpRxns(find(strncmp(transpRxns,'EX_',3)))=[];
            for j=1:length(transpRxns)
                rxnsToAdd{end+1} = [transpRxns{j} 'pp'];
                rxnNames{end+1} = [model.rxnNames{find(strcmp(model.rxns,transpRxns{j}))} ', periplasmatic'];
                rxnLB(end+1) = model.lb(find(strcmp(model.rxns,transpRxns{j})));
                rxnUB(end+1) = model.ub(find(strcmp(model.rxns,transpRxns{j})));
                form = printRxnFormula(model,transpRxns{j});
                rxnFormulas{end+1} = strrep(form{1},'[e]','[p]');
                rxnSubsystem{end+1} = 'Transport, periplasmatic';
            end
            modelNew = removeRxns(modelNew,transpRxns, 'metFlag', false);
        end
        
        % add transport reactions to transport reactions from
        % extracellular to periplasmatic space
        for i=1:length(exMets)
            rxnsToAdd{end+1} = [upper(strrep(exMets{i},'[e]','')) 'tex'];
            rxnNames{end+1} = [model.metNames{find(strcmp(model.mets,exMets{i}))} ' diffusion extracellular to periplasm'];
            rxnLB(end+1) = -1000;
            rxnUB(end+1) = 1000;
            rxnFormulas{end+1} = [exMets{i} ' <=> ' strrep(exMets{i},'[e]','[p]')];
            rxnSubsystem{end+1} = 'Transport, extracellular';
        end
        
        % add all new reactions
        for i=1:length(rxnsToAdd)
            modelNew = addReaction(modelNew,rxnsToAdd{i},'reactionName',rxnNames{i},...
                'reactionFormula',rxnFormulas{i},'lowerBound',rxnLB(i),'upperBound',rxnUB(i),'subSystem',rxnSubsystem{i});
        end
        
        model = convertOldStyleModel(modelNew);
    end
end

end
