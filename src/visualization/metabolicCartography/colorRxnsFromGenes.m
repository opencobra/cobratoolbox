function [newmap] = colorRxnsFromGenes(map, model, entrezList, color, areaWidth)
% Color and change the areaWidth of reactions based on the implicated gene
% given from a list of entezIDs.
%
% USAGE:
%
%   [newmap] = colorRxnsFromGenes(map, model, entrezList, color, areaWidth);
%
% INPUTS:
%   map:            map from CellDesigner parsed to MATLAB format
%   model:          COBRA model
%   entrezList:     List of genes, given as entrezIDs.
%
% OPTIONAL INPUTS:
%   color:          Preferred color, as written in function
%                   'createColorsMap'. (default: 'RED')
%   areaWidth:      Preferred areaWidth of lines. (default: 8)
%
% OUTPUT:
%   newmap          MATLAB structure of new map with default look
%
% .. Authors:
%       - A.Danielsdottir 01/08/2017
%       - MOUSS Rouquaya and J.Modamio 21/08/2017 LCSB. Belval. Luxembourg
%       - N.Sompairac - Institut Curie, Paris, 11/10/2017 (Code Checking)

    if nargin < 5
        areaWidth = 8;
    end
    if nargin < 4
        color = 'RED';
    end
    
    %rxnGeneMat is a required field for this function, so if it does not exist,
    %build it.
    if ~isfield(model,'rxnGeneMat')
        model = buildRxnGeneMat(model);
    end
    
    newmodel = model;
    newmap = map;

    % Remove '.x' and '.xx' from Entrez ID in model list
    for i = 1:length(newmodel.genes)
        newmodel.genes{i} = regexprep((newmodel.genes{i}), '\.[\w]+', '');
    end

    % Find index of Entrez IDs provided in input list
    geneIndex = find(ismember(newmodel.genes, entrezList));

    % Find the rxns that correspond to these genes
    summary = num2cell(geneIndex);
    globalList = [];

    for i = 1:length(geneIndex)
        gene = geneIndex(i);
        rxnIndex = find(model.rxnGeneMat(:, gene));
        rxnName = model.rxns(rxnIndex, 1);
        summary(i, 2) = {rxnName};
        globalList = [globalList; rxnName];
    end

    clear rxnName
    rxnName = unique(globalList);

    % Find the same rxns on the map and change the color
    colors = createColorsMap();
    index = find(ismember(newmap.rxnName, rxnName));

    for j = index'
        newmap.rxnColor{j, 1} = colors(color);
        newmap.rxnWidth{j, 1} = areaWidth;
    end

    % Use the existence of reactant lines to check if the map has the
    % complete structure, and if so change also secondary lines.
    if any(strcmp('rxnReactantLineColor', fieldnames(map))) == 1
        for j = index'
            if ~isempty(newmap.rxnReactantLineColor{j})
                for k = 1:length(map.rxnReactantLineColor{j})
                    newmap.rxnReactantLineColor{j, 1}{k, 1} = colors(color);
                    newmap.rxnReactantLineWidth{j, 1}{k, 1} = areaWidth;
                end
            end
            if ~isempty(newmap.rxnProductLineColor{j})
                for m = 1:1:length(newmap.rxnProductLineColor{j})
                    newmap.rxnProductLineColor{j, 1}{m, 1} = colors(color);
                    newmap.rxnProductLineWidth{j, 1}{m, 1} = areaWidth;
                end
            end
        end
    end

end
