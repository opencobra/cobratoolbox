% perform gene deletion on organ compendium


if strcmp(gender,'female')
    load OrganAtlas_Harvetta_2017_10_28
else
    load OrganAtlas_Harvey_2017_10_28
end

O = fieldnames(OrganCompendium);
for i =1 :length(O)
    if ~strcmp('gender',O{i}) && (strcmp(O{i},'Recon3DHarvey'))==0
        model = OrganCompendium.(O{i}).modelAllComp;
        model.lb(find(model.lb<0))=-1000;
        model.ub(find(model.ub<0))=0;
        model.ub(find(model.ub>0))=1000;
        model.lb(find(model.lb>0))=0;
        if ~isempty(find(strcmp(model.rxns,'biomass_maintenance')))
            model = changeObjective(model,'biomass_maintenance');
        elseif  ~isempty(find(strcmp(model.rxns,'biomass_maintenance_noTrTr')))
            model = changeObjective(model,'biomass_maintenance_noTrTr');
        else
            model = changeObjective(model,'biomass_reactionIEC01b_trtr');
        end
        [grRatio,grRateKO,grRateWT,hasEffect,delRxns,fluxSolution] = singleGeneDeletion(model);
    OrganCompendium.(O{i}).singleDel.grRatio = grRatio;
    OrganCompendium.(O{i}).singleDel.grRateKO = grRateKO;
    OrganCompendium.(O{i}).singleDel.grRateWT = grRateWT;
    OrganCompendium.(O{i}).singleDel.hasEffect = hasEffect;
    end
    
end

% get all genes in Organs
genesAll = [];
for i =1 :length(O)
    if ~strcmp('gender',O{i})
        if (strcmp(O{i},'Recon3DHarvey'))==0
            genes = OrganCompendium.(O{i}).modelAllComp.genes;
            genesAll = [genesAll;genes];
        end
    end
end
genesAll  = strtok(genesAll,'.');
genesAll = unique(genesAll);
grRatioAll = nan(length(genesAll),length(O)-2);
for i =1 :length(O)
    if ~strcmp('gender',O{i})
        if (strcmp(O{i},'Recon3DHarvey'))==0
            genes = OrganCompendium.(O{i}).modelAllComp.genes;
            genes = strtok(genes,'.');
            genes = unique(genes);
            
            OrganCompendium.(O{i}).singleDel.grRatio(isnan(OrganCompendium.(O{i}).singleDel.grRatio))=0;
            for j = 1 : length(genes)
                grRatioAll(find(ismember(genesAll,genes{j})),i) = OrganCompendium.(O{i}).singleDel.grRatio(j);
                
            end
        end
    end
end

clear ans O delRxns flux* genes grRateKO grRateWT grRatio has* i j model

if strcmp(gender,'female')
    save OrganAtlas_Harvetta_2017_10_28_del
else
    save OrganAtlas_Harvey_2017_10_28_del
end
