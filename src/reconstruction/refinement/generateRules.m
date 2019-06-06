function [model] = generateRules(model, printLevel)
% If a model does not have a model.rules field but has a model.grRules
% field, can be regenerated using this script
%
% USAGE:
%
%    [model] = generateRules(model)
%
% INPUT:
%    model:        COBRA model with model.grRules
%    printLevel:   optional variable to print out all new genes 
%                  (default = TRUE), can be zero if not needed
%
% OUTPUT:
%    model:     same model but with model.rules added
%
% .. Author: - Aarash Bordar 11/17/2010
%            - Uri David Akavia 6-Aug-2017, bug fixes and speedup
%            - Diana El Assal 30/8/2017
%            - Laurent Heirendt December 2017, speedup

    if ~exist('printLevel', 'var')
        printLevel = 1;
    end
    if ~isfield(model, 'grRules')
        warning 'This function can be only be used on a model that has grRules field!\n';
        return;
    end
    [preParsedGrRules,genes] = preparseGPR(model.grRules);  % preparse all model.grRules
    allGenes =  unique([genes{~cellfun(@isempty,genes)}]); %Get the unique gene list
    if (~isfield(model, 'genes'))
        newGenes = allGenes;
    else
        newGenes = setdiff(allGenes,model.genes);
    end
    if ~isempty(newGenes)
        if printLevel
            warning('Found the following genes not present in the original model:\n%s\nAdding them to the model.',strjoin(newGenes,'\n'));
        end
        model = addGenes(model,newGenes);
    end
    
    % determine the number of rules
    nRules = length(model.grRules);

    % allocate the model.rules field
    model.rules = cell(nRules, 1);    
    % loop through all the grRules
    for i = 1:nRules
        if ~isempty(preParsedGrRules{i})
            genePos = zeros(numel(genes{i}));
            for j = 1:numel(genes{i})
                genePos(j) = find(strcmp(model.genes,genes{i}{j}));
            end            
            rule = parseGPR(preParsedGrRules{i}, genes{i}, true, genePos);    
            model.rules{i, 1} = rule;
        else
            model.rules{i, 1} = '';
        end
    end
end


