function newmap = ColorRxnsFromGenes(map,model,EntrezList,color,width)

    % Color and change the width of reactions based on the imlicated gene
    % given from a list of EntezIDs.
    %
    % USAGE:
    %
    %   ColorRxnsFromGenes(map,model,EntrezList,color,width);
    %
    % INPUTS:
    %
    %   map:            map from CD parsed to matlab format
    %
    %   model:          COBRA model
    %
    %   EntrezList:     List of genes, given as EntrezIDs. 
    %
    % OPTIONAL INPUTS:
    %
    %   color:          Preferred color, as written in function
    %                   'Create_colors_map'. (default: 'RED')
    %
    %   width:          Preferred width of lines. (default: 8)
    %
    % OUTPUT:
    %
    %   newmap          Matlab structure of new map with default look
    %
    % A.Danielsdottir 01/08/2017 
    % MOUSS Rouquaya and J.Modamio 21/08/2017 LCSB. Belval. Luxembourg
    % N.Sompairac - Institut Curie, Paris, 11/10/2017 (Code Checking)
    
    if nargin<5

        width = 8;

    end
    if nargin<4

       color = 'RED';

    end

    newmodel = model;
    newmap = map;
    %remove '.x' and '.xx' from Entrez ID in model list
    for i = 1:length(newmodel.genes)
        newmodel.genes{i} = regexprep((newmodel.genes{i}),'\.[\w]+',''); 
    end
    
    %find index of Entrez IDs provided in input list
    geneIndex = find(ismember(newmodel.genes,EntrezList));
    
    %Find the rxns that correspond to these genes
    summary = num2cell(geneIndex);
    globalList = [];
    
    for i = 1:length(geneIndex)
        gene = geneIndex(i);
        rxnIndex = find(model.rxnGeneMat(:,gene));
        rxnName = model.rxns(rxnIndex,1);
        summary(i,2)= {rxnName};
        globalList = [globalList;rxnName];
    end
    
    clear rxnName
    rxnName = unique(globalList);
    %find the same rxns on the map and change the color
    Colors = Create_colors_map;
    index = find(ismember(newmap.rxnName,rxnName));
    
    for j = index'

        newmap.rxnColor{j,1} = Colors(color);

        newmap.rxnWidth{j,1} = width;

    end
    %use the existence of reactant lines to check if the map has the
    %complete structure, and if so change also secondary lines.
    
    if any(strcmp('rxnReactantLineColor',fieldnames(map))) == 1
        
        for j = index'
            
            if ~isempty(newmap.rxnReactantLineColor{j})
                
                for k = 1:length(map.rxnReactantLineColor{j})
                    
                    newmap.rxnReactantLineColor{j,1}{k,1} = Colors(color);
                    newmap.rxnReactantLineWidth{j,1}{k,1} = width;
                    
                end
            end
            
            if ~isempty(newmap.rxnProductLineColor{j})
                
                for m = 1:1:length(newmap.rxnProductLineColor{j})
                    
                    newmap.rxnProductLineColor{j,1}{m,1} = Colors(color);
                    newmap.rxnProductLineWidth{j,1}{m,1} = width;
                    
                end
            end
        end
    end

end