function modelNew=formatGenes(model)% TO DO - need to be adapated depending on the gene format used for cobratoolboxv3
%Gets rid of the Entrez suffixes ".x" or preffixes "HGNC:" in the gene identifiers 
%used in the model and updates the GPR rules with the new gene format.
%
%INPUTS
%
%   model       model structure containing genes in the form "entrez#.x"
%               (e.g. case of recon1) or in the form "HGNC:entrez#" (e.g. case of recon2) 
%   
%OUTPUTS 
%
%   modelNew    model structure with formatted genes (all genes are just
%               "enrez#" (string))
%
% S. Opdam & A. Richelle May 2017
    
    genes={};
    format=0;
    
    % Modification of the format of the gene identifier in the model
    for i = 1:numel(model.genes)
        str = model.genes{i};
        % if Entrez contains suffixes ".x" (e.g. case of recon1)
        if  str(end-1)=='.'
            format=1;
            genes{i} = str(1:end-2);
        % if Entrez contains preffixes "HGNC:" (e.g. case of recon2)
        elseif strcmpi(str(1:5),'HGNC:')==1
            format=2;
            genes{i} = str(6:end);
        else
            genes{i} = str;
        end
    end
    genes = unique(genes);
    
    % Modification of the reaction gpr thank to the new gene identifier format
    model.rules=[];
    model.rxnGeneMat=[];
    model.genes=[];
    %turning off the warning related to the addition of a "new gene" in changeGeneAssociation.m
    warning off all
    if format~=0
        for m=1:numel(model.rxns)
            grRule = model.grRules{m,1};
            if format == 1
                grRule = regexprep(grRule,'[.]\d*','');
                model = changeGeneAssociation(model,model.rxns{m,1},grRule,genes,genes);
            elseif format == 2
                grRule = regexprep(grRule,'HGNC:','');
                model = changeGeneAssociation(model,model.rxns{m,1},grRule,genes,genes);
            end
        end
    end
    warning on all
    modelNew=model;
end